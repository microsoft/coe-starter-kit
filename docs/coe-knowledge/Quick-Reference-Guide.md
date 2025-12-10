# CoE Starter Kit - Quick Reference Guide

This guide provides quick answers to the most common questions and issues reported on GitHub.

## Most Common Issues

### 1. Setup Wizard Skips Dataflow Step ⚡

**Q:** Why does the setup wizard skip "Configure dataflows (Data export)"?

**A:** This is **expected behavior**. The step only appears if you selected "Data Export" as your inventory method. If you selected "Cloud flows" (recommended), it will be skipped.

**Action:** ✅ No action needed. Continue with setup.

[Detailed guide →](./Setup-Wizard-Troubleshooting.md#configure-dataflows-step-skipped)

---

### 2. Power BI Dashboard Shows No Data ⚡

**Q:** Dashboard is blank or shows "no data" messages.

**A:** Most commonly caused by inventory collection not completing yet. First-time collection takes **4-8 hours minimum**.

**Action:** 
1. ✅ Wait 4-8 hours after setup completion
2. ✅ Check flow run history for "Admin | Sync Template v3"
3. ✅ Verify Dataverse tables contain records
4. ✅ Ensure Power BI is connected to correct environment URL

[Detailed guide →](./PowerBI-Dashboard-Troubleshooting.md#blank-dashboard---no-data-showing)

---

### 3. Inventory Flows Not Running ⚡

**Q:** Inventory flows don't start or don't collect data.

**A:** Common causes: permissions, DLP policies, or connections.

**Action:**
1. ✅ Verify admin permissions (Power Platform Admin or Global Admin)
2. ✅ Check DLP policies allow required connectors
3. ✅ Verify flow connections are authenticated
4. ✅ Ensure proper licensing (not trial)

[Detailed guide →](./Setup-Wizard-Troubleshooting.md#inventory-flows-not-running)

---

### 4. Which Inventory Method Should I Use? ⚡

**Q:** Should I use Cloud flows or Data Export?

**A:** Use **Cloud flows** (recommended for 95% of organizations).

**Cloud flows:**
- ✅ Easier setup
- ✅ Standard licensing
- ✅ All necessary data
- ✅ Recommended by Microsoft

**Data Export:**
- ❌ More complex
- ❌ Requires additional setup
- ❌ BYODL no longer recommended
- ⚠️ Only for advanced scenarios

[Detailed info →](./COE-Kit-Common%20GitHub%20Responses.md#data-export-and-dataflows)

---

### 5. How Long Does Initial Setup Take? ⚡

**Q:** How long before I see data?

**A:** 
- Setup wizard: 30-60 minutes
- Inventory collection: **4-8 hours minimum** (can be 24+ hours for large tenants)
- Power BI configuration: 15-30 minutes

**Timeline:**
1. Complete setup wizard → 30-60 min
2. Wait for inventory → 4-8 hours
3. Configure Power BI → 15-30 min
4. View dashboard → Immediate after step 3

[Detailed info →](./PowerBI-Dashboard-Troubleshooting.md#expected-timeline)

---

## Quick Checks

### Is My Inventory Complete?

✅ **Check this:**
1. Go to Cloud flows in CoE environment
2. Open "Admin | Sync Template v3"
3. Check run history for green checkmarks
4. Go to Tables > Check "Environment", "Power Apps App", "Flow" have records

If all above are ✅, inventory is complete.

---

### Is My Power BI Connected Correctly?

✅ **Check this:**
1. Open .pbit template in Power BI Desktop
2. Verify environment URL: `https://[org].crm[region].dynamics.com/`
3. Sign in with admin account
4. Wait for data load
5. Check visualizations show data

If all above are ✅, Power BI is configured correctly.

---

### Do I Have the Right Permissions?

✅ **Check this:**

**Required roles (at least one):**
- Power Platform Administrator
- Global Administrator
- Dynamics 365 Administrator

**Required licenses:**
- Power Apps Per User or Per App
- Power Automate Per User (recommended)

**Test access:**
- Can you access Power Platform Admin Center?
- Can you see all environments in your tenant?
- Can you view Dataverse tables in CoE environment?

If all above are ✅, permissions are adequate.

---

## Common Error Messages

### "Access is denied"

**Cause:** Insufficient permissions

**Fix:**
- Verify admin role assignment
- Check security roles in CoE environment
- Ensure user not disabled in Azure AD

---

### "Unable to connect to datasource"

**Cause:** Connection or URL issues

**Fix:**
- Verify environment URL is correct
- Check internet connectivity
- Ensure environment is accessible
- Format: `https://[org].crm[region].dynamics.com/`

---

### "Invalid credentials"

**Cause:** Authentication issues

**Fix:**
- Re-authenticate in Power BI data source settings
- Use organizational account (not personal)
- Verify MFA completion if required

---

### "DLP policy violation"

**Cause:** Required connectors blocked

**Fix:**
- Check DLP policies on CoE environment
- Ensure these connectors in same data group:
  - Dataverse
  - Power Apps for Admins
  - Power Automate for Admins
  - Office 365 Users
  - Office 365 Outlook

---

## Environment URLs by Region

Power BI needs your environment URL in this format:

| Region | URL Format | Example |
|--------|-----------|---------|
| North America | `https://[org].crm.dynamics.com/` | `https://contoso.crm.dynamics.com/` |
| South America | `https://[org].crm2.dynamics.com/` | `https://contoso.crm2.dynamics.com/` |
| Canada | `https://[org].crm3.dynamics.com/` | `https://contoso.crm3.dynamics.com/` |
| Europe | `https://[org].crm4.dynamics.com/` | `https://contoso.crm4.dynamics.com/` |
| Asia Pacific | `https://[org].crm5.dynamics.com/` | `https://contoso.crm5.dynamics.com/` |
| Australia | `https://[org].crm6.dynamics.com/` | `https://contoso.crm6.dynamics.com/` |
| Japan | `https://[org].crm7.dynamics.com/` | `https://contoso.crm7.dynamics.com/` |
| India | `https://[org].crm8.dynamics.com/` | `https://contoso.crm8.dynamics.com/` |
| UK | `https://[org].crm11.dynamics.com/` | `https://contoso.crm11.dynamics.com/` |
| France | `https://[org].crm12.dynamics.com/` | `https://contoso.crm12.dynamics.com/` |

**How to find yours:**
1. Go to [Power Platform Admin Center](https://admin.powerplatform.microsoft.com)
2. Select **Environments**
3. Find your CoE environment
4. Copy the **Environment URL**

---

## Setup Wizard Steps Overview

Understanding the flow helps troubleshoot issues:

1. ✅ **Confirm pre-requisites** - Admin permissions, licensing
2. ✅ **Configure communication** - Email settings
3. ✅ **Configure mandatory settings** - Required configuration
4. ✅ **Configure inventory source** - **Choose Cloud flows or Data Export**
5. ✅ **Run setup flows** - Initialize configuration
6. ✅ **Run inventory flows** - Start data collection
7. ⚠️ **Configure dataflows** - *Only if Data Export selected*
8. ✅ **Share apps** - App permissions
9. ✅ **Publish Power BI** - Dashboard info (manual setup required)
10. ✅ **Finish** - Complete

**Key point:** Step 7 only appears if you selected "Data Export" in step 4.

---

## CoE Components Overview

Understanding what each component does:

### Core Components
- **Inventory flows** - Collect tenant data
- **Power BI Dashboard** - Analytics and reporting
- **Admin apps** - Governance tools
- **Dataverse tables** - Data storage

### Setup Wizard
- Guided configuration experience
- One-time setup process
- Configures core components

### Power BI Dashboard
- Separate component from Power Apps
- Requires Power BI Desktop
- Connects to Dataverse
- Shows analytics and insights

---

## Decision Trees

### Dataflow Step Missing?

```
Is "Configure dataflows" step missing?
│
├─ Yes → Did you select "Cloud flows"? 
│        │
│        ├─ Yes → ✅ EXPECTED - Continue to next step
│        └─ No → Check if Data Export is configured
│
└─ No → Step should appear if Data Export selected
```

### Dashboard Shows No Data?

```
Power BI dashboard blank?
│
├─ How long since setup completed?
│  │
│  ├─ Less than 8 hours → ⏱️ WAIT - Inventory needs time
│  └─ More than 24 hours → Check inventory flows
│
└─ Do Dataverse tables have records?
   │
   ├─ Yes → Check Power BI connection/URL
   └─ No → Check flow run history for errors
```

---

## Licensing Quick Reference

### Minimum Requirements

**For CoE Admin:**
- Power Apps Per User OR Per App
- Power Automate Per User (recommended)
- Power Platform Admin role

**For Dashboard Viewers:**
- Power BI Pro (for Power BI Service sharing)
- OR Power BI Desktop (for local viewing)
- Read access to CoE environment

**Not Recommended:**
- ❌ Trial licenses for production
- ❌ Microsoft 365 only (limited)
- ❌ Free Power Apps (insufficient)

---

## When to Escalate

Contact Microsoft Support when:

1. ❌ Flow errors persist after following troubleshooting
2. ❌ Licensing questions about enterprise agreements
3. ❌ Platform issues (not CoE specific)
4. ❌ Azure AD or tenant-level configuration

**Note:** CoE Starter Kit is community-supported via GitHub, not official Microsoft Support.

---

## Best Practices

### For Setup

✅ **Do:**
- Use dedicated environment for CoE
- Wait for inventory to complete (4-8 hours)
- Use Cloud flows for inventory
- Follow setup wizard sequentially
- Keep setup wizard open during configuration

❌ **Don't:**
- Use default environment
- Expect immediate results
- Skip steps in wizard
- Run setup from multiple sessions
- Customize managed components directly

### For Troubleshooting

✅ **Do:**
- Check flow run history first
- Verify Dataverse tables have data
- Wait adequate time for inventory
- Document error messages
- Search existing GitHub issues

❌ **Don't:**
- Repeatedly re-run failed flows without fixing root cause
- Delete and reinstall without understanding issue
- Modify managed solution components
- Ignore DLP policy violations

---

## Helpful Commands & Checks

### Power Platform CLI

Check environment details:
```powershell
pac admin list
pac env select --environment [environment-id]
```

### PowerShell (Admin)

List environments:
```powershell
Get-AdminPowerAppEnvironment
```

### Web Browser Checks

| What to Check | URL | What to Look For |
|--------------|-----|------------------|
| Admin Center | https://admin.powerplatform.microsoft.com | Environments list, CoE environment exists |
| Power Apps | https://make.powerapps.com | CoE environment, flows running, tables have data |
| Power BI | https://app.powerbi.com | Published reports (if published) |

---

## Emergency Troubleshooting

If everything seems broken:

1. ✅ **Verify environment exists** - Admin Center
2. ✅ **Check solution is installed** - Power Apps > Solutions
3. ✅ **Verify user has access** - Can you open the environment?
4. ✅ **Check flows exist** - Navigate to Cloud flows
5. ✅ **Look at run history** - Any successful runs?
6. ✅ **Check tables** - Do they exist and have records?
7. ✅ **Review DLP policies** - Any violations?
8. ✅ **Verify connections** - All authenticated?

If all above fail, consider:
- Check recent tenant changes
- Review Azure AD changes
- Check license expiration
- Look for platform-wide issues

---

## Links & Resources

### Official Documentation
- [CoE Starter Kit Overview](https://learn.microsoft.com/en-us/power-platform/guidance/coe/starter-kit)
- [Setup Guide](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup-core-components)
- [Power BI Setup](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup-powerbi)
- [Troubleshooting](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup-core-components#troubleshooting)

### Community
- [GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues)
- [Power Apps Community](https://powerusers.microsoft.com/t5/Power-Apps-Governance-and/bd-p/Admin_PowerApps)

### Video Guides
- [Setup Walkthrough Videos](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup-core-components#watch-a-walk-through)

---

## Quick Wins

After setup, try these to verify everything works:

1. ✅ **Open Admin Apps** - Verify apps load
2. ✅ **Check Power Apps App table** - See your apps
3. ✅ **View an environment record** - Data looks correct
4. ✅ **Open Power BI in Desktop** - Dashboard shows data
5. ✅ **Run a simple flow** - Flows can execute

If all work → ✅ Setup successful!

---

*Last updated: 2025-12-10*
