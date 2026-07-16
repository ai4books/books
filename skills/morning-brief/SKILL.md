---
name: morning-brief
description: Produce one daily report of drift across every project in a workspace, repo and secrets and uncommitted-or-unpushed work, plus the correlated governance checks, so decay is found by a scheduled report instead of by a customer.
version: 1.0.0
changelog: CHANGELOG.md
---

# morning-brief

A single capability that, once a day, tells you what drifted while you were not
looking. It is the "immune system" pattern from the book: a check that runs on a
schedule (a cron job or a launch agent) whether or not anyone remembers to run
it, so the silent failure mode (rot) is surfaced within a day instead of weeks.

## Contract

- **Input:** the workspace root (defaults to the parent of this library).
- **Output:** a human-readable brief plus a non-zero exit code if anything needs
  attention, so a scheduler can alert on it.
- **Guarantee:** green means checked. A project that could not be checked is
  named as skipped, never silently dropped. A partial result that presents as
  complete is a defect.

## Procedure

1. For each project, detect repo drift, uncommitted work, and unpushed commits.
2. Run the correlated governance checks shipped in `checks/`:
   `audit-secrets` (leaked secrets), `public-prefix-leak-scan.sh` (a public-prefixed
   variable holding a private value), and `check-naming.sh` (slug drift).
3. Emit the brief. Report `N green, M skipped` with a reason for each skip.

## Why this is a Skill, not a habit

A habit lives in a person and fails the day that person is busy. A Skill lives in
the library, is named and versioned, runs on a schedule, and is inherited by
every new project on day zero. That is the whole compounding argument of the
book, applied to operations.
