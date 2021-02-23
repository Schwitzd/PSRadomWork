# Module created by Microsoft.PowerShell.Crescendo
Function Get-KerberosTicketDomainGroup
{
[CmdletBinding()]

param(    )

BEGIN {
    $__PARAMETERMAP = @{}
    $__outputHandlers = @{
        Default = @{ StreamOutput = $False; Handler = { param ( $whoamiOutput )
                $whoamiOutput | ConvertFrom-CSV | Where-Object { $_."Group Name" -like "$env:USERDOMAIN\*" } |
                    Select-Object 'Group Name', SID
             } }
    }
}
PROCESS {
    $__commandArgs = @(
        "/groups"
        "/fo"
        "CSV"
    )
    $__boundparms = $PSBoundParameters
    $MyInvocation.MyCommand.Parameters.Values.Where({$_.SwitchParameter -and $_.Name -notmatch "Debug|Whatif|Confirm|Verbose" -and ! $PSBoundParameters[$_.Name]}).ForEach({$PSBoundParameters[$_.Name] = [switch]::new($false)})
    if ($PSBoundParameters["Debug"]){wait-debugger}
    foreach ($paramName in $PSBoundParameters.Keys|Sort-Object {$__PARAMETERMAP[$_].OriginalPosition}) {
        $value = $PSBoundParameters[$paramName]
        $param = $__PARAMETERMAP[$paramName]
        if ($param) {
            if ( $value -is [switch] ) { $__commandArgs += if ( $value.IsPresent ) { $param.OriginalName } else { $param.DefaultMissingValue } }
            elseif ( $param.NoGap ) { $__commandArgs += "{0}""{1}""" -f $param.OriginalName, $value }
            else { $__commandArgs += $param.OriginalName; $__commandArgs += $value |Foreach-Object {$_}}
        }
    }
    $__commandArgs = $__commandArgs|Where-Object {$_}
    if ($PSBoundParameters["Debug"]){wait-debugger}
    if ( $PSBoundParameters["Verbose"]) {
         Write-Verbose -Verbose -Message whoami
         $__commandArgs | Write-Verbose -Verbose
    }
    $__handlerInfo = $__outputHandlers[$PSCmdlet.ParameterSetName]
    if (! $__handlerInfo ) {
        $__handlerInfo = $__outputHandlers["Default"] # Guaranteed to be present
    }
    $__handler = $__handlerInfo.Handler
    if ( $PSCmdlet.ShouldProcess("whoami")) {
        if ( $__handlerInfo.StreamOutput ) {
            & "whoami" $__commandArgs | & $__handler
        }
        else {
            $result = & "whoami" $__commandArgs
            & $__handler $result
        }
    }
  } # end PROCESS

<#
.SYNOPSIS

WhoAmI has three ways of working: 

Syntax 1:
    WHOAMI [/UPN | /FQDN | /LOGONID]

Syntax 2:
    WHOAMI { [/USER] [/GROUPS] [/CLAIMS] [/PRIV] } [/FO format] [/NH]

Syntax 3:
    WHOAMI /ALL [/FO format] [/NH]

Description:
    This utility can be used to get user name and group information
    along with the respective security identifiers (SID), claims,
    privileges, logon identifier (logon ID) for the current user
    on the local system. I.e. who is the current logged on user?
    If no switch is specified, tool displays the user name in NTLM
    format (domain\username).

Parameter List:
    /UPN                    Displays the user name in User Principal 
                            Name (UPN) format.

    /FQDN                   Displays the user name in Fully Qualified 
                            Distinguished Name (FQDN) format.

    /USER                   Displays information on the current user
                            along with the security identifier (SID).

    /GROUPS                 Displays group membership for current user,
                            type of account, security identifiers (SID)
                            and attributes.

    /CLAIMS                 Displays claims for current user,
                            including claim name, flags, type and values.

    /PRIV                   Displays security privileges of the current
                            user.

    /LOGONID                Displays the logon ID of the current user.

    /ALL                    Displays the current user name, groups 
                            belonged to along with the security 
                            identifiers (SID), claims and privileges for 
                            the current user access token.

    /FO       format        Specifies the output format to be displayed.
                            Valid values are TABLE, LIST, CSV.
                            Column headings are not displayed with CSV
                            format. Default format is TABLE.

    /NH                     Specifies that the column header should not
                            be displayed in the output. This is
                            valid only for TABLE and CSV formats.

    /?                      Displays this help message.

Examples:
    WHOAMI
    WHOAMI /UPN
    WHOAMI /FQDN 
    WHOAMI /LOGONID
    WHOAMI /USER
    WHOAMI /USER /FO LIST
    WHOAMI /USER /FO CSV
    WHOAMI /GROUPS
    WHOAMI /GROUPS /FO CSV /NH
    WHOAMI /CLAIMS
    WHOAMI /CLAIMS /FO LIST
    WHOAMI /PRIV
    WHOAMI /PRIV /FO TABLE
    WHOAMI /USER /GROUPS
    WHOAMI /USER /GROUPS /CLAIMS /PRIV
    WHOAMI /ALL
    WHOAMI /ALL /FO LIST
    WHOAMI /ALL /FO CSV /NH
    WHOAMI /?

.DESCRIPTION See help for whoami

#>
}

Export-ModuleMember -Function Get-KerberosTicketDomainGroup
