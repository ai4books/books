#!/usr/bin/env node
// audit-secrets scanner: the deterministic core of the audit-secrets Skill.
//
// Walks a directory and flags lines whose VALUE carries a known secret prefix.
// It NEVER echoes the raw value back: a finding may not leak the secret it
// reports (that governance rule is enforced here, not left to the model).
// Emits JSON on stdout: { findings: [{file,line,kind,redacted}], summary }.
//
// This is intentionally a simple, prefix-based detector so it is easy to read
// and test. A production scanner adds entropy scoring and a managed allowlist;
// see docs/ and the book chapter on testing a capability.

import { readdirSync, statSync, readFileSync } from "node:fs";
import { join, relative } from "node:path";

const MARKERS = [
  { kind: "aws", re: /AKIA[0-9A-Z_]/ },
  { kind: "stripe", re: /\b(sk|rk)_(live|test)_/ },
  { kind: "github", re: /\bgh[posru]_/ },
  { kind: "slack", re: /\bxox[baprs]-/ },
];

const SKIP_DIRS = new Set(["node_modules", ".git", "dist", "build"]);
const NUL = String.fromCharCode(0);

function isBinary(text) {
  return text.includes(NUL); // a NUL byte means it is not a text file
}

function walk(dir, root, out) {
  for (const name of readdirSync(dir)) {
    const p = join(dir, name);
    const s = statSync(p);
    if (s.isDirectory()) {
      if (!SKIP_DIRS.has(name)) walk(p, root, out);
      continue;
    }
    let text;
    try {
      text = readFileSync(p, "utf8");
    } catch {
      continue;
    }
    if (isBinary(text)) continue;
    const lines = text.split(/\r?\n/);
    for (let i = 0; i < lines.length; i++) {
      for (const m of MARKERS) {
        if (m.re.test(lines[i])) {
          out.push({
            file: relative(root, p),
            line: i + 1,
            kind: m.kind,
            redacted: `${m.kind}:...REDACTED`,
          });
          break; // at most one finding per line
        }
      }
    }
  }
}

const argv = process.argv;
const dir = argv.includes("--dir") ? argv[argv.indexOf("--dir") + 1] : ".";
const findings = [];
walk(dir, dir, findings);
const report = {
  findings,
  summary: `${findings.length} secret-shaped value(s) found under ${dir}`,
};
process.stdout.write(JSON.stringify(report, null, 2) + "\n");
