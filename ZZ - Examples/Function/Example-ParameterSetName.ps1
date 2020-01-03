# https://richardspowershellblog.wordpress.com/2018/05/22/powershell-parameter-sets/

function Convert-Temperature {
    param (
        [Parameter(ParameterSetName = 'Celsius')]
        [double]$degreeC,

        [Parameter(ParameterSetName = 'Fahrenheit')]
        [double]$degreeF,

        [Parameter(ParameterSetName = 'Kelvin')]
        [double]$degreeK
    )

    $temps = New-Object -TypeName psobject -Property @{
        'Temperature-Celsius'    = 0.0
        'Temperature-Fahrenheit' = 0.0
        'Temperature-Kelvin'     = 0.0
    }

    switch ($psCmdlet.ParameterSetName) {
        "Celsius" {
            $temps.'Temperature-Celsius' = $degreeC
            $temps.'Temperature-Fahrenheit' = [math]::Round((32 + ($degreeC * 1.8)), 2)
            $temps.'Temperature-Kelvin' = $degreeC + 273.15
        }

        "Fahrenheit" {
            $temps.'Temperature-Celsius' = [math]::Round((($degreeF - 32) / 1.8), 2)
            $temps.'Temperature-Fahrenheit' = $degreeF
            $temps.'Temperature-Kelvin' = $temps.'Temperature-Celsius' + 273.15
        }

        "Kelvin" {
            $temps.'Temperature-Celsius' = $degreeK - 273.15
            $temps.'Temperature-Fahrenheit' = [math]::Round((32 + ($temps.'Temperature-Celsius' * 1.8)), 2)
            $temps.'Temperature-Kelvin' = $degreeK
        }

        default {Write-Error -Message "Error!!! Should not be here" }
    }

    $temps
}