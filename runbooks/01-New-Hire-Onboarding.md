# Runbook: New Hire Onboarding

Use when HR confirms a start date. Complete at least one day before the start.

1. Get the new hire's first name, last name, department and title from HR.
2. Add a row to `scripts/new_hires.csv`. Department must be Mining Operations, Engineering or Office.
3. On DC01, open PowerShell as Administrator and run `.\New-MagnaUser.ps1`.
4. Enter a temporary password that meets the domain password policy.
5. Check the log in `scripts\logs`. Every row should say CREATED.
6. Confirm in Active Directory Users and Computers that the user is in the right OU and group.
7. Set up the laptop: join it to the domain, log in once as the user, check the S: drive and printer appear.
8. Give the user the temporary password in person or by phone, never by email. They must change it at first logon.
9. Record the ticket number and close the request.
