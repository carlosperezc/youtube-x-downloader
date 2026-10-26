
# Path to the CSV file that contains the data to process
$csvFile = "$PSScriptRoot\bookmarks.csv"

# Program you want to run for each link
$program = "$PSScriptRoot\..\yt-dlp.exe"

#Cookies file path
$cookiesFilePath = "$PSScriptRoot\x.com_cookies.txt"

# Read all rows from the CSV (skipping header automatically)
$rows = Import-Csv $csvFile


# If CSV is empty, exit
if ($rows.Count -eq 0) {
    Write-Host "CSV file is empty. Nothing to process."
    exit
}

set-location -path "$PSScriptRoot\extractions"

$links = $rows | Where-Object { -not [string]::IsNullOrWhiteSpace($_.Link) } | Select-Object -ExpandProperty Link

foreach ($link in $links) {
    Write-Host "Processing: $link"
    & $program $link --merge-output-format mp4 --cookies $cookiesFilePath
    Remove-Item *.vtt 
}
$dt = (get-date).tostring()
Add-Content -Value "" -Path "$($csvFile)_history.txt" 
Add-Content -Value "$dt ---------------------" -Path "$($csvFile)_history.txt" 
Add-Content -Value ($links -join "`n") -Path "$($csvFile)_history.txt" 
New-Item $csvFile -ItemType File -Force | Out-Null