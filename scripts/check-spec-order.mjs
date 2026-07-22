#!/usr/bin/env node
/**
 * Guardrail: within a spec file, test() blocks must appear in ascending order
 * by their leading ADO test-case id — e.g. test('20001 - AC1 - ...'), then
 * '20002 - ...', then '20003 - ...'. Keeps specs readable and matching TC order.
 *
 * Run: npm run check:order
 */
import { readFileSync, readdirSync, statSync, existsSync } from 'node:fs';
import { join } from 'node:path';

const TEST_DIR = 'src/tests';
// Matches: test('20001 - …'), test.only("20002 - …"), etc. Captures the id.
const TEST_ID = /\btest(?:\.\w+)?\(\s*['"`](\d+)\b/;

function walk(dir) {
  let files = [];
  for (const e of readdirSync(dir)) {
    const p = join(dir, e);
    if (statSync(p).isDirectory()) files = files.concat(walk(p));
    else if (e.endsWith('.spec.ts')) files.push(p);
  }
  return files;
}

if (!existsSync(TEST_DIR)) {
  console.log(`✔ No ${TEST_DIR} directory — nothing to check.`);
  process.exit(0);
}

const problems = [];
for (const file of walk(TEST_DIR)) {
  const lines = readFileSync(file, 'utf8').split(/\r?\n/);
  const ids = [];
  lines.forEach((line, i) => {
    const m = line.match(TEST_ID);
    if (m) ids.push({ id: Number(m[1]), raw: m[1], line: i + 1 });
  });
  for (let k = 1; k < ids.length; k++) {
    if (ids[k].id < ids[k - 1].id) {
      problems.push({
        file: file.replace(/\\/g, '/'),
        line: ids[k].line,
        msg: `test ${ids[k].raw} appears after ${ids[k - 1].raw} — out of order`,
      });
    }
  }
}

if (problems.length) {
  console.error('✘ Test cases are out of order — write them in ascending TC id order:\n');
  for (const p of problems) console.error(`  ${p.file}:${p.line}  ${p.msg}`);
  console.error(`\n${problems.length} ordering issue(s). Insert each test at its correct position.`);
  process.exit(1);
}

console.log('✔ Spec test cases are in ascending order.');
