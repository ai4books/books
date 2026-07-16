# Secret patterns

The deterministic scanner (`../scripts/scan.mjs`) flags a line when its value
carries one of these known prefixes. The set is intentionally small and
prefix-based so it is easy to read and test. Anything the scanner references
must live inside the package, which is exactly why this file sits next to the
script instead of in someone's head.

| Kind   | Prefix marker        | Example provider          |
|--------|----------------------|---------------------------|
| aws    | `AKIA`               | AWS access key id         |
| stripe | `sk_live_` `sk_test_` `rk_live_` | Stripe API keys |
| github | `ghp_` `gho_` `ghu_` `ghs_` `ghr_` | GitHub tokens   |
| slack  | `xoxb-` `xoxp-` ...  | Slack tokens              |

## What this is NOT

A prefix scanner catches the obvious, structured leaks. It does not catch
high-entropy values with no recognizable prefix. A production scanner adds an
entropy score and a managed allowlist, and treats this prefix set as the fast
first pass. The point of the starter is the testable shape, not exhaustive
coverage: a deterministic core you can pin a golden-case suite against.
