#!/usr/bin/env bash
set -e

say()  { printf "\033[1;32m[✔]\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m[!]\033[0m %s\n" "$*"; }
die()  { printf "\033[1;31m[✖]\033[0m %s\n" "$*" >&2; exit 1; }

say "🔍 Scanning docs/ for images..."
[ -d docs ] || die "docs/ folder not found."

# Build the new manifest
manifest_file="docs/MANIFEST.md"
echo "# 🖼️ Visual Manifest — V-Comp SSC" > "$manifest_file"
echo "" >> "$manifest_file"

count=0
for img in docs/*.{png,jpg,jpeg,ppm,gif,svg}; do
  [ -f "$img" ] || continue
  ((count++))
  name=$(basename "$img")
  echo "### Figure $count — ${name%.*}" >> "$manifest_file"
  echo "![${name%.*}]($img)" >> "$manifest_file"
  echo "" >> "$manifest_file"
done

if [ "$count" -eq 0 ]; then
  warn "No image files found in docs/. Nothing to update."
  exit 0
fi

say "🧾 $count images indexed into docs/MANIFEST.md"

# Inject / update section in README.md
say "📘 Updating README.md with gallery section..."
awk '
/^## 📊 Benchmarks/ {print; print "\n## 🖼️ Visual Manifest\n\n"; system("cat docs/MANIFEST.md"); next}
{print}
' README.md > README.tmp && mv README.tmp README.md

# Stage and commit changes
say "💾 Committing and pushing updates..."
git add README.md docs/MANIFEST.md
git commit -m "docs: auto-update visual manifest for V-Comp SSC"
git push

say "✅ Visual manifest successfully committed and pushed!"
