Function Get-FoldersWithoutAccess
{
  <#
  .SYNOPSIS 
    Get all Folders with Access Denied.
  
  .DESCRIPTION 
    Get all Folders with Access Denied. This script must but rus as Administrator on a fileserver.
    This means that output will be the folders without permissions.
  
  .PARAMETER Path
    Specified the path.
  
  .EXAMPLE 
    PS C:\> Get-FoldersWithoutAccess -Path C:\temp
    This command gets the path of the folders without permissions. 

  .NOTES 
    Author:    Daniel Schwitzgebel
    Created:   14/11/2018
    Modified:  09/04/2020
    Version:   1.1.1
  #>
  
  param ( 
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [String]
    $Path
  )

  $null = Get-ChildItem -Path $Path -Recurse -ErrorAction SilentlyContinue -ErrorVariable $withoutAccess
  Write-Output $withoutAccess.TargetObject
}