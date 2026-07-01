"""Markdown format guard.

Check-only by default. With --fix, apply *whitespace-only* normalization outside
fenced code blocks:
  - Convert TABs to spaces (default 4)
  - Strip trailing whitespace
  - Ensure final newline

Also validates:
  - YAML frontmatter (if present) is properly terminated
  - Fenced code blocks are balanced

This script is intentionally dependency-free and safe to run offline.
"""

from __future__ import annotations

import argparse
import re
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, List, Optional, Tuple


_FENCE_RE = re.compile(r"^(?P<indent>[ \t]*)(?P<fence>(`{3,}|~{3,}))(?P<rest>.*)$")


@dataclass
class Issue:
    kind: str
    message: str
    line: Optional[int] = None


@dataclass
class FileResult:
    path: Path
    issues: List[Issue]
    fixed: bool = False
    changed: bool = False


def _iter_md_files(inputs: List[str]) -> List[Path]:
    out: List[Path] = []
    for raw in inputs:
        p = Path(raw)
        if p.is_dir():
            out.extend([pp for pp in p.rglob("*.md") if pp.is_file()])
        else:
            # Allow glob patterns via Path().glob only when the raw contains wildcard.
            if any(ch in raw for ch in ["*", "?", "["]):
                out.extend([pp for pp in Path().glob(raw) if pp.is_file() and pp.suffix.lower() == ".md"])
            else:
                out.append(p)

    # Normalize, dedupe, stable order.
    norm: List[Path] = []
    seen = set()
    for p in out:
        rp = p.resolve() if p.exists() else p
        key = str(rp)
        if key in seen:
            continue
        seen.add(key)
        norm.append(p)
    return sorted(norm, key=lambda x: str(x))


def _detect_preferred_newline(text: str) -> str:
    # Prefer the most common newline style in the existing file.
    crlf = text.count("\r\n")
    lf = text.count("\n") - crlf
    return "\r\n" if crlf > lf else "\n"


def _scan_frontmatter(lines: List[str]) -> Optional[Issue]:
    # Frontmatter is recognized only when the first line is exactly '---'.
    if not lines:
        return None
    first = lines[0].lstrip("\ufeff")
    if first.strip("\r\n") != "---":
        return None

    # Search for terminating '---' or '...' within a reasonable bound.
    for idx in range(1, min(len(lines), 400)):
        token = lines[idx].strip("\r\n")
        if token in ("---", "..."):
            return None
    return Issue(
        kind="frontmatter",
        message="YAML frontmatter starts with '---' but is missing a terminating '---' or '...'.",
        line=1,
    )


def _scan_fences(lines: List[str]) -> Optional[Issue]:
    in_fence = False
    fence_char: Optional[str] = None
    fence_len: int = 0
    opened_at: Optional[int] = None

    for idx, line in enumerate(lines, start=1):
        m = _FENCE_RE.match(line.rstrip("\r\n"))
        if not m:
            continue
        fence = m.group("fence")
        ch = fence[0]
        ln = len(fence)
        if not in_fence:
            in_fence = True
            fence_char = ch
            fence_len = ln
            opened_at = idx
            continue

        # Close only if same fence char and length >= opener length.
        if fence_char == ch and ln >= fence_len:
            in_fence = False
            fence_char = None
            fence_len = 0
            opened_at = None

    if in_fence:
        return Issue(
            kind="fence",
            message="Unterminated fenced code block (missing closing fence).",
            line=opened_at,
        )
    return None


