function Get-HADetails
{
    <#
    .SYNOPSIS 
        This function will get detailed information about HA status.
    
    .DESCRIPTION 
        This function will get detailed information about HA Status for all clusters in a given vCenter.
    
    .PARAMETER vCenter
        Specifies the address of the vCenter server.
    
    .EXAMPLE 
        PS C:\> Get-HADetails -vCenter vcenter01
        This command gets details about the HA Clusters status.
    
    .NOTES 
        Author:     Daniel Schwitzgebel
        Created:    20/04/2020
        Modified:   20/04/2020
        Version:    1.0

    .LINK
        https://code.vmware.com/forums/2530/vsphere-powercli#579473
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
        try
        {
            Get-Cluster | ForEach-Object {

                $haDasConfig = $_.ExtensionData.Configuration.DasConfig
                $haAdminsionControlConfig = $_.ExtensionData.Configuration.DasConfig.AdmissionControlPolicy
                $haDefaultVmSettings = $_.ExtensionData.Configuration.DasConfig.DefaultVmSettings
                
                $haHostFailoverCapacity = switch ($haAdminsionControlConfig.GetType().Name)
                {
                    'ClusterFailoverHostAdmissionControlPolicy' { 'Dedicated Failover Hosts (H)' }
                    'ClusterFailoverResourcesAdmissionControlPolicy' { 'Cluster Resource Percentage (R)' }
                    'ClusterFailoverLevelAdmissionControlPolicy' { 'Slot Policy (s)' }
                }

                $haOverrideCalculatedFailover = switch ($haAdminsionControlConfig.AutoComputePercentages)
                {
                    $true { $true }
                    $false { 'False (R-O)' }
                }

                if ($haAdminsionControlConfig.FailOverHosts)
                {
                    $getViewParam = @{
                        ID       = $haAdminsionControlConfig.FailOverHosts
                        Property = 'Name'
                    }

                    $haFailoverHosts = (Get-View @getViewParam).Name -join ','
                }

                $haSlotPolicy = if ($haAdminsionControlConfig.SlotPolicy)
                {
                    'Fixed Slot Size (S-F)'
                }
                else
                {
                    'Cover all powered-on VM'
                }

                $haHearthbeatDatastorePolicy = switch ($haDasConfig.HBDatastoreCandidatePolicy)
                {
                    'allFeasibleDs' { 'Automatically select datastores accessible from the host' }
                    'allFeasibleDsWithUserPreference' { 'Use datastores from the specified list and complement automatically (L)' }
                    'userSelectedDs' { 'Use datastores only from the specified list (L)' }
                }

                if ($haDasConfig.HeartbeatDatastore)
                {
                    $getViewParam = @{
                        ID       = $haDasConfig.HeartbeatDatastore
                        Property = 'Name'
                    }

                    $haHearthbeatDatastore = (Get-View @getViewParam).Name -join ','
                }

                $haHostFailureResponse = switch ($haDasConfig.RestartPriority)
                {
                    'disabled' { 'Disabled' }
                    default { 'Restart VMs' }
                }

                [PSCustomObject]@{
                    'Cluster Name'                                           = $_.Name
                    'HA Admission Control'                                   = $_.HAAdmissionControlEnabled
                    'Host failures cluster tolerates'                        = $haAdminsionControlConfig.FailOverLevel
                    'Define host failover capacity by'                       = $haHostFailoverCapacity
                    '(H) Failover Hosts'                                     = $haFailoverHosts
                    '(R) Override calculated failover capacity'              = $haOverrideCalculatedFailover
                    '(R-O) CPU %'                                            = $haAdminsionControlConfig.CpuFailoverResourcesPercent
                    '(R-O) Memory %'                                         = $haAdminsionControlConfig.MemoryFailoverResourcesPercent
                    '(S) Slot Policy'                                        = $haSlotPolicy
                    '(S-F) CPU MhZ'                                          = $haAdminsionControlConfig.SlotPolicy.Cpu
                    '(S-F) Memorya MB'                                       = $haAdminsionControlConfig.SlotPolicy.Memory
                    'HA Admission Policy ResourceReductionToToleratePercent' = $haAdminsionControlConfig.ResourceReductionToToleratePercent
                    'Hearthbeat Datastore Policy'                            = $haHearthbeatDatastorePolicy
                    '(L) Hearthbeat Datastore'                               = $haHearthbeatDatastore
                    'Host Monitoring'                                        = $haDasConfig.HostMonitoring
                    'Host Failure Response'                                  = $haHostFailureResponse
                    'Host Isolation Response'                                = $haDefaultVmSettings.IsolationResponse
                    'Datastore with PDL'                                     = $haDefaultVmSettings.VmComponentProtectionSettings.VmStorageProtectionForPDL
                    'Datastore with APD'                                     = $haDefaultVmSettings.VmComponentProtectionSettings.VmStorageProtectionForAPD
                    'VM Monitoring'                                          = $haDasConfig.VmMonitoring
                }
            }
        }
        catch
        {
            throw $_.Exception.Message  
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