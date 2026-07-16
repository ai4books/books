#!/usr/bin/env bash
# public-prefix-leak-scan.sh: flag any NEXT_PUBLIC_/VITE_/EXPO_PUBLIC_ variable
# whose VALUE looks like a private secret. This is the failure class behind the
# real "$350 photo bill" in the book: a private key shipped to the browser
# because it sat behind a public build-time prefix.
set -uo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

hits="$(grep -rEn \
  '(NEXT_PUBLIC_|VITE_|EXPO_PUBLIC_)[A-Z0-9_]*[=:][[:space:]]*["'\'']?(sk_(live|test)_|rk_live_|AKIA[0-9A-Z]|ghp_|-----BEGIN)' \
  --include='*.env*' --include='*.ts' --include='*.tsx' --include='*.js' --include='*.jsx' \
  "$root" 2>/dev/null || true)"

if [[ -n "$hits" ]]; then
  echo "LEAK: a public-prefixed env var holds a secret-shaped value"
  echo "$hits"
  exit 1
fi
echo "public-prefix-leak-scan: ok (no public-prefixed secrets)"
