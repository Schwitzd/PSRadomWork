function Get-PrinterDriver
{
  <#
  .SYNOPSIS 
    This function will get the list of printer driver installed.
  
  .DESCRIPTION 
    This function will get the list of printer driver installed on a local or remote Computer.
    Admin right are required to run this script!
  
  .PARAMETER ComputerName 
    Computer name
    
  .EXAMPLE 
    Get-PrinterDriver -ComputerName foo
  
  .NOTES 
    Author:     Daniel Schwitzgebel
    Created:    18/04/2016
    Modified:   20/11/2019
    Version:    1.2
  #>

  [OutputType([System.Management.Automation.PSCustomObject])] 
  param ( 
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [String]
    $ComputerName
  )

  Get-CimInstance -ClassName Win32_Printer -Namespace 'root\CIMV2' -ComputerName $ComputerName | ForEach-Object {
    [PSCustomObject] @{
      'Printer Name' = $($_.Name)
      'Driver Name'  = $($_.DriverName)
    }
  }
}