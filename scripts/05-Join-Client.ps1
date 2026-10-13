# Run on CLIENT01 (PowerShell as Administrator) after its network is set to labnet.
# Checks it can reach the DC, then joins magnalab.local and restarts.
$ErrorActionPreference = "Stop"
ipconfig /all | Select-String "IPv4|DNS Servers"
if (-not (Test-Connection 10.0.2.10 -Count 2 -Quiet)) { throw "Cannot reach DC01 at 10.0.2.10. Check the network adapter is on labnet." }
Resolve-DnsName magnalab.local | Out-Null
$cred = Get-Credential -Message "Domain admin" -UserName "MAGNALAB\Administrator"
Add-Computer -DomainName "magnalab.local" -Credential $cred -Restart
