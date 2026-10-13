# Step 4 on DC01: OU structure, security groups, department share, shared printer.
$ErrorActionPreference = "Stop"
Import-Module ActiveDirectory
$base = (Get-ADDomain).DistinguishedName

function New-OUIfMissing($Name, $Path) {
    if (-not (Get-ADOrganizationalUnit -Filter "Name -eq '$Name'" -SearchBase $Path -SearchScope OneLevel)) {
        New-ADOrganizationalUnit -Name $Name -Path $Path
        Write-Host "OU created: $Name"
    }
}

New-OUIfMissing "Magna Users" $base
foreach ($dept in "Mining Operations", "Engineering", "Office") {
    New-OUIfMissing $dept "OU=Magna Users,$base"
}
New-OUIfMissing "Magna Computers" $base
New-OUIfMissing "Disabled Users" $base

# Newly joined computers land in Magna Computers instead of the default container
redircmp "OU=Magna Computers,$base"

foreach ($g in "GG-MiningOps", "GG-Engineering", "GG-Office") {
    if (-not (Get-ADGroup -Filter "Name -eq '$g'")) {
        New-ADGroup -Name $g -GroupScope Global -GroupCategory Security -Path "OU=Magna Users,$base"
        Write-Host "Group created: $g"
    }
}

# Office share: only GG-Office can change files (least privilege)
New-Item -ItemType Directory -Path "C:\Shares\Office" -Force | Out-Null
icacls "C:\Shares\Office" /inheritance:r /grant "Administrators:(OI)(CI)F" "SYSTEM:(OI)(CI)F" "MAGNALAB\GG-Office:(OI)(CI)M" | Out-Null
if (-not (Get-SmbShare -Name "Office" -ErrorAction SilentlyContinue)) {
    New-SmbShare -Name "Office" -Path "C:\Shares\Office" -FullAccess "MAGNALAB\Domain Admins" -ChangeAccess "MAGNALAB\GG-Office" | Out-Null
}
Write-Host "Share ready: \\DC01\Office"

# Lab printer (no real device, prints to file)
Add-PrinterDriver -Name "Generic / Text Only" -ErrorAction SilentlyContinue
if (-not (Get-Printer -Name "Office-Printer" -ErrorAction SilentlyContinue)) {
    Add-Printer -Name "Office-Printer" -DriverName "Generic / Text Only" -PortName "FILE:" -Shared -ShareName "OfficePrinter"
}
Write-Host "Printer shared: \\DC01\OfficePrinter"
