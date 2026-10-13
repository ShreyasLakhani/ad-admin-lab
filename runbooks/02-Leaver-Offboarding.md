# Runbook: Leaver Offboarding

Use on the employee's last day, as soon as HR confirms they have left.

1. Confirm the username and the HR ticket number.
2. On DC01, open PowerShell as Administrator and run:
   `.\Remove-MagnaUser.ps1 -UserName <username> -Ticket <ticket>`
3. The script disables the account, removes all group access, scrambles the password, records the date and ticket, and moves the account to Disabled Users.
4. Check the log in `scripts\logs` shows each step.
5. Collect the laptop, phone and badge. Update the asset record.
6. Keep the account disabled for 90 days, then delete it if the manager agrees.

Why disable first: it stops access straight away. Deleting at once would break file ownership and audit history.
