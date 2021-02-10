function Test-RunAsAdmin {
   $User = [Security.Principal.WindowsIdentity]::GetCurrent();
   return (New-Object Security.Principal.WindowsPrincipal $User).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}