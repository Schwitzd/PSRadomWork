$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe 'Get-SCCMClientStatus' {

    Mock 'Get-CimInstance'

    It 'should not allow multiple computer name' {
        { $null = Get-SCCMClientStatus -ComputerName foo, bar } | Should throw
    }

    It 'should query the CCM_Application CIM Class' {
        $null = Get-SCCMClientStatus -ComputerName foo

        $assMParams = @{
            CommandName     = 'Get-CimInstance'
            Times           = 1
            Exactly         = $True
            Scope           = 'It'
            ParameterFilter = { $ClassName -eq 'CCM_Application' }
        }

        Assert-MockCalled @assMParams
    }
}