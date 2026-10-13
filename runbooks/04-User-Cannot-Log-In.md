# Runbook: User Cannot Log In to a Domain PC

Work from the most common cause to the least.

1. Caps Lock, keyboard layout, typo. Ask the user to type the password in the username box to see it.
2. Account locked or disabled? Check in AD (see runbook 03).
3. Network: is the cable in or Wi-Fi connected? Run `ipconfig`. An address starting 169.254 means no DHCP.
4. DNS: the PC must use the DC for DNS. `nslookup magnalab.local` should answer from 10.0.2.10.
5. Time: more than 5 minutes off the DC breaks Kerberos. `w32tm /resync`.
6. "Trust relationship failed": rejoin the PC to the domain or run `Test-ComputerSecureChannel -Repair`.
7. If none of these fix it, escalate with the steps tried and the exact error message.
