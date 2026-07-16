#!/usr/bin/env bash
# bootstrap.sh: take a fresh clone to a working Skill library in one command.
#
# The cold-start bar from the platform chapter: one command, idempotent, so
# running it twice is safe and the diff between run one and run two is your
# reusability score. The reliability chapter's warn-and-continue applies here
# too. A step that fails records the failure and lets the run proceed, so you
# get a partial result with an honest summary instead of a clean exit that hid
# six of seven steps.
#
# Deliberately NOT `set -e`: aborting on the first error is the bug this
# pattern exists to prevent.
set -uo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$root" || exit 1

ok=0
failed=0
failures=()

log()  { printf '  %s\n' "$1"; }
warn() { printf '  WARN %s\n' "$1"; }

run_step() {
  local name="$1"; shift
  if "$@" >/dev/null 2>&1; then
    log "$name ok"
    ok=$((ok + 1))
  else
    warn "$name failed (continuing)"
    failures+=("$name")
    failed=$((failed + 1))
  fi
}

echo "bootstrap: setting up the Skill library in $root"

# 1. Pin the toolchain. The book's "node 26 broke 39 projects" lesson: a
#    capability that only runs on its author's Node is not packaged.
want="$(cat .node-version 2>/dev/null || echo 22)"
have="$(node --version 2>/dev/null || echo none)"
if [[ "$have" == v"$want".* ]]; then
  log "node $have ok (matches .node-version)"
  ok=$((ok + 1))
else
  warn "node is $have, this library pins v$want.x (continuing; see .node-version)"
  failures+=("node version")
  failed=$((failed + 1))
fi

# 2. Dependency state from the lockfile. There are no runtime dependencies;
#    this establishes reproducible lockfile state. Idempotent by design.
run_step "npm ci" npm ci

# 3. Install the pre-commit secret gate.
#
#    Idempotent: re-running replaces our own managed hook and never clobbers an
#    unrelated one you wrote.
#
#    The subtle part is core.hooksPath. If it is set (husky, the pre-commit
#    framework, or a company-managed hooks directory), git ignores .git/hooks
#    entirely. Writing the file there and reporting success would be a green
#    that does not mean checked: the gate would look installed and never fire.
#    So we install it, then check whether it can actually run, and say so.
install_hook() {
  local dir="$1"
  local hook="$dir/pre-commit"
  local marker="# managed-by: skill-library-starter"
  if [[ -f "$hook" ]] && ! grep -q "$marker" "$hook" 2>/dev/null; then
    return 2 # a hook we did not write; do not touch it
  fi
  mkdir -p "$dir" || return 1
  cat > "$hook" <<'HOOK'
#!/usr/bin/env bash
# managed-by: skill-library-starter
# Installed by bootstrap.sh. Blocks a commit that stages a secret.
exec "$(git rev-parse --show-toplevel)/checks/pre-commit-secret-gate.sh"
HOOK
  chmod +x "$hook"
}

if git rev-parse --git-dir >/dev/null 2>&1; then
  repo_root="$(git rev-parse --show-toplevel 2>/dev/null)"
  hooks_cfg="$(git config core.hooksPath 2>/dev/null || true)"

  if [[ -z "$hooks_cfg" ]]; then
    target="$repo_root/.git/hooks"; managed_elsewhere=0
  else
    case "$hooks_cfg" in
      /*) target="$hooks_cfg" ;;
      *)  target="$repo_root/$hooks_cfg" ;;
    esac
    # A hooks dir inside this repo is ours to write. One outside it belongs to
    # you or your company, and quietly editing it would be a worse bug than the
    # one this gate prevents.
    if [[ "$target" == "$repo_root"/* ]]; then managed_elsewhere=0; else managed_elsewhere=1; fi
  fi

  if (( managed_elsewhere == 1 )); then
    install_hook "$repo_root/.git/hooks" || true
    warn "core.hooksPath is '$hooks_cfg', so .git/hooks never runs"
    warn "  the secret gate is INSTALLED BUT INACTIVE. To arm it, either:"
    warn "    git config --local --unset core.hooksPath"
    warn "    (or call checks/pre-commit-secret-gate.sh from your managed hook)"
    failures+=("pre-commit gate (inactive: core.hooksPath -> $hooks_cfg)")
    failed=$((failed + 1))
  else
    install_hook "$target"
    case $? in
      0) log "pre-commit secret gate installed ($target/pre-commit)"
         ok=$((ok + 1)) ;;
      2) warn "a pre-commit hook exists at $target and is not ours, leaving it alone"
         warn "  to gate secrets, call checks/pre-commit-secret-gate.sh from it"
         failures+=("pre-commit gate (foreign hook present)")
         failed=$((failed + 1)) ;;
      *) warn "could not write the pre-commit hook to $target"
         failures+=("pre-commit gate (write failed)")
         failed=$((failed + 1)) ;;
    esac
  fi
else
  warn "not a git repo, skipping pre-commit gate (clone the repo to get it)"
  failures+=("pre-commit gate (not a git repo)")
  failed=$((failed + 1))
fi

# 4. Prove the capability actually works, rather than asserting it does.
run_step "eval suite (score 4/4)" npm run eval
run_step "check-naming" npm run check:naming
run_step "public-prefix-leak-scan" npm run check:leak
run_step "daily-check" bash checks/daily-check.sh

echo
echo "bootstrap: ${ok} ok, ${failed} failed"
if (( failed > 0 )); then
  printf '  FAILED %s\n' "${failures[@]}"
  echo "bootstrap: partial. The steps above ran; the listed ones did not."
  exit 1
fi

cat <<'DONE'
bootstrap: complete. You now have:
  - a governed Skill        skills/audit-secrets/ (SKILL.md, contract, changelog)
  - an eval suite           npm run eval          -> score: 4/4
  - a daily check           bash checks/daily-check.sh
  - a pre-commit gate       .git/hooks/pre-commit -> blocks staged secrets
  - a CI eval gate          .github/workflows/ci.yml and .gitlab-ci.yml

Next: `npm run ci`, then copy docs/SKILL_TEMPLATE.md to start your own Skill.
DONE
