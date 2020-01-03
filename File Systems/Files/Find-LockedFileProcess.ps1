function Find-LockedFileProcess
{
  <#
  .SYNOPSIS 
    This function help track down a process that is locking down a file you are trying access
  
  .DESCRIPTION 
    This function help track down a process that is locking down a file you are trying access.
    Is used Handle64.exe tool from Microsoft Sysinternal 
  
  .PARAMETER FileName 
    Name of the file to check

  .PARAMETER HandleFilePath
    Path to handle64.exe

  .EXAMPLE 
    Find-LockedFileProcess -FileName computers.txt
  
  .NOTES 
    Author:     Daniel Schwitzgebel
    Created:    26/03/2018
    Modified:   20/12/2019
    Version:    1.1
  #> 

  [OutputType([System.Management.Automation.PSCustomObject])]
  [CmdletBinding()] 
  param ( 
    [Parameter(Mandatory)]
    [ValidateNotNullorEmpty()]
    [String]
    $FileName,
        
    [Parameter(Mandatory)]
    [ValidateNotNullorEmpty()]
    [string]
    $HandleFilePath
  )
    
  if (Test-Path $HandleFilePath)
  {
    [regex]$matchPattern = '(?<Name>\w+\.\w+)\s+pid:\s+(?<PID>\b(\d+)\b)\s+type:\s+(?<Type>\w+)\s+\w+:\s+(?<Path>.*)'
 
    $data = &$HandleFilePath $FileName
    $myMatches = $matchPattern.Matches($data)
 
    if ($myMatches.value)
    {
      $myMatches | ForEach-Object {
        [pscustomobject]@{ 
          FullName = $_.groups['Name'].value
          Name     = $_.groups['Name'].value.split('.')[0]
          ID       = $_.groups['PID'].value
          Type     = $_.groups['Type'].value
          Path     = $_.groups['Path'].value
        }
      }
    }
    else
    {
      Write-Warning 'No matching handles found or Eula not accepted.'
    }
  }
  else
  {
    Write-Warning 'No handle.exe found'
  }
}