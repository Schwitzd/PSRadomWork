#Remote Bios List
gwmi -class Lenovo_BiosSetting -namespace root\wmi -ComputerName foo | ForEach-Object {if ($_.CurrentSetting -ne '') {Write-Output $_.CurrentSetting.replace(',',' = ')}}

#Remote Bios Item
gwmi -class Lenovo_BiosSetting -namespace root\wmi -ComputerName foo | Where-Object {$_.CurrentSetting.split(',',[StringSplitOptions]::RemoveEmptyEntries) -eq 'Wake On LAN'} | Format-List CurrentSetting