# Contributing

This library separates two rights that a single-author script never had to:
using a Skill and publishing one.

## Use is open

Install the library, the Skills are there, no gate. Running a Skill costs you
nothing and asks no one.

## Publishing is reviewed

Publishing a new version (anything a downstream consumer will pull) goes through
a pull request that contains, together:

1. the change to the Skill,
2. a version bump in the frontmatter (PATCH / MINOR / MAJOR per `docs/NAMING.md`),
3. a `CHANGELOG.md` entry explaining what and why,
4. a green CI run: `npm run eval` plus the governance checks.

A maintainer of the affected Skill approves the merge. Publishing a MAJOR version
that downstream agents depend on is a consequential action: it does not need two
human confirmations like a destructive infra change, but it does need a review
and a passing test run. "I changed the shared prompt and pushed it" is exactly
the ungoverned move this library exists to prevent.

## Adding a Skill

1. Copy `docs/SKILL_TEMPLATE.md` into `skills/<slug>/SKILL.md`.
2. Keep the slug canonical (see `docs/NAMING.md`); `check-naming.sh` will verify it.
3. Put the deterministic core in `scripts/` and a golden-case suite in `tests/`.
4. Wire the suite into `eval/` so CI runs it on every change.
