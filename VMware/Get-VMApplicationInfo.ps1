Function Get-VMApplicationInfo
{
    <#
    .SYNOPSIS 
        This function will get the list of running process on a VM
    
    .DESCRIPTION 
        This function will get the list of running process on a VM using the AppInfo Plugin available on VMware Tools 11
    
    .PARAMETER vCenter
        Specifies the address of the vCenter server.
    
    .PARAMETER VM
        Specifies the name of the virtual machine.
    
    .EXAMPLE 
        PS C:\> Get-VMApplicationInfo -vCenter vcenter01 -VM foo
        This command gets the processes running on 'foo' VM.
    
    .NOTES 
        Author:     Daniel Schwitzgebel
        Created:    03/01/2019
        Modified:   03/01/2019
        Version:    1.0
    #>

    [CmdletBinding()]
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

    begin
    {
        try
        { 
            $null = Connect-VIServer -Server $vCenter -Force -ErrorAction Stop
        }
        catch
        {
            throw $_.Exception.Message
        }

        $vmToolsVersion = (Get-VM -Name $VM).Guest.ToolsVersion
        if (-not ([version]$vmToolsVersion -gt [version]'11.0.0'))
        {
            throw 'AppInfo is available from VMware Tools 11.0.0, upgrade the tools on the VM'
        }
    }

    process
    {
        $appInfo = (Get-AdvancedSetting -Entity $VM -Name 'guestinfo.appInfo').Value | ConvertFrom-Json

        if ($appInfo)
        {
            $appInfo.applications | Sort-Object -Property a | 
                Select-Object @{Name = 'Application'; Expression = { $_.a } }, 
                @{Name = 'Version'; Expression = { $_.v } }
        }
        else
        {
            Write-Warning 'Application Discovery is not enabled for this VM'
        }
    }

    end
    {
        try
        { 
            $null = Disconnect-VIServer -Server $vCenter -Confirm:$false
        }
        catch
        {
            throw $_.Exception.Message
        }  
    }
}