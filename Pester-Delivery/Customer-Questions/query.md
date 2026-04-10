# Customer Query — Automated Policy Testing with Pester

> **Context:** AzPolicyAutomationV2 — self-developed PowerShell product for managing Azure Policy lifecycle  
> **Current State:** Manual testing before rollout to DEV → QA → PROD tenants  
> **Goal:** Replace manual test plans with automated, repeatable Pester tests

---

## Product Overview

**AzPolicyAutomationV2** manages three Azure Policy artifact types:

| Artifact | Storage | Rollout |
|---|---|---|
| Custom PolicyDefinitions | JSON files in repo | Azure DevOps Build Pipeline |
| Custom PolicySetDefinitions | JSON files in repo | Azure DevOps Build Pipeline |
| PolicyAssignments | JSON files (custom structure) in repo | Azure DevOps Build Pipeline |

**Current CI/CD pipeline flow:**

```
Repository (JSON files) → Azure DevOps Build Pipeline → DEV Tenant → QA Tenant → PROD Tenant
```

**Existing automation:**
- JSON format validation is already implemented
- No Pester tests exist yet

---

## The Manual Test Plan (To Be Automated)

### Example: NSG Diagnostic Logging Policy

**Policy Purpose:**  
Configure DiagnosticLogs for `Microsoft.Network/networkSecurityGroups` to send security-relevant logging data to a central Log Analytics Workspace where the SIEM system collects logs for investigations.

**Policy Details:**

| Property | Value |
|---|---|
| Assignment Scope | BASF_ManagementRoot |
| Resource Type Scope | Microsoft.Network/networkSecurityGroups |
| Additional Filters | None |

**Expected Diagnostic Settings:**

| Setting | Expected Value |
|---|---|
| Diagnostic setting name | `service` |
| Category: Network Security Group Event | Enabled |
| Category: Network Security Group Rule Counter | Enabled |
| Destination | Send to Log Analytics Workspace |
| Workspace Resource ID | `/subscriptions/ee5f8667-c5cd-4990-b756-8360bf2be985/resourcegroups/basf_rg_monitoring_chub01/providers/microsoft.operationalinsights/workspaces/monitoring-chub01-firstwave` |

**Manual Test Steps:**

1. **Deploy-and-Verify:** Deploy a new NSG → check if DiagnosticLogs are configured with all expected settings
2. **Drift-and-Remediate:** Change settings on the NSG → run remediation task → verify policy corrects all settings
3. **Remediate-Existing:** For existing resources → run remediation task at the given scope → verify compliance

---

## Key Challenges

1. **These are integration tests** — they interact with real Azure tenants, not mocked environments
2. **Multi-tenant rollout** — same policies must work across DEV, QA, and PROD
3. **JSON validation alone is insufficient** — valid JSON doesn't mean valid policy behavior
4. **Manual testing doesn't scale** — each new policy or policy update requires the same 3-step manual process
5. **No regression coverage** — changes to one policy could break others silently

---

## What the Customer Needs

1. **Pre-deployment validation** (before rollout): Are the JSON artifacts structurally correct and complete?
2. **Baseline testing** (unit/integration): Does the policy definition contain the right rules, effects, and parameters?
3. **Post-deployment verification** (integration): After rollout, is the policy applied and resources compliant?
4. **Remediation testing** (integration): After drift, does remediation restore the expected state?
5. **Regression suite** that runs in the Azure DevOps pipeline before promoting to the next tenant
