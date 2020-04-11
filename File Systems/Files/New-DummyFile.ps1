function New-DummyFile
{
  <#
  .SYNOPSIS
    This function create a dummy file.
  
  .DESCRIPTION
    This function create a dummy file with a custom size.

  .PARAMETER FilePath 
    Specifies the path and file name.

  .PARAMETER Size 
    Specifies the size of the Dummy file.
    
  .EXAMPLE
    PS C:\> New-DummyFile -FilePath C:\Temp\1.dummy -Size 1gb
    This command creates a new Dummy file of 1Gb size.
  
  .NOTES 
    Author:     Daniel Schwitzgebel
    Created:    07/08/2014
    Modified:   11/04/2020
    Version:    1.3.2
  #>

  [OutputType([void])]
  [CmdletBinding()]
  Param (
    [parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [String]
    $FilePath,

    [parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [double]
    $Size
  )

  try
  {
    $objFile = [System.IO.File]::Create($FilePath) 
    $objFile.SetLength($Size) 
    $objFile.Close()
    Write-Verbose "Creating a dummy file with size: $Size"
  }
  catch [System.IO.IOException]
  {
    throw $_.Exception.Message
  }
}