function Test-RegistryValue
{
    param (
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()] 
        $Path,

        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()] 
        $Value
    )

    try
    {
        $null = Get-ItemProperty -Path $Path | Select-Object -ExpandProperty $Value -ErrorAction Stop
        return $true
    }
    catch
    {
        return $false
    }
}