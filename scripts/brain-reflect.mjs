#!/usr/bin/env node
/**
 * brain-reflect.mjs — the Reflection faculty of this project's brain (see docs/BRAIN.md).
 *
 * Reads KNOWLEDGE (recent git delta + optional docs/growth/knowledge.md) + MEMORY (the tail of the
 * ideas log), asks the model for concrete next-move PROPOSALS, APPENDS them to the ideas log, writes
 * an inspectable transparency entry, and reports.
 *
 * HARD BOUNDARIES: it PROPOSES, it does not execute — it only appends to log files; it never sends,
 * spends, publishes, or mutates any system. Skip-safe: with no ANTHROPIC_API_KEY (or no git delta)
 * it exits cleanly and writes nothing. Dependency-free: Node 18+ (global fetch) only.
 */
import { readFileSync, appendFileSync, existsSync, mkdirSync } from "node:fs";
import { execSync } from "node:child_process";
import { dirname } from "node:path";

const KEY = process.env.ANTHROPIC_API_KEY;
const MODEL = process.env.BRAIN_MODEL || "claude-haiku-4-5-20251001";
const PROJECT = process.env.BRAIN_PROJECT || "this project";
const IDEAS = "docs/growth/ideas-log.md";
const TRANSPARENCY = "docs/agent/transparency-log.md";

const git = (cmd, fb = "") => {
  try {
    return execSync(`git ${cmd}`, { encoding: "utf8" }).trim();
  } catch {
    return fb;
  }
};
const ensure = (p) => existsSync(dirname(p)) || mkdirSync(dirname(p), { recursive: true });
const nowIso = new Date().toISOString();
const date = nowIso.slice(0, 10);

const log = git("log --oneline -20");
const stat = git("diff --stat HEAD~10..HEAD");
// Knowledge: explicit docs/growth/knowledge.md if present, else auto-derive from README + package.json.
const explicitKnowledge = existsSync("docs/growth/knowledge.md")
  ? readFileSync("docs/growth/knowledge.md", "utf8").slice(0, 4000)
  : "";
const readme = existsSync("README.md") ? readFileSync("README.md", "utf8").slice(0, 2500) : "";
const pkg = existsSync("package.json") ? readFileSync("package.json", "utf8").slice(0, 1500) : "";
const knowledge =
  explicitKnowledge ||
  [readme && `README.md:\n${readme}`, pkg && `package.json:\n${pkg}`].filter(Boolean).join("\n\n");
// Memory (prior ideas) + Feedback (lessons: what paid off / was reverted).
const memory = existsSync(IDEAS) ? readFileSync(IDEAS, "utf8").split("\n").slice(-60).join("\n") : "";
const lessons = existsSync("docs/growth/lessons-log.md")
  ? readFileSync("docs/growth/lessons-log.md", "utf8").slice(-2000)
  : "";

if (!KEY) {
  console.log("brain-reflect: SKIPPED — no ANTHROPIC_API_KEY (skip-safe; nothing written).");
  process.exit(0);
}
if (!log) {
  console.log("brain-reflect: SKIPPED — no git history to reflect on.");
  process.exit(0);
}

const system =
  `You are the Reflection faculty of ${PROJECT}'s brain (docs/BRAIN.md). Read the recent change ` +
  `delta, the project knowledge, prior ideas, and the LESSONS LOG (what paid off or was reverted), ` +
  `then PROPOSE 3–5 concrete, high-leverage next actions — specific and grounded, building on prior ` +
  `ideas without repeating them, and WEIGHTED by the lessons (favor what worked, avoid what was ` +
  `reverted). You PROPOSE; you do NOT execute — nothing is acted on from this output. Be terse. ` +
  `Output a markdown bullet list only.`;
const user =
  `## Recent commits\n${log}\n\n## Change surface (last 10 commits)\n${stat || "(none)"}\n\n` +
  `## Project knowledge\n${knowledge || "(none provided)"}\n\n` +
  `## Prior ideas (memory tail)\n${memory || "(empty — first run)"}\n\n` +
  `## Lessons — what paid off / was reverted (Feedback)\n${lessons || "(none yet)"}`;

let res;
try {
  res = await fetch("https://api.anthropic.com/v1/messages", {
    method: "POST",
    headers: {
      "content-type": "application/json",
      "x-api-key": KEY,
      "anthropic-version": "2023-06-01",
    },
    body: JSON.stringify({ model: MODEL, max_tokens: 800, system, messages: [{ role: "user", content: user }] }),
  });
} catch (e) {
  console.error("brain-reflect: network error:", e.message);
  process.exit(1);
}
if (!res.ok) {
  console.error("brain-reflect: API error", res.status, (await res.text()).slice(0, 200));
  process.exit(1);
}
const data = await res.json();
const ideas = (data.content || [])
  .filter((b) => b.type === "text")
  .map((b) => b.text)
  .join("")
  .trim();
const usage = data.usage || {};
const count = (ideas.match(/^[-*]/gm) || []).length;

ensure(IDEAS);
appendFileSync(IDEAS, `\n### ${date} — reflection\n${ideas}\n`);
ensure(TRANSPARENCY);
appendFileSync(
  TRANSPARENCY,
  `\n- **${nowIso}** · trigger=${process.env.GITHUB_ACTIONS ? "cron/action" : "manual"} · ` +
    `read: git log+diff + ${explicitKnowledge ? "knowledge.md" : "README/package.json"} + ${IDEAS} + lessons-log · ` +
    `used: ANTHROPIC_API_KEY (name only) · model=${MODEL} tokens=${usage.input_tokens || 0}/${usage.output_tokens || 0} · ` +
    `wrote: ${IDEAS} (append) · sent: none · summary: proposed ${count} next-action(s) — propose-not-execute\n`,
);
console.log(`brain-reflect: appended ${count} proposal(s) to ${IDEAS}. Nothing executed.`);
