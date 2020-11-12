function Get-SCCMClientStatus
{
  <#
  .SYNOPSIS
    This function will get the state of the SCCM Client Softwares.
  
  .DESCRIPTION
    This function will get the state of the SCCM Client Softwares querying the remote Computer.
  
  .PARAMETER ComputerName
    Specifies the computer name.
  
  .EXAMPLE
    PS C:\> Get-SCCMClientStatus -ComputerName foo
    This command gets the SCCM Client status for the given computer name.
  
  .NOTES
    Author:    Daniel Schwitzgebel 
    Created:   08/06/2018
    Modified:  19/10/2020
    Version:   1.4
  #>

  [OutputType([Microsoft.Management.Infrastructure.CimInstance])]
  param (
    [Parameter(Mandatory, ValueFromPipeline)]
    [ValidateNotNullOrEmpty()]
    [String]
    $ComputerName
  )
 
  begin { }

  process
  {
    $getCimInstanceParam = @{
      ComputerName = $ComputerName
      ClassName    = 'CCM_Application'
      Namespace    = 'root\ccm\clientSDK'
    }

    Get-CimInstance @getCimInstanceParam | ForEach-Object {
      [PSCustomObject]@{
        ComputerName = $ComputerName
        Name         = $_.Name
        InstallState = $_.InstallState
      }
    }
  }
}