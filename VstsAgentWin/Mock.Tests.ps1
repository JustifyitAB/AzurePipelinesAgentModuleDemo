Mock Test-RunAsAdmin { $true }
Mock Test-Path { $true }
Mock Resolve-Path { param($Path) return $Path }
Mock Invoke-VstsAgentConfig {
    param(
        $AgentPath,
        [string[]]$ConfigureArgs
    )
    $script:ActualConfigureArgs = $ConfigureArgs
    return $true
}