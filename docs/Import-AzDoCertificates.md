---
external help file: VstsAgentWin-help.xml
Module Name: VstsAgentWin
online version:
schema: 2.0.0
---

# Import-AzDoCertificates

## SYNOPSIS
Install an intermediate or root certificate on this computer.
You MUST run this function as Administrator

## SYNTAX

```
Import-AzDoCertificates
```

## DESCRIPTION
If the cert have a parent is it a intermediate cert and the cert is installd into CA folder
If the cert do not have a parent is it a Root cert and the cert is installd into Root folder
This function is idempotent

## EXAMPLES

### EXAMPLE 1
```
Import-AzDoCertificate
```

## PARAMETERS

## INPUTS

### No input
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
