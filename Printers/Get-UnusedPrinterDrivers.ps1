function Get-UnusedPrinterdrivers
{
  <#
  .SYNOPSIS 
    Get the unused printer drivers.
  
  .DESCRIPTION 
    Get a list of unused printer drivers on a specified Print Server.
  
  .PARAMETER PrintServerName
    Hostname of the Print Server.
    
  .EXAMPLE 
    PS C:\> Get-UnusedPrinterdrivers -PrintServerName foo
  
  .NOTES 
    Author:     Daniel Schwitzgebel
    Created:    18/08/2016
    Modified:   18/09/2019
    Version:    1.1
  #>

  [OutputType([String])]
  param (
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]
    $PrintServerName
  )

  $arrPrtdrivers = @()

  $drivers = Get-CimInstance -ClassName Win32_PrinterDriver -ComputerName $PrintServerName
  $printers = Get-CimInstance -ClassName Win32_Printer -ComputerName $PrintServerName

  foreach ($printer in $printers)
  {
    if (-not ($arrPrtdrivers.Contains($printer.DriverName)))
    {
      $arrPrtdrivers += $printer.DriverName
    }
  }

  foreach ($driver in $drivers)
  {
    $driverName = ($driver.Name).Split(',')[0]
    if (-not ($arrPrtdrivers.Contains($driverName)))
    {
      Write-Output $driverName
    }
  }
}