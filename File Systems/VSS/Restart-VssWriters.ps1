function Restart-VssWriter
{
    <# 
    .SYNOPSIS 
        This function restart a list of specified VSS writers.
  
    .DESCRIPTION 
        This function restart a list of specified VSS writers.
  
    .PARAMETER Name 
        Specifies the name of VSS Writer(s) to restart.
    
    .EXAMPLE
        Get-VSSWriters -Status 'Failed' | Restart-VssWriter
        This command gets the VSS writers in a failed state and restart it.

    .EXAMPLE
        Restart-VssWriter -Name 'BITS Writer'
        This command restarts the VSS Writer named 'BITS Writer'
  
    .NOTES
        Author:    Daniel Schwitzgebel
        Created:   22/06/2021
        Modified:  22/06/2021
        Version:   1.0
    #>

    [OutputType([void])]
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, Mandatory)]
        [String[]] 
        $Name
    )

    begin { }

    process
    {

        Write-Verbose -Message "Working on VSS Writer: $Name"

        switch ($Name)
        {
            'ASR Writer' { $vssServiceName = 'VSS' }
            'BITS Writer' { $vssServiceName = 'BITS' }
            'Certificate Authority' { $vssServiceName = 'EventSystem' }
            'COM+ REGDB Writer' { $vssServiceName = 'VSS' }
            'Dedup Writer' { $vssServiceName = 'ddpvssvc' }
            'DFS Replication service writer' { $vssServiceName = 'DFSR' }
            'DHCP Jet Writer' { $vssServiceName = 'DHCPServer' }
            'FRS Writer' { $vssServiceName = 'NtFrs' }
            'FSRM writer' { $vssServiceName = 'srmsvc' }
            'IIS Config Writer' { $vssServiceName = 'AppHostSvc' }
            'IIS Metabase Writer' { $vssServiceName = 'IISADMIN' }
            'Microsoft Exchange Replica Writer' { $vssServiceName = 'MSExchangeRepl' }
            'Microsoft Exchange Writer' { $vssServiceName = 'MSExchangeIS' }
            'Microsoft Hyper-V VSS Writer' { $vssServiceName = 'vmms' }
            'MSMQ Writer (MSMQ)' { $vssServiceName = 'MSMQ' }
            'MSSearch Service Writer' { $vssServiceName = 'WSearch' }
            'NPS VSS Writer' { $vssServiceName = 'EventSystem' }
            'NTDS' { $vssServiceName = 'NTDS' }
            'OSearch VSS Writer' { $vssServiceName = 'OSearch' }
            'OSearch14 VSS Writer' { $vssServiceName = 'OSearch14' }
            'Registry Writer' { $vssServiceName = 'VSS' }
            'Shadow Copy Optimization Writer' { $vssServiceName = 'VSS' }
            'SMS Writer' { $vssServiceName = 'SMS_SITE_VSS_WRITER' }
            'SPSearch VSS Writer' { $vssServiceName = 'SPSearch' }
            'SPSearch4 VSS Writer' { $vssServiceName = 'SPSearch4' }
            'SqlServerWriter' { $vssServiceName = 'SQLWriter' }
            'System Writer' { $vssServiceName = 'CryptSvc' }
            'TermServLicensing' { $vssServiceName = 'TermServLicensing' }
            'WDS VSS Writer' { $vssServiceName = 'WDSServer' }
            'WIDWriter' { $vssServiceName = 'WIDWriter' }
            'WINS Jet Writer' { $vssServiceName = 'WINS' }
            'WMI Writer' { $vssServiceName = 'Winmgmt' }
            default { $null = $vssServiceName }
        }

        if ($vssServiceName)
        {
            Write-Verbose -Message 'Found matching service'
            $serviceName = Get-Service -Name $vssServiceName
            Write-Output "Restarting service $(($serviceName).DisplayName)"
            $serviceName | Restart-Service -Force
        }
        else
        {
            Write-Warning -Message "No service associated with VSS Writer: $Name"
        }
    }

    end { }
}