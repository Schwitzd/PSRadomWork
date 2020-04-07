function Remove-ProfileItem
{
    <#
	.SYNOPSIS
        This function removes a file(s) or folder(s) with the same path in all user profiles (also AllUsers).

	.DESCRIPTION
        This function removes a file(s) or folder(s) with the same path in all user profiles (also AllUsers)
        excluding system profiles like SYSTEM, NetworkService.
        
    .PARAMETER Path
       The path(s) to the file or folder you'd like to remove.
    
    .EXAMPLE
		PS> Remove-ProfileItem -Path 'AppData\foo'
        This example will remove the folder path 'AppData\foo' from all user profiles
    
    .NOTES 
        Author:     Daniel Schwitzgebel
        Created:    27/11/2019
        Modified:   11/12/2019
        Version:    1.1
    #>
    
    [OutputType([void])]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Path
    )
			
    $allUserProfileFolderPath = $env:Public
    $userProfileFolderPaths = Get-UserProfilePath
			
    foreach ($p in $Path)
    {
        if (Test-Path -Path "$allUserProfileFolderPath\$p")
        {
            if ($PSCmdlet.ShouldProcess("$allUserProfileFolderPath\$p", 'Remove Item'))
            {
                Remove-Item -Path "$allUserProfileFolderPath\$p" -Force -Recurse
            }
        }
			
        foreach ($ProfilePath in $userProfileFolderPaths)
        {
            if (Test-Path "$ProfilePath\$p")
            {
                if ($PSCmdlet.ShouldProcess("$ProfilePath\$p", 'Remove Item'))
                {
                    Remove-Item -Path "$ProfilePath\$p" -Force -Recurse
                }
            }
        }       
    }
}