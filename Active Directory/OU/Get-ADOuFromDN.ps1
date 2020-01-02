function Get-ADOuFromDN
{
  <# 
  .SYNOPSIS 
    This function will return the OU DN of the Input object.
  
  .DESCRIPTION 
    Get a Distinguished name property from an Active Directory cmdlet i.e Get-ADUser, 
    Get-ADComputer and this function will return the OU DN of the object.
  
  .PARAMETER DistinguishedName
    Object DistinguishedName to parse.
  
  .EXAMPLE 
    (Get-ADUser -Identity foo).DistinguishedName | Get-ADOuFromDN
  
  .NOTES 
    Author:     Daniel Schwitzgebel
    Created:    16/08/2018
    Modified:   02/01/2019
    Version:    1.1
    Changes:    1.1   Change  - code restyle
                      Change  - Improved error handling 
                      Add     - Added OutputType and ValueFromPipelineByPropertyName                       
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