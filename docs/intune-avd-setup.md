# Intune + AVD personal pool: manual steps

Terraform builds the AVD resources and Entra-joins each session host with Intune
enrollment (`mdmId` on the AADLoginForWindows extension). These tenant settings
have no Terraform resource and must be in place **before** session hosts deploy,
or the Intune enrollment step fails.

## 1. Licensing

The tenant needs a license that includes Intune and Windows Enterprise / AVD
access rights. Microsoft 365 Business Premium (trial: 25 seats) covers Intune
Plan 1, Entra ID P1, and Windows client rights for AVD.

- Microsoft 365 admin center → Billing → Purchase services → start the trial.
- After `terraform apply`, assign the license to each AVD user
  (`terraform output avd_user_upns`).

## 2. Intune automatic enrollment

Intune admin center → Devices → Enrollment → Windows → Automatic Enrollment:

- **MDM user scope**: All, or the `AVD Personal Users (<prefix>)` group.

## 3. Entra device join

Entra admin center → Devices → Device settings:

- **Users may join devices to Microsoft Entra**: All (the default).

## Signing in

Users connect at https://windows.cloud.microsoft (or the Windows App) with their
cloud-only UPN. Guest / personal Microsoft accounts can't sign in to
Entra-joined session hosts.

```bash
terraform output avd_user_upns
terraform output -json avd_user_passwords   # temporary; change at first sign-in
```
