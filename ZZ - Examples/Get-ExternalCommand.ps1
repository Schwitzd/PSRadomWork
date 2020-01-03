function Get-ExternalCommand {
    <# 
 
.SYNOPSIS 
  Get all the function defined in a script.
 
.DESCRIPTION 
  AGet all the function defined in a script.
 
.PARAMETER Path
  Path to the ps1 file. 
 
.PARAMETER ItemType
  Could be a function or a command.
   
.EXAMPLE 
  PS C:\> Get-ExternalCommand -Path $value1 -ItemType $value2
 
.NOTES 

.LINK
  https://community.idera.com/database-tools/powershell/powertips/b/tips/posts/checking-cmdlet-availability-and-script-compatibility-part-1

#> 

    param
    (
        [Parameter(Mandatory = $true)]
        [string]$Path
    )
    function Get-ContainedCommand {
        param
        (
            [Parameter(Mandatory = $true)]
            [string]$Path,

            [Parameter(Mandatory = $false)]
            [ValidateSet('FunctionDefinition', 'Command')]
            [string]$ItemType
        )

        $Token = $Err = $null
        $ast = [Management.Automation.Language.Parser]::ParseFile($Path, [ref] $Token, [ref] $Err)

        $ast.FindAll( { $args[0].GetType().Name -eq "${ItemType}Ast" }, $true)

    }

    $functionNames = Get-ContainedCommand $Path -ItemType FunctionDefinition | 
        Select-Object -ExpandProperty Name
   
    $commands = Get-ContainedCommand $Path -ItemType Command 
    $commands | Where-Object {
        $commandName = $_.CommandElements[0].Extent.Text
        $commandName -notin $functionNames
    } | 
        ForEach-Object { $_.GetCommandName() } |
        Sort-Object -Unique |
        ForEach-Object { 
        $module = (Get-Command -name $_).Source
        $builtIn = $module -like 'Microsoft.PowerShell.*'

        [PSCustomObject]@{
            Command = $_
            BuiltIn = $builtIn
            Module  = $module
        }
    }
}