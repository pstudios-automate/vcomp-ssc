#!/usr/bin/env bash
set -e
say(){ printf "\033[1;32m[✔]\033[0m %s\n" "$*"; }

for f in docs/*; do
  base=$(basename "$f")
  if ! grep -q "$base" README.md; then
    sed -i "s#docs/.*${base##*_}#docs/$base#g" README.md || true
  fi
done

git add README.md docs/
git commit -m "fix: update image references and ensure docs committed"
git push
say "Images and README references synced!"
