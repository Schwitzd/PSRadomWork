function Get-ACLTreeInternal
{
    <# 
    .NOTES
        Credit: Lee Spottiswood (https://github.com/0x4c6565/PSTree)
    #>

    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Path = '.',

        [Parameter()]
        [int]
        $MaxDepth = 0,

        [Parameter()]
        [int]
        $Depth = 0,

        [Parameter()]
        [string]
        $DepthPrefix = ''
    )

    process
    {
        if ($MaxDepth -gt 0 -and ($Depth + 1) -gt $MaxDepth)
        {
            return
        }

        $output = @()
                
        if ($Depth -eq 0)
        {
            $output += $Path
        }

        $items = Get-ChildItem -Path $Path -Directory -ErrorAction SilentlyContinue

        $folderCount = 0
        $totalCountCount = ($items | Where-Object -FilterScript { $_.PSIsContainer }).Count
        
        foreach ($item in $items)
        {
            $folderCount++
            $itemTreeBranch = '├── '
            $newDepthPrefix = '│   '
            $itemTreeName = $DepthPrefix

            if ($folderCount -eq $totalCountCount)
            {
                $itemTreeBranch = '└── '
                $newDepthPrefix = '    '
            }

            $itemTreeName += $itemTreeBranch
            $identityCheck = @(
                'BUILTIN\Administrators',
                'BUILTIN\Users',
                'CREATOR OWNER',
                'NT AUTHORITY\SYSTEM',
                'NT AUTHORITY\Authenticated Users',
                "$env:USERDOMAIN\Domain Admins"
            )

            $acl = Get-Acl -Path $item.FullName
            $acls = @()

            foreach ($access in $acl.access)
            {
                if (-not ($access.IsInherited))
                {
                    foreach ($group in $access.IdentityReference)
                    {
                        if ($identityCheck -notcontains $group)
                        {
                            $acls += ([string]$group).Split('\\')[1] + ';'
                        }
                    }
                }
            }
            If ($acls)
            {
                $itemTreeName += ("[$acls] ")
            }

            $itemTreeName += $item.Name

            $output += $itemTreeName
            if ($Item.PSIsContainer)
            {
                $getACLTreeInternalParams = @{
                    MaxDepth    = $MaxDepth
                    Depth       = ($Depth + 1)
                    DepthPrefix = ($DepthPrefix + $newDepthPrefix)
                }
                $output += $item | Get-ACLTreeInternal @getACLTreeInternalParams
            }
        }
        return $output
    }
}

function Get-ACLTree
{
    <# 
    .SYNOPSIS 
    Get all ACL groups for a Directory Path in tree view.
    
    .DESCRIPTION 
    Get all ACL groups for a Directory and its subfolders in tree view and where the Inherited is interrupted.
    
    .PARAMETER Path
    Path Name.
    
    .PARAMETER MaxDepth
    Subfolders level, default is 0.
    
    .EXAMPLE 
    PS C:\> Get-ACLTree -Path C:\temp -MaxDepth 2

    .NOTES 
    Author:     Daniel Schwitzgebel
    Created:    28/09/2019
    Modified:   10/12/2019
    Version:    1.1

    Credit: Lee Spottiswood (https://github.com/0x4c6565/PSTree)
    #>

    [CmdletBinding()]
    Param
    (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Path,
        
        [int]
        $MaxDepth = 0
    )

    $Path | Get-ACLTreeInternal -MaxDepth $MaxDepth
}