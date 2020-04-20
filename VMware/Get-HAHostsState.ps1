function Get-HAHostsState 
{
    <#
    .SYNOPSIS 
        This function will get information about the hosts HA state.
    
    .DESCRIPTION 
        This function will get information about master/slave status of the hosts HA.
    
    .PARAMETER vCenter
        Specifies the address of the vCenter server.
    
    .EXAMPLE 
        PS C:\> Get-HAHostsStatus -vCenter vcenter01
        This command gets details about hosts HA state.
    
    .NOTES 
        Author:     Daniel Schwitzgebel
        Created:    20/04/2020
        Modified:   20/04/2020
        Version:    1.0
    #>

    [OutputType([System.Management.Automation.PSCustomObject])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]
        $vCenter        
    )
    
    begin
    {
        try
        { 
            $null = Connect-VIServer -Server $vCenter -Force -ErrorAction Stop
        }
        catch
        {
            throw $_.Exception.Message
        }   
    }
    
    process
    {
        Get-Cluster -PipelineVariable cluster | Get-VMHost | ForEach-Object {
            
            $haHostState = $_.ExtensionData.Runtime.DasHostState.State

            if ($haHostState -eq 'connectedToMaster')
            {
                $state = 'Slave'
            }
            else
            {
                $state = 'Master'
            }

            [PSCustomObject]@{
                Cluster = $cluster.Name
                Host    = $_.Name
                State   = $state
            }
        }  
    }
    
    end
    {
        try
        { 
            $null = Disconnect-VIServer -Server $vCenter -Confirm:$false  
        }
        catch
        {
            throw $_.Exception.Message
        }   
    }
}