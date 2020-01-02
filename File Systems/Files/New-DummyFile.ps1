function New-DummyFile
{
  <#
  .SYNOPSIS
    This function create a dummy file.
  
  .DESCRIPTION
    This function create a dummy file with a custom size.

  .PARAMETER FilePath 
    Path and file name

  .PARAMETER Size 
    Size of the Dummy file
    
  .EXAMPLE
    New-DummyFile -FilePath C:\Temp\1.dummy -Size 1gb
  
  .NOTES 
    Author:   Daniel Schwitzgebel
    Created:  07/08/2014
    Modified: 27/12/2019
    Version:  1.3.1
    Updates:  1.1   Add     - Created Function with Parameters
              1.2   Add     - Added OutputType
                    Add     - Added Verbose Parameter
                    Change  - Converted to Advanced Function
              1.3   Change  - Error handling with try/catch
              1.3.1 Change  - Better Exception handling

    To do:      
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
 
  Write-Verbose "Creating a dummy file with size: $Size"

  try
  {
    $objFile = [System.IO.File]::Create($FilePath) 
    $objFile.SetLength($Size) 
    $objFile.Close()
  }
  catch [System.IO.IOException]
  {
    throw $_.Exception.Message
  }
}