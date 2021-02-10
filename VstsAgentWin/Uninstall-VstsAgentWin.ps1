. $PSScriptRoot\Test-RunAsAdmin.ps1
. $PSScriptRoot\Invoke-VstsAgentConfig.ps1
function Uninstall-VstsAgentWin {
    <#
    .SYNOPSIS
        Uninstall Self-hosted Azure Pipelines agent on this machine.
    .DESCRIPTION
        You MUST run this function as Administrator, because you are going to create a windows service.
        If you like to save agent folder after uninstall i Azure DevOps use SkipDeleteFolder flag.
    .EXAMPLE
        > Uninstall-VstsAgentWin -AgentPath "E:\azagent\A1"
    .EXAMPLE
        > "E:\azagent\A1","E:\azagent\A2" | Uninstall-VstsAgentWin
    .EXAMPLE
        > Uninstall-VstsAgentWin E:\azagent\A1 -SkipDeleteFolder
    .EXAMPLE
        # Reconfigure all agents in the folder
        > Get-ChildItem E:\azagent | Uninstall-VstsAgentWin -SkipDeleteFolder | Install-VstsAgentWin -Pool MyPool -CapabilityTags CoolTag1,CoolTag2
    .OUTPUTS
        None, [System.Management.Automation.PathInfo] Path to agent folder if using SkipDeleteFolder
    #>
    [CmdletBinding()]
    param (
        # Path to agent home folder.
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateScript( { Test-Path $_/config.cmd })]
        [string]$AgentPath,

        # Authentication type: personal access token (pat) or windows default credentials (integrated)
        # If using pat you MUST specified your pat-token in varable $env:VSTS_AGENT_INPUT_token before you call
        # Create a personal access token with name 'VstsAgent' for 'All accessible organizations' with Scopes:
        # Agent Pools (Read & mangage); Environment (Read & manage); Deployment Groups (Read & manage) 
        [ValidateSet("pat", "integrated")]
        [string]$Auth = "integrated",

        # Save agent folder after uninstall i Azure DevOps
        [switch]$SkipDeleteFolder = $false
    )
    begin {
        if ($Auth -eq "pat" -and $null -eq $env:VSTS_AGENT_INPUT_token) {
            throw "You must specified your pat-token in varable `$env:VSTS_AGENT_INPUT_token before you call"
        }
    }
    process {
        $AgentPath = Resolve-Path $AgentPath # Braces and belt. Fix to absolut path

        # Check if you run as admin
        if (-not (Test-RunAsAdmin)) {
            throw "You MUST run this functions as Administrator"
        }

        # Delete agent from server and delete windows service
        $ConfigureArgs = @("remove", "--auth $Auth")
        if (-not (Invoke-VstsAgentConfig -AgentPath $AgentPath -ConfigureArgs $ConfigureArgs)) {
            throw "The installation failed"
        }

        # Delete agent folder or only delete .capabilities file 
        if ($SkipDeleteFolder -eq $false) {
            Start-Sleep -Seconds 2 # Wait for windows service to delete 
            Remove-Item $AgentPath -Recurse
            # If folder is empty then delete parent folder
            $parentPath = Split-Path $AgentPath
            if (-not (Get-ChildItem $parentPath)) {
                Remove-Item $parentPath
            }
        }
        else {
            if (Test-Path $AgentPath/.capabilities) {
                Remove-Item $AgentPath/.capabilities
            }
            $AgentPath # Return path for piping
        }

        Write-Host "The uninstallation was successful :-)"
    }
}
