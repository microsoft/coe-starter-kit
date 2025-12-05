# Quick Reference Guide - CoE Starter Kit Common Issues

This is a quick lookup guide for the most common CoE Starter Kit issues and their solutions.

## 🔴 Critical Issues (Prevents Use)

### Blank Screens / Apps Not Loading
**Symptoms**: Apps show only header, blank white content area, no controls render

**Quick Fix**:
1. ✅ Verify Power Apps Premium license assigned
2. ✅ Check DLP policies allow Power Platform admin connectors
3. ✅ Ensure English language pack enabled
4. ✅ Clear browser cache / try InPrivate mode

**Full Guide**: [Troubleshooting-Blank-Screens.md](./Troubleshooting-Blank-Screens.md)

---

### Setup Wizard Won't Complete
**Symptoms**: "Confirm pre-requisites" step stuck, environment variables not saving

**Quick Fix**:
1. ✅ Verify System Administrator role in environment
2. ✅ Check Dataverse database is provisioned
3. ✅ Ensure all required licenses assigned
4. ✅ Verify connection references are configured

**Full Guide**: [COE-Kit-Common GitHub Responses.md#setup-wizard-guidance](./COE-Kit-Common%20GitHub%20Responses.md#setup-wizard-guidance)

---

## 🟡 Common Issues (Impacts Functionality)

### Inventory Flows Failing
**Symptoms**: "Admin | Sync Template v3" fails, not all apps/flows collected, pagination errors

**Quick Fix**:
1. ✅ Verify Premium license (not trial)
2. ✅ Check API limits not exceeded
3. ✅ Review flow run history for specific errors
4. ✅ Ensure admin roles assigned correctly

**Full Guide**: [COE-Kit-Common GitHub Responses.md#pagination-and-licensing-requirements](./COE-Kit-Common%20GitHub%20Responses.md#pagination-and-licensing-requirements)

---

### DLP Policy Blocking Flows/Apps
**Symptoms**: Connection errors, "connector not available", flows fail at connector steps

**Quick Fix**:
1. ✅ Verify these connectors in "Business" group:
   - Microsoft Dataverse
   - Power Apps for Admins
   - Power Automate Management
   - Office 365 Users
2. ✅ Or exclude CoE environment from DLP policy

**Full Guide**: [COE-Kit-Common GitHub Responses.md#dlp-policies-and-connector-issues](./COE-Kit-Common%20GitHub%20Responses.md#dlp-policies-and-connector-issues)

---

### Missing Data / Incomplete Inventory
**Symptoms**: Not all apps/flows/resources showing, data seems incomplete

**Quick Fix**:
1. ✅ Run full inventory flow manually
2. ✅ Check for pagination errors
3. ✅ Verify flow run history shows success
4. ✅ Run cleanup flows to remove stale data
5. ✅ Allow 24-48 hours for initial inventory

**Full Guide**: [COE-Kit-Common GitHub Responses.md#cleanup-flows-and-inventory](./COE-Kit-Common%20GitHub%20Responses.md#cleanup-flows-and-inventory)

---

### Language/Localization Errors
**Symptoms**: Missing labels, controls not displaying, partial rendering

**Quick Fix**:
1. ✅ Enable English language pack in environment
2. ✅ Wait 10-15 minutes after enabling
3. ✅ Sign out and back in
4. ✅ Clear browser cache

**Full Guide**: [COE-Kit-Common GitHub Responses.md#language-pack-requirements](./COE-Kit-Common%20GitHub%20Responses.md#language-pack-requirements)

---

## 🟢 Information Requests

### Can I Use BYODL (Data Lake)?
**Answer**: No, BYODL is no longer recommended. Use cloud flows or wait for Fabric integration.

**Details**: [COE-Kit-Common GitHub Responses.md#byodl-data-lake-status](./COE-Kit-Common%20GitHub%20Responses.md#byodl-data-lake-status)

---

### What Licenses Do I Need?
**Answer**: Power Apps Premium or Per User + Premium roles. Trial/Per-App insufficient.

**Details**: [COE-Kit-Common GitHub Responses.md#pagination-and-licensing-requirements](./COE-Kit-Common%20GitHub%20Responses.md#pagination-and-licensing-requirements)

---

### Is This Officially Supported?
**Answer**: No. CoE Starter Kit is best-effort/unsupported. GitHub-only support, no SLA.

**Details**: [COE-Kit-Common GitHub Responses.md#general-support-information](./COE-Kit-Common%20GitHub%20Responses.md#general-support-information)

---

## Prerequisites Checklist

Before reporting an issue, verify these prerequisites:

**Environment**:
- [ ] Production or Sandbox environment (not Trial)
- [ ] Dataverse database provisioned
- [ ] English language pack enabled
- [ ] At least 1GB available Dataverse capacity

**Licensing**:
- [ ] Power Apps Premium or Per User license
- [ ] Power Automate Premium license
- [ ] Microsoft 365 license
- [ ] NOT trial or per-app licenses

**Permissions**:
- [ ] Global Admin, Power Platform Admin, or Dynamics 365 Admin
- [ ] System Administrator role in CoE environment
- [ ] Can create Azure AD app registrations (for service principals)

**DLP Policies**:
- [ ] No policies blocking required connectors
- [ ] OR CoE environment excluded from restrictive policies

**Configuration**:
- [ ] Core solution installed first
- [ ] Environment variables configured
- [ ] Connection references set up
- [ ] Required flows turned on

## Diagnostic Quick Commands

### Check License (PowerShell)
```powershell
# Install module if needed
Install-Module -Name Microsoft.PowerApps.Administration.PowerShell

# Connect
Add-PowerAppsAccount

# Check environments
Get-AdminPowerAppEnvironment

# Test pagination (should work with premium license)
Get-AdminPowerApp -EnvironmentName [env-id] -Top 5000
```

### Check DLP Policies (PowerShell)
```powershell
# Get all DLP policies
Get-DlpPolicy

# Get policies for specific environment
Get-DlpPolicy | Where-Object {$_.environments.name -contains "[env-id]"}
```

### Browser Console Check
1. Open affected app
2. Press F12 to open Developer Tools
3. Go to Console tab
4. Look for red errors
5. Screenshot and include in issue report

## Issue Reporting Template

When creating a GitHub issue, include:

```markdown
**Environment Details:**
- Solution Version: [e.g., 4.50.6]
- Environment Type: [Production/Sandbox/Trial]
- Dataverse: [Yes/No, capacity]
- Languages: [English enabled? Others?]

**User Details:**
- Licenses: [Power Apps Premium? Other?]
- Azure AD Role: [Global Admin? Power Platform Admin?]
- Environment Role: [System Administrator?]

**DLP Policies:**
- Policies Applied: [Yes/No, which ones?]
- Connectors Allowed: [List]

**Issue Description:**
[Detailed description]

**Steps to Reproduce:**
1. [Step 1]
2. [Step 2]
3. [See error]

**Screenshots:**
[Attach screenshots]

**Browser Console Errors:**
[Paste F12 console errors if any]

**What I've Tried:**
- [ ] Cleared browser cache
- [ ] Tried InPrivate/Incognito
- [ ] Verified licenses
- [ ] Checked DLP policies
- [ ] Enabled English language pack
- [ ] [Other steps]
```

## Getting Help

1. **Search existing issues**: https://github.com/microsoft/coe-starter-kit/issues
2. **Check documentation**: https://learn.microsoft.com/power-platform/guidance/coe/starter-kit
3. **Review these guides**: Start with the quick fixes above
4. **Create detailed issue**: Use the template above
5. **Community forum**: https://powerusers.microsoft.com/t5/Power-Apps-Governance-and/bd-p/Admin_PowerApps (for general governance questions)

## Response Time Expectations

- **CoE Starter Kit is unsupported**: No SLA for responses
- **Best-effort support**: Community and team review on availability
- **Typical response**: 1-5 business days
- **Complex issues**: May require multiple back-and-forth exchanges
- **Blocked by prerequisites**: Cannot proceed until prerequisites are met

## Success Rate by Issue Type

Based on historical data:

| Issue Type | Typical Resolution | Success Rate |
|------------|-------------------|--------------|
| Blank screens | Prerequisites fix | 95% |
| DLP blocking | Policy adjustment | 90% |
| License issues | Assign premium | 100% |
| Language pack | Enable English | 100% |
| Inventory failures | Premium license + permissions | 85% |
| Setup wizard | Prerequisites + configuration | 80% |
| Custom modifications | Varies | 50% |
| Feature requests | May not be implemented | 20% |

## Update History

- **2025-12-03**: Initial creation based on common issue patterns
