$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe 'Set-SCCMClientSoftware' {
    Mock 'Where-Object'
    Mock 'Get-CimInstance' 
    
    Context 'Validate Parameters' {
        $parameterInfo = (Get-Command Set-SCCMClientSoftware).Parameters['Method']
        $validateSet = $parameterInfo.Attributes.Where{ $_ -is [ValidateSet] }
        
        It 'should has ValidateSet for parameter Method' {
            $parameterInfo.Attributes.Where{ $_ -is [ValidateSet] }.Count | Should be 1
        }
        It 'ValidateSet contains option Install' {
            $validateSet.ValidValues -contains 'Install' | Should be $true
        }
        It 'ValidateSet contains option Uninstall' {
            $validateSet.ValidValues -contains 'Uninstall' | Should be $true
        }
    }

    Context 'Get Information for each computer' {
        Mock 'Invoke-CimMethod'

        It 'should allow multiple computer name' {
            { $null = Set-SCCMClientSoftware -ComputerName foo, bar } | Should Not Be throw
        }

        It 'should query the CCM_Application CIM Class' {
            $computers = 'Foo', 'Bar'
            $result = Set-SCCMClientSoftware -ComputerName $computers -AppName 'foo' -Method Install
        
            $assMParams = @{
                CommandName     = 'Get-CimInstance'
                Times           = @($computers).Count
                Exactly         = $true
                Scope           = 'It'
                ParameterFilter = { $ClassName -eq 'CCM_Application' }
            }
            Assert-MockCalled @assMParams
        }
    }

    Context 'Invoke a Client Action' {
        Mock 'Invoke-CimMethod'

        It 'should invoke a client action for a specific application' {
            $computers = 'Foo', 'Bar'
            $result = Set-SCCMClientSoftware -ComputerName $computers -AppName 'foo' -Method Install
        
            $assMParams = @{
                CommandName = 'Invoke-CimMethod'
                Times       = @($computers).Count
                Exactly     = $true
                Scope       = 'It'
            }
            Assert-MockCalled @assMParams
        }

    }
    
    Context 'When the function throws an exception' {      
        It 'an exception is thrown when querying a computer' { 
            Mock 'Get-CimInstance' {
                throw
            }

            $installSCCMClientSoftwareParameters = @{
                ComputerName = 'foo'
                AppName      = 'bar'
                Method       = 'Install'
            }
            { Set-SCCMClientSoftware @installSCCMClientSoftwareParameters } | Should throw
        }
        It 'an exception is thrown when invoking method in a computer' { 
            Mock 'Get-CimInstance' {
                New-MockObject -Type 'Microsoft.Management.Infrastructure.CimSession'
            }
            Mock 'Invoke-CimMethod' {
                throw
            }

            $installSCCMClientSoftwareParameters = @{
                ComputerName = 'foo'
                AppName      = 'bar'
                Method       = 'Install'
            }
            { Set-SCCMClientSoftware @installSCCMClientSoftwareParameters } | Should throw
        }
    }    
}