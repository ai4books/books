# Skill Library Starter

A minimal, **runnable** company-wide Skill library. This is the companion
reference implementation for the book *Implementing Enterprise AI: Building a
Company-Wide Skill Library and Running AI Agents at Scale*.

The book argues that the durable unit of AI work is not a clever prompt. It is a
named, versioned, tested, governed capability that an entire organization can
pull off a shelf. This repo is that idea in the smallest form that still runs:
one real Skill with a deterministic core and a golden-case eval suite, a second
Skill as a contract, governance-as-code checks, and CI for both GitHub and
GitLab. Clone it, run `npm run ci`, and watch a non-deterministic capability get
tested like normal software.

## Quickstart

```bash
git clone https://github.com/ai4books/books.git
cd books
./bootstrap.sh            # one command, idempotent: running it twice is safe
```

That gives you a governed Skill, an eval suite, a daily check, a pre-commit
secret gate, and a CI eval gate:

```
bootstrap: setting up the Skill library in /path/to/books
  node v22.23.1 ok (matches .node-version)
  npm ci ok
  pre-commit secret gate installed (.git/hooks/pre-commit)
  eval suite (score 4/4) ok
  check-naming ok
  public-prefix-leak-scan ok
  daily-check ok

bootstrap: 7 ok, 0 failed
```

The individual gates, once you are set up:

```bash
# Node 22 LTS (the book's "node 26 broke 39 projects" lesson: pin your toolchain)
node --version            # expect v22.x
npm run eval              # the audit-secrets golden-case suite -> score: 4/4
npm run ci                # eval + naming check + public-prefix leak scan
bash checks/daily-check.sh # sweep every Skill; reports what it could not check
```

Expected output:

```
PASS  catches all three planted secrets
PASS  names the leaked env-style file
PASS  no false positives on the clean fixture
PASS  never echoes a raw secret value

score: 4/4
check-naming: ok (2 skills, every directory name matches its frontmatter name)
public-prefix-leak-scan: ok (no public-prefixed secrets)
daily-check: 2 green, 0 skipped
```

### If bootstrap says the secret gate is inactive

Git ignores `.git/hooks` when `core.hooksPath` is set, which is common if your
company manages hooks centrally or you use husky. The bootstrap detects this and
tells you rather than reporting a gate that would never fire. Either point this
repo at its own hooks:

```bash
git config --local --unset core.hooksPath
```

or call `checks/pre-commit-secret-gate.sh` from your managed pre-commit hook.

## What is here

```
skill-library-starter/
  bootstrap.sh              one idempotent command from fresh clone to working
  skills/
    audit-secrets/            the worked example: a tested capability
      SKILL.md                name, description trigger, contract, procedure
      CHANGELOG.md            a version number is a promise
      reference/              the patterns the script cites (packaged, not in your head)
      scripts/scan.mjs        the deterministic core (no model needed to test it)
      tests/fixtures/         planted (3 fake secrets) + clean (false-positive bait)
    morning-brief/            a second Skill, shipped as a contract
  eval/
    run.mjs                   the harness: property checks, a score, a non-zero exit
    cases/audit-secrets.json  golden cases as data
  checks/
    check-naming.sh           slug discipline: dir name must equal frontmatter name
    public-prefix-leak-scan.sh the "$350 photo bill" failure class, as a gate
    daily-check.sh            the sweep: green means checked, skips get named
    pre-commit-secret-gate.sh blocks a commit that stages a secret
    secret-scan-allowlist.txt where secret-shaped strings are allowed to live
  docs/
    NAMING.md                 one canonical slug, everywhere
    SKILL_TEMPLATE.md         copy this to start a new Skill
  .github/workflows/ci.yml    GitHub CI: eval + governance gates
  .gitlab-ci.yml              the same gates in GitLab syntax
  CONTRIBUTING.md             the use-is-open, publish-is-reviewed boundary
```

## How it maps to the book

| Book idea | Where it lives here |
|---|---|
| The SKILL.md pattern (name, description, contract) | `skills/*/SKILL.md` |
| A version number is a promise | `skills/*/CHANGELOG.md`, frontmatter `version:` |
| Package the context, do not leak it | `skills/audit-secrets/reference/` |
| Testing a non-deterministic capability | `eval/run.mjs`, `tests/fixtures/` |
| Deterministic guardrails around a model core | `scripts/scan.mjs` + the redaction guarantee |
| Governance as code | `checks/check-naming.sh`, `checks/public-prefix-leak-scan.sh`, `checks/pre-commit-secret-gate.sh` |
| CI/CD gates the library | `.github/workflows/ci.yml`, `.gitlab-ci.yml` |
| Pin the toolchain | `.node-version`, `engines` in `package.json` |
| Publish vs use | `CONTRIBUTING.md` |
| The cold start: one idempotent command | `bootstrap.sh` |
| Warn-and-continue, honest partial results | `bootstrap.sh`, `checks/daily-check.sh` |
| Green has to mean checked | `checks/daily-check.sh` counts and names its skips |

## The one rule worth copying first

A finding never contains the secret it found. `scan.mjs` redacts every hit, and
one of the four eval cases exists only to prove it. A tool that leaks the secret
while reporting the leak is worse than useless. That is the shape of the whole
book: let the model do judgment, and let plain code enforce the contract.

## Scope

This is a **starter**, deliberately small. The scanner is prefix-based so it is
easy to read and test; production adds entropy scoring and a far richer
allowlist than the one in `checks/secret-scan-allowlist.txt`. The point is not
exhaustive coverage. It is the testable, governed, versioned *shape* that lets a
capability become something an entire company can depend on.

Two limits worth knowing before you trust it, because a gate you misjudge is
worse than one you know the edges of:

- **The allowlist is a real hole.** Anything under `skills/audit-secrets/tests/fixtures/`
  is exempt, so a genuine secret parked there commits clean. That is the price of
  a detector whose own tests must contain the patterns it hunts. Keep the list
  short, review changes to it, and never widen it to silence a finding.
- **The pre-commit gate is a convenience, not a control.** Any commit can bypass
  it with `--no-verify`, and it never runs on a contributor's machine that has not
  run `./bootstrap.sh`. CI is the control, because it is the one gate nobody can
  skip. The hook exists to catch the mistake early, not to be the last line.

## License

MIT. See `LICENSE`.
