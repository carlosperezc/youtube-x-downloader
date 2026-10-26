$inputpath = "\\nas01\Downloads\"
$outputpath = "$inputpath\converted\"
Get-ChildItem "$Inputpath\*.mkv"| ForEach-Object {
    ffmpeg -i $_.FullName -c:v libx264 -crf 23 -preset medium "$outputpath\$($_.BaseName).mp4"
}
