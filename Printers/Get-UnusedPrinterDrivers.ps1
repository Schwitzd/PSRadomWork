function Get-UnusedPrinterdrivers
{
  <#
  .SYNOPSIS 
    This function will get the unused printer drivers.
  
  .DESCRIPTION 
    This function will get a list of unused printer drivers on a specified Print Server.
  
  .PARAMETER ComputerName
    Specifies the print server name.
    
  .EXAMPLE 
    PS C:\> Get-UnusedPrinterdrivers -ComputerName foo
    This command gets the unused printer driver on a given print server.
  
  .NOTES 
    Author:     Daniel Schwitzgebel
    Created:    18/08/2016
    Modified:   11/04/2020
    Version:    1.2
  #>

  [OutputType([String])]
  param (
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]
    $ComputerName
  )

  $arrPrtdrivers = @()

  $drivers = Get-CimInstance -ClassName Win32_PrinterDriver -ComputerName $ComputerName
  $printers = Get-CimInstance -ClassName Win32_Printer -ComputerName $ComputerName

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