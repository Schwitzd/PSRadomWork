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
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
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
        $pathToRemove = "$allUserProfileFolderPath\$p"
        if (Test-Path -Path $pathToRemove)
        {
            if ($PSCmdlet.ShouldProcess($pathToRemove, 'Remove Item'))
            {
                Remove-Item -Path $pathToRemove -Force -Recurse
                Write-Verbose -Message "Removing $pathToRemove"
            }
        }
			
        foreach ($ProfilePath in $userProfileFolderPaths)
        {
            $pathToRemove = "$ProfilePath\$p"
            if (Test-Path -Path $pathToRemove)
            {
                if ($PSCmdlet.ShouldProcess($pathToRemove, 'Remove Item'))
                {
                    Remove-Item -Path $pathToRemove -Force -Recurse
                    Write-Verbose -Message "Removing $pathToRemove"
                }
            }
        }       
    }
}