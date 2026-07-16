#!/usr/bin/env bash
# pre-commit-secret-gate.sh: refuse a commit that stages a secret.
#
# Governance as code: the rule "never commit a secret" is worth nothing as a
# wiki page and everything as a gate that runs whether or not anyone remembers
# it. Installed into .git/hooks/pre-commit by bootstrap.sh.
#
# Two deliberate design choices:
#
# 1. It scans STAGED CONTENT (`git show :file`), not the working tree. Those
#    differ, and the staged bytes are what the commit would actually contain.
# 2. It reuses skills/audit-secrets/scripts/scan.mjs as its detector rather
#    than growing a second copy of the patterns. One capability, one core,
#    called from CI, from the daily check, and from here.
#
# Bypass with `git commit --no-verify` only when you know why.
set -uo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# The detector, its fixtures, and its pattern docs all contain secret-shaped
# strings by necessity; without an allowlist this repo could never commit
# itself. The list is managed as data in one file, shared with daily-check.sh,
# so the two gates can never drift apart on what counts as expected noise.
allowlist_file="$root/checks/secret-scan-allowlist.txt"
patterns="$(grep -Ev '^[[:space:]]*(#|$)' "$allowlist_file" 2>/dev/null)"

staged="$(git diff --cached --name-only --diff-filter=ACM 2>/dev/null)"
if [[ -z "$staged" ]]; then
  echo "pre-commit-secret-gate: ok (nothing staged)"
  exit 0
fi

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

scanned=0
skipped=0
skip_reasons=()

while IFS= read -r file; do
  [[ -n "$file" ]] || continue
  if [[ -n "$patterns" ]] && printf '%s\n' "$file" | grep -Eq "$patterns"; then
    skipped=$((skipped + 1))
    skip_reasons+=("$file: allowlisted (see checks/secret-scan-allowlist.txt)")
    continue
  fi
  dest="$tmp/$file"
  mkdir -p "$(dirname "$dest")" 2>/dev/null || true
  # Materialize the staged blob, not the working-tree file.
  if git show ":$file" > "$dest" 2>/dev/null; then
    scanned=$((scanned + 1))
  else
    skipped=$((skipped + 1))
    skip_reasons+=("$file: could not read staged blob")
  fi
done <<< "$staged"

# The scanner's redaction guarantee means this output can never print the
# secret it is complaining about.
report="$(node "$root/skills/audit-secrets/scripts/scan.mjs" --dir "$tmp" 2>/dev/null)"
if [[ -z "$report" ]]; then
  echo "pre-commit-secret-gate: FAIL, scanner did not run (is node installed?)"
  exit 1
fi

found="$(printf '%s' "$report" | node -e '
let s = "";
process.stdin.on("data", d => (s += d)).on("end", () => {
  const r = JSON.parse(s);
  for (const f of r.findings) console.log(`  ${f.file}:${f.line}  ${f.redacted}`);
  process.exit(r.findings.length > 0 ? 1 : 0);
});
')"
status=$?

if (( skipped > 0 )); then
  printf '  SKIPPED %s\n' "${skip_reasons[@]}"
fi

if (( status != 0 )); then
  echo "pre-commit-secret-gate: BLOCKED, staged changes carry a secret"
  echo "$found"
  echo
  echo "Move the value to your secrets vault and reference it by name."
  echo "If this is a deliberate fixture, put it under tests/fixtures/."
  exit 1
fi

echo "pre-commit-secret-gate: ok ($scanned staged file(s) scanned, $skipped skipped)"
