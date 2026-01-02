#!/usr/bin/env node
/**
 * Firestore Rules Builder
 *
 * Concatenates modular .rules files into a single firestore.rules file.
 * Files are processed in alphabetical order, so use numeric prefixes
 * to control the order (e.g., 00_header.rules, 01_helpers.rules, etc.)
 *
 * Usage:
 *   node firestore-rules/build.js
 *   npm run build:rules
 */

const fs = require('fs');
const path = require('path');

const RULES_DIR = __dirname;
const OUTPUT_FILE = path.join(__dirname, '..', 'firestore.rules');

// Get all .rules files, sorted alphabetically
const rulesFiles = fs
  .readdirSync(RULES_DIR)
  .filter((file) => file.endsWith('.rules'))
  .sort();

if (rulesFiles.length === 0) {
  console.error('Error: No .rules files found in', RULES_DIR);
  process.exit(1);
}

console.log('Building firestore.rules from:');
rulesFiles.forEach((file) => console.log(`  - ${file}`));

// Concatenate all files
let output = '';
for (const file of rulesFiles) {
  const filePath = path.join(RULES_DIR, file);
  const content = fs.readFileSync(filePath, 'utf8');
  output += content;
  // Add newline between files if not already present
  if (!content.endsWith('\n')) {
    output += '\n';
  }
}

// Write the combined output
fs.writeFileSync(OUTPUT_FILE, output);

// Get file stats for summary
const stats = fs.statSync(OUTPUT_FILE);
const lineCount = output.split('\n').length;

console.log(`\nSuccess! Built ${OUTPUT_FILE}`);
console.log(`  Files combined: ${rulesFiles.length}`);
console.log(`  Total lines: ${lineCount}`);
console.log(`  File size: ${(stats.size / 1024).toFixed(1)} KB`);
