function Get-VSSWriters
{
  <# 
  .SYNOPSIS 
    This function get the list of VSS writers
  
  .DESCRIPTION 
    This function get a list of VSS writers or a filtered list with only the writers in stable state
  
  .PARAMETER Failed 
    Specifies to return only failed writers
    
  .EXAMPLE 
    Get-VSSWriters -Failed
    This command gets the VSS writers in a failed state
  
  .NOTES
    Author:    Daniel Schwitzgebel
    Created:   22/06/2021
    Modified:  22/06/2021
    Version:   1.0
  #>
    
    [OutputType([String])]
    [CmdletBinding()]
    param (
        [Parameter()]
        [switch]
        $Failed    
    )

    $vssWriters = vssadmin.exe list writers

    if ($PSBoundParameters.ContainsKey('Failed'))
    {
        $vssWriters = $vssWriters | Select-String -Context 1, 4 '^writer name:' 
            | Where-Object {
                $_.Context.PostContext[2].Trim() -ne "state: [1] stable" -or
                $_.Context.PostContext[3].Trim() -ne "last error: no error"
        }
    }

    return $vssWriters
}