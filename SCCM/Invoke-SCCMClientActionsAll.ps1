Function Invoke-SCCMClientActionsAll
{
    <#
    .SYNOPSIS
        Triggers a ConfigMgr Client Cycle Action on a remote computer.
        
    .DESCRIPTION
        Triggers a ConfigMgr Client cycle action on a remote computer. 
        Accepts pipeline input for computer name so can be run against many machines or in a script.
            
    .PARAMETER Computername
        The name of the target computer
            
    .EXAMPLE
        Invoke-CMClientActionAll -Computername DC01
    
    .NOTES 
        Author:     Daniel Schwitzgebel
        Created:    20/01/2018
        Modified:   20/12/2019
        Version:    1.3
    #>

    [OutputType([void])]
    [CmdletBinding()] 
    param( 
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [String]
        $ComputerName
    ) 

    begin
    {
        $scheduleIDMappings = @{
            'ApplicationDeploymentEvaluation'     = '{00000000-0000-0000-0000-000000000121}'
            'DiscoveryDataCollection'             = '{00000000-0000-0000-0000-000000000003}'
            'FileCollection'                      = '{00000000-0000-0000-0000-000000000010}'
            'HardwareInventory'                   = '{00000000-0000-0000-0000-000000000001}'
            'MachinePolicyRetrievalandEvaluation' = '{00000000-0000-0000-0000-000000000021}'
            'SoftwareInventory'                   = '{00000000-0000-0000-0000-000000000002}'
            'SoftwareMeteringUsageReport'         = '{00000000-0000-0000-0000-000000000031}'
            'SoftwareUpdatesDeploymentEvaluation' = '{00000000-0000-0000-0000-000000000108}'
            'SoftwareUpdatesScan'                 = '{00000000-0000-0000-0000-000000000113}'
            'WindowsInstallerSourceListUpdate'    = '{00000000-0000-0000-0000-000000000032}'
        }
    }

    process
    {
        try
        {
            $scheduleIDMappings.GetEnumerator() | ForEach-Object {
                $invokeWmiMethodParams = @{
                    ComputerName = $ComputerName
                    Namespace    = 'root\CCM'
                    Class        = 'SMS_Client'
                    Name         = 'TriggerSchedule'
                    ArgumentList = $_.Value
                    ErrorAction  = 'Stop'
                }
                    
                $null = Invoke-WmiMethod @invokeWmiMethodParams
            }
        }
        catch
        {
            throw $_.Exception.Message
        }
    }
}