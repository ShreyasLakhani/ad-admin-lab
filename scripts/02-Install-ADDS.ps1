# Step 2 on DC01: install AD DS, DNS and DHCP, then create the magnalab.local forest.
# The server restarts at the end. Log back in as MAGNALAB\Administrator.
$ErrorActionPreference = "Stop"
Install-WindowsFeature AD-Domain-Services, DNS, DHCP -IncludeManagementTools

$dsrm = Read-Host "Directory Services Restore Mode password" -AsSecureString
Install-ADDSForest `
    -DomainName "magnalab.local" `
    -DomainNetbiosName "MAGNALAB" `
    -InstallDns `
    -SafeModeAdministratorPassword $dsrm `
    -Force
