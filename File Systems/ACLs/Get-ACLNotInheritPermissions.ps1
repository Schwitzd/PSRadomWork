function Get-ACLNotInheritPermissions
{
  <#
  .SYNOPSIS 
    Get all paths with not Inherit Permissions.
  
  .DESCRIPTION 
    Loop true a folder structure and get all paths with not Inherit Permissions.
  
  .PARAMETER Path
    Path Name.
  
  .EXAMPLE 
    PS C:\> Get-ACLNotInheritPermissions -Path C:\temp

  .NOTES 
    Author:     Daniel Schwitzgebel
    Created:    25/09/2019
    Modified:   25/09/2019
    Version:    1.1
    Changes:    1.1   Change - Code restyle
  #>

  param ( 
    [Parameter(Mandatory)] 
    [String]
    $Path
  )

  Get-ChildItem -Path $Path -Recurse -Directory | 
    Select-Object @{
      Name = 'Path'; Expression = { $_.FullName } }, 
      @{ Name = 'InheritedCount'; Expression = { (Get-Acl $_.FullName |
            Select-Object -ExpandProperty Access | Where-Object { $_.IsInherited }).Count 
        }
      } | Where-Object { $_.InheritedCount -eq 0 } | Select-Object Path
}