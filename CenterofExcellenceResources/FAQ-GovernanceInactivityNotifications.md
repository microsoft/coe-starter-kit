# FAQ: Governance - Inactivity Notifications

## Overview

This document addresses common questions about the Governance solution's inactivity notification flows, which help identify and manage inactive Power Apps and Power Automate flows in your tenant.

---

## Common Questions

### Q: How does the Environment table affect inactivity notification flows?

**A:** The Environment table acts as the scope controller for environment-level flows, including inactivity notification flows.

**Here's how it works:**

The inactivity notification flows (`Admin | Inactivity notifications v2 (Start Approval for Apps)` and `Admin | Inactivity notifications v2 (Start Approval for Flows)`) read directly from the Environment table to determine which environments to process.

**Key Points:**
- ✅ Flows process **only** those environment records where `IsIncluded = Yes` (selected environments)
- ❌ Environments not present in the table are **ignored completely**
- ❌ Environments present but not selected (`IsIncluded = No`) are **ignored completely**
- ⚠️ There is **no implicit tenant-wide inclusion**

**Example:**

| Environment Name | In Environment Table? | IsIncluded | Processed by Inactivity Flows? |
|-----------------|----------------------|------------|-------------------------------|
| Production | ✅ Yes | Yes | ✅ Yes |
| Development | ✅ Yes | Yes | ✅ Yes |
| Test | ✅ Yes | No | ❌ No |
| Sandbox | ❌ No | N/A | ❌ No |

**To include additional environments:**
1. Ensure the environment is discovered by the Core Components inventory flows
2. Navigate to the Environment table in the CoE environment
3. Find the environment record
4. Set `IsIncluded = Yes`
5. Save the record

---

### Q: Can I change where approval notifications are sent during testing?

**A: Yes.** You can configure the approval recipient email address using environment variables.

When the `admin_ProductionEnvironment` variable is set to `No`, the system operates in **test mode**. By default, approvals are sent to the admin account configured during setup. However, you can redirect these to any email address.

**Configuration Steps:**

