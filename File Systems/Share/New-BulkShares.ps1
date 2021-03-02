function New-BulkShares {
    <# 
  .SYNOPSIS 
    This function will create multiple share in bulk.
  
  .DESCRIPTION 
    This function read a json file with all the information to create shares in bulk.
  
  .PARAMETER SharesFile 
    Specifies the file path with all shares information
    
  .EXAMPLE 
    New-BulkShares -ShareFile c:\temp\share.json
    This command create shares in bulk
  
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
        [validatescript({ (Get-Item $_).Extension -eq '.json' })]
        [String]
        $SharesFile    
    )

    $shares = Get-Content $SharesFile -Raw | ConvertFrom-Json
    Write-Verbose -Message "Importing bulk shares from json file $SharesFile"

    foreach ($share in $shares)
    {
        if (Test-Path $share.SharePath)
        {
            Write-Verbose -Message "Path $share.SharePath exists"

            $newSmbShare = @{
                Path         = $share.SharePath
                Name         = $share.ShareName
                ChangeAccess = 'NT AUTHORITY\Authenticated Users'
            }
        
            $null = New-SmbShare @newSmbShare
            Write-Verbose -Message "Creating the new share $share.ShareName"
        }  
        else
        {
            Write-Error -Message "Folder $share.ShareName not found"    
        }
    }
}