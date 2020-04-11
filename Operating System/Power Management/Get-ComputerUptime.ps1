function Get-ComputerUptime
{
  <#
  .SYNOPSIS 
    This function will get the computer uptime.
  
  .DESCRIPTION 
    This function will get the computer uptime by querying wmi.
  
  .PARAMETER ComputerName 
    Specifies the computer name to check the uptime.
    
  .EXAMPLE 
    PS C:\> Get-ComputerUptime -ComputerName foo
    This command gets the computer uptime.
  
  .NOTES
    Author:    Daniel Schwitzgebel
    Created:   27/04/2012
    Modified:  11/04/2020
    Version:   1.5.1
  #>

  [OutputType([String])] 
  param ( 
    [Parameter(Mandatory)] 
    [ValidateNotNullOrEmpty()]
    [String]
    $ComputerName
  ) 

  if (Test-NetConnection $ComputerName -InformationLevel Quiet)
  {
    $hostUptime = (Get-CimInstance -Class Win32_OperatingSystem -Computername $ComputerName).LastBootUpTime
    $uptime = (Get-Date) - $hostUptime
    $hostUptime = '{0:dd/MM/yyyy hh:mm:ss}' -f $hostUptime

    Write-Output "Power on: $hostUptime"
    Write-Output "Uptime is: $($uptime.days) days $($uptime.hours) hours $($uptime.minutes) minutes $($uptime.seconds) seconds"
  } 
  else
  {
    Write-Warning "$ComputerName is offline"
  } 
}