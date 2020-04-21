function Get-VMToolsAndVirtualHWStatus
{
  <#
  .SYNOPSIS 
    This function get the list VM tools status for all VMs.
 
  .DESCRIPTION 
    This function get the List status and version for all VMs.
 
  .PARAMETER vCenter
    Specifies the address of the vCenter server.

  .PARAMETER VM
    Specifies the VM(s) name.
    
  .EXAMPLE 
    PS C:\> Get-VMToolsAndVirtualHWStatus -vCenter vcenter01
    This command gets VM tools and Virtual Hardware info for all VMs.

  .EXAMPLE
    PS C:\> Get-VMToolsAndVirtualHWStatus -vCenter vcenter01 -VM foo,bar
    This command gets VM tools and Virtual Hardware info for the specified VMs.    
 
  .NOTES 
    Author:     Daniel Schwitzgebel
    Created:    22/08/2016
    Modified:   21/04/2020
    Version:    2.0
#>

  [OutputType([System.Management.Automation.PSCustomObject])]
  [CmdletBinding()] 
  param (
    [Parameter(Mandatory)]
    [String]
    $vCenter,

    [Parameter(ValueFromPipeline)]
    [String[]]
    $VM
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
    $getVMParam = @{ }
    if ($VM) { $getVMParam['Name'] = $VM }

    Get-VM @getVMParam | ForEach-Object {
      [PSCustomObject]@{
        'VM Name'                = $_.Name
        'VM Tools Version'       = $_.Guest.ToolsVersion
        'VM Tools Status'        = $_.ExtensionData.Guest.ToolsStatus
        'VM Tools Version State' = $_.ExtensionData.Guest.ToolsVersionStatus
        'HW Version'             = $_.HardwareVersion
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
