#!/usr/bin/env bash
# check-naming.sh: every Skill's directory name must equal its frontmatter name.
# This is the workspace's product-level slug discipline applied to the Skill
# library, so a name never means two things and two names never mean one.
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

drift=0
count=0
for dir in "$root"/skills/*/; do
  [[ -d "$dir" ]] || continue
  count=$((count + 1))
  slug="$(basename "$dir")"
  name="$(grep -m1 '^name:' "$dir/SKILL.md" 2>/dev/null | awk '{print $2}')"
  if [[ "$slug" != "$name" ]]; then
    echo "DRIFT: directory '$slug' != frontmatter name '$name' in $dir"
    drift=$((drift + 1))
  fi
done

if (( drift > 0 )); then
  echo "check-naming: FAIL, $drift drift(s) found"
  exit 1
fi
echo "check-naming: ok ($count skills, every directory name matches its frontmatter name)"
