Function Get-IISApplicationPoolsCredential
{
    <#
    .SYNOPSIS 
        Get credentials used in a Specific ApplicationPool in IIS.
    
    .DESCRIPTION 
        Get credentials used in a Specific ApplicationPool in IIS by connecting to the remote host.
    
    .PARAMETER ComputerName
        IIS Server name.
    
    .EXAMPLE 
        Get-IISApplicationPoolsCredential -ComputerName foo
    
    .NOTES 
        Author:    Daniel Schwitzgebel
        Created:   28/11/2018
        Modified:  28/11/2018
        Version:   1.0
        Changes:   
    #>

    [OutputType([System.Management.Automation.PSCustomObject])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]
        $ComputerName
    )

    begin 
    {
        try
        {
            $appPools = Invoke-Command -ComputerName $ComputerName -ScriptBlock {
                Get-WebConfiguration -Filter '/system.applicationHost/applicationPools/add'
            }
        }
        catch
        {
            throw 'error connecting to the host or IIS not installed'
        }
    }
     
    process
    {
        foreach ($appPool in $appPools)
        {
            if ($appPool.ProcessModel.identityType -eq 'SpecificUser')
            {
                [PSCustomObject]@{
                    'Pool Name' = $appPool.Name
                    Username    = $appPool.ProcessModel.UserName
                    Password    = $appPool.ProcessModel.Password
                }
            }
        }
    }
}
