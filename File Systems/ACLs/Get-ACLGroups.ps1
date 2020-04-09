Function Get-aclGroups
{
  <# 
  .SYNOPSIS 
    Get all ACL Groups for a Directory Path.
  
  .DESCRIPTION 
    Get all ACL Groups for a Directory and its subfolders.
  
  .PARAMETER Depth
    Specifies the subfolders level, default is 2.

  .PARAMETER Path
   Specifies the path name.
    
  .EXAMPLE 
    PS C:\> Get-aclGroups -Path 'C:\temp' -Depth 2
    This command gets all the ACL groups for the given path.

  .NOTES 
    Author:    Daniel Schwitzgebel
    Created:   25/09/2018
    Modified:  09/04/2020
    Version:   1.2
  #>
  
  [OutputType([System.Security.Principal.NTAccount])]
  [CmdletBinding()]
  param( 
    [Parameter(Mandatory)] 
    [String]
    $Path,

    [Parameter()]
    [int]
    $Depth = 2
  )

  begin
  {
    $aclGroups = [System.Collections.ArrayList]@()
    $identityExcluded = @(
      'BUILTIN\Administrators',
      'BUILTIN\Users',
      'CREATOR OWNER',
      'NT AUTHORITY\SYSTEM',
      'NT AUTHORITY\Authenticated Users',
      "$env:USERDOMAIN\Domain Admins"
    )

    $folders = Get-ChildItem -Path $Path -Directory -Depth $Depth
  }
  
  process
  {
    foreach ($folder in $folders)
    {
      $acls = Get-Acl $folder.FullName

      foreach ($acl in $acls.Access)
      {
        if ($identityExcluded -notcontains $acl.IdentityReference)
        {
          if ($aclGroups -notcontains $acl.IdentityReference)
          {
            [void]$aclGroups.Add($acl.IdentityReference)
          }
        }
      }
    }
  }

  end
  {
    $aclGroups
  }  
}