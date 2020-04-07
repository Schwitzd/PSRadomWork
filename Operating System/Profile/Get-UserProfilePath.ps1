function Get-UserProfilePath
{
    <#
	.SYNOPSIS
		This function find the folder path of a user profile based on a number of different criteria.

    .DESCRIPTION
        This function find the folder path of a user profile based on a number of different criteria. 
        If no criteria is used, it will return all user profile paths except the system profiles.
            
	.PARAMETER Sid
         The user SID.
         
	.PARAMETER Username
        The username.
        
	.EXAMPLE
		PS> Get-UserProfilePath -Sid 'S-1-5-21-350904792-1544991288-1862953342-43987'	
        This example finds the user profile path based on the user's SID
        
	.EXAMPLE
		PS> Get-UserProfilePath -Username 'foo'
        This example finds the user profile path based on the username
        
    .NOTES 
        Author:    Daniel Schwitzgebel
        Created:   27/11/2019
        Modified:  27/11/2019
        Version:   1.0
    #>
    
    [OutputType([string])]
    [CmdletBinding(DefaultParameterSetName = 'None')]
    param (
        [Parameter(ParameterSetName = 'SID')]
        [string]
        $Sid,
		
        [Parameter(ParameterSetName = 'Username')]
        [string]
        $Username
    )
	
    process
    {
        if ($Sid)
        {
            $whereBlock = { $_.PSChildName -eq $Sid }
        }
        elseif ($Username)
        {
            $whereBlock = { $_.GetValue('ProfileImagePath').Split('\')[-1] -eq $Username }
        }
        else
        {
            $whereBlock = { $_.PSChildName -notmatch 'S-1-5-(18|19|20)' }
        }
        
        Get-ChildItem 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\ProfileList' | 
            Where-Object $whereBlock | ForEach-Object { $_.GetValue('ProfileImagePath') }
    }
}