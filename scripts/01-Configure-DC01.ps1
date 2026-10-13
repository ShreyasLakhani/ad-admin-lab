# Step 1 on DC01: static IP and computer name. The server restarts at the end.
# Run in PowerShell as Administrator.
$ErrorActionPreference = "Stop"
$nic = Get-NetAdapter | Where-Object Status -eq "Up" | Select-Object -First 1

# Static IP on the lab network (VirtualBox NAT Network "labnet", gateway 10.0.2.1)
Remove-NetIPAddress -InterfaceIndex $nic.ifIndex -Confirm:$false -ErrorAction SilentlyContinue
Remove-NetRoute -InterfaceIndex $nic.ifIndex -Confirm:$false -ErrorAction SilentlyContinue
New-NetIPAddress -InterfaceIndex $nic.ifIndex -IPAddress 10.0.2.10 -PrefixLength 24 -DefaultGateway 10.0.2.1
# Public DNS for now so Windows Update works. Step 2 switches DNS to the server itself.
Set-DnsClientServerAddress -InterfaceIndex $nic.ifIndex -ServerAddresses 8.8.8.8

Write-Host "IP set to 10.0.2.10. Renaming to DC01 and restarting..."
Rename-Computer -NewName "DC01" -Restart
