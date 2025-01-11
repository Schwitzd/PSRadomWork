<#
    Name:           Get-VisualCppLoaded
    Description:    This script identifies and lists running processes that have specific Visual C++ runtime DLLs loaded
    Author:         Daniel Schwitzgebel
    Created:        09/01/2025
    Modified:       09/01/2025
    Version:        1.0.0

$memo = @{
    "2005"      = "8.0.0"
    "2008"      = "9.0.0"
    "2010"      = "10.0.0"
    "2012"      = "11.0.0"
    "2013"      = "12.0.0"
    "2015"      = "14.0.0"
    "2017"      = "14.0.0"
    "2019"      = "14.0.0"
    "2015-2019" = "14.0.0"
    "2015-2022" = "14.0.0"
}
#>
Add-Type @"
using System;
using System.Runtime.InteropServices;

public class ProcessArchitecture {
    [DllImport("kernel32.dll", SetLastError = true, CallingConvention = CallingConvention.Winapi)]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool IsWow64Process(IntPtr hProcess, out bool wow64Process);
}
"@

function Get-ProcessArchitecture
{
    param (
        [Parameter(Mandatory = $true)]
        [System.Diagnostics.Process]$Process
    )

    $wow64Process = $false
    [ProcessArchitecture]::IsWow64Process($Process.Handle, [ref]$wow64Process) | Out-Null

    if ([Environment]::Is64BitOperatingSystem)
    {
        if ($wow64Process)
        {
            return "32-bit"
        }
        else
        {
            return "64-bit"
        }
    }
    else
    {
        return "32-bit OS"
    }
}

function Get-VisualCppLoaded
{
    $output = [System.Collections.ArrayList]::new()

    foreach ($process in Get-Process)
    {
        try
        {
            # Filter Visual C++ modules while excluding "_win"
            $modules = $process.Modules | Where-Object {
                $_.ModuleName -like "msvcp*.dll" -and $_.ModuleName -notlike "*_win*"
            }

            if ($modules)
            {
                # Get the architecture of the process
                $processArchitecture = Get-ProcessArchitecture -Process $process

                foreach ($module in $modules)
                {
                    [void]$output.Add([PSCustomObject]@{
                            ProcessName         = $process.ProcessName
                            PID                 = $process.Id
                            DLLPath             = $module.FileName
                            DLLVersion          = $module.FileVersionInfo.FileVersion
                            ProcessArchitecture = $processArchitecture
                        })
                }
            }
        }
        catch
        {
            Write-Warning "Could not access modules for process ID $($process.Id): $($_.Exception.Message)"
        }
    }

    return $output
}