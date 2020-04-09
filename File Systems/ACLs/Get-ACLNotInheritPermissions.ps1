function Get-ACLNotInheritPermissions
{
  <#
  .SYNOPSIS 
    Get all paths with not Inherit Permissions.
  
  .DESCRIPTION 
    Loop true a folder structure and get all paths with not Inherit Permissions.
  
  .PARAMETER Path
    Specifies the path.
  
  .EXAMPLE 
    PS C:\> Get-ACLNotInheritPermissions -Path C:\temp
    This command gets the all the paths without Inherit Permissions.

  .NOTES 
    Author:     Daniel Schwitzgebel
    Created:    25/09/2019
    Modified:   09/04/2020
    Version:    1.1.1
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