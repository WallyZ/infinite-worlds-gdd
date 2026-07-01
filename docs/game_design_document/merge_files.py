import glob
import re
import os

# 📁 Define your input and output paths here
INPUT_DIR = r"C:/Users/Owner/Documents/game_gdd/markdown_export"
OUTPUT_FILE = r"C:/Users/Owner/Documents/game_gdd/merged_gdd.txt"

print(f"📂 Searching in: {INPUT_DIR}")
print(f"📄 Output will be saved to: {OUTPUT_FILE}")

def extract_sort_key(filename):
    """
    Extracts a tuple of integers from the filename's prefix like '1 2 3 Title.md'
    """
    name = os.path.basename(filename)
    match = re.match(r"^(\d+(?: \d+)*)", name)
    if match:
        parts = match.group(1).split()
        return tuple(int(p) for p in parts)
    else:
        return (9999, name.lower())  # Sort unnumbered files last

def load_and_clean_md(path):
    with open(path, encoding="utf-8") as f:
        content = f.read()
    # Remove YAML front matter
    content = re.sub(r"^---[\s\S]*?---\s*", "", content)
    return content.strip()

# 🗂️ Find and sort all markdown files
md_files = glob.glob(os.path.join(INPUT_DIR, "*.md"))
md_files_sorted = sorted(md_files, key=extract_sort_key)

print(f"📦 Found {len(md_files_sorted)} markdown files.")
for f in md_files_sorted[:5]:
    print("→", os.path.basename(f))

# 📜 Merge content
merged_text = ""
for md_file in md_files_sorted:
    section_text = load_and_clean_md(md_file)
    if not section_text:
        print(f"⚠️ Skipping empty file: {md_file}")
        continue
    section_name = os.path.basename(md_file)
    merged_text += f"\n\n## SECTION: {section_name}\n\n{section_text}"
    print(f"Loaded {section_name} with {len(section_text)} characters.")

# 💾 Save merged output
with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
    f.write(merged_text)

print(f"✅ Merged GDD saved to: {OUTPUT_FILE}")
