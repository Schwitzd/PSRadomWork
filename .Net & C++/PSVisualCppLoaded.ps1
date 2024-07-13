<#
    Name:           PSVisualCppLoaded
    Description:    This script identifies and lists running processes that have specific Visual C++ runtime DLLs loaded
    Author:         Daniel Schwitzgebel
    Created:        08/07/2024
    Modified:       08/07/2024
    Version:        1.0.0
#>

function Test-VisualCppDllLoaded {
    param (
        [array]$DllVersions
    )

    # Get all running processes
    $processes = Get-Process

    $results = New-Object System.Collections.Generic.List[PSObject]

    foreach ($process in $processes) {
        try {
            # Get the loaded modules for the process
            $processModules = Get-Process -Id $process.Id -Module -ErrorAction SilentlyContinue | Where-Object {$_.ModuleName -like "MSVCP*.dll"}

            foreach ($module in $processModules) {
                # Determine architecture based on file path
                $isX86 = $module.FileName -match 'SysWOW64'
               
                $matchingDlls = $DllVersions | Where-Object {
                    $_.DllName -eq $module.ModuleName -and
                    (($isX86 -and $_.Caption -match 'x86') -or (!$isX86 -and $_.Caption -match 'x64'))
                }

                foreach ($matchingDll in $matchingDlls) {
                    $fileVersion = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($module.FileName).FileVersion
                    $fileVersion = $fileVersion -replace '\.0$'  # Remove the trailing .0 if present

                    if ($fileVersion -eq $matchingDll.Version) {
                        $result = [PSCustomObject]@{
                            ProcessName = $process.ProcessName
                            ProcessId   = $process.Id
                            DllName     = $module.ModuleName
                            DllPath     = $module.FileName
                            FileVersion = $fileVersion
                            Caption     = $matchingDll.Caption
                        }
                        $results.Add($result)
                    }
                }
            }
        } catch {
            # Handle access denied errors silently
            continue
        }
    }

    return $results
}

function Get-InstalledVisualCppVersion {
    $products = Get-CimInstance -ClassName Win32_Product | Where-Object { $_.Name -like '*Visual C++*' } | Select-Object Caption, Version

    $visualCppVersions = $products | ForEach-Object {
        $dllName = ""

        switch -regex ($_.Caption) {
            "2005" { $dllName = "MSVCP80.DLL" }
            "2008" { $dllName = "MSVCP90.DLL" }
            "2010" { $dllName = "MSVCP100.DLL" }
            "2012" { $dllName = "MSVCP110.DLL" }
            "2013" { $dllName = "MSVCP120.DLL" }
            "2015|2017|2019|2022" { $dllName = "MSVCP140.DLL" }
        }

        # Truncate Caption at the last whitespace
        $truncatedCaption = $_.Caption -replace '\s?-?\s\d+(\.\d+)+$',''

        [PSCustomObject]@{
            Caption  = $truncatedCaption
            Version  = $_.Version
            DllName  = $dllName
        }
    }

    return $visualCppVersions
}

# Get installed Visual C++ versions
$visualCppVersions = Get-InstalledVisualCppVersion

# Display the installed Visual C++ versions
Write-Output "Installed Visual C++ Versions:"
$visualCppVersions | Format-Table -AutoSize

# Check all running processes and return if any of the specified DLLs are loaded
$results = Test-VisualCppDllLoaded -DllVersions $visualCppVersions

if ($results) {
    Write-Output "Processes with Visual C++ runtime DLLs loaded:"
    $results | Format-Table -AutoSize
} else {
    Write-Output "No processes found with the specified Visual C++ runtime DLLs loaded."
}
