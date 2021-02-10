---
external help file: VstsAgentWin-help.xml
Module Name: VstsAgentWin
online version: https://github.com/microsoft/azure-pipelines-agent/blob/master/src/Test/L0/Listener/Configuration/ConfigurationManagerL0.cs
schema: 2.0.0
---

# Uninstall-VstsAgentWin

## SYNOPSIS
Uninstall Self-hosted Azure Pipelines agent on this machine.

## SYNTAX

```
Uninstall-VstsAgentWin [-AgentPath] <String> [[-Auth] <String>] [-SkipDeleteFolder] [<CommonParameters>]
```

## DESCRIPTION
You MUST run this function as Administrator, because you are going to create a windows service.
If you like to save agent folder after uninstall i Azure DevOps use SkipDeleteFolder flag.

## EXAMPLES

### EXAMPLE 1
```
Uninstall-VstsAgentWin -AgentPath "E:\azagent\A1"
```

### EXAMPLE 2
```
"E:\azagent\A1","E:\azagent\A2" | Uninstall-VstsAgentWin
```

### EXAMPLE 3
```
Uninstall-VstsAgentWin E:\azagent\A1 -SkipDeleteFolder
```

### EXAMPLE 4
```
# Reconfigure all agents in the folder
> Get-ChildItem E:\azagent | Uninstall-VstsAgentWin -SkipDeleteFolder | Install-VstsAgentWin -Pool MyPool -CapabilityTags CoolTag1,CoolTag2
```

## PARAMETERS

### -AgentPath
Path to agent home folder.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Auth
Authentication type: personal access token (pat) or windows default credentials (integrated)
If using pat you MUST specified your pat-token in varable $env:VSTS_AGENT_INPUT_token before you call
Create a personal access token with name 'VstsAgent' for 'All accessible organizations' with Scopes:
Agent Pools (Read & mangage); Environment (Read & manage); Deployment Groups (Read & manage)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: Integrated
Accept pipeline input: False
Accept wildcard characters: False
```

### -SkipDeleteFolder
Save agent folder after uninstall i Azure DevOps

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### None, [System.Management.Automation.PathInfo] Path to agent folder if using SkipDeleteFolder
## NOTES

## RELATED LINKS
