Function Get-FoldersWithoutAccess
{
  <#
  .SYNOPSIS 
    Get all Folders with Access Denied.
  
  .DESCRIPTION 
    Get all Folders with Access Denied. This script must but rus as Administrator on a fileserver.
    This means that output will be the folders without permissions.
  
  .PARAMETER Path
    Path Name.
  
  .EXAMPLE 
    PS C:\> Get-FoldersWithoutAccess -Path C:\temp

  .NOTES 
    Author:    Daniel Schwitzgebel
    Created:   14/11/2018
    Modified:  10/12/2019
    Version:   1.1
    Changes:   1.1  Add    - Function OutputType and parameter validation
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