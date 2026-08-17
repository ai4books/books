# ai4books-books — ideas log (Memory faculty)

Append-only. The weekly Reflection run appends dated proposals here; it PROPOSES, never executes.
Newest at the bottom. Prune or promote durable items by hand.

_(no reflections yet — the first weekly run, or a manual `node scripts/brain-reflect.mjs`, seeds this)_

### 2026-08-10 — reflection
# Reflection: ai4books-books — Next Actions

## Status
- **Brain scaffolding**: ✅ Installed (five faculties, propose-not-execute pattern live)
- **Core product**: ✅ Runnable (Skill library starter ships with eval suite, governance gates, CI)
- **Lessons log**: Empty (no prior feedback cycles yet)

## Proposed Next Actions

- **Seed the Lessons log with the bootstrap's first run outcome.** Run `./bootstrap.sh` locally, capture the `7 ok, 0 failed` result and any friction encountered (or lack thereof), and commit a dated entry to `docs/LESSONS.md` so future reflections have signal about what the minimal setup actually buys. *(Why: The book's thesis is "durable governance"—we need lived proof that this starter does what it claims.)*

- **Hardcode a weekly Reflection trigger in CI.** Add a scheduled GitHub Actions job (or GitLab CI schedule) that runs `node scripts/brain-reflect.mjs` every Friday and opens a PR with the next-actions delta. *(Why: Without automation, the brain stays in local memory; the five faculties only work if proposals feed back into the repo.)*

- **Expand the Memory faculty with one "Book alignment checkpoint."** Add a checklist in `docs/BRAIN.md` or a separate `docs/ALIGNMENT.md` that maps the three concrete wins in the README (eval suite, governance gates, CI) back to specific chapters/lessons in the book. Keep it 1–2 pages. *(Why: The repo is a "companion reference implementation"—readers need to see the book concept mirrored in code without having to reverse-engineer it.)*

- **Document the daily-check skip/failure modes.** Currently `daily-check.sh` reports "what it could not check"; add a 50-line comment in that script explaining *why* a Skill might be skipped (missing `pyproject.toml`, no test dir, etc.) so contributors know what to fix. *(Why: Governance only sticks if people understand what "green" means.)*

- **Create a single "add your first Skill" tutorial.** One Markdown file (`docs/TUTORIAL.md`) with a walk-through: copy `skills/audit-secrets/`, rename, edit frontmatter and `index.mjs`, run eval, see it fail, fix the test. Ship it to unblock the next user. *(Why: The bootstrap gets you running; a tutorial gets you *contributing*—that's where the book's premise proves or fails.)*

### 2026-08-17 — reflection
# Reflection: ai4books-books — Next Actions (2026-08-10)

## Status
- **Brain scaffolding**: ✅ Live (five faculties installed; propose-not-execute pattern active)
- **Core product**: ✅ Runnable (Skill library starter with eval suite, governance gates, CI)
- **Lessons log**: Empty (first reflection cycle; no feedback loops closed yet)

## Proposed Next Actions

- **Run `./bootstrap.sh` locally, capture friction or success, commit proof to `docs/LESSONS.md`.** The book's thesis is "durable governance"—we need lived signal that this starter does what it claims. First reflection should seed the feedback loop with real outcomes, not just code.

- **Hardcode weekly Reflection as a GitHub Actions scheduled job (Friday EOD).** Wire `node scripts/brain-reflect.mjs` to run on schedule and open a PR with delta. Without automation, the brain stays in local memory; the five faculties only compound if proposals feed back to the repo.

- **Add a "Book alignment checkpoint" in `docs/ALIGNMENT.md` (1–2 pages).** Map the three concrete wins in the README (eval suite, governance gates, CI) back to specific book chapters/lessons. Readers need to see the concept mirrored in code without reverse-engineering it.

- **Document daily-check skip/failure modes in `checks/daily-check.sh`.** Add 50-line comment explaining why a Skill is skipped (missing `pyproject.toml`, no test dir, etc.). Governance only sticks if contributors understand what "green" means.

- **Ship `docs/TUTORIAL.md`: "Add your first Skill in 5 minutes."** Walk-through: copy `skills/audit-secrets/`, rename, edit frontmatter + index, run eval, watch it fail, fix the test. Bootstrap gets you running; tutorial gets you contributing—that's where the premise proves.
