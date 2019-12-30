Function Set-SCCMClientSoftware
{
    <#
    .SYNOPSIS 
        Install or uninstall software on target computers.
    
    .DESCRIPTION 
        Install or uninstall software on target computers calling the SCCM Client Class.
    
    .PARAMETER ComputerName
        A single Computer or a computers range.
    
    .EXAMPLE 
        PS C:\> Set-SCCMClientStatus -ComputerName foo,bar
    
    .NOTES 
        Author:     Daniel Schwitzgebel
        Created:    08/06/2018
        Modified:   30/12/2019
        Version:    1.1
        Changes:    1.1     Change - Code Refactoring
                            Change - Improved code quality with try/catch
    #>

    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String[]]
        $ComputerName,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]
        $AppName,
        
        [ValidateSet('Install', 'Uninstall')]
        [Parameter(Mandatory)] 
        [String]
        $Method
    )
 
    Process
    {
        foreach ($computer in $ComputerName)
        {
            try
            {
                $getCimInstanceParameters = @{
                    ComputerName = $computer
                    ClassName    = 'CCM_Application'
                    NameSpace    = 'root\ccm\clientSDK'
                    ErrorAction  = 'Stop'
                }
                
                $application = Get-CimInstance @getCimInstanceParameters |
                    Where-Object { $_.Name -eq $AppName }
            }
            catch
            {
                throw "$computer`: $_"
            }
            
            try
            {
                $args = @{
                    EnforcePreference = [UINT32] 0
                    Id                = "$($application.id)"
                    IsMachineTarget   = $application.IsMachineTarget
                    IsRebootIfNeeded  = $False
                    Priority          = 'High'
                    Revision          = "$($application.Revision)" 
                }
                
                $invokeCimMethodParameters = @{
                    ComputerName = $computer
                    ClassName    = 'CCM_Application'
                    Namespace    = 'root\ccm\clientSDK'
                    MethodName   = $Method
                    Arguments    = $args
                    ErrorAction  = 'Stop'                    
                }
                
                Invoke-CimMethod @invokeCimMethodParameters 
            }
            catch
            {
                throw "$computer`: $_"                    
            }
        }
    }
}