# Setup Wizard Troubleshooting Guide

This document provides detailed troubleshooting steps for common issues encountered with the CoE Starter Kit Setup Wizard.

## Table of Contents

1. [Setup Wizard Overview](#setup-wizard-overview)
2. [Configure Dataflows Step Skipped](#configure-dataflows-step-skipped)
3. [Inventory Flows Not Running](#inventory-flows-not-running)
4. [Setup Wizard Progress Not Saving](#setup-wizard-progress-not-saving)
5. [Pre-requisites Not Met](#pre-requisites-not-met)

---

## Setup Wizard Overview

The CoE Setup Wizard provides a guided experience for configuring the CoE Starter Kit. The wizard follows this flow:

1. **Confirm pre-requisites** - Verify admin permissions and environment setup
2. **Configure communication methods** - Set up email and notification preferences
3. **Configure mandatory settings** - Essential configuration for CoE operation
4. **Configure inventory data source** - Choose between Cloud flows or Data Export
5. **Run setup flows** - Initialize configuration data
6. **Run inventory flows** - Start initial data collection
7. **Configure dataflows (Data export)** - *Optional, only if Data Export selected*
8. **Share apps** - Configure app sharing and permissions
9. **Publish Power BI dashboard** - Configure analytics dashboard
10. **Finish** - Complete setup

---

## Configure Dataflows Step Skipped

### Symptom

After completing "Run Inventory Flows" step successfully, the wizard skips "Configure dataflows (Data export)" and moves directly to "Share Apps".

### Expected Behavior

**This is normal** - The "Configure dataflows (Data export)" step only appears under specific conditions.

### When the Step Appears

The dataflows configuration step ONLY appears when:

1. ✅ You selected **"Data Export"** as your inventory and telemetry method
2. ✅ Data Export features are enabled in your environment  
3. ✅ Your license supports Dataverse Data Export capabilities

### When the Step is Skipped

The step is automatically skipped when:

- ❌ You selected **"Cloud flows"** as your inventory method (most common)
- ❌ You selected **"None"** for inventory method
- ❌ Data Export is not configured in your environment

### Verification Steps

To confirm which method you selected:

1. In the Setup Wizard, navigate to "Configure inventory data source" step
2. Check which radio button is selected:
   - **Cloud flows** (recommended) → Dataflows step will be skipped
   - **Data Export** → Dataflows step will appear
   - **None** → Dataflows step will be skipped

### Resolution

**No action needed** - This is expected behavior. If you selected "Cloud flows", proceed to the next step (Share Apps).

If you intended to use Data Export and the step is missing:

1. Return to "Configure inventory data source" step
2. Select "Data Export" option
3. Complete subsequent steps
4. The dataflows step should now appear

### Important Notes

- **Cloud flows** is the recommended method for most organizations
- **Data Export** is more complex and requires additional setup
- **BYODL (Bring Your Own Data Lake)** is no longer recommended per latest guidance
- Microsoft is moving toward Fabric integration for advanced analytics

### References

- [Choose your inventory method](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup-core-components#inventory-and-telemetry)
- [Setup wizard documentation](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup-core-components)

---

## Inventory Flows Not Running

### Symptom

After clicking "Run Inventory Flows" in the setup wizard:
- Flows don't appear to start
- No data is collected in Dataverse tables
- Flow run history shows no runs or failures

### Common Causes

1. **Insufficient permissions** - User running setup needs admin roles
2. **DLP policies** - Required connectors blocked by policy
3. **Connection issues** - Flows need proper connections configured
4. **Licensing issues** - Inadequate Power Platform licenses

### Troubleshooting Steps

1. **Verify Admin Permissions:**
   ```
   Required roles (at least one):
   - Power Platform Administrator
   - Global Administrator  
   - Dynamics 365 Administrator
   ```

2. **Check Flow Connections:**
   - Navigate to Cloud flows in CoE environment
   - Open "Admin | Sync Template v3" flow
   - Check connection references are valid (no red exclamation marks)
   - Re-authenticate connections if needed

3. **Review DLP Policies:**
   - Check if connectors are in same DLP data group:
     - Dataverse
     - Power Apps for Admins
     - Power Automate for Admins
     - Office 365 Users
     - Office 365 Outlook
   
4. **Verify Licensing:**
   - Ensure user has Power Automate license
   - Not using trial licenses for production

5. **Check Flow Run History:**
   - Open "Admin | Sync Template v3" flow
   - View 28-day run history
   - Look for error messages if runs exist
   - If no runs, flows may not be turned on

6. **Manually Turn On Flows:**
   - Navigate to Cloud flows
   - Search for "Admin | Sync Template"
   - Ensure flow is turned "On"
   - Manually trigger to test

### Expected Results

After successful inventory flow run:
- Flow run history shows green checkmarks
- Dataverse tables contain records:
  - Environment table has entries
  - Power Apps App table populated
  - Flow table has data
- First run takes 4-8 hours for large tenants

---

## Setup Wizard Progress Not Saving

### Symptom

- Setup wizard doesn't remember completed steps
- Need to redo steps each time wizard is opened
- Progress indicators don't show completed status

### Common Causes

1. Browser session expired
2. Browser cache issues
3. Setup wizard state table not updating
4. Multiple users running setup simultaneously

### Resolution

1. **Clear Browser Cache:**
   - Close all Power Apps tabs
   - Clear browser cache and cookies
   - Reopen setup wizard

2. **Use Supported Browser:**
   - Microsoft Edge (Chromium)
   - Google Chrome
   - Latest versions recommended

3. **Single User Setup:**
   - Only one admin should run setup wizard
   - Don't have multiple sessions open
   - Complete setup in one session if possible

4. **Check Setup State Table:**
   - In CoE environment, navigate to Tables
   - Find "Setup Wizard State" table
   - Verify records are being created/updated

---

## Pre-requisites Not Met

### Symptom

Setup wizard shows warnings or errors about pre-requisites not being met.

### Common Pre-requisites

1. **Admin Permissions:**
   - Need Power Platform Admin or Global Admin role
   - May need Azure AD permissions for some features

2. **Environment Requirements:**
   - Dedicated environment for CoE (recommended)
   - Not using default environment
   - Environment in supported region
   - Sufficient database capacity

3. **Licensing:**
   - Power Apps license
   - Power Automate license
   - Not trial licenses for production

4. **Connectors Enabled:**
   - Required connectors not blocked by DLP
   - Custom connectors allowed (for some features)

### Verification Checklist

- [ ] User has Power Platform Admin or Global Admin role
- [ ] CoE installed in dedicated (non-default) environment
- [ ] Environment has adequate database storage (2GB+ recommended)
- [ ] User has Power Apps and Power Automate licenses
- [ ] DLP policies allow required connectors
- [ ] Environment language includes English

### Resolution Steps

1. Verify each pre-requisite above
2. Address any gaps before proceeding
3. Re-run pre-requisites check in wizard
4. Contact Microsoft support if license issues persist

---

## Additional Resources

### Documentation
- [Setup Core Components](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup-core-components)
- [Before you setup](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup)
- [Setup prerequisites](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup-core-components#before-you-start)

### Community Support
- [GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues)
- [Power Apps Community Forum](https://powerusers.microsoft.com/t5/Power-Apps-Governance-and/bd-p/Admin_PowerApps)

### Video Walkthroughs
- [CoE Starter Kit Setup Video Series](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup-core-components#watch-a-walk-through)

---

*Last updated: 2025-12-10*
