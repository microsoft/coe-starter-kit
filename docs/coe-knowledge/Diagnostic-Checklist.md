# CoE Inventory Diagnostic Checklist

Use this checklist to systematically diagnose inventory flow issues. Complete each section and note your findings.

## Pre-Diagnostic Information

**Date of check**: _______________  
**Last upgrade date**: _______________  
**CoE Core Components version**: _______________  
**Approximate tenant size**: 
- Number of environments: _______________
- Number of apps: _______________
- Number of flows: _______________

## Section 1: Driver Flow Health Check

**Flow Name**: Admin - Sync Template v4 (Driver)

- [ ] **Flow is turned ON**
  - Status: ⚪ On / ⚪ Off
  - If Off, turn it on and proceed

- [ ] **Recent run exists** (within last 48 hours)
  - Last run date/time: _______________
  - If no recent run, manually trigger the flow

- [ ] **Last run completed successfully**
  - Status: ⚪ Succeeded / ⚪ Failed / ⚪ Running / ⚪ Cancelled
  - If Failed, note error: _______________________________________________

- [ ] **Run duration is reasonable**
  - Duration: _______________ (hours:minutes)
  - Expected: 15 min - 4 hours depending on tenant size
  - If > 8 hours, investigate for hanging steps

- [ ] **No throttling errors** (429 responses)
  - Throttling detected: ⚪ Yes / ⚪ No
  - If Yes, this is expected - flows will retry automatically

**Driver Flow Assessment**: ⚪ Healthy / ⚪ Needs Attention / ⚪ Critical Issue

---

## Section 2: Environments Table Validation

**Table Name**: admin_environment (Environments)

- [ ] **Table contains records**
  - Record count: _______________
  - If 0, Driver flow has not completed successfully

- [ ] **Recent data exists**
  - Latest "Modified On" date: _______________
  - Expected: Within last 48 hours
  - If older, Driver flow may not be running

- [ ] **All environments are listed**
  - Missing environments: ⚪ None / ⚪ Some / ⚪ Many
  - If missing, check Driver flow filters and permissions

- [ ] **Environment data looks complete**
  - Fields populated: ⚪ Yes / ⚪ Partial / ⚪ Mostly empty
  - Key fields to check: Name, Environment ID, Created On

**Environments Table Assessment**: ⚪ Healthy / ⚪ Needs Attention / ⚪ Critical Issue

---

## Section 3: Apps Child Flow Health Check

**Flow Name**: Admin - Sync Template v4 (Apps)

- [ ] **Flow is turned ON**
  - Status: ⚪ On / ⚪ Off
  - If Off, turn it on

- [ ] **Recent runs exist** (within last 48 hours)
  - Number of recent runs: _______________
  - Expected: Multiple runs (one per environment)

- [ ] **Runs completed successfully**
  - Success rate: _______________% (count successes vs total)
  - Failed runs: _______________
  - If failures > 20%, investigate errors

- [ ] **Runs occurred after Driver flow**
  - Driver completion: _______________
  - First Apps run: _______________
  - Gap should be < 30 minutes

- [ ] **Apps table is being populated**
  - Recent apps in table: ⚪ Yes / ⚪ No / ⚪ Partial
  - If No, check flow run details for errors

**Apps Flow Assessment**: ⚪ Healthy / ⚪ Needs Attention / ⚪ Critical Issue

---

## Section 4: Flows Child Flow Health Check

**Flow Name**: Admin - Sync Template v4 (Flows)

- [ ] **Flow is turned ON**
  - Status: ⚪ On / ⚪ Off
  - If Off, turn it on

- [ ] **Recent runs exist** (within last 48 hours)
  - Number of recent runs: _______________
  - Expected: Multiple runs (one per environment)

- [ ] **Runs completed successfully**
  - Success rate: _______________% (count successes vs total)
  - Failed runs: _______________
  - If failures > 20%, investigate errors

- [ ] **Runs occurred after Driver flow**
  - Driver completion: _______________
  - First Flows run: _______________
  - Gap should be < 30 minutes

- [ ] **Flows table is being populated**
  - Recent flows in table: ⚪ Yes / ⚪ No / ⚪ Partial
  - If No, check flow run details for errors

**Flows Flow Assessment**: ⚪ Healthy / ⚪ Needs Attention / ⚪ Critical Issue

---

## Section 5: Connection References Validation

**Location**: Solutions > Center of Excellence - Core Components > Connection References

Check each required connection:

- [ ] **Power Platform for Admins** (admin_CoECorePowerPlatformforAdmins)
  - Status: ⚪ Valid / ⚪ Invalid / ⚪ Not Set
  - Owner: _______________

- [ ] **Power Platform for Admins (Env Request)** (admin_CoECorePowerPlatformforAdminsEnvRequest)
  - Status: ⚪ Valid / ⚪ Invalid / ⚪ Not Set
  - Owner: _______________

- [ ] **Dataverse** (admin_sharedcommondataserviceforapps_98924)
  - Status: ⚪ Valid / ⚪ Invalid / ⚪ Not Set
  - Owner: _______________

