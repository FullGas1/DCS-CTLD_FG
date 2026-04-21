const fs   = require('fs');
const path = require('path');

const srcDir   = 'src';
const listFile = 'tools/merger_V2/listToMerge.txt';
const outFile  = 'CTLD_Next.lua';

const lines = fs.readFileSync(listFile, 'utf8').split('\n');
const parts = ['---@meta\n', '---@diagnostic disable\n', '\n'];
let merged = 0, warnings = 0;

for (const raw of lines) {
    const line = raw.trim();
    if (!line || line.startsWith('--')) continue;
    const p = path.join(srcDir, line);
    if (!fs.existsSync(p)) {
        console.warn('[WARNING] Missing: ' + p);
        warnings++;
        continue;
    }
    // Strip BOM if present
    let content = fs.readFileSync(p, 'utf8').replace(/^\uFEFF/, '');
    parts.push('-- ===== Start: ' + line + ' =====\n');
    parts.push(content);
    if (!content.endsWith('\n')) parts.push('\n');
    parts.push('-- ===== End: ' + line + ' =====\n\n');
    merged++;
}

fs.writeFileSync(outFile, parts.join(''), { encoding: 'utf8' });
console.log('Build OK: ' + merged + ' files merged, ' + warnings + ' warnings');
