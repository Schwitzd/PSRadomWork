function Invoke-SCCMClientSoftware
{
  <#
  .SYNOPSIS
    This function will install/uninstall a software through the SCCM Client.
  
  .DESCRIPTION
    This function will install a software through the SCCM Client.

  .PARAMETER AppName
    Specifies the name of the application to install/uninstall.

  .PARAMETER ComputerName
    Specifies the computer name.

  .PARAMETER Method
    Specifies the method to perform. The acceptable values for this parameter are:

      -- Install: install an application.

      -- Uninstall: uninstall an application.
  
  .EXAMPLE
    PS C:\> Invoke-SCCMClientSoftware -ComputerName foo -AppName '7-Zip' -Method Install
    This command install the application 7-Zip on the given computer name.
  
  .NOTES
    Author:    Daniel Schwitzgebel 
    Created:   08/06/2018
    Modified:  11/04/2020
    Version:   1.3
  #>

  [OutputType([Microsoft.Management.Infrastructure.CimMethodResult])]
  param (
    [Parameter()]
    [ValidateNotNullOrEmpty()] 
    [String]
    $AppName,

    [Parameter(Mandatory, ValueFromPipeline)]
    [ValidateNotNullOrEmpty()]
    [String]
    $ComputerName,
        
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