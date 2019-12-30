<#
Name:	     Get-ClickOnceAppsFolder
Author:      Daniel Schwitzgebel
Created:     28/02/2019
Modified:    28/02/2019
Version:     1.0.0
Description: Get ClickOnce App Folder
Updates:
#>

$appToken  = Get-ItemPropertyValue -Path 'HKCU:\SOFTWARE\Classes\Software\Microsoft\Windows\CurrentVersion\Deployment\SideBySide\2.0' -Name 'ComponentStore_RandomString'
$dataToken = Get-ItemPropertyValue -Path 'HKCU:\SOFTWARE\Classes\Software\Microsoft\Windows\CurrentVersion\Deployment\SideBySide\2.0\StateManager' -Name 'StateStore_RandomString'
$rootPath = Join-Path -Path $env:LOCALAPPDATA -ChildPath 'Apps\2.0' 

if ($null -ne $appToken -and $null -ne $dataToken) {
    $appDir = $appToken.Substring(0, 8) + '.' + $appToken.Substring(8, 3) + '\' + $appToken.Substring(11, 8)
    $dataDir = 'data\' + $appToken.Substring(0, 8) + '.' + $appToken.Substring(8, 3) + '\' + $appToken.Substring(11, 8)
    Write-Output "Appdir: $rootPath\$appDir"
    Write-Output "Datadir: $rootPath\$dataDir"
}
