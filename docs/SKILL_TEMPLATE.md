# SKILL.md template

Copy this into `skills/<slug>/SKILL.md` to start a new Skill. The frontmatter is
the contract a machine reads; the body is the procedure a human or an agent
follows.

```markdown
---
name: <slug>
description: <one sentence that triggers the Skill. State what it does and when
  to use it, concretely, because relevance matching reads this line.>
version: 1.0.0
changelog: CHANGELOG.md
---

# <slug>

<One paragraph: what this capability does and why it exists.>

## Contract

- **Input:** <what it takes>
- **Output:** <the exact shape it returns>
- **Guarantee:** <the load-bearing promise, for example "never echoes a raw
  secret" or "green means checked">

## Procedure

1. <step>
2. <step>

## Tests

<Where the golden cases live and what a passing score means. A passing score
does not prove the output is correct; it proves the output is still acceptable
on the cases you chose to represent the job.>
```

## Rules

- Anything `SKILL.md` references (a regex set, a config, a helper script) must
  live inside the package directory, never on your disk or in your head.
- A version number is a promise. Bump PATCH for wording, MINOR for additive
  changes, MAJOR when the contract changes, and write the changelog entry in the
  same change.
- Put the deterministic part in `scripts/`. Let the model do judgment, and let
  code enforce the contract.
