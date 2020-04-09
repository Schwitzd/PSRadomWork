function Get-ADOuFromDN
{
  <# 
  .SYNOPSIS 
    This function will return the OU DN of the Input object.
  
  .DESCRIPTION 
    Get a Distinguished name property from an Active Directory cmdlet i.e Get-ADUser, 
    Get-ADComputer and this function will return the OU DN of the object.
  
  .PARAMETER DistinguishedName
    Specifies the DistinguishedName to parse.
  
  .EXAMPLE 
    PS C:\> (Get-ADUser -Identity foo).DistinguishedName | Get-ADOuFromDN
    This command gets the DistinguishedName.    
  
  .NOTES 
    Author:     Daniel Schwitzgebel
    Created:    16/08/2018
    Modified:   09/04/2020
    Version:    1.1.1                  
  #>

  [OutputType([String])]
  [CmdletBinding()]
  param (
    [Parameter(Mandatory, ValueFromPipelineByPropertyName, ValueFromPipeline)]
    [string]
    $DistinguishedName
  )
  
  begin
  {
    if (-not (Select-String -InputObject $DistinguishedName -Pattern 'OU' -CaseSensitive -Quiet))
    {
      throw 'Invalid Input Object, must be an OU string'
    }
  }
  
  process
  {
    $ouIndex = $DistinguishedName.IndexOf('OU')
    $ouPath = $DistinguishedName.Remove(0, $ouIndex)
    Write-Output -InputObject $ouPath
  }
}