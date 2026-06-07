$base = 'C:\Users\Moi\Documents\GitHub\DCS-CTLD_FG\recette'
$emDash = [char]0x2014; $enDash = [char]0x2013

function Sanitize {
    param([string]$raw)
    $s = $raw

    # Strip "CTLD" prefix from class tokens, keep the rest  (e.g. CTLDBeaconManager → BeaconManager)
    $s = $s -replace '\bCTLD', ''
    $s = $s -replace '\bctld\.', ''

    # Literal em/en dash + arrow → space
    $s = $s.Replace($emDash, ' ').Replace($enDash, ' ').Replace([char]0x2192, ' ')

    # Accent removal via NFD decomposition
    $normalized = $s.Normalize([System.Text.NormalizationForm]::FormD)
    $sb = New-Object System.Text.StringBuilder
    foreach ($ch in $normalized.ToCharArray()) {
        if ([System.Globalization.CharUnicodeInfo]::GetUnicodeCategory($ch) -ne
            [System.Globalization.UnicodeCategory]::NonSpacingMark) {
            [void]$sb.Append($ch)
        }
    }
    $s = $sb.ToString()

    # All non-alphanumeric → space
    $s = $s -replace '[^a-zA-Z0-9]', ' '

    # Split into words, drop empty
    $words = ($s.Trim() -split '\s+') | Where-Object { $_.Length -gt 0 }
    if ($words.Count -eq 0) { return 'test' }

    # camelCase: lowercase first char of first word, keep rest; Title-case subsequent words
    $w0 = $words[0]
    if ($w0.Length -gt 1) { $result = $w0.Substring(0,1).ToLower() + $w0.Substring(1) }
    else                   { $result = $w0.ToLower() }

    for ($i = 1; $i -lt $words.Count; $i++) {
        $w = $words[$i]
        if ($w.Length -gt 1) { $result += $w.Substring(0,1).ToUpper() + $w.Substring(1) }
        else                  { $result += $w.ToUpper() }
    }

    if ($result.Length -gt 50) { $result = $result.Substring(0, 50) }
    return $result
}

function Extract-Desc {
    param([string]$file, [string]$id)
    $lines = Get-Content $file -Encoding UTF8 -ErrorAction SilentlyContinue | Select-Object -First 10
    $escaped = [regex]::Escape($id)
    foreach ($line in $lines) {
        # Normalise em/en dash to ':' before matching
        $norm = $line.Replace($emDash, ':').Replace($enDash, ':')
        if ($norm -match "^--\s+$escaped\s*:\s*(.+)") {
            return Sanitize $matches[1].Trim()
        }
    }
    return 'test'
}

Write-Host "=== U- tests ==="
$uDirs = Get-ChildItem -Path $base -Directory |
    Where-Object { $_.Name -match '^U-(\d+)$' } |
    Sort-Object { [int]($_.Name -replace 'U-','') }
foreach ($dir in $uDirs) {
    $num = [int]($dir.Name -replace 'U-',''); $pad = $num.ToString("000")
    $f = Join-Path $dir.FullName "test.lua"
    if (Test-Path $f) {
        $desc = Extract-Desc $f $dir.Name
        Write-Host "  $($dir.Name)  ->  unit/U-${pad}_${desc}.lua"
    }
}

Write-Host "`n=== F- tests ==="
$fDirs = Get-ChildItem -Path $base -Directory |
    Where-Object { $_.Name -match '^F-(\d+)$' } |
    Sort-Object { [int]($_.Name -replace 'F-','') }
foreach ($dir in $fDirs) {
    $num = [int]($dir.Name -replace 'F-',''); $pad = $num.ToString("000")
    $id  = $dir.Name
    $luas = Get-ChildItem $dir.FullName -Filter "*.lua" | Sort-Object Name
    $testFile = $luas | Where-Object { $_.Name -eq 'test.lua' } | Select-Object -First 1

    if ($testFile) {
        $desc = Extract-Desc $testFile.FullName $id
        Write-Host "  $id/test.lua  ->  functional/F-${pad}_${desc}.lua"
        foreach ($e in ($luas | Where-Object { $_.Name -ne 'test.lua' })) {
            Write-Host "    $id/$($e.Name)  ->  local/F${pad}_$($e.Name)  [diag]"
        }
    } else {
        foreach ($lua in $luas) {
            $desc = Extract-Desc $lua.FullName $id
            Write-Host "  $id/$($lua.Name)  ->  functional/F-${pad}_${desc}.lua"
        }
    }
}
