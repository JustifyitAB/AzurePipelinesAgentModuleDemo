. $PSScriptRoot\Test-RunAsAdmin.ps1
function Import-AzDoCertificates {
   <#
         .Synopsis
            Install an intermediate or root certificate on this computer. You MUST run this function as Administrator
         .DESCRIPTION
            If the cert have a parent is it a intermediate cert and the cert is installd into CA folder
            If the cert do not have a parent is it a Root cert and the cert is installd into Root folder
            This function is idempotent
         .EXAMPLE
            Import-AzDoCertificate
         .INPUTS
            No input
         .OUTPUTS
            System.Object
     #>
   foreach ($FilePath in (Get-ChildItem $PSScriptRoot\certificate | Convert-Path)) {
      $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 $FilePath
      $chain = New-Object System.Security.Cryptography.X509Certificates.X509Chain
      $chain.build($cert) | Out-Null
      
      if ($chain.ChainElements.Count -eq 1) {
         $location = "Cert:\LocalMachine\Root"
      }
      else {
         $location = "Cert:\LocalMachine\CA"
      }

      $thumbprint = $cert.Thumbprint

      if (Get-ChildItem -Path Cert:\LocalMachine\CA | Where-Object Thumbprint -eq $thumbprint) {
         Write-Host "The certificate $thumbprint is already installed in $location"
      }
      else {
         # Check if you run as admin
         if (-not (Test-RunAsAdmin)) {
            throw "You MUST run this functions as Administrator"
         }
         Write-Host "Try to install the certificate $thumbprint into $location"
         Import-Certificate -FilePath $FilePath -CertStoreLocation $location
      }
   }
}