#!/usr/bin/env node
// Regenerates src/content/docs/docs/rules/ from Bull's rule catalog.
//
//   BULL_REPO=../bull node scripts/sync-rules.mjs
//   node scripts/sync-rules.mjs ../bull
//
// The Bull repo must be built (`npm run build`) so packages/cli/dist/bin.js exists.

import { execFileSync } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";

const here = path.dirname(fileURLToPath(import.meta.url));
const site = path.resolve(here, "..");
const repo = path.resolve(process.argv[2] ?? process.env.BULL_REPO ?? path.join(site, "..", "bull"));
const bin = path.join(repo, "packages/cli/dist/bin.js");

if (!fs.existsSync(bin)) {
  console.error(`✗ ${path.relative(process.cwd(), bin)} not found.`);
  console.error("  Pass the Bull repo path (BULL_REPO=../bull) and run `npm run build` in it first.");
  process.exit(1);
}

const tmp = fs.mkdtempSync(path.join(os.tmpdir(), "bull-rules-"));
execFileSync(process.execPath, [bin, "explain", "--all", "--format", "md", "--out", tmp], { stdio: "ignore" });

const out = path.join(site, "src/content/docs/docs/rules");
fs.rmSync(out, { recursive: true, force: true });
fs.mkdirSync(out, { recursive: true });

const pages = fs.readdirSync(tmp).filter((f) => /^MVVM\d+\.md$/.test(f)).sort();
pages.forEach((file, order) => {
  const source = fs.readFileSync(path.join(tmp, file), "utf8");
  const [heading, ...body] = source.split("\n");
  const title = heading.replace(/^#\s*/, "").trim();
  const summary = body.find((line) => line.trim() && !line.startsWith(">"))?.trim() ?? "";
  const frontmatter = [
    "---",
    `title: ${JSON.stringify(title)}`,
    `description: ${JSON.stringify(summary)}`,
    "sidebar:",
    `  label: ${JSON.stringify(title.replace(" · ", " "))}`,
    `  order: ${order + 1}`,
    "---",
  ].join("\n");
  fs.writeFileSync(path.join(out, file.toLowerCase()), `${frontmatter}\n${body.join("\n").replace(/^\n+/, "\n")}`);
});

// The index: same table, with links to the generated pages.
const index = fs
  .readFileSync(path.join(tmp, "README.md"), "utf8")
  .replace(/^# .*\n/, "")
  .replace(/\]\(\.\/(MVVM\d+)\.md\)/g, (_, code) => `](./${code.toLowerCase()}/)`);
fs.writeFileSync(
  path.join(out, "index.md"),
  [
    "---",
    'title: "Rule reference"',
    'description: "Every Bull architecture rule, its severity and whether it can be disabled."',
    "sidebar:",
    "  label: Overview",
    "  order: 0",
    "---",
    "",
    "Every rule has a stable code and an ESLint slug. Run `bull explain <code>` for the same text in your terminal.",
    "",
    index.trim(),
    "",
  ].join("\n"),
);

fs.rmSync(tmp, { recursive: true, force: true });
console.log(`✓ ${pages.length} rule pages written to ${path.relative(process.cwd(), out)}`);
