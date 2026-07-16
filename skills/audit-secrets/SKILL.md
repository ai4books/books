---
name: audit-secrets
description: Scan a directory for secret-shaped values (API keys, tokens, private keys) committed by mistake, and report each finding with its file and line, redacted so the report never leaks the secret it found.
version: 1.0.0
changelog: CHANGELOG.md
---

# audit-secrets

Scan a tree of source and config files for values that look like leaked secrets,
and produce a structured report a human or an agent can act on. This Skill is
the worked example that runs through the book: a non-deterministic capability
wrapped in deterministic guardrails, with a test suite that proves it still
works after a model or policy change.

## Contract

- **Input:** a directory path (`--dir <path>`). Defaults to the current directory.
- **Output:** JSON with the shape `{ findings: [{ file, line, kind, redacted }], summary }`.
- **Guarantee:** a finding NEVER contains the raw secret value. Every finding is
  redacted (`<kind>:...REDACTED`). A tool that leaks the secret while reporting
  the leak is worse than useless.

## Procedure

1. Run the deterministic scanner: `node scripts/scan.mjs --dir <path>`. It walks
   the tree, skips binaries and `node_modules`, and flags any line whose value
   carries a known secret prefix (`reference/secret-patterns.md` lists them).
2. Validate the output against the contract above. The `redacted` field must
   match a redaction pattern; a raw value must never appear.
3. Summarize: how many findings, in which files. Route anything found to the
   owner of that project, never paste the value into chat or a ticket.

## Why a script, not a prompt

The detection itself is deterministic, so it lives in `scripts/scan.mjs`, not in
the model. The model's job (when this Skill is driven by an agent) is judgment:
deciding what to do about a finding, writing the summary, opening the right
issue. Pushing the secret-matching into code is what makes the capability
testable and immune to the model rephrasing its output.

## Tests

`tests/fixtures/planted/` holds three deliberately-fake, structurally-broken
secrets; `tests/fixtures/clean/` is engineered to tempt a false positive. The
eval suite (`npm run eval`) asserts: catches all three, names the leaked file,
zero false positives on the clean set, and never echoes a raw value. A passing
score does not prove the output is correct; it proves the output is still
acceptable on the cases you chose to represent the job.
