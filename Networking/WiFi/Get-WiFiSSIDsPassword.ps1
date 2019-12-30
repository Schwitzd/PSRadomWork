(netsh wlan show profiles) | Select-String “\:(.+)$” | 
ForEach-Object { $name = $_.Matches.Groups[1].Value.Trim(); $_ } | 
ForEach-Object { (netsh wlan show profile name=”$name” key=clear) } | 
Select-String “Key Content\W+\:(.+)$” | ForEach-Object { $pass = $_.Matches.Groups[1].Value.Trim(); $_ } | 
ForEach-Object { [PSCustomObject]@{ PROFILE_NAME = $name; PASSWORD = $pass } } | Format-Table -AutoSize