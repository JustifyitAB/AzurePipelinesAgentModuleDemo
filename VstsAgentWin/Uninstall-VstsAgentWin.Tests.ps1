BeforeAll {
    . $PSScriptRoot\Uninstall-VstsAgentWin.ps1
    . $PSScriptRoot\Mock.Tests.ps1
    Mock Remove-Item -Verifiable {}
}

Describe "Uninstall-VstsAgentWin" {
    BeforeAll {
        $script:ActualConfigureArgs = @()
    }

    It "Should return AgentPath" {
        Uninstall-VstsAgentWin -AgentPath "path to file" -SkipDeleteFolder | Should -be "path to file"
    }

    It "Should remove agent folder" {
        Mock Get-ChildItem -Verifiable {}
        Mock Split-Path { param($Path) return $Path }
    
        Uninstall-VstsAgentWin -AgentPath "." | Out-Null

        Assert-MockCalled Remove-Item -Times 1
        Assert-MockCalled Get-ChildItem -Times 1
    }
}
