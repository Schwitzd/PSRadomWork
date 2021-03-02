function New-Share
{
    <# 
  .SYNOPSIS 
    This function will create a file system share.
  
  .DESCRIPTION 
    This function read will create a file system share with predefined properties.
  
  .PARAMETER Name 
    Specifies the name of the share

  .PARAMETER Path 
    Specifies the path of the share
    
  .EXAMPLE 
    New-Share -Path 'c:\temp\foo' -Name 'foo$'
    This command create a new share
  
  .NOTES
    Author:    Daniel Schwitzgebel
    Created:   01/03/2021
    Modified:  01/03/2021
    Version:   1.0
  #>
    
    [OutputType([Void])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String]
        $Name,

        [Parameter(Mandatory)]
        [String]
        $Path
    )

    if (Test-Path $Path)
    {
        Write-Verbose -Message "Path $Path exists"

        $newSmbShare = @{
            Path         = $Path
            Name         = $Name
            ChangeAccess = 'NT AUTHORITY\Authenticated Users'
        }
        
        $null = New-SmbShare @newSmbShare
        Write-Verbose -Message "Creating the new share $Name"
    }  
    else
    {
        throw -Message "Folder $Path not found"    
    }
}