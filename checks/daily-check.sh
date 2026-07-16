#!/usr/bin/env bash
# daily-check.sh: sweep every Skill in the library and report what it could not
# check as loudly as what it could.
#
# The observability chapter's rule: green has to mean checked. A run that
# quietly drops a Skill and prints a cheerful summary has not saved you
# anything, it has lied to you, and you will trust the lie until it costs you.
# A partial result is fine; a partial result that presents as complete is a
# defect. So this counts what it processed and names what it skipped.
#
# Warn-and-continue, per the reliability chapter: one unreadable Skill must not
# abort the sweep and silently skip the gates that come after it.
#
# In the book's workspace this walks ~70 projects from a LaunchAgent at 9am.
# Here it walks the Skills in this library. Same discipline, smaller road.
set -uo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root" || exit 1

checked=0
skipped=0
skip_reasons=()

# --- Per-Skill sweep -------------------------------------------------------
# A Skill is checkable when it has the things the book says make a capability
# dependable: a manifest, a name that matches its slug, and a version.
for dir in skills/*/; do
  [[ -d "$dir" ]] || continue
  slug="$(basename "$dir")"

  if [[ ! -f "$dir/SKILL.md" ]]; then
    skipped=$((skipped + 1)); skip_reasons+=("$slug: no SKILL.md, not a Skill"); continue
  fi

  name="$(grep -m1 '^name:' "$dir/SKILL.md" 2>/dev/null | awk '{print $2}')"
  if [[ -z "$name" ]]; then
    skipped=$((skipped + 1)); skip_reasons+=("$slug: SKILL.md has no frontmatter name"); continue
  fi
  if [[ "$slug" != "$name" ]]; then
    skipped=$((skipped + 1)); skip_reasons+=("$slug: name drift, frontmatter says '$name'"); continue
  fi

  version="$(grep -m1 '^version:' "$dir/SKILL.md" 2>/dev/null | awk '{print $2}')"
  if [[ -z "$version" ]]; then
    skipped=$((skipped + 1)); skip_reasons+=("$slug: no version, a promise you cannot roll back"); continue
  fi

  checked=$((checked + 1))
done

# --- Library-level gates ---------------------------------------------------
# Each gate runs inside a guard so a failure is recorded, not fatal.
gate_failed=0
gate_failures=()

run_gate() {
  local name="$1"; shift
  if "$@" >/dev/null 2>&1; then
    return 0
  fi
  gate_failures+=("$name")
  gate_failed=$((gate_failed + 1))
}

run_gate "eval suite"              npm run eval
run_gate "check-naming"            bash checks/check-naming.sh
run_gate "public-prefix-leak-scan" bash checks/public-prefix-leak-scan.sh

# Secrets drift across the whole tree, using the same deterministic core the
# pre-commit gate and CI call. The detector, its fixtures, and its docs all
# contain the patterns by necessity, so findings are filtered through the
# managed allowlist and anything left over is a real leak. Expecting a magic
# count instead would break the day someone adds a fixture.
patterns="$(grep -Ev '^[[:space:]]*(#|$)' checks/secret-scan-allowlist.txt 2>/dev/null)"
# Tab-separated so the allowlist is matched against the PATH alone. Matching it
# against a rendered "path:line  kind" string would silently defeat every
# anchored pattern in the list.
raw="$(node skills/audit-secrets/scripts/scan.mjs --dir . 2>/dev/null \
  | node -e 'let s="";process.stdin.on("data",d=>s+=d).on("end",()=>{try{for(const f of JSON.parse(s).findings)console.log([f.file,f.line,f.redacted].join("\t"))}catch{console.log("SCANNER_ERROR")}})')"
if [[ "$raw" == "SCANNER_ERROR" ]]; then
  gate_failures+=("secrets-drift (scanner did not run)")
  gate_failed=$((gate_failed + 1))
else
  leaks=0
  while IFS=$'\t' read -r path lineno redacted; do
    [[ -n "$path" ]] || continue
    if [[ -n "$patterns" ]] && printf '%s\n' "$path" | grep -Eq "$patterns"; then
      continue
    fi
    gate_failures+=("secrets-drift $path:$lineno $redacted")
    leaks=$((leaks + 1))
  done <<< "$raw"
  if (( leaks > 0 )); then
    gate_failed=$((gate_failed + 1))
  fi
fi

# --- Honest summary --------------------------------------------------------
echo "daily-check: ${checked} green, ${skipped} skipped"
if (( skipped > 0 )); then
  printf '  SKIPPED %s\n' "${skip_reasons[@]}"
fi
if (( gate_failed > 0 )); then
  printf '  GATE FAILED %s\n' "${gate_failures[@]}"
  exit 1
fi
if (( checked == 0 )); then
  echo "  no Skills were checkable, which is a red result, not a green one"
  exit 1
fi
