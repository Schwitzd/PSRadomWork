function Get-ComputerOwner
{
  <#
  .SYNOPSIS 
    This function will get the computer owner.
  
  .DESCRIPTION 
    This function will get the computer owner based on the attribute Description in Active Directory.

  .PARAMETER OwnerName
    Specifies the owner name.
    
  .EXAMPLE 
    PS C:\> Get-ComputerOwner -OwnerName foo
    This command gets the computer's owner name.
  
  .NOTES 
    Author:    Daniel Schwitzgebel
    Created:   23/05/2018
    Modified:  09/04/2020
    Version:   1.3.3
  #> 

  [OutputType([Microsoft.ActiveDirectory.Management.ADComputer])]
  param (
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [String]
    $OwnerName
  )

  $getADComputerParams = @{
    Filter     = "description -like '*$OwnerName*'"
    Properties = 'Description'
  }

  Get-ADComputer @getADComputerParams | 
    Select-Object @(
      @{ Label = 'ComputerName'; Expression = { $_.Name } },
      'Description'
    )
}