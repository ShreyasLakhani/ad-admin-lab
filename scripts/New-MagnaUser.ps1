<#
Onboarding: creates domain accounts for new hires from a CSV.
For each row: builds the username, creates the user in the department OU,
sets a temporary password that must be changed at first logon,
adds the user to the department group, and logs every action.
Usage:  .\New-MagnaUser.ps1            (uses new_hires.csv next to the script)
        .\New-MagnaUser.ps1 -CsvPath C:\path\file.csv
#>
param(
    [string]$CsvPath = "$PSScriptRoot\new_hires.csv",
    [string]$Domain  = "magnalab.local"
)
Import-Module ActiveDirectory

$logDir = Join-Path $PSScriptRoot "logs"
New-Item -ItemType Directory -Path $logDir -Force | Out-Null
$log = Join-Path $logDir ("onboarding_{0}.log" -f (Get-Date -Format yyyyMMdd))
function Write-Log([string]$Message) {
    $line = "{0}  {1}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $Message
    Add-Content -Path $log -Value $line
    Write-Host $line
}

$groupByDept = @{
    "Mining Operations" = "GG-MiningOps"
    "Engineering"       = "GG-Engineering"
    "Office"            = "GG-Office"
}
$base = (Get-ADDomain).DistinguishedName
$tempPassword = Read-Host "Temporary password for new hires" -AsSecureString

foreach ($hire in Import-Csv -Path $CsvPath) {
    $sam = ($hire.FirstName.Substring(0,1) + $hire.LastName).ToLower()

    if (-not $groupByDept.ContainsKey($hire.Department)) {
        Write-Log "SKIPPED $sam : unknown department '$($hire.Department)'"
        continue
    }
    if (Get-ADUser -Filter "SamAccountName -eq '$sam'") {
        Write-Log "SKIPPED $sam : account already exists"
        continue
    }

    $ou = "OU=$($hire.Department),OU=Magna Users,$base"
    try {
        New-ADUser -Name "$($hire.FirstName) $($hire.LastName)" `
            -GivenName $hire.FirstName -Surname $hire.LastName `
            -SamAccountName $sam -UserPrincipalName "$sam@$Domain" `
            -Title $hire.Title -Department $hire.Department `
            -Path $ou -AccountPassword $tempPassword `
            -ChangePasswordAtLogon $true -Enabled $true
        Add-ADGroupMember -Identity $groupByDept[$hire.Department] -Members $sam
        Write-Log "CREATED $sam ($($hire.Title)) in $($hire.Department), added to $($groupByDept[$hire.Department])"
    }
    catch {
        Write-Log "ERROR $sam : $($_.Exception.Message)"
    }
}
Write-Log "Onboarding run finished. Log: $log"
