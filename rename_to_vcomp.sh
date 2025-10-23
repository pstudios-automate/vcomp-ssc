#!/usr/bin/env bash
set -e

say()  { printf "\033[1;32m[✔]\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m[!]\033[0m %s\n" "$*"; }
die()  { printf "\033[1;31m[✖]\033[0m %s\n" "$*" >&2; exit 1; }

#───────────────────────────────────────────────────────────────
# 1. Preflight
#───────────────────────────────────────────────────────────────
[ -d .git ] || die "Not a git repository — run inside repo root."
current=$(basename "$(pwd)")
say "Current repository: $current"

#───────────────────────────────────────────────────────────────
# 2. Rename project directory if still vcomp
#───────────────────────────────────────────────────────────────
if [ "$current" = "vcomp" ]; then
    cd ..
    mv vcomp vcomp-ssc
    cd vcomp-ssc
    say "Renamed folder → vcomp-ssc"
fi

#───────────────────────────────────────────────────────────────
# 3. Replace all internal strings 'vcomp' → 'vcomp'
#───────────────────────────────────────────────────────────────
say "Replacing text references..."
grep -rl "vcomp" . | while read -r file; do
    sed -i 's/\bvizos\b/vcomp/g' "$file"
done

#───────────────────────────────────────────────────────────────
# 4. Rename scripts & binaries
#───────────────────────────────────────────────────────────────
say "Renaming scripts..."
for old in vizos_*.sh; do
    [ -e "$old" ] || continue
    new="${old/vizos_/vcomp_}"
    mv "$old" "$new"
    say "→ $old  →  $new"
done

#───────────────────────────────────────────────────────────────
# 5. Clean cache & rebuild
#───────────────────────────────────────────────────────────────
say "Cleaning old builds..."
rm -rf build CMakeCache.txt CMakeFiles
./build_all.sh || warn "Build may need manual check."

#───────────────────────────────────────────────────────────────
# 6. Git commit and push
#───────────────────────────────────────────────────────────────
git add -A
git commit -m "rebrand: rename VizOS → V-Comp SSC (world’s first Vulkan OS compositor)"
git push origin master
say "✅ Rebrand committed and pushed!"

#───────────────────────────────────────────────────────────────
# 7. Final message
#───────────────────────────────────────────────────────────────
say "Repository is now officially 'V-Comp SSC'."
say "You can update remote URL in GitHub repo settings if needed."
