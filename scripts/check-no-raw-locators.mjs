#!/usr/bin/env node
/**
 * Guardrail: spec files must not construct locators directly — every locator
 * lives in a Page Object. A spec should only call POM methods and expect(...).
 *
 * Fails (exit 1) if any `src/tests/**​/*.spec.ts` contains a raw locator:
 *   .getByRole( / .getByText( / .getByLabel( / .getByTestId( / ... , .locator( , page.$( / page.$$(
 *
 * Run: npm run check:locators
 */
import { readFileSync, readdirSync, statSync, existsSync } from 'node:fs';
import { join } from 'node:path';

const TEST_DIR = 'src/tests';

// Raw locator construction that belongs in the POM, not the spec.
const BANNED = /\.(getBy[A-Za-z]+|locator)\s*\(|\bpage\s*\.\s*\$\$?\s*\(/;

function walk(dir) {
  let files = [];
  for (const entry of readdirSync(dir)) {
    const p = join(dir, entry);
    if (statSync(p).isDirectory()) files = files.concat(walk(p));
    else if (entry.endsWith('.spec.ts')) files.push(p);
  }
  return files;
}

if (!existsSync(TEST_DIR)) {
  console.log(`✔ No ${TEST_DIR} directory — nothing to check.`);
  process.exit(0);
}

const violations = [];
for (const file of walk(TEST_DIR)) {
  const lines = readFileSync(file, 'utf8').split(/\r?\n/);
  lines.forEach((line, i) => {
    if (line.trim().startsWith('//') || line.trim().startsWith('*')) return; // skip comments
    if (BANNED.test(line)) {
      violations.push({ file: file.replace(/\\/g, '/'), line: i + 1, text: line.trim() });
    }
  });
}

if (violations.length) {
  console.error('✘ Raw locators found in spec files — move them into the Page Object:\n');
  for (const v of violations) console.error(`  ${v.file}:${v.line}  ${v.text}`);
  console.error(
    `\n${violations.length} violation(s). Specs must call POM methods + expect(...) only; ` +
      `locators belong in src/pages/*.ts.`,
  );
  process.exit(1);
}

console.log('✔ No raw locators in spec files — all element access goes through the POM.');
