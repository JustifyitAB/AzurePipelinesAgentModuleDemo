. $PSScriptRoot\Test-RunAsAdmin.ps1
. $PSScriptRoot\Save-VstsAgentPackage.ps1
. $PSScriptRoot\Invoke-VstsAgentConfig.ps1
function Install-VstsAgentWin {
   <#
         .SYNOPSIS
            Download and install Self-hosted Azure Pipelines agent on this machine.
         .DESCRIPTION
            You MUST run this function as Administrator, because you are going to create a windows service.
            You MUST have permissions to register or unregister agent i Azure DevOps. This is a high level permission so only
            adm- user have that permissions. This function use windows default credential for login into Azure DevOps.
            
            The agent can be configurated in 4 different ways:

            - BuildReleasesAgent. New and classic way in Automation. Use as automation agent in yaml file as keyword pool or as classic build agent
            - EnvironmentVMResource. New way in Deployment. Use as deploy agent in release yaml file as keyword environment
            - SharedDeployment. Classic way in Deployment. Use as deploy agent in cross projects in classic release pipeline
            - DeploymentAgent. Classic way in Deployment. Use as deploy agent in one project in classic click in UI release pipeline

            There are two different pool types: Automation (Agent pools) and Deployment (Deployment pools)
         .EXAMPLE
            > Install-VstsAgentWin
         .EXAMPLE
            > Install-VstsAgentWin -Pool CM -CapabilityTags DatabaseRight,GDPR
         .EXAMPLE
            > Install-VstsAgentWin -EnvironmentName Dev -EnvironmentVMResourceTags XE8
         .EXAMPLE
            > Install-VstsAgentWin -DeploymentPoolName PTR9-Test -WindowsUser SYSTEM
         .EXAMPLE
            > Install-VstsAgentWin -DeploymentGroupName KJ7-Prod -ProjectName Ops -DeploymentGroupTags Web,App
         .EXAMPLE
            > "E:/azagent/A2" | Install-VstsAgentWin -DeploymentPoolName MyPool -SkipNewPackage
         .EXAMPLE
            > $env:VSTS_AGENT_INPUT_windowslogonaccount = "nameofuser@justifyit.se"
            > $env:VSTS_AGENT_INPUT_windowslogonpassword = "MyPassword"
            > Install-VstsAgentWin -ProjectName Ops -DeploymentGroupName PTR9-QA -WindowsUser ADUser
         .LINK
            https://github.com/microsoft/azure-pipelines-agent/blob/master/src/Test/L0/Listener/Configuration/ConfigurationManagerL0.cs
         .LINK
            https://github.com/microsoft/azure-pipelines-agent/blob/master/src/Agent.Listener/Configuration/ConfigurationManager.cs#L185
         .LINK
            https://github.com/microsoft/azure-pipelines-agent/blob/master/src/Microsoft.VisualStudio.Services.Agent/Constants.cs#L80
         .OUTPUTS
            [System.Management.Automation.PathInfo] Path to agent folder
     #>
   [CmdletBinding(DefaultParameterSetName = "Automation")]
   param (
      # Authentication type: personal access token (pat) or windows default credentials (integrated)
      # If using pat you MUST specified your pat-token in varable $env:VSTS_AGENT_INPUT_token before you call.
      # Note:
      # Create a personal access token with name 'VstsAgent' for 'All accessible organizations' with Scopes:
      # Agent Pools (Read & mangage); Environment (Read & manage); Deployment Groups (Read & manage) 
      [ValidateSet("pat", "integrated")]
      [string]$Auth = "integrated",

      # Pool name under Agent pools. Use as automation agent in yaml file as keyword pool
      [Parameter(ParameterSetName = "Automation")]
      [string]$Pool,

      # Add User-defined capabilities to this automation agent
      [Parameter(ParameterSetName = "Automation")]
      [string[]]$CapabilityTags,

      # Environment name under Environments in your project. Use as deploy agent in release yaml file as keyword environment
      [Parameter(Mandatory, ParameterSetName = "Environment")]
      [string]$EnvironmentName,

      # List of custom tags using for this enviroment resource 
      [Parameter(ParameterSetName = "Environment")]
      [string[]]$EnvironmentVMResourceTags,

      # Pool name under Deployment pools. Use as deploy agent a cross projects in classic release pipeline
      [Parameter(Mandatory, ParameterSetName = "SharedDeploymentGroup")]
      [string]$DeploymentPoolName,

      # Group name under Deployment groups in your project. Use as deploy agent in one project in classic release pipeline
      [Parameter(Mandatory, ParameterSetName = "DeploymentGroup")]
      [string]$DeploymentGroupName,

      # List of custom tags using for this target deployment group
      [Parameter(ParameterSetName = "DeploymentGroup")]
      [string[]]$DeploymentGroupTags,
      
      # Project name under the collection
      [Parameter(Mandatory, ParameterSetName = "Environment")]
      [Parameter(Mandatory, ParameterSetName = "DeploymentGroup")]
      [ValidateSet("Ops", "Fax")]
      [string]$ProjectName,

      # Agent run as Windows service.
      # Default local user is "NT AUTHORITY\Network Service"
      # Admin local user is "NT AUTHORITY\SYSTEM"
      # ADUser, you MUST put user into $env:VSTS_AGENT_INPUT_windowslogonaccount
      # and password $env:VSTS_AGENT_INPUT_windowslogonpassword 
      [ValidateSet("NetworkService", "SYSTEM", "ADUser")]
      [string]$WindowsUser = "NetworkService",

      # Use this flag when you already have an agent unziped in the folder
      [switch]$SkipNewPackage = $false,

      # Path to agent home folder. If folder MUST exist
      [Parameter(ValueFromPipeline)]
      [ValidateScript( { Test-Path $_ })]
      [string]$AgentPath
   )
   begin {
      if ($Auth -eq "pat" -and $null -eq $env:VSTS_AGENT_INPUT_token) {
         throw "You must specified your pat-token in varable `$env:VSTS_AGENT_INPUT_token before you call"
      }
      if ($WindowsUser -eq "ADUser" -and $null -eq $env:VSTS_AGENT_INPUT_windowslogonaccount) {
         throw "You must specified ADUser name into in varable `$env:VSTS_AGENT_INPUT_windowslogonaccount before you call"
      }
      if ($WindowsUser -eq "ADUser" -and $null -eq $env:VSTS_AGENT_INPUT_windowslogonpassword) {
         throw "You must specified ADUser password into in varable `$env:VSTS_AGENT_INPUT_windowslogonpassword before you call"
      }
   }
   process {
      if ($AgentPath) {
         $AgentPath = Resolve-Path $AgentPath # Braces and belt. Fix to absolut path
      }
      else {
         $AgentBasePath = "E:/azagent"
         if (-not (Test-Path $AgentBasePath -IsValid)) {
            throw "Cannot using $AgentBasePath as base path. Please manually create a folder and use parameter -AgentPath"
         }

         # Create location folder
         $AgentLocationId = 1..10 | Where-Object { -not (Test-Path $AgentBasePath/A$_) } | Select-Object -First 1
         if ($AgentLocationId) {
            $AgentPath = New-Item $AgentBasePath/A$AgentLocationId -ItemType Directory
         }
         else {
            throw "Avoid using more than 10 agents on the same machine"
         }
      }
      
      if (-not ($SkipNewPackage)) {
         Save-VstsAgentPackage $AgentPath
      }

      if (-not (Test-Path $AgentPath/config.cmd)) {
         throw "File $AgentPath/config.cmd is missing"
      }

      # Check if you run as admin
      if (-not (Test-RunAsAdmin)) {
         throw "You MUST run this functions as Administrator"
      }

      # Add capabilities if needed
      if ($CapabilityTags) {
         $CapabilitiesFile = New-Item -Path $AgentPath -Name .capabilities -ItemType File
         $CapabilityTags | ForEach-Object { Add-Content -Path $CapabilitiesFile -Value "$_=" }
      }

      # Set arguments
      $Collectionname = "OpsCollection"
      [string[]]$ConfigureArgs = "--unattended"
      $ConfigureArgs += "--url 'https://dev.azure.com/henrikroos/'"
      $ConfigureArgs += "--auth '$Auth'"
      $ConfigureArgs += "--runAsService"

      if ($AgentLocationId) {
         $ConfigureArgs += "--agent '$env:COMPUTERNAME-$AgentLocationId'"
      }

      if ($Pool) {
         $ConfigureArgs += "--pool '$Pool'"
      }

      if ($EnvironmentName) {
         $ConfigureArgs += "--collectionname '$Collectionname'"
         $ConfigureArgs += "--environment"
         $ConfigureArgs += "--environmentname '$EnvironmentName'"
      }

      if ($EnvironmentVMResourceTags) {
         $ConfigureArgs += "--addvirtualmachineresourcetags"
         $ConfigureArgs += "--virtualmachineresourcetags '" + ($EnvironmentVMResourceTags -join ",") + "'"
      }

      if ($DeploymentPoolName) {
         $ConfigureArgs += "--deploymentpool"
         $ConfigureArgs += "--deploymentpoolname '$DeploymentPoolName'"
      }

      if ($DeploymentGroupName) {
         $ConfigureArgs += "--collectionname '$Collectionname'"
         $ConfigureArgs += "--deploymentgroup"
         $ConfigureArgs += "--deploymentgroupname '$DeploymentGroupName'"
      }
      
      if ($DeploymentGroupTags) {
         $ConfigureArgs += "--adddeploymentgrouptags"
         $ConfigureArgs += "--deploymentgrouptags '" + ($DeploymentGroupTags -join ",") + "'"
      }

      if ($ProjectName) {
         $ConfigureArgs += "--projectname '$ProjectName'"
      }

      if ($WindowsUser -eq "NetworkService") {
         $ConfigureArgs += "--windowslogonaccount 'NT AUTHORITY\Network Service'"
      }

      if ($WindowsUser -eq "SYSTEM") {
         $ConfigureArgs += "--windowslogonaccount 'NT AUTHORITY\SYSTEM'"
      }

      # Run agent config
      if (-not (Invoke-VstsAgentConfig -AgentPath $AgentPath -ConfigureArgs $ConfigureArgs)) {
         throw "The installation failed"
      }

      Write-Host "The installation was successful :-)"
      return $AgentPath
   }
}
