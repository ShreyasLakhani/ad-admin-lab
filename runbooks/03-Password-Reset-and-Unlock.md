# Runbook: Password Reset and Account Unlock

1. Verify the caller's identity before changing anything (employee ID or manager callback).
2. Check if the account is locked:
   `Get-ADUser <username> -Properties LockedOut, BadLogonCount, LastBadPasswordAttempt`
3. If locked and the user just forgot the password, unlock:
   `Unlock-ADAccount <username>`
4. If a reset is needed:
   `Set-ADAccountPassword <username> -Reset` then `Set-ADUser <username> -ChangePasswordAtLogon $true`
5. Many lockouts in a short time with no user error can mean a saved old password on a phone or mapped drive, or an attack. Escalate if the user did not cause it.
6. Note the ticket number and what was done.

Lab policy: 5 failed attempts locks the account for 15 minutes.
