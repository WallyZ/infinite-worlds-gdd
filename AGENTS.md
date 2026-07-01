# AGENTS.md

## Mission

Preserve the Infinite Worlds GDD source package with minimal churn.

This repo is source material, not the implementation backlog. Keep raw exports intact unless the user explicitly asks for a migration or cleanup.

## Operating Model

At the start of every task:

1. Read this file.
2. If present, read `.codex-cache/task-pack.md`.
3. Identify the smallest relevant file set.
4. State the intended verification command before editing.
5. Keep scope narrow.

## Boundaries

- Do not normalize, rename, delete, or rewrite raw export files without explicit instruction.
- Do not move implementation TODOs or Unreal project files into this repo.
- Use `F:\dev\infinite-worlds` for canonical implementation docs and backlog work.
- Keep this repo private unless the owner explicitly changes that policy.

## Codex Navigation

Use the smallest search surface that answers the task:

1. Start with `docs/CODEX_GDD_NAVIGATION.md`.
2. Use `docs/index/GDD_SOURCE_INDEX.md` to identify the specific source files.
3. Search `merged_gdd.txt` only for broad keyword discovery.
4. Open source files in `docs/game_design_document/` only after narrowing the topic.
5. Use `docs/GDD_STANDARDS.md` before renaming, renumbering, merging, or splitting GDD material.

## Verification Contract

Use exactly:

```powershell
.\scripts\codex-verify.ps1
```

The verifier must write logs under `.codex-cache\logs\` and use `.codex-cache\tmp\<run-id>\` for temp files.

## Output Style

Report:

- files changed
- why they changed
- verification run
- any follow-up risk or limitation
