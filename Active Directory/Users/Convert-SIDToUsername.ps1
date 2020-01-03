Import-Module ActiveDirectory
Function Convert-SIDToUsername
{
  <# 
  .SYNOPSIS 
    Convert a SID to Username.
  
  .DESCRIPTION 
    Convert a SID to Username and display additional user information.
  
  .PARAMETER SID
    User SID. 
    
  .EXAMPLE 
    PS C:\> Convert-SIDToUsername -SID $value1
  
  .NOTES 
    Author:    Daniel Schwitzgebel
    Created:   28/02/2017
    Modified:  10/12/2019
    Version:   1.1
  #> 

  [OutputType([Microsoft.ActiveDirectory.Management.ADUser])]
  param( 
    [Parameter(Mandatory)] 
    [String]
    $SID
  )

  Get-ADUser -Identity $SID
}