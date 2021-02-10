if (-not (Get-Module -ListAvailable | Where-Object Name -eq platyPS)) {
    Install-Module -Name platyPS
}

# Import latest module local
Import-Module -Name $PSScriptRoot\VstsAgentWin -Force

# Generate new docs
New-MarkdownHelp -Module VstsAgentWin -OutputFolder $PSScriptRoot\docs -Force
