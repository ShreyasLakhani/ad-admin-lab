<#
Offboarding: secures a leaver's account the same day they leave.
Order matters: disable first so the account cannot be used,
then remove access, scramble the password, record why, and move it.
The account is kept (not deleted) so files and audit history stay linked.
Usage:  .\Remove-MagnaUser.ps1 -UserName ntremblay -Ticket HD-1042
#>
param(
    [Parameter(Mandatory)][string]$UserName,
    [string]$Ticket = "N/A"
)
Import-Module ActiveDirectory

$logDir = Join-Path $PSScriptRoot "logs"
New-Item -ItemType Directory -Path $logDir -Force | Out-Null
$log = Join-Path $logDir ("offboarding_{0}.log" -f (Get-Date -Format yyyyMMdd))
function Write-Log([string]$Message) {
    $line = "{0}  {1}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $Message
    Add-Content -Path $log -Value $line
    Write-Host $line
}

try {
    $user = Get-ADUser -Identity $UserName -Properties MemberOf
} catch {
    Write-Log "ERROR $UserName : user not found"
    exit 1
}
$base = (Get-ADDomain).DistinguishedName

# 1. Disable the account
Disable-ADAccount -Identity $user
Write-Log "DISABLED $UserName"

# 2. Remove every group membership (Domain Users is the primary group and stays)
foreach ($groupDn in $user.MemberOf) {
    Remove-ADGroupMember -Identity $groupDn -Members $user -Confirm:$false
    Write-Log "REMOVED $UserName from $((Get-ADGroup $groupDn).Name)"
}

# 3. Scramble the password so an old password cannot be reused
$random = -join ((48..57) + (65..90) + (97..122) + 33,35,36,37 | Get-Random -Count 24 | ForEach-Object { [char]$_ })
Set-ADAccountPassword -Identity $user -Reset -NewPassword (ConvertTo-SecureString $random -AsPlainText -Force)
Write-Log "PASSWORD RESET to random value for $UserName"

# 4. Record when and why
Set-ADUser -Identity $user -Description ("Disabled {0} ticket {1}" -f (Get-Date -Format yyyy-MM-dd), $Ticket)

# 5. Move to the Disabled Users OU
Move-ADObject -Identity $user.DistinguishedName -TargetPath "OU=Disabled Users,$base"
Write-Log "MOVED $UserName to Disabled Users. Offboarding complete."
