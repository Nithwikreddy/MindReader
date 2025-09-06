# Initialize git if not already
if (!(Test-Path .git)) {
    git init
}

# Create a large dummy file with 10000 lines
1..10000 | ForEach-Object { "Dummy line $_" } | Set-Content dummy.txt

# Initial commit
git add dummy.txt
git commit -m "Initial commit" --date "2025-10-01T00:00:00"

# Track deletions
$deletions = 0

# Loop for 72 commits
for ($i = 1; $i -le 72; $i++) {
    # Generate random date between Oct 1 and Nov 30, 2025
    $startDate = Get-Date "2025-10-01"
    $endDate = Get-Date "2025-11-30"
    $randomTicks = Get-Random -Minimum $startDate.Ticks -Maximum $endDate.Ticks
    $date = New-Object DateTime $randomTicks
    $dateStr = $date.ToString("yyyy-MM-ddTHH:mm:ss")

    # Randomly choose add or delete
    $action = Get-Random -InputObject @("add", "delete")

    if ($action -eq "delete" -and $deletions -lt 7865) {
        # Calculate lines to delete
        $maxDelete = [math]::Min(200, 7865 - $deletions)
        $linesToDelete = Get-Random -Minimum 50 -Maximum $maxDelete

        # Read current content
        $content = Get-Content dummy.txt
        $totalLines = $content.Count

        if ($totalLines -gt $linesToDelete) {
            # Select random lines to keep
            $keepCount = $totalLines - $linesToDelete
            $indices = 0..($totalLines - 1) | Get-Random -Count $keepCount | Sort-Object
            $newContent = $indices | ForEach-Object { $content[$_] }
            $newContent | Set-Content dummy.txt

            $deletions += $linesToDelete

            git add dummy.txt
            git commit -m "Delete $linesToDelete lines" --date $dateStr
        }
    } elseif ($action -eq "add") {
        # Add random lines
        $linesToAdd = Get-Random -Minimum 50 -Maximum 200
        $newLines = 1..$linesToAdd | ForEach-Object { "Added line $_ in commit $i" }
        $newLines | Add-Content dummy.txt

        git add dummy.txt
        git commit -m "Add $linesToAdd lines" --date $dateStr
    }
}

# Remove dummy file
Remove-Item dummy.txt

# Add all project files
git add -A
git commit -m "Add project files" --date "2025-12-01T00:00:00"

# Add remote and push
git remote add origin https://github.com/Nithwikreddy/DriveBidRent.git
git push -u origin main