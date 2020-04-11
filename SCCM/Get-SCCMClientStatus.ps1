Function Get-SCCMClientStatus
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
    Modified:  11/04/2020
    Version:   1.3
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

    $sccmSoftwares = Get-CimInstance @getCimInstanceParam |
      Select-Object Name, InstallState | Sort-Object InstallState 
  }

  end
  {
    $sccmSoftwares 
  }
}