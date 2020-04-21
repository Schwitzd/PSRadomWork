function Resize-PartitionMaxSize
{
    <# 
    .SYNOPSIS 
        This function will extend the partition to the maximum size.
    
    .DESCRIPTION 
        This function will extend the partition to the maximum size available on the disk.
    
    .PARAMETER ComputerName
        Specifies the computer name.

    .PARAMETER DriveLetter
        Specifies the drive letter to expand.

    .EXAMPLE 
        PS C:\> Resize-PartitionMaxSize -ComputerName foo -DriveLetter E
        This command expands the given drive on the remote computer.
    
    .NOTES 
        Author:     Daniel Schwitzgebel
        Created:    14/04/2020
        Modified:   21/04/2020
        Version:    1.1
  #> 

    [OutputType([Void])]
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]
        $ComputerName,
      
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [String]
        $DriveLetter
    )

    begin
    {
        try 
        {
            $session = New-CimSession -ComputerName $ComputerName -ErrorAction Stop
            Write-Verbose -Message "Opening CIM session to $ComputerName"
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
            if ($PSCmdlet.ShouldProcess("Partition ${DriveLetter}:", 'Resize to maximum available size'))
            {

                $getPartitionParam = @{
                    CimSession  = $session
                    DriveLetter = $DriveLetter
                }

                $partitionInfo = Get-Partition @getPartitionParam

                Update-Disk -CimSession $session -Number $partitionInfo.DiskNumber
                
                $getPartitionSupportedSizeParam = @{
                    CimSession  = $session
                    DriveLetter = $DriveLetter
                }

                $sizeMax = (Get-PartitionSupportedSize @getPartitionSupportedSizeParam).SizeMax

                if (-not ($partitionInfo.Size -ge $sizeMax))
                {

                    $resizePartitionParam = @{
                        CimSession  = $session 
                        DriveLetter = $DriveLetter
                        Size        = $sizeMax
                    }
                    Resize-Partition @resizePartitionParam
                    Write-Verbose -Message "Resizing Partition $DriveLetter to $sizeMax."
                }
            }
        }
        catch
        {
            throw $_.Exception.Message
        }
    }
        
    end
    {
        Remove-CimSession -CimSession $session
        Write-Verbose -Message "Closing CIM session to $ComputerName"     
    }
}