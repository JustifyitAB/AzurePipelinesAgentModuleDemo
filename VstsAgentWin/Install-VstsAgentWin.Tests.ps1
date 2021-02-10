BeforeAll {
    . $PSScriptRoot\Install-VstsAgentWin.ps1
    . $PSScriptRoot\Mock.Tests.ps1
    Mock Save-VstsAgentPackage { }
}

Describe "Install-VstsAgentWin" {
    BeforeAll {
        $script:ActualConfigureArgs = @()
    }

    It "Should return AgentPath" {
        Install-VstsAgentWin -AgentPath "path to file" | Should -be "path to file"
    }

    It "Should contains --runAsService" {
        Install-VstsAgentWin -AgentPath "." | Out-Null
        $script:ActualConfigureArgs | Should -Contain "--runAsService"
    }

    It "Should contains --deploymentpoolname" {
        Install-VstsAgentWin -AgentPath "." -DeploymentPoolName "MyPool" | Out-Null
        $script:ActualConfigureArgs | Should -Contain "--deploymentpool"
        $script:ActualConfigureArgs | Should -Contain "--deploymentpoolname 'MyPool'"
    }

    It "Should create capabilities file" {
        Mock New-Item -Verifiable { return "file" }
        Mock Add-Content -Verifiable {}

        Install-VstsAgentWin -AgentPath "." -WindowsUser SYSTEM -CapabilityTags "Tag1", "Tag2" | Out-Null
        
        Assert-MockCalled New-Item -Times 1
        Assert-MockCalled Add-Content -Times 2
    }

    It "Should throw missing username" {
        $env:VSTS_AGENT_INPUT_windowslogonaccount = $null
        { Install-VstsAgentWin -AgentPath "." -WindowsUser ADUser } | Should -Throw "You must specified ADUser name*"
    }

    It "Should throw missing password" {
        $env:VSTS_AGENT_INPUT_windowslogonaccount = "xxx"
        $env:VSTS_AGENT_INPUT_windowslogonpassword = $null
        { Install-VstsAgentWin -AgentPath "." -WindowsUser ADUser } | Should -Throw "You must specified ADUser password*"
    }

    It "Should not use local user" {
        $env:VSTS_AGENT_INPUT_windowslogonaccount = "xxx"
        $env:VSTS_AGENT_INPUT_windowslogonpassword = "xxx"
        Install-VstsAgentWin -AgentPath "." -WindowsUser ADUser | Out-Null

        $script:ActualConfigureArgs | Should -HaveCount 4
        $script:ActualConfigureArgs | Should -Not -Contain "--windowslogonaccount"
    }
}
