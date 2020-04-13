function Get-ExpandableDisk
{
    <# 
    .SYNOPSIS 
        This function will get all the expandable disks.
    
    .DESCRIPTION 
        This function will get all the expandable disks and the existing partitions on it.
    
    .PARAMETER ComputerName
        Specifies the computer name.

    .EXAMPLE 
        PS C:\> Get-expandableVolume -ComputerName foo
        This command gets all all expandable disks.
    
    .NOTES 
        Author:     Daniel Schwitzgebel
        Created:    12/04/2020
        Modified:   13/04/2020
        Version:    1.0
  #> 

    [OutputType([Void])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]
        $ComputerName
    )

    begin
    {
        try 
        {
            $session = New-CimSession -ComputerName $ComputerName -ErrorAction Stop
        }
        catch 
        {
            throw 'Failed to connect on the remove host.'
        }
    }

    process
    {
        try
        {
            Get-Disk -CimSession $session | Where-Object { $_.LargestFreeExtent -ne 0 } | ForEach-Object {
                $getPartitionParam = @{
                    CimSession = $session
                    DiskNumber = $_.DiskNumber
                }

                $existingPartitions = Get-Partition @getPartitionParam | Where-Object { $_.Type -ne 'Reserved' } |
                    Select-Object -ExpandProperty DriveLetter 

                [PSCustomObject]@{
                    DiskNumber            = $_.DiskNumber
                    'Existing Partitions' = $existingPartitions
                    'Free (GB)'           = [math]::Round(($_.LargestFreeExtent / 1GB), 2)
                }
            }
        }
        catch
        {
            throw 'failed to get disk information.'
        }
    }
        
    end
    {
        Remove-CimSession -CimSession $session
    } 
}