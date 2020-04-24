function Import-MyScheduledTask {
    <#
    .SYNOPSIS 
        This function will import scheduled tasks.
  
    .DESCRIPTION 
        This function will import scheduled tasks from XML file.
  
    .PARAMETER Path 
        Specifies the path to export the XML.
    
    .EXAMPLE 
        PS C:\> Import-MyScheduledTask -Path 'c:\temp\foo.xml'
        This command import the specified scheduled task.
  
    .NOTES
        Author:    Daniel Schwitzgebel
        Created:   24/04/2020
        Modified:  24/04/2020
        Version:   1.0
    #>

    [OutputType([Void])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String]
        $Path
    )
    
    [xml]$xmlTask = Get-Content -Path $Path
    $taskName = [io.path]::GetFileNameWithoutExtension($Path)
    $taskusername = $xmlTask.Task.Principals.Principal.UserId
    [pscredential]$cred = (Get-Credential -UserName $taskusername)

    schtasks.exe /Create /XML $Path /TN $taskName /RU $taskusername /RP $cred.getNetworkCredential().password

}