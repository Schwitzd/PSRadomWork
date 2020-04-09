Import-Module ActiveDirectory
Function Convert-SIDToUsername
{
  <# 
  .SYNOPSIS 
    Convert a SID to Username.
  
  .DESCRIPTION 
    Convert a SID to Username and display additional user information.
  
  .PARAMETER SID
    Specifies the username SID. 
    
  .EXAMPLE 
    PS C:\> Convert-SIDToUsername -SID $value1
    This command convert the SID to the username.
  
  .NOTES 
    Author:    Daniel Schwitzgebel
    Created:   28/02/2017
    Modified:  09/04/2020
    Version:   1.1.1
  #> 

  [OutputType([Microsoft.ActiveDirectory.Management.ADUser])]
  param( 
    [Parameter(Mandatory)] 
    [String]
    $SID
  )

  Get-ADUser -Identity $SID
}