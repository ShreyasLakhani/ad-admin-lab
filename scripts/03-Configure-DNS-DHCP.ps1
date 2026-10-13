# Step 3 on DC01: DNS forwarder and a DHCP scope for lab clients.
$ErrorActionPreference = "Stop"
$nic = Get-NetAdapter | Where-Object Status -eq "Up" | Select-Object -First 1

# The DC points to itself for DNS. Outside names go to a public resolver.
Set-DnsClientServerAddress -InterfaceIndex $nic.ifIndex -ServerAddresses 127.0.0.1
if (-not (Get-DnsServerForwarder).IPAddress) { Add-DnsServerForwarder -IPAddress 8.8.8.8 }

# DHCP: authorize in AD, create security groups, add the scope
Add-DhcpServerSecurityGroup
Restart-Service dhcpserver
Add-DhcpServerInDC -DnsName "dc01.magnalab.local" -IPAddress 10.0.2.10
if (-not (Get-DhcpServerv4Scope -ErrorAction SilentlyContinue | Where-Object ScopeId -eq "10.0.2.0")) {
    Add-DhcpServerv4Scope -Name "Lab Clients" -StartRange 10.0.2.100 -EndRange 10.0.2.200 -SubnetMask 255.255.255.0 -State Active
}
Set-DhcpServerv4OptionValue -ScopeId 10.0.2.0 -Router 10.0.2.1 -DnsServer 10.0.2.10 -DnsDomain "magnalab.local"

# Tell Server Manager the DHCP post-install task is done
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\ServerManager\Roles\12" -Name ConfigurationState -Value 2

Write-Host "DNS and DHCP ready. Scope 10.0.2.100 to 10.0.2.200."
