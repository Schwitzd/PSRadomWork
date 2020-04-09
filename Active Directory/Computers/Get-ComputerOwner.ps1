function Get-ComputerOwner
{
  <#
  .SYNOPSIS 
    Get User ID from Name or Surname.
  
  .DESCRIPTION 
    Search in Active Directory and get User ID from Name or Surname.

  .PARAMETER Name
    Specifies the person's name.

  .PARAMETER Surname
    Specifies the person's surname. 
    
  .EXAMPLE 
    PS C:\> Get-UserID -Surname foo
    This command gets the person's surname
  
  .NOTES 
    Author:    Daniel Schwitzgebel
    Created:   23/05/2018
    Modified:  09/04/2020
    Version:   1.3.2
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