- [ ] **Office 365 Users** (admin_CoECoreO365Users)
  - Status: ⚪ Valid / ⚪ Invalid / ⚪ Not Set
  - Owner: _______________

- [ ] **All connections use same account**
  - Consistent: ⚪ Yes / ⚪ No
  - If No, recreate with single admin account

**Connection References Assessment**: ⚪ Healthy / ⚪ Needs Attention / ⚪ Critical Issue

---

## Section 6: Permissions and Licensing

**Account running flows**: _______________________________________________

- [ ] **Has admin role**
  - Role: ⚪ Power Platform Admin / ⚪ Global Admin / ⚪ Other: _______________
  - If Other, may lack permissions

- [ ] **Has required licenses**
  - Power Apps license: ⚪ Full / ⚪ Trial / ⚪ None
  - Power Automate license: ⚪ Full / ⚪ Trial / ⚪ None
  - If Trial, upgrade to full license

- [ ] **Can access all environments**
  - Test access: ⚪ Confirmed / ⚪ Not Tested / ⚪ Access Denied
  - If denied, investigate environment security

**Permissions Assessment**: ⚪ Healthy / ⚪ Needs Attention / ⚪ Critical Issue

---

## Section 7: Data Quality Check

Spot check actual vs. reported data:

- [ ] **Apps count matches reality**
  - CoE reports: _______________ apps
  - Actual (from Power Platform admin): _______________ apps
  - Variance: _______________% 
  - Expected variance: < 5%

- [ ] **Flows count matches reality**
  - CoE reports: _______________ flows
  - Actual (from Power Platform admin): _______________ flows
  - Variance: _______________% 
  - Expected variance: < 5%

- [ ] **Data freshness is acceptable**
  - Oldest record "Modified On": _______________
  - Expected: Within 7 days
  - If older, cleanup flows may not be running

**Data Quality Assessment**: ⚪ Healthy / ⚪ Needs Attention / ⚪ Critical Issue

---

## Section 8: Environment and Configuration

- [ ] **Environment language is English**
  - Base language: _______________
  - If not English, may cause issues

- [ ] **Environment variables are set**
  - Power Automate Environment Variable: ⚪ Set / ⚪ Not Set
  - Individual Admin: ⚪ Yes / ⚪ No
  - If not set, configure through Setup Wizard

- [ ] **DLP policies don't block flows**
  - DLP check: ⚪ Allowed / ⚪ Blocked / ⚪ Not Checked
  - If blocked, request exception for CoE environment

- [ ] **No unmanaged layers on flows**
  - Unmanaged layers found: ⚪ None / ⚪ Some / ⚪ Many
  - If present, remove to allow updates

**Environment Assessment**: ⚪ Healthy / ⚪ Needs Attention / ⚪ Critical Issue

---

## Overall Diagnostic Summary

### Critical Issues Found
(List any items marked as "Critical Issue")

1. _______________________________________________
2. _______________________________________________
3. _______________________________________________

### Issues Needing Attention
(List any items marked as "Needs Attention")

1. _______________________________________________
2. _______________________________________________
3. _______________________________________________

### Root Cause Hypothesis
Based on the findings above, the most likely cause is:

⚪ Driver flow not completing successfully
⚪ Environments table not populated
⚪ Child flows turned off or not triggering
⚪ Connection reference issues
⚪ Permission/licensing problems
⚪ Environment configuration issues
⚪ Other: _______________________________________________

### Recommended Next Steps

**Immediate actions**:
1. _______________________________________________
2. _______________________________________________
3. _______________________________________________

**Follow-up in 24 hours**:
1. _______________________________________________
2. _______________________________________________

---

## Diagnostic Results for GitHub Issue

If creating a GitHub issue, include this summary:

```
**Diagnostic Checklist Results**

Date: _______________
Version: _______________
Tenant Size: _______________ environments, _______________ apps, _______________ flows

**Issues Found**:
- Driver Flow: [Status]
- Environments Table: [Status]
- Apps Flow: [Status]
- Flows Flow: [Status]
- Connection References: [Status]
- Permissions: [Status]

**Root Cause**: [Your hypothesis]

**Attempted Solutions**:
1. [What you tried]
2. [Results]

**Additional Context**:
[Any other relevant information]
```

---

## Quick Reference

If any section shows "Critical Issue", consult:
- **Driver Flow issues**: [Troubleshooting-Inventory-Flows.md](Troubleshooting-Inventory-Flows.md) - Step 1
- **Environments Table issues**: [Troubleshooting-Inventory-Flows.md](Troubleshooting-Inventory-Flows.md) - Step 2
- **Child Flow issues**: [Troubleshooting-Inventory-Flows.md](Troubleshooting-Inventory-Flows.md) - Step 3
- **Connection issues**: [Issue-Response-Template.md](Issue-Response-Template.md) - Missing Connection template
- **Dependencies**: [Flow-Dependencies-Quick-Reference.md](Flow-Dependencies-Quick-Reference.md)

---

*Complete this checklist systematically to identify the root cause of inventory issues.*
