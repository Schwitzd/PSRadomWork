$sitesFile = (Split-Path -Parent $MyInvocation.MyCommand.Path) + "\config.json"
$objSites = Get-Content -Raw $sitesFile | ConvertFrom-Json 
$sites = @{ }

# Get Json config
foreach ($property in $objSites.PSObject.Properties)
{
    $sites[$property.Name] = $property.Value
}

# Loop through each location
foreach ($site in $sites.GetEnumerator())
{
    Write-Output $site.Key
    Write-Output $Site.Value.LocalPath
}