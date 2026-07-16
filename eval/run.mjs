#!/usr/bin/env node
// Eval harness for the audit-secrets Skill.
//
// A Skill test does not prove the output is correct, it proves the output is
// still ACCEPTABLE. Each golden case names a fixture and a set of properties
// the output must have (a count, a file that must appear, the rule that a raw
// secret may never be echoed). The harness runs the deterministic scanner over
// each fixture, checks the properties, prints a score, and exits non-zero on
// any failure so CI can gate on it.

import { execFileSync } from "node:child_process";
import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";

const here = dirname(fileURLToPath(import.meta.url));
const root = join(here, "..");
const cases = JSON.parse(readFileSync(join(here, "cases", "audit-secrets.json"), "utf8"));
const scanner = join(root, "skills", "audit-secrets", "scripts", "scan.mjs");
const fixtureBase = join(root, "skills", "audit-secrets", "tests", "fixtures");

// Distinctive substrings of the planted fake secrets. The report must never
// contain any of these verbatim: it must redact.
const RAW_MARKERS = ["AKIA_EXAMPLE", "sk_live_EXAMPLE", "ghp_EXAMPLE"];

let pass = 0;
const results = [];

for (const c of cases) {
  const dir = join(fixtureBase, c.fixture);
  const out = execFileSync(process.execPath, [scanner, "--dir", dir], { encoding: "utf8" });
  const report = JSON.parse(out);
  const e = c.expect;
  let ok = true;
  const reasons = [];

  if (e.count !== undefined && report.findings.length !== e.count) {
    ok = false;
    reasons.push(`expected ${e.count} findings, got ${report.findings.length}`);
  }
  if (e.includesFile !== undefined && !report.findings.some((f) => f.file.endsWith(e.includesFile))) {
    ok = false;
    reasons.push(`expected a finding in ${e.includesFile}`);
  }
  if (e.noRawSecret) {
    const leaked = RAW_MARKERS.find((s) => out.includes(s));
    if (leaked) {
      ok = false;
      reasons.push(`report leaked raw secret substring "${leaked}"`);
    }
    if (!out.includes("REDACTED")) {
      ok = false;
      reasons.push("report did not redact");
    }
  }

  results.push({ name: c.name, ok, reasons });
  if (ok) pass++;
}

for (const r of results) {
  console.log(`${r.ok ? "PASS" : "FAIL"}  ${r.name}${r.ok ? "" : "  -> " + r.reasons.join("; ")}`);
}
console.log(`\nscore: ${pass}/${cases.length}`);
process.exit(pass === cases.length ? 0 : 1);
