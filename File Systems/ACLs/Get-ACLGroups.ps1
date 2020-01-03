Function Get-aclGroups
{
  <# 
  .SYNOPSIS 
    Get all ACL Groups for a Directory Path.
  
  .DESCRIPTION 
    Get all ACL Groups for a Directory and its subfolders.
  
  .PARAMETER Path
    Path Name.
  
  .PARAMETER Depth
    Subfolders level, default is 2.
    
  .EXAMPLE 
    PS C:\> Get-aclGroups -Path C:\temp -Depth 2

  .NOTES 
    Author:    Daniel Schwitzgebel
    Created:   25/09/2018
    Modified:  25/09/2018
    Version:   1.1
  #>
  
  param ( 
    [Parameter(Mandatory)] 
    [String]
    $Path,

    [Parameter()]
    [int]
    $Depth = 2
  )

  $aclGroups = [System.Collections.ArrayList]@()
  $identityExcluded = @(
    'BUILTIN\Administrators',
    'BUILTIN\Users',
    'CREATOR OWNER',
    'NT AUTHORITY\SYSTEM',
    'NT AUTHORITY\Authenticated Users',
    'HUGOBOSS\Domain Admins'
  )

  $folders = Get-ChildItem -Path $Path -Directory -Depth $Depth

  foreach ($folder in $folders)
  {
    $acls = Get-Acl $folder.FullName

    foreach ($ACL in $acls.Access)
    {
      if ($identityExcluded -notcontains $ACL.IdentityReference)
      {
        if ($aclGroups -notcontains $ACL.IdentityReference)
        {
          [void]$aclGroups.Add($ACL.IdentityReference)
        }
      }
    }
  }
  $aclGroups
}