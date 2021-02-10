---
external help file: VstsAgentWin-help.xml
Module Name: VstsAgentWin
online version: https://github.com/microsoft/azure-pipelines-agent/blob/master/src/Test/L0/Listener/Configuration/ConfigurationManagerL0.cs
schema: 2.0.0
---

# Install-VstsAgentWin

## SYNOPSIS
Download and install Self-hosted Azure Pipelines agent on this machine.

## SYNTAX

### Automation (Default)
```
Install-VstsAgentWin [-Auth <String>] [-Pool <String>] [-CapabilityTags <String[]>] [-WindowsUser <String>]
 [-SkipNewPackage] [-AgentPath <String>] [<CommonParameters>]
```

### Environment
```
Install-VstsAgentWin [-Auth <String>] -EnvironmentName <String> [-EnvironmentVMResourceTags <String[]>]
 -ProjectName <String> [-WindowsUser <String>] [-SkipNewPackage] [-AgentPath <String>] [<CommonParameters>]
```

### SharedDeploymentGroup
```
Install-VstsAgentWin [-Auth <String>] -DeploymentPoolName <String> [-WindowsUser <String>] [-SkipNewPackage]
 [-AgentPath <String>] [<CommonParameters>]
```

### DeploymentGroup
```
Install-VstsAgentWin [-Auth <String>] -DeploymentGroupName <String> [-DeploymentGroupTags <String[]>]
 -ProjectName <String> [-WindowsUser <String>] [-SkipNewPackage] [-AgentPath <String>] [<CommonParameters>]
```

## DESCRIPTION
You MUST run this function as Administrator, because you are going to create a windows service.
You MUST have permissions to register or unregister agent i Azure DevOps.
This is a high level permission so only
adm- user have that permissions.
This function use windows default credential for login into Azure DevOps.

The agent can be configurated in 4 different ways:

- BuildReleasesAgent.
New and classic way in Automation.
Use as automation agent in yaml file as keyword pool or as classic build agent
- EnvironmentVMResource.
New way in Deployment.
Use as deploy agent in release yaml file as keyword environment
- SharedDeployment.
Classic way in Deployment.
Use as deploy agent in cross projects in classic release pipeline
- DeploymentAgent.
Classic way in Deployment.
Use as deploy agent in one project in classic click in UI release pipeline

There are two different pool types: Automation (Agent pools) and Deployment (Deployment pools)

## EXAMPLES

### EXAMPLE 1
```
Install-VstsAgentWin
```

### EXAMPLE 2
```
Install-VstsAgentWin -Pool CM -CapabilityTags DatabaseRight,GDPR
```

### EXAMPLE 3
```
Install-VstsAgentWin -EnvironmentName Dev -EnvironmentVMResourceTags XE8
```

### EXAMPLE 4
```
Install-VstsAgentWin -DeploymentPoolName PTR9-Test -WindowsUser SYSTEM
```

### EXAMPLE 5
```
Install-VstsAgentWin -DeploymentGroupName KJ7-Prod -ProjectName Ops -DeploymentGroupTags Web,App
```

### EXAMPLE 6
```
"E:/azagent/A2" | Install-VstsAgentWin -DeploymentPoolName MyPool -SkipNewPackage
```

### EXAMPLE 7
```
$env:VSTS_AGENT_INPUT_windowslogonaccount = "nameofuser@justifyit.se"
> $env:VSTS_AGENT_INPUT_windowslogonpassword = "MyPassword"
> Install-VstsAgentWin -ProjectName Ops -DeploymentGroupName PTR9-QA -WindowsUser ADUser
```

## PARAMETERS

### -Auth
Authentication type: personal access token (pat) or windows default credentials (integrated)
If using pat you MUST specified your pat-token in varable $env:VSTS_AGENT_INPUT_token before you call.
Note:
Create a personal access token with name 'VstsAgent' for 'All accessible organizations' with Scopes:
Agent Pools (Read & mangage); Environment (Read & manage); Deployment Groups (Read & manage)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Integrated
Accept pipeline input: False
Accept wildcard characters: False
```

### -Pool
Pool name under Agent pools.
Use as automation agent in yaml file as keyword pool

```yaml
Type: String
Parameter Sets: Automation
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CapabilityTags
Add User-defined capabilities to this automation agent

```yaml
Type: String[]
Parameter Sets: Automation
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -EnvironmentName
Environment name under Environments in your project.
Use as deploy agent in release yaml file as keyword environment

```yaml
Type: String
Parameter Sets: Environment
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -EnvironmentVMResourceTags
List of custom tags using for this enviroment resource

```yaml
Type: String[]
Parameter Sets: Environment
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DeploymentPoolName
Pool name under Deployment pools.
Use as deploy agent a cross projects in classic release pipeline

```yaml
Type: String
Parameter Sets: SharedDeploymentGroup
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DeploymentGroupName
Group name under Deployment groups in your project.
Use as deploy agent in one project in classic release pipeline

```yaml
Type: String
Parameter Sets: DeploymentGroup
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DeploymentGroupTags
List of custom tags using for this target deployment group

```yaml
Type: String[]
Parameter Sets: DeploymentGroup
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProjectName
Project name under the collection

```yaml
Type: String
Parameter Sets: Environment, DeploymentGroup
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WindowsUser
Agent run as Windows service.
Default local user is "NT AUTHORITY\Network Service"
Admin local user is "NT AUTHORITY\SYSTEM"
ADUser, you MUST put user into $env:VSTS_AGENT_INPUT_windowslogonaccount
and password $env:VSTS_AGENT_INPUT_windowslogonpassword

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: NetworkService
Accept pipeline input: False
Accept wildcard characters: False
```

### -SkipNewPackage
Use this flag when you already have an agent unziped in the folder

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -AgentPath
Path to agent home folder.
If folder MUST exist

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### [System.Management.Automation.PathInfo] Path to agent folder
## NOTES

## RELATED LINKS

[https://github.com/microsoft/azure-pipelines-agent/blob/master/src/Test/L0/Listener/Configuration/ConfigurationManagerL0.cs](https://github.com/microsoft/azure-pipelines-agent/blob/master/src/Test/L0/Listener/Configuration/ConfigurationManagerL0.cs)

[https://github.com/microsoft/azure-pipelines-agent/blob/master/src/Agent.Listener/Configuration/ConfigurationManager.cs#L185](https://github.com/microsoft/azure-pipelines-agent/blob/master/src/Agent.Listener/Configuration/ConfigurationManager.cs#L185)

[https://github.com/microsoft/azure-pipelines-agent/blob/master/src/Microsoft.VisualStudio.Services.Agent/Constants.cs#L80](https://github.com/microsoft/azure-pipelines-agent/blob/master/src/Microsoft.VisualStudio.Services.Agent/Constants.cs#L80)

