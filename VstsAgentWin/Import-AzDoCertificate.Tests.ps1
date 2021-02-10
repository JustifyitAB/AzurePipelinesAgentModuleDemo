BeforeAll {
    . $PSScriptRoot\Import-AzDoCertificates.ps1
    Mock Test-RunAsAdmin { $true }
    Mock Import-Certificate {
        param(
            $FilePath,
            $CertStoreLocation
        )
        $script:FilePath = $FilePath
        $script:CertStoreLocation = $CertStoreLocation
    }
}

Describe "Import-AzDoCertificate" {
    BeforeAll {
        $script:FilePath = $null,
        $script:CertStoreLocation = $null
    }

    It "Should return CA" {
        Mock Get-ChildItem { Convert-Path "$PSScriptRoot\certificate\my-issuing.cer" } -ParameterFilter { $Path -like '*certificate*' }
        Mock Get-ChildItem {} -ParameterFilter { $Path -like 'Cert:*' }

        Import-AzDoCertificates
        
        $script:FilePath | Should -BeLike '*my-issuing.cer*'
        $script:CertStoreLocation | Should -Be 'Cert:\LocalMachine\CA'
    }

    It "Should return Root" {
        Mock Get-ChildItem { Convert-Path "$PSScriptRoot\certificate\my-root.cer" } -ParameterFilter { $Path -like '*certificate*' }
        Mock Get-ChildItem {} -ParameterFilter { $Path -like 'Cert:*' }

        Import-AzDoCertificates
        
        $script:FilePath | Should -BeLike '*my-root.cer*'
        $script:CertStoreLocation | Should -Be 'Cert:\LocalMachine\Root'
    }
}