1. **Navigate to Environment Variables:**
   - Go to [Power Apps](https://make.powerapps.com)
   - Select your CoE environment
   - Go to **Solutions** → **Center of Excellence - Governance**
   - Navigate to **Environment variables**

2. **Update the Approval Email Variable:**

   Find and update one or more of these variables depending on your needs:
   
   - `admin_AdminEmail` - Primary admin email for notifications
   - `admin_CoEAdminEmail` - CoE admin contact email
   - `admin_ApprovalEmail` - Email address for approval notifications
   
3. **Set the Value:**
   - Click on the variable
   - Update the **Current Value** field to your user email address
   - Click **Save**

4. **Restart Affected Flows:**
   - Navigate to **Cloud flows** in the solution
   - Find flows that use the updated variable
   - Turn each flow **Off** then **On** again
   - This ensures flows pick up the new variable value

**Example:**
```
Variable: admin_ApprovalEmail
Old Value: admin@contoso.com
New Value: myuser@contoso.com
```

**Important Notes:**
- ⚠️ Changes to environment variables require flows to be restarted to take effect
- ⚠️ Only use test mode (`admin_ProductionEnvironment = No`) in non-production scenarios
- ⚠️ When ready for production, set `admin_ProductionEnvironment = Yes` to send approvals to actual app/flow owners

---

### Q: What is the difference between test mode and production mode?

**A:** The `admin_ProductionEnvironment` environment variable controls the behavior of governance flows.

| Mode | Setting | Approval Recipients | Use Case |
|------|---------|-------------------|----------|
| **Test Mode** | `admin_ProductionEnvironment = No` | Admin/designated test email | Testing, validation, dry-run |
| **Production Mode** | `admin_ProductionEnvironment = Yes` | Actual app/flow owners | Live governance operations |

**Test Mode Behavior:**
- ✅ Approvals sent to admin/test email (configured via `admin_ApprovalEmail`)
- ✅ Safe to test without bothering end users
- ✅ Can validate flow logic and email templates
- ⚠️ Does not engage actual makers/owners

**Production Mode Behavior:**
- ✅ Approvals sent to actual app and flow owners
- ✅ Engages makers directly for governance decisions
- ✅ Real business impact on inactive resources
- ⚠️ Notifications will be sent to real users

---

### Q: Which flows are affected by the Environment table scope?

**A:** The following Governance flows respect the Environment table's `IsIncluded` setting:

**Inactivity Notification Flows:**
- `Admin | Inactivity notifications v2 (Start Approval for Apps)`
- `Admin | Inactivity notifications v2 (Start Approval for Flows)`
- `Admin | Inactivity notifications v2 (Clean Up and Delete)`

**Related Governance Flows:**
- Most environment-scoped governance flows check the Environment table
- Tenant-wide inventory flows operate independently of this setting
- DLP policy flows may have separate scoping mechanisms

**Best Practice:**
- Start with a small subset of environments (2-3) in test mode
- Validate the flows work as expected
- Gradually add more environments as you gain confidence
- Always have at least one production and one development environment included for representative testing

---

### Q: How do I know which environments are currently included?

**A:** You can view the current environment scope in multiple ways:

**Option 1: Via the Environment Table**
1. Go to [Power Apps](https://make.powerapps.com)
2. Select your CoE environment
3. Navigate to **Tables** → **Environment** table
4. View all records
5. Filter by `IsIncluded = Yes` to see active environments

**Option 2: Via Power BI Reports**
- The CoE Starter Kit Power BI dashboards show which environments are being monitored
- Environment-level reports will only show data from included environments

**Option 3: Via Model-Driven App**
- Open the **Center of Excellence - Core Components** app
- Navigate to **Environments**
- Use views to filter by included/excluded status

---

### Q: Can I programmatically set which environments are included?

**A: Yes.** You can use the Dataverse Web API or Power Automate to bulk-update the Environment table.

**Example using Power Automate:**
1. Create a custom flow
2. List rows from the Environment table with filter criteria
3. Update each row's `IsIncluded` field based on your criteria (e.g., environment type, display name pattern)
4. This allows for dynamic environment scoping

**Example criteria:**
- Include all environments with "Production" or "Prod" in the name
- Exclude all default environments
- Include only environments in specific regions
- Include only Managed Environments

---

### Q: What happens if I exclude an environment after it was previously included?

**A:** Setting `IsIncluded = No` on a previously included environment will:

**Immediate Effects:**
- ✅ Future inactivity notification flows will skip this environment
- ✅ No new approvals will be generated for resources in this environment
- ✅ Existing approvals in progress will continue to completion

**Data Retention:**
- ✅ Historical data for apps/flows in that environment remains in the CoE tables
- ✅ Power BI reports will still show historical data
- ❌ New inventory updates will not be processed for governance flows (Core inventory still runs)

**Re-enabling:**
- Setting `IsIncluded = Yes` again will resume processing for that environment
- No data loss occurs when toggling the setting

---

## Environment Variables Reference

### Governance-Related Environment Variables

These variables control the behavior of governance flows:

| Variable Name | Purpose | Example Value | Used By |
|--------------|---------|---------------|---------|
| `admin_ProductionEnvironment` | Toggle test/production mode | `Yes` or `No` | Most governance flows |
| `admin_AdminEmail` | Primary admin contact email | `admin@contoso.com` | Notification flows |
| `admin_CoEAdminEmail` | CoE admin email address | `coe-admin@contoso.com` | General notifications |
| `admin_ApprovalEmail` | Test mode approval recipient | `test-user@contoso.com` | Approval flows in test mode |
| `admin_InactivityThresholdDays` | Days before app/flow considered inactive | `90` | Inactivity detection |

**Note:** Exact variable names and availability may vary by solution version. Always check the Environment Variables section in your installed Governance solution.

---

## Setup Workflow for Inactivity Notifications

### Recommended Setup Process

Follow these steps when deploying inactivity notification flows:

#### Phase 1: Initial Configuration (Test Mode)
1. ✅ Set `admin_ProductionEnvironment = No`
2. ✅ Set `admin_ApprovalEmail` to your test email address
3. ✅ Select 1-2 test environments in the Environment table (`IsIncluded = Yes`)
4. ✅ Turn on the inactivity notification flows
5. ✅ Manually trigger or wait for scheduled run
6. ✅ Verify you receive test approvals at your email address
7. ✅ Review email content and approval process

#### Phase 2: Expanded Testing
1. ✅ Add 3-5 more environments to the scope
2. ✅ Trigger flows again
3. ✅ Validate performance and accuracy
4. ✅ Review detected inactive apps/flows
5. ✅ Adjust `admin_InactivityThresholdDays` if needed

#### Phase 3: Production Rollout
1. ✅ Set `admin_ProductionEnvironment = Yes`
2. ✅ Select all desired environments in the Environment table
3. ✅ Turn flows off then on to pick up configuration changes
4. ✅ Communicate to makers that they may receive inactivity notifications
5. ✅ Monitor flow runs for the first few cycles
6. ✅ Provide support documentation for makers on how to respond to approvals

---

## Troubleshooting

### Issue: Approvals Not Being Sent

**Possible Causes:**
1. ❌ Flow is turned off
2. ❌ Environment variable not configured
3. ❌ No environments selected in Environment table
4. ❌ Connection issues with approval connector
5. ❌ No inactive apps/flows detected (working as designed)

**Solutions:**
- Verify flow is turned on
- Check environment variables are set correctly
- Confirm at least one environment has `IsIncluded = Yes`
- Test the approval connection manually
- Review flow run history for specific errors

---

### Issue: Approvals Going to Wrong Email Address

**Possible Causes:**
1. ❌ Wrong environment variable value
2. ❌ Flow not restarted after variable change
3. ❌ `admin_ProductionEnvironment` set to `Yes` (sends to owners, not test email)

**Solutions:**
- Verify `admin_ApprovalEmail` variable value
- Turn flows off then on again
- Check `admin_ProductionEnvironment` setting
- Clear flow run history and trigger fresh run

---

### Issue: Some Environments Not Being Processed

**Possible Causes:**
1. ❌ Environment not in the Environment table
2. ❌ Environment has `IsIncluded = No`
3. ❌ Environment was recently created and hasn't been inventoried yet
4. ❌ Filtering logic in flow excludes certain environment types

**Solutions:**
- Run Core Components inventory flows to discover new environments
- Verify Environment table has the expected records
- Check `IsIncluded` field on each environment
- Review flow logic for any hardcoded filters

---

## Additional Resources

### Official Documentation
- [CoE Starter Kit - Governance Components](https://learn.microsoft.com/power-platform/guidance/coe/governance-components)
- [CoE Starter Kit Setup - Governance](https://learn.microsoft.com/power-platform/guidance/coe/setup-governance)
- [Inactivity Notifications Documentation](https://learn.microsoft.com/power-platform/guidance/coe/governance-components#inactivity-notifications)

### Related FAQs
- [FAQ: Power Platform Administrator Role Requirements](FAQ-AdminRoleRequirements.md)

### GitHub Resources
- [CoE Starter Kit Issues](https://github.com/microsoft/coe-starter-kit/issues)
- [Release Notes](../CenterofExcellenceResources/Release/Notes/CoEStarterKit/RELEASENOTES.md)

### Community
- [Power Apps Governance Community](https://powerusers.microsoft.com/t5/Power-Apps-Governance-and/bd-p/Admin_PowerApps)
- [CoE Office Hours](https://aka.ms/coeofficehours)

---

## Summary

### Key Takeaways

✅ **Environment Scoping:**
- Inactivity flows only process environments where `IsIncluded = Yes` in the Environment table
- No tenant-wide automatic inclusion
- Must explicitly select environments

✅ **Test Mode Configuration:**
- Use `admin_ProductionEnvironment = No` for testing
- Configure `admin_ApprovalEmail` to redirect approvals to test email
- Always restart flows after changing environment variables

✅ **Production Deployment:**
- Follow phased rollout approach
- Start small, validate, then expand
- Communicate with makers before enabling

✅ **Troubleshooting:**
- Check Environment table for scope
- Verify environment variables are set correctly
- Ensure flows are restarted after configuration changes

---

## Need Help?

If you have questions about inactivity notifications or governance flows:

1. Review the [official CoE Starter Kit documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
2. Search [existing GitHub issues](https://github.com/microsoft/coe-starter-kit/issues)
3. Ask in [Power Apps Community forums](https://powerusers.microsoft.com/t5/Power-Apps-Governance-and/bd-p/Admin_PowerApps)
4. Create a [new GitHub issue](https://github.com/microsoft/coe-starter-kit/issues/new/choose) with specific details
5. Join [CoE Starter Kit Office Hours](https://aka.ms/coeofficehours)

---

**Applies to:** CoE Starter Kit - Governance Components (v3.x and later)  
**Last Updated:** January 2026
