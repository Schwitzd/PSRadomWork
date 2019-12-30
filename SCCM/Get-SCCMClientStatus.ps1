Function Get-SCCMClientStatus
{
  <#
  .SYNOPSIS
    Return the state of the SCCM Client Softwares.
  
  .DESCRIPTION
    Return the state of the SCCM Client Softwares querying the remote Computer.
  
  .PARAMETER ComputerName
    A single Computer.
  
  .EXAMPLE
    PS C:\> Get-SCCMClientStatus -ComputerName foo
  
  .NOTES
    Author:    Daniel Schwitzgebel 
    Created:   08/06/2018
    Modified:  30/12/2019
    Version:   1.2.1
    Changes:   1.1    Add    - Implemented Return to Pipeline
               1.2    Add    - Function OutputType and parameter validation
               1.2.1  Change - Small cosmetic changes
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
    $sccmSoftwares = Get-CimInstance -ComputerName $ComputerName -ClassName CCM_Application -Namespace 'root\ccm\clientSDK' | 
      Select-Object Name, InstallState | Sort-Object InstallState 
  }

  end
  {
    return $sccmSoftwares 
  }
}