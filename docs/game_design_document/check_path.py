import glob

files = glob.glob(r"C:\Users\Owner\Documents\game_gdd\markdown_export\*.md")
print(f"Found {len(files)} files")
for f in files[:5]:  # Show a sample
    print(f)
