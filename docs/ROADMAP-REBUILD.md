# Rebuild roadmap (epic R)

This repo rebuilds the original AVD personal pool Terraform from scratch, so Austin writes every line himself. Same task format as the main roadmap: **Depends on**, **Done when**, **Fallback**, **Learn / teach**. Terraform is the source of truth; portal walkthroughs are for understanding, followed by `terraform plan` to show drift.

**Order (decided 2026-11-11):** E0.1 state recovery drill (in the original repo) → **R** → E1 CI/CD (targets this repo). Writing R replaces the E0.2 tour.

**How tasks run:** Claude explains and shows code in the chat in small pieces; Austin types it; Claude reviews with `fmt`, `validate`, `tflint` and `plan -out`; Austin applies. One branch and pull request per task; Austin runs every git command.

## Decisions for the rebuild (2026-11-11)
- **State:** reuse the existing state account (created by the original repo's `bootstrap/`), container `tfstate`, new key **`azure-avd-lab/dev.tfstate`**. No second bootstrap, budget or duplicate role assignments.
- **Naming:** prefix **`avdlab-dev`** (e.g. `rg-avdlab-dev`, `vdpool-avdlab-dev`), so nothing clashes with the original `rg-avd-dev`.
- **Address space:** VNet **`10.20.0.0/16`** (the original uses `10.10.0.0/16`). Non-overlapping ranges keep peering and a hub/spoke design possible later.
- **Original dev environment:** stays deployed and **deallocated** as a reference, then gets destroyed after R.6 shows parity. Austin applies the destroy.
- **Repo:** stays **public**; no GitHub Pro (changed later on 2026-11-11). On public repos, protected environments with required reviewers and branch protection are free, so E1 task 1.2 needs no paid plan. Rules that follow from it:
  - Never commit tenant/subscription IDs, UPNs, account or storage account names. They go in `.env` / `*.tfvars` (git-ignored).
  - In E1, don't post full plan output as a PR comment (logs and comments are public). Use a short summary (add/change/destroy counts) and keep the full plan as a workflow artifact.
  - OIDC federated credentials trust only this repo's `pull_request` / `environment:dev` subjects. Pull requests from forks get no Azure access or secrets.
- **Layout:** the same shape as the original: `environments/dev` calling `modules/<name>`. Each module is written when its task needs it.

| # | Task | Depends on | Est. | Status |
|---|---|---|---|---|
| R.1 | Providers, backend, resource group | E0.1 | 1.5 h | todo |
| R.2 | Networking module | R.1 | 2 h | todo |
| R.3 | Users and group | R.1 | 1.5 h | todo |
| R.4 | Host pool, app group, workspace, roles | R.2, R.3 | 2.5 h | todo |
| R.5 | Session hosts | R.4 | 3 h | todo |
| R.6 | Parity check and retire the original | R.5 | 1 h | todo |

**R.1 Providers, backend, resource group**
- *Does:* `versions.tf` (pinned Terraform and providers: `azurerm`, `azuread`, `random`), `backend.tf` (`azurerm` backend with Entra ID auth, so no storage keys), variables with validation, and `rg-avdlab-dev` with tags.
- *Done when:* `terraform init` shows the remote backend, the `azure-avd-lab/dev.tfstate` blob exists after apply, and a second `plan` shows no changes.
- *Fallback:* `terraform destroy`, then delete the blob key. The original state keys are untouched.
- *Learn / teach:* provider version constraints and the lock file; why the backend can't use variables; how the state lock works (blob lease); the RG in the portal next to its state blob.

**R.2 Networking module**
- *Does:* `modules/networking`: VNet `10.20.0.0/16`, a session host subnet sized for growth to hundreds of hosts, an NSG with no inbound rules, and the subnet association. Outputs the subnet ID.
- *Done when:* `plan` is clean after apply; the NSG has no inbound allow rules beyond the defaults.
- *Learn / teach:* why AVD needs no inbound ports (reverse connect); subnet sizing math; module inputs and outputs.

**R.3 Users and group**
- *Does:* cloud-only test users with random temporary passwords (`force_password_change`), and the `AVD Personal Users (avdlab-dev)` group.
- *Done when:* users and group appear in Entra; passwords are only in state and in a sensitive output.
- *Learn / teach:* why state is sensitive (it holds those passwords); `for_each` over a map vs `count`.

**R.4 Host pool, app group, workspace, roles**
- *Does:* `modules/host-pool`: Personal pool (Persistent, `Automatic` assignment, Start VM on Connect), Desktop app group, workspace and association. Role assignments: Desktop Virtualization User for the group; Power On Contributor for the AVD service principal.
- *Applied by:* Austin (role assignments).
- *Done when:* the workspace shows in the portal; `plan` is clean.
- *Learn / teach:* control plane vs session hosts; RBAC scopes; why Start VM on Connect needs a role on the RG.

**R.5 Session hosts**
- *Does:* `modules/session-hosts`: stock `win11-25h2-ent`, `Standard_D2s_v6` (NVMe controller), Trusted Launch, StandardSSD, `Windows_Client` license, AADLoginForWindows with Intune (`mdmId`), the AVD agent with a registration token, VM User Login for the group, and auto-shutdown at 19:00 Eastern.
- *Watch for:* Windows computer names are limited to 15 characters (`vm-avdlab-dev-0` is exactly 15). Do the manual tenant steps in `docs/intune-avd-setup.md` first.
- *Done when:* `avduser1` signs in through the Windows App; the host shows as Entra-joined and enrolled in Intune; the VM is deallocated afterwards.
- *Cost:* host run time while testing. Deallocate when done.

**R.6 Parity check and retire the original**
- *Does:* compare the rebuild with the original resource by resource (graphify on both repos, plus the portal). Write down any differences and the reasons for them. Then Austin destroys the original dev environment.
- *Done when:* the differences are documented, the original `rg-avd-dev` is gone, and spend is back to a single environment.

**Exit check R:** Austin can rebuild the environment from an empty subscription (plus the state account) and explain every resource.
