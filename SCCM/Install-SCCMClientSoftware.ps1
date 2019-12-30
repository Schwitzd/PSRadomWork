Function Install-SCCMClientSoftware
{

    [OutputType([Microsoft.Management.Infrastructure.CimMethodResult])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]
        $ComputerName,

        [Parameter()]
        [ValidateNotNullOrEmpty()] 
        [String]
        $AppName,
        
        [Parameter(Mandatory)]
        [ValidateSet('Install', 'Uninstall')]
        [String]
        $Method
    )
 
    begin
    {
        $getCimInstanceParams = @{
            ComputerName = $ComputerName
            ClassName    = 'CCM_Application'
            Namespace    = 'root\ccm\clientSDK'
        }
        
        $application = (Get-CimInstance @getCimInstanceParams | Where-Object { $_.Name -like $AppName })
        $invokeCimMethodArgs = @{
            EnforcePreference = [UINT32] 0
            Id                = "$($application.id)"
            IsMachineTarget   = $application.IsMachineTarget
            IsRebootIfNeeded  = $false
            Priority          = 'High'
            Revision          = "$($application.Revision)" 
        }
    }

    process
    {
        $invokeCimMethodParams = @{
            ComputerName = $ComputerName
            Namespace    = 'root\ccm\clientSDK'
            ClassName    = 'CCM_Application'
            MethodName   = $Method
            Arguments    = $invokeCimMethodArgs
        }

        Invoke-CimMethod @invokeCimMethodParams
    }
}