$sourcePath = ''
$exportPath = ''
$last = 50

Get-ChildItem -Path $sourcePath -Recurse -File -Exclude 'thumb.db' | 
    Sort-Object LastWriteTime | Select-Object LastWriteTime, Fullname -Last $last | 
        Export-Csv $exportPath