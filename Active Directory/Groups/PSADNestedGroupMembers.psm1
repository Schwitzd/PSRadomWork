#Requires -Modules ActiveDirectory

$script:indentGetNastedGroup = ''
$script:indentExportNastedGroup = ''

function Get-ADNestedGroupMembers
{
    <#
    .SYNOPSIS
        Get nested group membership from a given group.

    .DESCRIPTION
        Function enumerates members of a given AD group recursively along with nesting level and parent group information. 
        It also displays if each user account is disabled. 
    
    .PARAMETER SearchGroup
        Specifies the group name.

    .EXAMPLE
        PS C:\> Get-ADNestedGroupMembers -SearchGroup MyGroup
        This command gets the all the members of the group 'MyGroup'

    .NOTES 
        Author:     Daniel Schwitzgebel
        Created:    17/03/2016
        Modified:   09/04/2020
        Version:    2.4.1
    #>

    [OutputType([String])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String]
        $SearchGroup
    )

    begin
    {
        $groupInfo = Get-ADGroup $SearchGroup -Properties Description
    }

    Process
    {
        Write-Host
        Write-Host 'LDAP URL: ' -NoNewline -ForegroundColor DarkGray; Write-Host $groupInfo.DistinguishedName
        Write-Host 'Group Name: ' -NoNewline -ForegroundColor DarkGray; Write-Host $groupInfo.Name
        Write-Host 'Group Description: ' -NoNewline -ForegroundColor DarkGray; Write-Host $groupInfo.Description
        Write-Host
        Get-ADSubGroupMembers -SearchGroup $SearchGroup
        Write-Host
    }      
}

function Get-ADSubGroupMembers
{
    param (
        [Parameter(Mandatory)]
        [String]
        $SearchGroup
    )

    $groupMember = Get-ADGroupMember $SearchGroup | Sort-Object objectClass -Descending

    if ($groupMember)
    {
        foreach ($member in $groupMember)
        {
            switch ($member.ObjectClass)
            {
                'computer'
                {
                    $computer = (Get-ADComputer $member.Name -Properties Description).Description
                    Write-Output "$script:indentGetNastedGroup $($member.name) : $computer"
                }
                'user'
                {
                    $username = ((Get-ADUser $member.sAMAccountName -Properties displayName).displayName).replace(',', '')
                    $userOU = (Get-ADUser $member.sAMAccountName -Properties distinguishedName).distinguishedName
                    if ($userOU -like '*OU=DisabledUsers*')
                    {
                        Write-Host $script:indentGetNastedGroup 'Disabled - ', $member.sAMAccountName, ':', $username -Foregroundcolor DarkGray
                    }
                    else
                    {
                        Write-Output "$script:indentGetNastedGroup $($member.sAMAccountName) : $username" 
                    }                    
                }
                'group'
                {
                    Write-Host $script:indentGetNastedGroup $member.name -Foregroundcolor DarkCyan
                }
            }
            if ($member.ObjectClass -eq 'group')
            {
                $script:indentGetNastedGroup += "`t"
                Get-ADSubGroupMembers $member.name
                $script:indentGetNastedGroup = "`t" * ($script:indentGetNastedGroup.length - 1)  
            }
        }
    }
    else
    {
        Write-Output "$script:indentGetNastedGroup Group is Empty"
    }
}

function Export-ADNestedGroupMembers
{
    <#
    .SYNOPSIS
        Export nested group membership from a given group.

    .DESCRIPTION
        Function export members of a given AD group recursively along with nesting level and parent group information. 
        It also displays if each user account is disabled. 


    .PARAMETER ExportFile
        Specifies the file name where the group members will be exported.

    .PARAMETER SearchGroup
        Specifies the group name.
    
    .EXAMPLE   
        PS C:\> Export-ADNestedGroupMembers -SearchGroup MyGroup -ExportFile 'c:\temp\export.txt'
        This command export all the group members of 'MyGroup' on a txt file.

    .NOTES 
        Author:     Daniel Schwitzgebel
        Created:    17/03/2016
        Modified:   27/12/2019
        Version:    1.1.1
    #>

    [OutputType([void])]
    param (
        [Parameter(Mandatory)]
        [String]
        $SearchGroup,

        [Parameter(Mandatory)]
        [String]
        $ExportFile

    )

    $groupMember = Get-ADGroupMember $SearchGroup | Sort-Object objectClass -descending
    if ($groupMember)
    {
        foreach ($member in $groupMember)
        {
            if (-not ($member.ObjectClass -eq 'group'))
            {
                $username = ((Get-ADUser $member.SamAccountName -Properties displayName).displayName).replace(',', '')
                $userOU = (Get-ADUser $member.SamAccountName -Properties distinguishedName).distinguishedName
                if ($userOU -like '*OU=DisabledUsers*')
                {
                    Add-Content $ExportFile -Value ($script:indentExportNastedGroup + "Disabled - $($member.name) : $username")
                }
                else
                {
                    Add-Content $ExportFile -Value ($script:indentExportNastedGroup + "$($member.name) : $username")
                }			
            }
            else
            {
                Add-Content $ExportFile -Value ($script:indentExportNastedGroup + $member.name)
            }
            if ($member.ObjectClass -eq 'group')
            {
                $script:indentExportNastedGroup += "`t"
                Export-ADNestedGroupMembers $member.name -ExportFile $ExportFile
                $script:indentExportNastedGroup = "`t" * ($script:indentExportNastedGroup.length - 1)  
            }
        }
    }
    else
    {
        Add-Content $ExportFile -Value "$script:indentExportNastedGroup Group is Empty"
    }
}