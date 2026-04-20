// build.js — merge src/ files into CTLD_Next.lua
// Usage: node tools/build.js  (run from repo root)

const fs   = require('fs');
const path = require('path');

const srcDir   = path.join(__dirname, '..', 'src');
const listFile = path.join(__dirname, 'merger_V2', 'listToMerge.txt');
const outFile  = path.join(__dirname, '..', 'CTLD_Next.lua');

const lines = fs.readFileSync(listFile, 'utf8').split(/\r?\n/);
const parts = ['---@meta\n', '---@diagnostic disable\n', '\n'];

for (const raw of lines) {
    const line = raw.trim();
    if (!line || line.startsWith('--')) continue;
    const filePath = path.join(srcDir, line);
    if (!fs.existsSync(filePath)) {
        console.warn('[WARNING] Not found: ' + filePath);
        continue;
    }
    const content = fs.readFileSync(filePath, 'utf8');
    parts.push('-- ===== Start : ' + line + ' =====\n');
    parts.push(content);
    if (!content.endsWith('\n')) parts.push('\n');
    parts.push('-- ===== End   : ' + line + ' =====\n\n');
}

const result = parts.join('');
fs.writeFileSync(outFile, result, 'utf8');
console.log('[OK] ' + outFile + ' — ' + result.split('\n').length + ' lines');
