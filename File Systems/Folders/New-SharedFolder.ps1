function New-SharedFolder
{
    <# 
    .SYNOPSIS 
        Create a new SMB Share.
    
    .DESCRIPTION 
        Create a new SMB Share with share permission and grant access to Authenticated Users.
            
    .PARAMETER EnumerateFolder
        Enable Access Base Enumeration.

    .PARAMETER FolderName
        Specifies the name of the folder to share. 

    .PARAMETER Path
        Specifies the path of the share.
            
    .PARAMETER ShareName
        Specifies the name of the the share. 
    
    .EXAMPLE 
        PS C:\> New-ShareFolder -Path 'c:\temp' -FolderName 'test' -ShareName 'test$'
        This command creates a new share named 'test'.

    .EXAMPLE 
        PS C:\> New-ShareFolder -Path 'c:\foo' -FolderName 'foo' -ShareName 'foo$' -EnumerateFolder
        This command creates a new share named 'foo' with Access Base Enumaration enabled.

    .NOTES 
        Author:     Daniel Schwitzgebel
        Created:    02/04/2020
        Modified:   11/04/2020
        Version:    1.0.2
  #> 

    [OutputType([Void])]
    [CmdletBinding()]
    param (
        [Parameter()]
        [Switch]
        $EnumerateFolder,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]
        $FolderName,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Path,
      
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]
        $ShareName
    )

    process
    {
        if (-not (Test-Path -Path "$Path\$FolderName"))
        {
            $null = New-Item -ItemType Directory -Path $Path -Name $FolderName
            Write-Verbose -Message "Creating folder $Path\$FolderName"
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
            Write-Verbose -Message "Creating the share."
        
        }
        catch 
        {
            throw "Failed to create $($ShareName)"
        }

        try
        {
            Revoke-SmbShareAccess -Name $ShareName -AccountName 'Everyone' -Force
            Write-Verbose -Message "Removing Everyone Account from the share."
        }
        catch
        {
            throw 'Failed to remove Everyone permission on the share'
        }
    }
}