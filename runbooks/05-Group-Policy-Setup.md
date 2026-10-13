# Runbook: Group Policy Setup (done in the GUI on DC01)

Open Group Policy Management (Server Manager > Tools).

## Account lockout
1. Edit **Default Domain Policy**.
2. Computer Configuration > Policies > Windows Settings > Security Settings > Account Policies > Account Lockout Policy.
3. Account lockout threshold: 5. Lockout duration: 15 minutes. Reset counter after: 15 minutes.

## Drive mapping (S: to the Office share)
1. Right-click the **Magna Users** OU > Create a GPO and link it here > name `Map Office Drive`.
2. Edit > User Configuration > Preferences > Windows Settings > Drive Maps > New > Mapped Drive.
3. Action: Create. Location: `\\DC01\Office`. Drive letter: S. Label: Office.
4. Common tab > tick Item-level targeting > Targeting > New Item > Security Group > `MAGNALAB\GG-Office`.

## Printer deployment
1. Create and link a GPO on **Magna Users** named `Deploy Office Printer`.
2. Edit > User Configuration > Preferences > Control Panel Settings > Printers > New > Shared Printer.
3. Action: Create. Share path: `\\DC01\OfficePrinter`.

## Test on CLIENT01
1. Log in as an Office user (for example `nroy`).
2. Run `gpupdate /force`, sign out and back in.
3. Run `gpresult /r` and check both GPOs are listed under Applied Group Policy Objects.
4. Check S: drive and Office-Printer appear.
5. Log in as a Mining Operations user. S: should NOT appear. This proves the targeting works.