def _scan_and_fix_whitespace(
    text: str,
    *,
    fix: bool,
    tab_width: int,
) -> Tuple[str, List[Issue], bool]:
    """Return (new_text, issues, changed)."""
    preferred_nl = _detect_preferred_newline(text)
    # splitlines(True) keeps line endings.
    lines = text.splitlines(keepends=True)

    issues: List[Issue] = []
    changed = False

    in_fence = False
    fence_char: Optional[str] = None
    fence_len: int = 0

    out_lines: List[str] = []
    for idx, line in enumerate(lines, start=1):
        raw_no_eol = line.rstrip("\r\n")
        eol = line[len(raw_no_eol) :]

        # Fence state transitions are based on the line content (no EOL).
        m = _FENCE_RE.match(raw_no_eol)
        if m:
            fence = m.group("fence")
            ch = fence[0]
            ln = len(fence)
            if not in_fence:
                in_fence = True
                fence_char = ch
                fence_len = ln
            elif fence_char == ch and ln >= fence_len:
                in_fence = False
                fence_char = None
                fence_len = 0

        new_no_eol = raw_no_eol

        if not in_fence:
            # Tabs are only disallowed outside fenced code blocks.
            if "\t" in new_no_eol:
                issues.append(Issue("tabs", "TAB character outside fenced code block.", idx))
                if fix:
                    new_no_eol = new_no_eol.replace("\t", " " * tab_width)
                    changed = True

            # Trailing whitespace outside fenced code blocks.
            if re.search(r"[ \t]+$", new_no_eol):
                issues.append(Issue("trailing_whitespace", "Trailing whitespace.", idx))
                if fix:
                    new_no_eol = re.sub(r"[ \t]+$", "", new_no_eol)
                    changed = True

        out_lines.append(new_no_eol + eol)

    new_text = "".join(out_lines)

    # Final newline (always enforced; safe).
    if new_text and not (new_text.endswith("\n") or new_text.endswith("\r\n")):
        issues.append(Issue("final_newline", "Missing final newline.", None))
        if fix:
            new_text = new_text + preferred_nl
            changed = True

    return new_text, issues, changed


def _process_file(path: Path, *, fix: bool, tab_width: int) -> FileResult:
    res = FileResult(path=path, issues=[])

    if path.suffix.lower() != ".md":
        res.issues.append(Issue("input", "Not a markdown file (.md)."))
        return res
    if not path.exists():
        res.issues.append(Issue("input", "File does not exist."))
        return res

    raw = path.read_bytes()
    # UTF-8 is the project default; accept BOM.
    text = raw.decode("utf-8-sig", errors="replace")

    lines = text.splitlines(keepends=True)

    fm_issue = _scan_frontmatter(lines)
    if fm_issue:
        res.issues.append(fm_issue)
    fence_issue = _scan_fences(lines)
    if fence_issue:
        res.issues.append(fence_issue)

    new_text, ws_issues, changed = _scan_and_fix_whitespace(text, fix=fix, tab_width=tab_width)
    res.issues.extend(ws_issues)
    res.changed = changed

    if fix and changed:
        path.write_text(new_text, encoding="utf-8", newline="")
        res.fixed = True

    return res


def _print_results(results: List[FileResult]) -> int:
    any_issues = False
    for r in results:
        if not r.issues:
            status = "OK"
        else:
            status = "FAIL"
            any_issues = True

        fixed = " (fixed)" if r.fixed else ""
        print(f"[{status}]{fixed} {r.path}")
        for issue in r.issues:
            loc = f":{issue.line}" if issue.line else ""
            print(f"  - {issue.kind}{loc}: {issue.message}")

    return 1 if any_issues else 0


def main(argv: Optional[List[str]] = None) -> int:
    parser = argparse.ArgumentParser(description="Markdown format guard (check/fix).")
    mode = parser.add_mutually_exclusive_group(required=False)
    mode.add_argument("--check", action="store_true", help="Check only (default).")
    mode.add_argument("--fix", action="store_true", help="Fix whitespace-only issues.")
    parser.add_argument("--tab-width", type=int, default=4, help="Spaces per tab when fixing.")
    parser.add_argument("paths", nargs="+", help="Markdown files/dirs/globs to check.")
    ns = parser.parse_args(argv)

    fix = bool(ns.fix)
    # Default is check.
    if not ns.check and not ns.fix:
        fix = False

    paths = _iter_md_files(ns.paths)
    if not paths:
        print("No markdown files found.")
        return 0

    results = [_process_file(p, fix=fix, tab_width=ns.tab_width) for p in paths]
    rc = _print_results(results)

    if rc != 0 and not fix:
        print("\nHint: re-run with --fix to apply whitespace-only fixes (tabs/trailing whitespace/final newline) outside fenced code blocks.")
    return rc


if __name__ == "__main__":
    raise SystemExit(main())
