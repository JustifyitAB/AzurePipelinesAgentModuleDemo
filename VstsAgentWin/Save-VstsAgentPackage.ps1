function Save-VstsAgentPackage {
    param (
        [ValidateScript( { Test-Path $_ })]
        [string]$AgentPath
    )
    $AgentZip = "$AgentPath/agent.zip"
    $AgentZipLocal = Resolve-Path $PSScriptRoot/vsts-agent-win*.zip | Select-Object -First 1
    
    if ($AgentZipLocal) {
        Copy-Item -Path $AgentZipLocal -Destination $AgentZip
    }
    else {
        Invoke-WebRequest https://vstsagentpackage.azureedge.net/agent/2.170.1/vsts-agent-win-x64-2.170.1.zip -Out $AgentZip -UseBasicParsing
    }
    Expand-Archive -Path $AgentZip -DestinationPath $AgentPath
    Remove-Item $AgentZip
}