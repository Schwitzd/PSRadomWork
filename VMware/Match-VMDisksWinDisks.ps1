Function Match-VMDisksWinDisks
{
    <#
    .SYNOPSIS 
        Gets disk mapping information in VMWare virtual machines.
    
    .DESCRIPTION 
        This script gets SCSI information from both vCenter and WMI and collates them together to a grid view.
    
    .PARAMETER vCenter
        The address of the vCenter server. This can either be the server name or the FQDN.
    
    .PARAMETER VM
        The name of the virtual machine you want disk information for.
    
    .EXAMPLE 
        Match-VMDisksWinDisks -vCenter vcenter01 -VM SQLServer1
    
    .NOTES 
        Author:    Daniel Schwitzgebel
        Created:   04/05/2016
        Modified:  03/01/2019
        Version:   1.1
        Changes:   1.1  Change - Removed Snap-In
                        Change - Replaced WMI with CIM

        Credits: Jacob Ludriks (https://gist.github.com/jacobludriks/a6356e89d54aad11cc4f#file-vmscsi-ps1)

    .LINK
        https://jacob.ludriks.com/2015/04/22/Matching-VM-disks-and-Windows-disks-with-PowerCLI/
        https://4sysops.com/archives/map-vmware-virtual-disks-and-windows-drive-volumes-with-a-powershell-script
    #>

    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]
        $vCenter,
        
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]
        $VM
    )

    try
    { 
        $null = Connect-VIServer -Server $vCenter -Force -ErrorAction Stop
    }
    catch
    {
       throw $_.Exception.Message
    }

    $vmName = Get-VM $VM
    $vmSummaries = @()
    $diskMatches = @()
    $vmView = Get-VM $VM | Get-View
    foreach ($virtualSCSIController in ($vmView.Config.Hardware.Device | Where-Object { $_.DeviceInfo.Label -match 'SCSI Controller' }))
    {
        foreach ($virtualDiskDevice  in ($vmView.Config.Hardware.Device | Where-Object { $_.ControllerKey -eq $virtualSCSIController.Key }))
        {
            $vmSummary = '' | Select-Object VM, HostName, PowerState, DiskFile, DiskName, DiskSize, SCSIController, SCSITarget
            $vmSummary.VM = $vmName.Name
            $vmSummary.HostName = $vmView.Guest.HostName
            $vmSummary.PowerState = $vmName.PowerState
            $vmSummary.DiskFile = $virtualDiskDevice.Backing.FileName
            $vmSummary.DiskName = $virtualDiskDevice.DeviceInfo.Label
            $vmSummary.DiskSize = $virtualDiskDevice.CapacityInKB * 1KB
            $vmSummary.SCSIController = $virtualSCSIController.BusNumber
            $vmSummary.SCSITarget = $virtualDiskDevice.UnitNumber
            $vmSummaries += $vmSummary
        }
    }
    $disks = Get-CimInstance -Class Win32_DiskDrive -ComputerName $vmName.Name
    $diff = $disks.SCSIPort | Sort-Object -Descending | Select-Object -Last 1 
    foreach ($device in $vmSummaries)
    {
        $disks | ForEach-Object { if ((($_.SCSIPort - $diff) -eq $device.SCSIController) -and ($_.SCSITargetID -eq $device.SCSITarget))
            {
                $DiskMatch = '' | Select-Object VMWareDisk, VMWareDiskSize, WindowsDeviceID, WindowsDiskSize 
                $DiskMatch.VMWareDisk = $device.DiskName
                $DiskMatch.WindowsDeviceID = $_.DeviceID.Substring(4)
                $DiskMatch.VMWareDiskSize = $device.DiskSize / 1gb
                $DiskMatch.WindowsDiskSize = [decimal]::round($_.Size / 1gb)
                $diskMatches += $DiskMatch
            }
        }
    }
    $diskMatches | Format-Table
    $null = Disconnect-VIServer -Server $vCenter -Confirm:$false
}