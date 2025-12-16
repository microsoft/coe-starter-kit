# Troubleshooting Blank Screens in CoE Starter Kit Apps

This guide helps you resolve blank screen issues in CoE Starter Kit applications, including:
- CoE Setup Wizard
- Admin - Flow Permission Center
- Data Policy Impact Analysis
- Other Core Component apps

## Problem Description

Apps load with visible headers and navigation, but the main content area displays as blank or white. This is one of the most common issues reported with the CoE Starter Kit.

## Common Causes

Blank screens in CoE apps are typically caused by one or more of the following issues:

### 1. Missing or Insufficient Licensing (Most Common)
The CoE Starter Kit requires specific Power Platform licenses to function properly:

**Required Licenses:**
- **Power Apps Premium** or **Power Apps Per User** license
- **NOT** supported: Trial licenses, Power Apps Per App licenses, or Office 365 included licenses

**Why this causes blank screens:**
- Trial and insufficient licenses hit pagination limits in API calls
- PCF (PowerApps Component Framework) controls may fail to load
- Dataverse queries may timeout or fail silently

**How to verify:**
1. Go to [Microsoft 365 Admin Center](https://admin.microsoft.com)
2. Navigate to **Users > Active users**
3. Find your account and check **Licenses and apps**
4. Confirm you have **Power Apps Premium** or **Power Apps Per User** assigned
5. If using trial licenses, note that they may cause intermittent failures

### 2. Missing Administrator Roles and Permissions
You need both tenant-level and environment-level administrative permissions:

**Required Roles:**

**Tenant-level (Azure AD):**
- Global Administrator, OR
- Power Platform Administrator

**Environment-level (Dataverse):**
- System Administrator security role in the CoE environment

**Important:** Having Power Platform Administrator at the tenant level is NOT sufficient. You must also be assigned the System Administrator role within the specific CoE Dataverse environment.

**How to verify:**

**Check Tenant-level roles:**
1. Go to [Azure Portal](https://portal.azure.com)
2. Navigate to **Azure Active Directory > Users**
3. Find your account and check **Assigned roles**
4. Verify you have Global Administrator or Power Platform Administrator

**Check Environment-level roles:**
1. Go to [Power Platform Admin Center](https://admin.powerplatform.microsoft.com)
2. Select your CoE environment
3. Go to **Settings > Users + permissions > Users**
4. Find your account and verify you have **System Administrator** role
5. If not assigned, click **Manage security roles** and assign System Administrator

### 3. Canvas PCF Components Not Enabled
The CoE apps use PowerApps Component Framework (PCF) controls that must be enabled in the environment.

**How to enable:**
1. Go to [Power Platform Admin Center](https://admin.powerplatform.microsoft.com)
2. Select your CoE environment
3. Click **Settings**
4. Navigate to **Features**
5. Find **Power Apps component framework for canvas apps**
6. Turn it **On**
7. Save changes
8. Wait 10-15 minutes for the change to propagate
9. Try opening the app again

### 4. Missing English Language Pack
The CoE Starter Kit is only localized in English and requires the English language pack.

**How to verify and fix:**
1. Go to [Power Platform Admin Center](https://admin.powerplatform.microsoft.com)
2. Select your CoE environment
3. Click **Edit**
4. Under **Languages**, verify that **English** is enabled
5. If not, add English and save
6. Users may need to change their personal language settings in Power Apps

### 5. DLP Policies Blocking Required Connectors
Data Loss Prevention (DLP) policies may block connectors required by CoE apps.

**Required Connectors:**
- Microsoft Dataverse
- Power Apps for Admins
- Power Automate Management
- Office 365 Users
- Office 365 Groups
- Microsoft Dataverse (legacy)

**How to check and fix:**
1. Go to [Power Platform Admin Center](https://admin.powerplatform.microsoft.com)
2. Select **Data policies** from left navigation
3. Review any policies applied to your CoE environment
4. For each policy:
   - Check if the required connectors are in the **Business** data group
   - If connectors are in the **Blocked** or **Non-business** group, move them to **Business**
   - Or exclude your CoE environment from restrictive policies
5. Save changes
6. Wait a few minutes for policies to propagate

### 6. Missing or Incorrect Environment Variables
Environment variables must be properly configured for apps to load data.

**How to verify:**
1. Go to [Power Apps Maker Portal](https://make.powerapps.com)
2. Select your CoE environment
3. Navigate to **Solutions**
4. Open **Center of Excellence - Core Components** solution
5. Select **Environment variables** from the left menu
6. Verify these key variables are set:
   - **Organization URL** / **CoE Base URL**: Should be your environment URL (e.g., `https://orgname.crm.dynamics.com`)
   - **Admin eMail**: Valid admin email address
   - **Also Delete from CoE**: Set appropriately (Yes/No)
   - **Individual Admin**: Admin user UPN

### 7. Browser Cache or Extension Issues
Cached data or browser extensions can interfere with app rendering.

**How to test:**
1. Open an **InPrivate/Incognito** browser window
2. Navigate to [Power Apps](https://make.powerapps.com)
3. Try opening one of the affected apps
4. If it works in incognito:
   - Clear your browser cache and cookies
   - Disable browser extensions
   - Try again in a normal window

### 8. Missing Dataverse Database
The CoE environment must have a Dataverse database provisioned.

**How to verify:**
1. Go to [Power Platform Admin Center](https://admin.powerplatform.microsoft.com)
2. Select your CoE environment
3. Check if you see **Database capacity** and **Storage** information
4. If no database exists, you'll need to provision one:
   - Click **Add database**
   - Follow the wizard to create the database
   - Wait for provisioning to complete (can take several minutes)

## Step-by-Step Troubleshooting Process

Follow these steps in order to diagnose and resolve blank screen issues:

### Step 1: Verify Prerequisites Checklist
Go through this checklist and ensure all prerequisites are met:

- [ ] Power Apps Premium or Per User license assigned (NOT trial)
- [ ] Global Admin or Power Platform Admin role (tenant-level)
- [ ] System Administrator role in CoE environment (environment-level)
- [ ] Dataverse database provisioned in CoE environment
- [ ] English language pack enabled
- [ ] Canvas PCF components enabled in environment settings
- [ ] Required connectors allowed in DLP policies
- [ ] Environment variables properly configured

### Step 2: Test in Incognito Mode
1. Open InPrivate/Incognito browser window
2. Navigate to https://make.powerapps.com
3. Select CoE environment
4. Open affected app
5. If it works: Clear browser cache in normal mode
6. If still blank: Continue to next step

### Step 3: Check Monitor for Errors
Power Apps has a built-in monitor tool that can show detailed errors:

1. Open the affected app in edit mode (if possible) or play mode
2. Press **Ctrl+Alt+Shift+M** (or **Cmd+Option+Shift+M** on Mac) to open Monitor
3. Navigate through the app to trigger the blank screen
4. Look for errors in the Monitor panel:
   - Red entries indicate errors
   - Look for authentication errors, permission errors, or connector errors
   - Note any error messages or codes
5. Common errors and solutions:
   - **401 Unauthorized**: Missing permissions or roles
   - **403 Forbidden**: DLP policy blocking connectors
   - **500 Internal Server Error**: Environment variable issues or backend problems
   - **Connector timeout**: License or pagination issues

### Step 4: Verify Flow Runs
Many CoE apps depend on flows to populate data:

1. Go to [Power Apps Maker Portal](https://make.powerapps.com)
2. Select your CoE environment
3. Navigate to **Solutions > Center of Excellence - Core Components**
4. Select **Cloud flows**
5. Check recent runs of these key flows:
   - **Admin | Sync Template v3**
   - **CLEANUP - Admin | Sync Template v3**
   - Any flows related to the specific app having issues
6. Look for failed runs:
   - Click on failed runs to see error details
   - Common issues: Connector authentication, DLP blocks, license limits
7. If flows haven't run: Trigger them manually and wait for completion

### Step 5: Check Solution Health
1. Go to [Power Platform Admin Center](https://admin.powerplatform.microsoft.com)
2. Select your CoE environment
3. Navigate to **Solutions**
4. Find **Center of Excellence - Core Components**
5. Check for:
   - Solution import errors
   - Missing dependencies
   - Unmanaged layers (can prevent updates)
6. If issues found, consider reinstalling the solution

### Step 6: Validate Data in Dataverse Tables
If everything else looks good, check if data exists in Dataverse:

1. Go to [Power Apps Maker Portal](https://make.powerapps.com)
2. Select your CoE environment
3. Navigate to **Tables** (or **Dataverse > Tables**)
4. Check these key tables for data:
   - **Power Apps App** (admin_app)
   - **Flows** (admin_flow)
   - **Power Platform User** (admin_user)
5. If tables are empty:
   - Sync flows haven't run successfully
   - Run inventory flows manually
   - Wait for initial data population (can take hours for large tenants)

## Additional Troubleshooting for Specific Apps

### CoE Setup Wizard
If the Setup Wizard shows blank after "Confirm pre-requisites":

1. Ensure all prerequisites are met (see Step 1)
2. Check that environment variables are set in the Core Components solution
3. Verify that the user running the wizard has System Administrator role
4. Try running the wizard in a different browser
5. Check if PCF components are enabled for canvas apps

### Admin - Flow Permission Center
If Flow Permission Center loads but shows empty content:

1. Verify that the Flow inventory has been synchronized
2. Check that **Admin | Sync Template v3 (Flows)** has run successfully
3. Ensure the user has permissions to view flows in the tenant
4. Check that the **Power Automate Management** connector is not blocked by DLP

### Data Policy Impact Analysis
If DPI Analysis shows blank:

1. Verify that DLP policies exist in your tenant
2. Check that the **Power Apps for Admins** connector is not blocked
3. Ensure inventory flows have populated the apps and flows tables
4. Verify the user has Power Platform Administrator or policy viewing permissions

## Known Limitations

1. **Trial Licenses**: May cause intermittent blank screens due to pagination limits
2. **Per-App Licenses**: Not sufficient for CoE Starter Kit apps
3. **Multi-language**: Only English is supported; blank screens may occur in other languages
4. **Large Tenants**: Initial data sync can take several hours; apps may appear blank until complete
5. **Browser Compatibility**: Some older browsers may not render PCF components correctly

## Getting Help

If you've followed all troubleshooting steps and still experience blank screens:

1. **Check existing issues**: Search the [CoE Starter Kit GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues) for similar problems
2. **Review the wiki**: Visit the [Issue Triage Wiki](https://github.com/microsoft/coe-starter-kit/wiki/Issue-triage-(CoE-Starter-Kit))
3. **File a new issue**: Use the [Bug Report Template](https://github.com/microsoft/coe-starter-kit/issues/new/choose) and include:
   - Screenshots of the blank screen
   - Confirmation of prerequisites checked
   - Monitor errors (if any)
   - Solution version
   - Environment details (region, type, etc.)
   - Steps you've already tried
4. **Community support**: Post in the [Power Apps Community Forum](https://powerusers.microsoft.com/t5/Power-Apps-Governance-and/bd-p/Admin_PowerApps)

## Reference Links

- [Official CoE Starter Kit Documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- [Setup Instructions](https://learn.microsoft.com/power-platform/guidance/coe/setup)
- [Prerequisites](https://learn.microsoft.com/power-platform/guidance/coe/setup#prerequisites)
- [Troubleshooting Setup](https://learn.microsoft.com/power-platform/guidance/coe/setup-troubleshooting)
- [License Requirements](https://learn.microsoft.com/power-platform/guidance/coe/setup#what-identity-should-i-install-the-coe-starter-kit-with)

## Version History

- **v1.0** (2024-12-16): Initial troubleshooting guide for blank screen issues

---

**Note**: The CoE Starter Kit is a community-supported template and is provided "as-is" without official Microsoft support SLA. For production support needs, consult with your Microsoft account team.
