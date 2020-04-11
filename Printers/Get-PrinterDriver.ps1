function Get-PrinterDriver
{
  <#
  .SYNOPSIS 
    This function will get the list of printer driver installed.
  
  .DESCRIPTION 
    This function will get the list of printer driver installed on a local or remote print server.
  
  .PARAMETER ComputerName 
    Specifies the print server name.
    
  .EXAMPLE 
    PS C:\> Get-PrinterDriver -ComputerName foo
    This command gets the printer drivers on print server 'foo'.
  
  .NOTES 
    Author:     Daniel Schwitzgebel
    Created:    18/04/2016
    Modified:   11/04/2020
    Version:    1.2.1
  #>

  [OutputType([System.Management.Automation.PSCustomObject])] 
  param ( 
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [String]
    $ComputerName
  )

  process
  {
    $getCimInstanceParam = @{
      ComputerName = $ComputerName
      ClassName    = 'Win32_Printer'
      Namespace    = 'root\CIMV2'
    }

    try 
    {
      Get-CimInstance @getCimInstanceParam | ForEach-Object {
        [PSCustomObject] @{
          'Printer Name' = $($_.Name)
          'Driver Name'  = $($_.DriverName)
        }
      }
    }
    catch
    {
      throw "Failed to get printer driver from $ComputerName"
    }
  }
}