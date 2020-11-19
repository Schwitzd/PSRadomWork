function Get-SCCMClientCacheElements
{
    <#
    .SYNOPSIS 
        This function will get the elements inside the SCCM client cache.
    
    .DESCRIPTION 
        This function will get the elements inside the SCCM client cache.
        The elements are: Applications, Packages or Software Update
    
    .PARAMETER Application
        Specifies Application as filter.

    .PARAMETER Package
        Specifies Package as filter.

    .PARAMETER SoftwareUpdate
        Specifies SoftwareUpdate as filter.        

    .EXAMPLE 
        PS C:\> Get-SCCMClientCacheElements -Application
        This command outputs the Applications inside the SCCM cache
    
    .NOTES 
        Author:     Daniel Schwitzgebel
        Created:    19/11/2020
        Modified:   19/11/2020
        Version:    1.0
    #>

    [CmdletBinding(DefaultParameterSetName = 'Application')] 
    param(
        [Parameter(ParameterSetName = 'Application')]
        [Switch]
        $Application,

        [Parameter(ParameterSetName = 'Package')]
        [Switch]
        $Package,

        [Parameter(ParameterSetName = 'SoftwareUpdate')]
        [Switch]
        $SoftwareUpdate
    )
    
    begin
    {
        $cmObject = New-Object -ComObject 'UIResource.UIResourceMgr'
        $cmCacheObjects = $cmObject.GetCacheInfo()
    }

    process
    {
        switch ($PSBoundParameters.Keys)
        {
            'Application'
            {
                $getCimInstance = @{
                    Namespace    = 'root/ccm/CIModels'
                    ClassName    = 'CCM_AppDeliveryTypeSynclet'
                }

                $ccm_AppDeliveryTypeSynclet = Get-CimInstance @getCimInstance
                $CMCacheObjects.GetCacheElements() | Where-Object { $_.ContentID -match 'Content' } | ForEach-Object {

                    $contentID = $($_.ContentID)

                    [PSCustomObject]@{
                        Name         = $(($ccm_AppDeliveryTypeSynclet | Where-Object { $_.InstallAction.Content.ContentId -eq $contentID }).AppDeliveryTypeName)
                        'Cache Path' = $($_.Location)
                        'Cache Size' = $($_.ContentSize)
                    }                    
                }
            }

            'Package'
            {
                $cmCacheObjects.GetCacheElements() | Where-Object { $_.ContentID | 
                    Select-String -Pattern '^\w{8}$' } | ForEach-Object {

                        $getCimInstance = @{
                            Namespace    = 'root/ccm/Policy/Machine/ActualConfig'
                            ClassName    = 'CCM_SoftwareDistribution'
                            Filter       = "PKG_PackageID = '$($_.ContentId)'"
                        }

                        $PackageInfo = Get-CimInstance @getCimInstance

                        [PSCustomObject]@{
                            Name         = $($PackageInfo.PKG_Name)
                            'Package ID' = $($_.ContentId)
                            'Cache Path' = $($_.Location)
                            'Cache Size' = $($_.ContentSize)
                        }
                    }
            }

            'SoftwareUpdate'
            {
                $cmCacheObjects.GetCacheElements() | Where-Object { $_.ContentID | 
                        Select-String -Pattern '^[\dA-F]{8}-(?:[\dA-F]{4}-){3}[\dA-F]{12}$' } | ForEach-Object {

                        $getCimInstance = @{
                            Namespace    = 'root/ccm/SoftwareUpdates/UpdatesStore'
                            ClassName    = 'CCM_UpdateStatus'
                            Filter       = "UniqueId = '$(($_).ContentId)'"
                        }

                        $SoftwareUpdateInfo = Get-CimInstance @getCimInstance

                        [PSCustomObject]@{
                            Name         = $($SoftwareUpdateInfo.Title)
                            Status       = $($SoftwareUpdateInfo.Status)
                            'Cache Path' = $($_.Location)
                            'Cache Size' = $($_.ContentSize)
                        }
                    }
            }
        }
    }
}