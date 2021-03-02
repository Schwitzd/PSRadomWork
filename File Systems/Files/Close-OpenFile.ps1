function Close-OpenFile
{
  <#
  .SYNOPSIS 
    This function close an open file.

  .DESCRIPTION
    This function close and open file by getting its ID.

  .PARAMETER Path
    Specifies the path of the file to close.
    
  .EXAMPLE 
    PS C:\> Close-OpenFile -Path E:\data\foo.log
    This command close the open file.

  .NOTES 
    Author:     Daniel Schwitzgebel
    Created:    26/02/2021
    Modified:   26/02/2022
    Version:    1.0
  #>

  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')] 
  [OutputType([void])]    
  param (
    [parameter(ValueFromPipeline)] 
    [string]
    $Path
  )

  begin
  {
    if (-not(Test-Path -Path $path))
    { 
      throw "Cannot find the path $path because it does not exist"
    }
  }

  process
  {       
    if ($PSCmdlet.ShouldProcess($Path, 'Close file'))
    {
      Get-SmbOpenFile | Where-Object {$_.Path -match $Path} | Close-SmbOpenFile -Force
      Write-Verbose "Closing file $Path"
    }
  }
}