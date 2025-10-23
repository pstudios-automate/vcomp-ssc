#!/usr/bin/env bash
set -e
say()  { printf "\033[1;32m[✔]\033[0m %s\n" "$*"; }
die()  { printf "\033[1;31m[✖]\033[0m %s\n" "$*" >&2; exit 1; }

[ -d docs ] || die "docs/ folder not found."

say "🔧 Renaming old vizos_*.png / .ppm files → vcomp_*.png / .ppm..."
for f in docs/vizos_*; do
  [ -e "$f" ] || continue
  new="docs/$(basename "$f" | sed 's/^vizos_/vcomp_/')"
  mv "$f" "$new"
  say "→ $new"
done

say "🧾 Updating README references..."
sed -i 's#docs/vizos_#docs/vcomp_#g' README.md

say "💾 Adding and committing changes..."
git add docs/*.png docs/*.ppm README.md
git commit -m "docs: rename vizos_* images to vcomp_* and fix README paths"

say "🚀 Pushing to GitHub..."
git push

say "✅ All images renamed, committed, and pushed. Refresh GitHub to view inline previews."
