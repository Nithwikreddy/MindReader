# Generate 49 random dates between Oct 1, 2024 and Sep 30, 2025
$start = Get-Date "2024-10-01"
$end = Get-Date "2025-09-30"
$dates = @()
for ($i = 0; $i -lt 49; $i++) {
    $randomDays = Get-Random -Minimum 0 -Maximum (($end - $start).Days + 1)
    $date = $start.AddDays($randomDays)
    $dates += $date.ToString("yyyy-MM-ddTHH:mm:ss")
}
$dates = $dates | Sort-Object

# Generate deletion amounts totaling 5000 lines, non-uniform, 48 deletions
$deletions = @()
$total = 5000
for ($i = 0; $i -lt 47; $i++) {
    $maxDel = [math]::Min(1000, $total - (47 - $i))
    $del = Get-Random -Minimum 1 -Maximum ($maxDel + 1)
    $deletions += $del
    $total -= $del
}
$deletions += $total

# Create dummy.txt with 5000 lines
$content = 1..5000 | ForEach-Object { "line $_" }
$content | Out-File -FilePath dummy.txt -Encoding UTF8

# First commit: add dummy.txt
git add dummy.txt
$env:GIT_AUTHOR_DATE = $dates[0]
$env:GIT_COMMITTER_DATE = $dates[0]
git commit -m "Initial commit: Add dummy file with 5000 lines"

# 48 deletion commits
for ($i = 0; $i -lt 48; $i++) {
    $lines = Get-Content dummy.txt
    $skip = $deletions[$i]
    if ($lines.Count -gt $skip) {
        $newLines = $lines | Select-Object -Skip $skip
    } else {
        $newLines = @()
    }
    $newLines | Out-File -FilePath dummy.txt -Encoding UTF8
    git add dummy.txt
    $env:GIT_AUTHOR_DATE = $dates[$i]
    $env:GIT_COMMITTER_DATE = $dates[$i]
    git commit -m "Delete $($deletions[$i]) lines"
}

# Remove dummy.txt
Remove-Item dummy.txt
git add -A
git commit -m "Remove dummy file and add project files"