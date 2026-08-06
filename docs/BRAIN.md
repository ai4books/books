# ai4books-books — Brain

A persistent cognitive scaffold around a stateless model so **ai4books-books** compounds across
sessions instead of starting blank. This is **not** consciousness and does **not** self-modify
weights (that is fine-tuning, a separate human step). It is a disciplined, auditable loop that
remembers, reflects, and **proposes**.

## The five faculties

| Faculty | What it is | Where it lives here |
|---|---|---|
| **Memory** | long-term store of facts / decisions / ideas / lessons | `docs/growth/ideas-log.md` + `docs/growth/lessons-log.md` (append-only) |
| **Reflection** | reviews past output vs. what happened; proposes next moves | `scripts/brain-reflect.mjs` |
| **Knowledge** | the world-model it reasons over | recent git delta + optional `docs/growth/knowledge.md` |
| **Autonomy** | wakes on a schedule without being asked | `.github/workflows/brain-reflect.yml` (weekly cron) |
| **Feedback** | learns which proposals actually paid off | outcomes captured back into `ideas-log.md` / `lessons-log.md` |

## The thought loop

Autonomy wakes it → reads Knowledge (delta) + Memory → reflects → **appends** proposals to Memory
(compounding) → reports to a human. The next cycle builds on the last. **Feedback** closes the loop
so it gets *smarter*, not just *bigger*.

## Hard boundaries (non-negotiable)

- **Proposes, does not execute.** The reflection run only appends to log files. It never sends,
  spends, publishes, or mutates any system without a human.
- **Accountable.** Every run writes an inspectable entry to `docs/agent/transparency-log.md` (what it
  read/used/wrote — secret **names** only, never values).
- **Honest.** A capable system, not a mind. No sentience, no self-improving weights.

## Run it

- Manual: `ANTHROPIC_API_KEY=… BRAIN_PROJECT=ai4books-books node scripts/brain-reflect.mjs`
- Scheduled: the weekly GitHub Action (needs repo secret `ANTHROPIC_API_KEY`).

Skip-safe: with no key or no git delta it exits cleanly and writes nothing. Optionally add
`docs/growth/knowledge.md` with project-specific context (metrics, goals) to sharpen proposals.

_Architecture reference: `persoon.dev/docs/BRAIN.md`; skill: `ai/agent-cognitive-core` +
`platform/access-transparency-log` in skills-library._
