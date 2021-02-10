function Invoke-VstsAgentConfig {
    param(
        $AgentPath,
        [string[]]$ConfigureArgs
    )
    $Expression = "$AgentPath/config.cmd " + $ConfigureArgs -join " "
    Write-Verbose "Run: $Expression"
    Invoke-Expression $Expression | Out-Host # Write to stand out instead of output
    return -not($LASTEXITCODE) # $true if success
}