
# Path to the file that contains the lines to process
$playlistFilePath = ".\playlist.txt"


# Program you want to run for each line
$ytDlpExecutable = ".\yt-dlp.exe "

# Path to the playlist history file
$playlistHistoryFilePath = "$($playlistFilePath)_history.txt"

# Read all lines
$playlistLines = Get-Content $playlistFilePath

# If file is empty, exit
if ($playlistLines.Count -eq 0) {
    Write-Host "File is empty. Nothing to process."
    exit
}

# Log current operation to history file
$currentDateTime = (Get-Date).ToString()
$historyHeader = @()
$historyHeader += ""
$historyHeader += "$currentDateTime ---------------------"
Add-Content -Value $historyHeader -Path $playlistHistoryFilePath

foreach ($playlistUrl in $playlistLines) {
    # Skip empty lines if needed
    if ([string]::IsNullOrWhiteSpace($playlistUrl)) {
        continue
    }

    Write-Host "Processing: $playlistUrl"

    # Run the program with the line as parameter
    & $ytDlpExecutable $playlistUrl -f "bv*+ba/b" --write-subs --sub-langs fr,en,es,sp --merge-output-format mkv --cookies www.youtube.com_cookies.txt
    Remove-Item *.vtt

    # Log the processed line to the history file
    Add-Content -Value $playlistUrl -Path $playlistHistoryFilePath
}


add-content -value "Processing complete." -Path $playlistHistoryFilePath
# Clear playlist file for next run
New-Item $playlistFilePath -ItemType File -Force | Out-Null


# --- CONFIGURATION ---
$sourceFolder = "F:\yt-dl"
$destinationFolder = "\\nas01\Multimedia\Videos\MusicVideos\Downloaded"

# Create destination folder if it doesn't exist
if (!(Test-Path $destinationFolder)) {
    New-Item -ItemType Directory -Path $destinationFolder | Out-Null
}

# Get all MKV files
$mkvFiles = Get-ChildItem -Path $sourceFolder -Filter *.mkv -File

add-content -value "Found $($mkvFiles.Count) MKV files to process." -Path $playlistHistoryFilePath
s
foreach ($mkvFile in $mkvFiles) {
    $sourcePath = $mkvFile.FullName
    $destinationPath = Join-Path $destinationFolder $mkvFile.Name
    Add-Content -Value "Copying $sourcePath → $destinationPath" -Path $playlistHistoryFilePath
    Write-Host "Copying $sourcePath → $destinationPath"

    # Copy file
    Copy-Item -Path $sourcePath -Destination $destinationPath -Force

    # Verify copy succeeded by comparing file sizes
    $sourceSize = (Get-Item $sourcePath).Length
    $destinationSize = (Get-Item $destinationPath).Length
    
    if ($sourceSize -eq $destinationSize) {
        Add-Content -Value "✓ Verified. Deleting original file: $sourcePath" -Path $playlistHistoryFilePath
        Write-Host "✓ Verified. Deleting original file: $sourcePath"
        Remove-Item $sourcePath
    }
    else {
        Add-Content -Value "✗ Verification FAILED for $sourcePath — original NOT deleted" -Path $playlistHistoryFilePath
        Write-Host "✗ Verification FAILED for $sourcePath — original NOT deleted"
    }
}
