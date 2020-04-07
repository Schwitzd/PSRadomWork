function Get-ComputerOwner
{
  <#
  .SYNOPSIS 
    Get User ID from Name or Surname.
  
  .DESCRIPTION 
    Search in Active Directory and get User ID from Name or Surname.
  
  .PARAMETER Surname
    Surname of the person. 
  
  .PARAMETER Name
    Name of the person.
    
  .EXAMPLE 
    PS C:\> Get-UserID -Surname foo
  
  .NOTES 
    Author:    Daniel Schwitzgebel
    Created:   23/05/2018
    Modified:  10/12/2019
    Version:   1.3.1
  #> 

  [OutputType([Microsoft.ActiveDirectory.Management.ADComputer])]
  param(
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