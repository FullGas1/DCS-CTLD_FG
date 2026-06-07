$ErrorActionPreference = 'Continue'
$base    = 'C:\Users\Moi\Documents\GitHub\DCS-CTLD_FG\recette'
$unitDir = "$base\unit"
$funcDir = "$base\functional"
$repo    = 'C:\Users\Moi\Documents\GitHub\DCS-CTLD_FG'
$emDash  = [char]0x2014; $enDash = [char]0x2013

New-Item -ItemType Directory -Force -Path $unitDir | Out-Null
New-Item -ItemType Directory -Force -Path $funcDir | Out-Null

function Do-GitMv { param([string]$src, [string]$dst)
    $out = & git -C $repo mv $src $dst 2>&1
    if ($LASTEXITCODE -ne 0) { Write-Warning "git mv FAILED: $src -> $dst`n$out" }
}

function Sanitize { param([string]$raw)
    $s = $raw
    $s = $s -replace '\bCTLD', ''
    $s = $s -replace '\bctld\.', ''
    $s = $s.Replace($emDash,' ').Replace($enDash,' ').Replace([char]0x2192,' ')
    $normalized = $s.Normalize([System.Text.NormalizationForm]::FormD)
    $sb = New-Object System.Text.StringBuilder
    foreach ($ch in $normalized.ToCharArray()) {
        if ([System.Globalization.CharUnicodeInfo]::GetUnicodeCategory($ch) -ne
            [System.Globalization.UnicodeCategory]::NonSpacingMark) { [void]$sb.Append($ch) }
    }
    $s = $sb.ToString()
    $s = $s -replace '[^a-zA-Z0-9]', ' '
    $words = ($s.Trim() -split '\s+') | Where-Object { $_.Length -gt 0 }
    if ($words.Count -eq 0) { return 'test' }
    $w0 = $words[0]
    if ($w0.Length -gt 1) { $result = $w0.Substring(0,1).ToLower() + $w0.Substring(1) }
    else                   { $result = $w0.ToLower() }
    for ($i = 1; $i -lt $words.Count; $i++) {
        $w = $words[$i]
        if ($w.Length -gt 1) { $result += $w.Substring(0,1).ToUpper() + $w.Substring(1) }
        else                  { $result += $w.ToUpper() }
    }
    if ($result.Length -gt 50) { $result = $result.Substring(0,50) }
    return $result
}

function Get-TestDesc { param([string]$file, [string]$id)
    $lines = Get-Content $file -Encoding UTF8 -ErrorAction SilentlyContinue | Select-Object -First 10
    $escaped = [regex]::Escape($id)
    foreach ($line in $lines) {
        $norm = $line.Replace($emDash,':').Replace($enDash,':')
        if ($norm -match "^--\s+$escaped\s*:\s*(.+)") { return Sanitize $matches[1].Trim() }
    }
    return 'test'
}

# ── U-XX ────────────────────────────────────────────────────────────────────
$uDirs = Get-ChildItem -Path $base -Directory |
    Where-Object { $_.Name -match '^U-(\d+)$' } |
    Sort-Object { [int]($_.Name -replace 'U-','') }
foreach ($dir in $uDirs) {
    $num = [int]($dir.Name -replace 'U-',''); $pad = $num.ToString("000")
    $src = Join-Path $dir.FullName "test.lua"
    if (-not (Test-Path $src)) { Write-Warning "No test.lua in $($dir.Name)"; continue }
    $desc = Get-TestDesc $src $dir.Name
    $dst  = Join-Path $unitDir "U-${pad}_${desc}.lua"
    Write-Host "  $($dir.Name) -> unit/U-${pad}_${desc}.lua"
    Do-GitMv $src $dst
}

# ── F-XX ────────────────────────────────────────────────────────────────────
$fDirs = Get-ChildItem -Path $base -Directory |
    Where-Object { $_.Name -match '^F-(\d+)$' } |
    Sort-Object { [int]($_.Name -replace 'F-','') }
foreach ($dir in $fDirs) {
    $num  = [int]($dir.Name -replace 'F-',''); $pad = $num.ToString("000")
    $id   = $dir.Name
    $luas = Get-ChildItem $dir.FullName -Filter "*.lua" | Sort-Object Name
    $testFile = $luas | Where-Object { $_.Name -eq 'test.lua' } | Select-Object -First 1

    if ($testFile) {
        $desc = Get-TestDesc $testFile.FullName $id
        $dst  = Join-Path $funcDir "F-${pad}_${desc}.lua"
        Write-Host "  $id/test.lua -> functional/F-${pad}_${desc}.lua"
        Do-GitMv $testFile.FullName $dst
        foreach ($e in ($luas | Where-Object { $_.Name -ne 'test.lua' })) {
            $eDst = Join-Path "$base\local" "F${pad}_$($e.Name)"
            Write-Host "  $id/$($e.Name) -> local/F${pad}_$($e.Name)  [diag]"
            Do-GitMv $e.FullName $eDst
        }
    } else {
        foreach ($lua in $luas) {
            $desc = Get-TestDesc $lua.FullName $id
            $dst  = Join-Path $funcDir "F-${pad}_${desc}.lua"
            Write-Host "  $id/$($lua.Name) -> functional/F-${pad}_${desc}.lua"
            Do-GitMv $lua.FullName $dst
        }
    }
}

# ── Remove empty U-/F- directories ──────────────────────────────────────────
$emptyDirs = Get-ChildItem -Path $base -Directory |
    Where-Object { $_.Name -match '^[UF]-\d+$' } |
    Where-Object { (Get-ChildItem $_.FullName -Recurse -File).Count -eq 0 }
foreach ($d in $emptyDirs) {
    Write-Host "  rmdir $($d.Name)"
    Remove-Item $d.FullName -Recurse -Force
}

Write-Host "`nDone. Verify with: git diff --stat HEAD"
