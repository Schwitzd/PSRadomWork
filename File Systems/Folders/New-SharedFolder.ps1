function New-SharedFolder
{
    <# 
    .SYNOPSIS 
        Create a new SMB Share.
    
    .DESCRIPTION 
        Create a new SMB Share with share permission and grant access to Authenticated Users.
            
    .PARAMETER Path
        A description of the Path parameter.
        
    .PARAMETER FolderName
        Name of the folder to share. 
    
    .PARAMETER ShareName
        Name of the the share.
        
    .PARAMETER EnumerateFolder
        Enable Access Base Enumeration 
    
    .EXAMPLE 
        PS C:\> New-ShareFolder -Path 'c:\temp' -FolderName 'test' -ShareName 'test$'
    
    .NOTES 
        Author:     Daniel Schwitzgebel
        Created:    02/04/2020
        Modified:   02/04/2020
        Version:    1.0

  #> 

    [OutputType([Void])]
    [CmdletBinding()]
    param ( 
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Path,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]
        $FolderName,
      
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]
        $ShareName,

        [Parameter()]
        [Switch]
        $EnumerateFolder
    )

    process
    {
        if (-not (Test-Path "$Path\$FolderName"))
        {
            $null = New-Item -ItemType Directory -Path $Path -Name $FolderName
        }

        try
        {
            if ($EnumerateFolder)
            {
                $newSmbShareParam = @{
                    Path                  = "$Path\$FolderName"
                    Name                  = $ShareName
                    ChangeAccess          = 'Authenticated Users'
                    FolderEnumerationMode = 'AccessBased'
                }
            }
            else
            {
                $newSmbShareParam = @{
                    Path         = "$Path\$FolderName"
                    Name         = $ShareName
                    ChangeAccess = 'Authenticated Users'
                }   
            }

            $null = New-SmbShare @newSmbShareParam
        
        }
        catch 
        {
            throw "Failed to create $ShareName"
        }

        try
        {
            Revoke-SmbShareAccess -Name $ShareName -AccountName 'Everyone' -Force
        }
        catch
        {
            throw 'Failed to remove Everyone permission to the Share'
        }
    }
}