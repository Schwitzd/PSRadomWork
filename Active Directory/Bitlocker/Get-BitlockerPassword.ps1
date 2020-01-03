function Get-BitlockerPassword
{
  <#
  .SYNOPSIS 
    This function will get the Bitlocker Password for a specific computer.
  
  .DESCRIPTION 
    This function will get the Bitlocker Password for a specific computer.
  
  .PARAMETER ComputerName 
    Name of the computer.
    
  .EXAMPLE 
    Get-BitlockerPassword -ComputerName foo
  
  .NOTES 
    Author:     Daniel Schwitzgebel 
    Created:    16/07/2019
    Modified:   10/12/2019
    Version:    1.1
  #> 

  [OutputType([Selected.Microsoft.ActiveDirectory.Management.ADObject])]
  [CmdletBinding()] 
  param ( 
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()] 
    [String]
    $ComputerName
  )


  begin
  {
    try 
    {
      $computer = Get-ADComputer $ComputerName -ErrorAction Stop
    }
    catch
    {
      throw 'Computer non found in AD'
    }
  }
  
  process
  {
    $getADObjectParams = @{
      Filter     = 'objectClass -eq "msFVE-RecoveryInformation"'
      SearchBase = $computer.DistinguishedName
      Properties = 'msFVE-RecoveryPassword'
    }

    Get-ADObject @getADObjectParams | Select-Object 'msFVE-RecoveryPassword'
  }
}