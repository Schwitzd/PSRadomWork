function Get-VssWriters
{
    <# 
    .SYNOPSIS 
        This function get the list of VSS writers.
  
    .DESCRIPTION 
        This function get a list of VSS writers or a filtered based on the VSS writers state.
  
    .PARAMETER Status 
        Specifies the status to filter for.
    
    .EXAMPLE
        Get-VSSWriters -Status 'Failed'
        This command gets the VSS writers in a failed state.

    .EXAMPLE
        Get-VSSWriters
        This command gets all the VSS writers.
  
    .NOTES
        Author:    Daniel Schwitzgebel
        Created:   22/06/2021
        Modified:  22/06/2021
        Version:   1.0
    #>
    
    [OutputType([PSCustomObject])]
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateSet('Stable', 'Failed', 'Waiting for completion')]
        [string]
        $Status    
    )

    begin
    {
        Write-Verbose "Executing vssadmin utility"
        $vssWritersList = VSSAdmin list writers
    }

    process
    {
        Write-Verbose "Retrieving VSS Writers"
        $vssWritersList | Select-String -Pattern 'Writer name:' -Context 0, 4 |
            ForEach-Object {

                $vssWritersObj = [pscustomobject]@{
                    Name       = $_.Line -replace "^(.*?): " -replace "'"
                    Id         = $_.Context.PostContext[0] -replace "^(.*?): "
                    InstanceId = $_.Context.PostContext[1] -replace "^(.*?): "
                    State      = $_.Context.PostContext[2] -replace "^(.*?): "
                    LastError  = $_.Context.PostContext[3] -replace "^(.*?): "
                } 

                if ($PSBoundParameters.ContainsKey('Status'))
                {
                    Write-Verbose "Filtering out the results"
                    $vssWritersObj | Where-Object { $_.State -like "*$Status" }
                }
                else
                {
                    $vssWritersObj
                }
            }
    }

    end { }
}