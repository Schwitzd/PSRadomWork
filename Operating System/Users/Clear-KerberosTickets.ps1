function Clear-KerberosTickets
{
  <# 
  .SYNOPSIS 
    This function will clear all Kerberos Tickets.
  
  .DESCRIPTION 
    This function will clear all Kerberos Tickets on a remote computer.
    Admin right are required to run this script!
  
  .PARAMETER ComputerName 
    Target computername.

    .PARAMETER UserName 
    Target username.
    
  .EXAMPLE 
    Clear-KerberosTickets -ComputerName foo -UserName user1
  
  .NOTES
    Author:    Daniel Schwitzgebel
    Created:   26/10/2018
    Modified:  10/12/2019
    Version:   1.2
  #>

  [OutputType([void])]
  [CmdletBinding()] 
  param( 
    [Parameter(Mandatory)] 
    [String]
    $ComputerName,

    [Parameter(Mandatory)] 
    [String]
    $Username
  )

  $getCimInstanceParams = @{
    ClassName    = Win32_LoggedOnUser
    ComputerName = $ComputerName
  }

  $loggedOn = Get-CimInstance @getCimInstanceParams | Where-Object { $_.Antecedent.Name -like $Username }
  
  foreach ($sess in $loggedOn)
  {
    Invoke-Command -ComputerName $ComputerName -ScriptBlock {	
      C:\Windows\System32\klist.exe purge -li ('0x{0:X}' -f [int]$sess.Dependent.LogonId)
    }
  }
}