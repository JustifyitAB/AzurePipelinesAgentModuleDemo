# VstsAgentWin Demo

Powershell module using for install, configure, or uninstall self-hosted Azure Pipelines agent.

## Register PSRepository PSDemo if needed

````powershell
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if (-not (Get-PackageProvider -ListAvailable Nuget)) {
    Install-PackageProvider -Name NuGet -Force
}
else {
    Get-PackageProvider NuGet
}

if (-not (Get-Module -ListAvailable PowerShellGet | Where-Object Version -gt 1.0.0.1)) {
    Install-Module -Name PowerShellGet -Force
}
else {
    Get-Module -ListAvailable PowerShellGet | Format-Table
}

if (-not (Get-PSRepository | Where-Object Name -eq PSDemo)) {
    $PSRepo = @{
        Name               = "PSDemo"
        SourceLocation     = "https://pkgs.dev.azure.com/henrikroos/_packaging/henrikroos/nuget/v2"
        PublishLocation    = "https://pkgs.dev.azure.com/henrikroos/_packaging/henrikroos/nuget/v2"
        InstallationPolicy = "Trusted"
    }
    Register-PSRepository @PSRepo
}
else {
    Get-PSRepository PSDemo
}
````

## Install or Update module

````powershell
if (-not (Get-Module -ListAvailable | Where-Object Name -eq VstsAgentWin)) {
    Install-Module -Name VstsAgentWin -Repository PSDemo
} else {
    Update-Module -Name VstsAgentWin
}
````

## Install default build agent

````powershell
Install-VstsAgentWin
````

More examples [Install-VstsAgentWin](docs/Install-VstsAgentWin.md)

## Uninstall agent

````powershell
Uninstall-VstsAgentWin -AgentPath "E:\azagent\A1"
````

## Reconfigure agent

````powershell
"E:\azagent\A1", "E:\azagent\A2" |
Uninstall-VstsAgentWin -SkipDeleteFolder |
Install-VstsAgentWin -SkipDownload -Pool MyPool -CapabilityTags CoolTag1,CoolTag2
````

## Commands

| Name | Synopsis |
| - | - |
| [Install-VstsAgentWin](docs/Install-VstsAgentWin.md) | Download and install Self-hosted Azure Pipelines agent on this machine. |
| [Uninstall-VstsAgentWin](docs/Uninstall-VstsAgentWin.md) | Uninstall Self-hosted Azure Pipelines agent on this machine. |
| [Import-AzDoCertificates](docs/Import-AzDoCertificates.md) | Install an intermediate or root certificate on this computer. |
