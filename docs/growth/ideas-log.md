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

### 2026-08-24 — reflection
# Reflection: ai4books-books — Next Actions (Week of 2026-08-17)

## Status
- **Brain scaffolding**: ✅ Live (five faculties installed; propose-not-execute pattern active)
- **Core product**: ✅ Runnable (Skill library starter with eval suite, governance gates, CI)
- **Lessons log**: Empty (no closed feedback loops yet; proposals not yet shipped or validated)

## Proposed Next Actions

- **Ship `docs/TUTORIAL.md`: "Add your first Skill in 5 minutes."** Walk-through: copy `skills/audit-secrets/`, rename, edit frontmatter + `index.mjs`, run eval, watch it fail, fix the test. This unblocks the next user and closes the gap between "clone and run" → "actually contribute." *(Highest leverage: the book's thesis only proves if people add Skills.)*

- **Commit a real bootstrap run outcome to `docs/LESSONS.md` with exact friction observed.** Run `./bootstrap.sh` locally, capture the full output and any hiccups (or vindication of the "7 ok" claim), date it, commit. First signal that the minimal setup works or where it breaks. *(Why: The brain's Feedback faculty is empty; seeding it with lived proof turns proposals into learning.)*

- **Harden `checks/daily-check.sh` with inline skip-reason comments (50 lines max).** Document why a Skill is skipped (missing `pyproject.toml`, no test dir, no `index.mjs`). Governance only sticks if contributors understand what "green" means and how to fix "yellow."

- **Wire weekly Reflection to GitHub Actions (scheduled Friday).** Add `.github/workflows/reflect.yml` that runs `node scripts/brain-reflect.mjs` and opens a PR with the delta. Without automation, the five faculties stay in local memory; proposals only compound if they feed back to the repo.

- **Add `docs/ALIGNMENT.md` mapping README wins to book chapters (1 page).** Eval suite → Ch. 3 "Testing Non-Determinism", Governance gates → Ch. 5 "Naming & Drift", CI → Ch. 6 "Automation." Readers need the book concept mirrored in runnable code, not reverse-engineered.

### 2026-08-31 — reflection
# ai4books-books — Reflection Proposals (2026-08-31)

## Status
- **Brain scaffolding**: ✅ Live (five faculties installed; three weekly reflections completed, zero actions shipped)
- **Core product**: ✅ Runnable (Skill library starter with eval suite, governance gates, CI)
- **Lessons log**: 🔴 Empty (proposals stack unexecuted; no feedback cycle closed; brain is decoupled from reality)

## ⚠️ Critical Signal
Three weeks of proposals with **zero shipped actions** = the propose-not-execute pattern is working as designed, but **no one is executing the proposals**. The brain needs to surface *why* execution stalls, not repeat the same five asks.

## Proposed Next Actions

- **Reduce proposal scope by 75%: ship ONE action per week, not five.** The brain is becoming a backlog generator. Pick the highest-leverage action (currently: `docs/TUTORIAL.md`), commit a target ship date (e.g., "ship by Friday EOD"), and stop proposing until it lands. Rationale: a shipped tutorial unblocks contributors and closes the book's core thesis loop. Everything else is scaffolding.

- **Add an "Execution blockers" section to `docs/BRAIN.md`.** After each weekly reflection, capture *why* the prior week's top action did not ship: "Time?", "Unclear?", "Low priority?", "Blocked on [other task]?". This turns the empty Lessons log into actionable signal instead of repeating the same asks. *(Why: The Feedback faculty is broken if we don't log friction, not just ideas.)*

- **Commit one real bootstrap run outcome to `docs/LESSONS.md` this week.** Run `./bootstrap.sh`, paste the full output, note any friction (or lack thereof). This is the *only* piece of lived signal in the repo right now. Without it, all five faculties are hypothetical. *(Why: The book's "durable governance" thesis can't be proven without proof.)*

- **Wire the Reflection faculty to autopilot: add a Friday GitHub Actions trigger that opens a PR with the delta only if prior actions are documented.** If `docs/BRAIN.md` still has empty "Execution blockers," the job posts a comment and skips the PR. Forces feedback-loop closure before the brain proposes again. *(Why: Automation without consequence is theater.)*

- **Rename "Prior ideas (memory tail)" → "Shipped & Learned" in the next reflection run.** Log what *actually shipped* (tutorial, alignment doc, lessons.md entry, etc.) and what broke so the brain can weight its next proposals. *(Why: Without this, all three faculties are guessing.)*
