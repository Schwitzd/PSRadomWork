Function Get-FrameworkVersion
{
    <# 
    .SYNOPSIS 
        This function will get the framework version.
    
    .DESCRIPTION 
        This function will get the computer framework version for local or remote computer.
        Admin right are required to run this script!
    
    .PARAMETER ComputerName 
        Specifies the computers on which the command runs.
    
    .EXAMPLE 
        PS C:\> Get-FrameworkVersion -ComputerName foo
        This Command gets all the .Net Framework versions installed on the computer.
    
    .NOTES 
        Author:   	Daniel Schwitzgebel 
        Created:    25/09/2015
        Modified:   09/04/2020
        Version:  	1.4.1

    .LINK
        https://docs.microsoft.com/en-us/dotnet/framework/migration-guide/versions-and-dependencies
    #>
    
    #Requires -Version 3.0 

    [OutputType([PSCustomObject])] 
    param (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [String[]]
        $ComputerName
    )
    
    $dotNetRegistry = 'SOFTWARE\Microsoft\NET Framework Setup\NDP'
    $dotNet4Registry = 'SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full'
    $dotNet4Builds = @{
        30319  = '.NET Framework 4.0'
        378389 = '.NET Framework 4.5'
        378675 = '.NET Framework 4.5.1 (8.1/2012R2)'
        378758 = '.NET Framework 4.5.1 (8/7 SP1/Vista SP2)'
        379893 = '.NET Framework 4.5.2' 
        393295 = '.NET Framework 4.6 (Windows 10)'
        393297 = '.NET Framework 4.6 (NON Windows 10)'
        394254 = '.NET Framework 4.6.1 (Windows 10 November Update)'
        394271 = '.NET Framework 4.6.1 (All OS Before Windows 10 November Update)'
        394802 = '.NET Framework 4.6.2 (Windows 10 Anniversary Update and Windows Server 2016)'
        394806 = '.NET Framework 4.6.2 (All OS Before Windows 10 Anniversary Update)'
        460798 = '.NET Framework 4.7 (Windows 10 Creators Update)'
        460805 = '.NET Framework 4.7 (All OS Before Windows 10 Creators Update)'
        461308 = '.NET Framework 4.7.1 (Windows 10 Creators Update and Windows Server, version 1709)'
        461310 = '.NET Framework 4.7.1 (All OS Before Windows 10 Fall Creators Update)'
        461808 = '.NET Framework 4.7.2 (Windows 10 April 2018 Update and Windows Server, version 1803)'
        461814 = '.NET Framework 4.7.2 (All OS Before Windows 10 April 2018 Update)'
        528040 = '.NET Framework 4.8 (Windows 10 May 2019 Update)'
        528049 = '.NET Framework 4.8 (all other OS versions)'
    }

    foreach ($Computer in $ComputerName)
    {
        if ($regKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $Computer))
        {
            if ($netRegKey = $regKey.OpenSubKey("$dotNetRegistry"))
            {
                foreach ($versionKeyName in $netRegKey.GetSubKeyNames())
                {
                    if ($versionKeyName -match '^v[123]')
                    {
                        $versionKey = $netRegKey.OpenSubKey($versionKeyName)
                        $version = [version]($versionKey.GetValue('Version', ''))
                        New-Object -TypeName PSObject -Property @{
                            ComputerName     = $Computer
                            Builds           = $version.Build
                            FrameworkVersion = '.NET Framework ' + $version.Major + '.' + $version.Minor
                        } | Select-Object ComputerName, FrameworkVersion, Builds
                    }
                }
            }
            if ($net4RegKey = $regKey.OpenSubKey("$dotNet4Registry"))
            {
                if (-not ($net4Release = $net4RegKey.GetValue('Release')))
                {
                    $net4Release = 30319
                }
                New-Object -TypeName PSObject -Property @{
                    ComputerName     = $Computer
                    Builds           = $net4Release
                    FrameworkVersion = $dotNet4Builds[$net4Release]
                } | Select-Object ComputerName, FrameworkVersion, Builds
            }
        }
    }
}