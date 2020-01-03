function Get-ComputerUptime
{
  <#
  .SYNOPSIS 
    This function will get the computer uptime.
  
  .DESCRIPTION 
    This function will get the computer uptime by querying wmi.
    Admin right are required to run this script!
  
  .PARAMETER ComputerName 
    ComputerName to check the uptime
    
  .EXAMPLE 
    Get-ComputerUptime -ComputerName foo
  
  .NOTES
    Author:    Daniel Schwitzgebel
    Created:   27/04/2012
    Modified:  10/12/2019
    Version:   1.5
  #>

  [OutputType([string])] 
  param ( 
    [Parameter(Mandatory)] 
    [ValidateNotNullOrEmpty()]
    [String]
    $ComputerName
  ) 

  if (Test-NetConnection $ComputerName -InformationLevel Quiet)
  {
    $hostUptime = (Get-CimInstance -Class Win32_OperatingSystem -computername $ComputerName).LastBootUpTime
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