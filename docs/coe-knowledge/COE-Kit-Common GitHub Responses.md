# CoE Starter Kit - Common GitHub Responses

This document contains ready-to-use explanations, limits, workarounds, and troubleshooting guidance for common CoE Starter Kit issues.

## Table of Contents
- [General Support Information](#general-support-information)
- [Blank Screens / Apps Not Loading](#blank-screens--apps-not-loading)
- [Prerequisites and Setup Issues](#prerequisites-and-setup-issues)
- [BYODL (Data Lake) Status](#byodl-data-lake-status)
- [Pagination and Licensing Requirements](#pagination-and-licensing-requirements)
- [Language Pack Requirements](#language-pack-requirements)
- [DLP Policies and Connector Issues](#dlp-policies-and-connector-issues)
- [Cleanup Flows and Inventory](#cleanup-flows-and-inventory)
- [Unsupported Features](#unsupported-features)
- [Setup Wizard Guidance](#setup-wizard-guidance)

---

## General Support Information

The CoE Starter Kit is provided as **best-effort, unsupported** software. Microsoft does not provide official support through traditional support channels. All issues should be investigated and resolved through:

- **GitHub Issues**: https://github.com/microsoft/coe-starter-kit/issues
- **Official Documentation**: https://learn.microsoft.com/power-platform/guidance/coe/starter-kit
- **Community Forums**: Power Apps Community forum for general governance questions

**There is no SLA for issue resolution.** The CoE Starter Kit team reviews issues on a best-effort basis.

---

## Blank Screens / Apps Not Loading

### Symptoms
- Setup Wizard shows blank screen with only header visible
- Admin apps (Flow Permission Center, Data Policy Impact Analysis, etc.) display blank/white screens
- Apps load but show no content or controls
- Components fail to render

### Root Causes
This is one of the most common issues and is typically caused by:

1. **Missing Prerequisites** (Most Common)
   - Required licenses not assigned
   - Admin privileges not granted
   - Environment not configured correctly
   - Missing Dataverse database

2. **DLP Policy Blocking Connectors**
   - Power Apps connector blocked
   - Dataverse connector blocked
   - Office 365 Users connector blocked
   - HTTP connector blocked (if required)

3. **Missing Language Pack**
   - Environment doesn't have English language pack enabled
   - User's browser language settings incompatible

4. **Insufficient Permissions**
   - User not assigned System Administrator or Environment Admin role
   - Missing security role for CoE apps
   - Dataverse permissions not propagated

5. **Browser or Cache Issues**
   - Browser extensions blocking content
   - Cached data causing rendering problems
   - Pop-up blockers interfering with authentication

### Solutions

#### Step 1: Verify Prerequisites
Before using any CoE Starter Kit component, ensure all prerequisites are met:

**Required Licenses:**
- Power Apps Premium or Power Apps Per User license
- Power Automate Premium (for cloud flows)
- Microsoft 365 license (for Office 365 connectors)

**Verify License Assignment:**
```
1. Go to Power Platform Admin Center
2. Navigate to your CoE environment
3. Select Users
4. Verify your account has required licenses
```

**Required Admin Roles:**
- Global Administrator, Power Platform Administrator, or Dynamics 365 Administrator (for tenant-wide inventory)
- Environment Admin or System Administrator (for environment-level access)

#### Step 2: Check DLP Policies
Data Loss Prevention policies can block required connectors:

**Verify DLP Configuration:**
```
1. Go to Power Platform Admin Center
2. Select "Data policies" from left navigation
3. Review policies applied to your CoE environment
4. Ensure these connectors are in "Business" or allowed group:
   - Microsoft Dataverse
   - Power Apps for Admins
   - Power Automate Management
   - Office 365 Users
   - Office 365 Outlook (if using email features)
   - HTTP (if using external integrations)
```

**Common DLP Issue:**
If your organization has a strict DLP policy that blocks these connectors, you will need to:
- Create a DLP policy exemption for the CoE environment
- Or move your CoE environment to a separate policy group
- Work with your tenant admin to adjust DLP settings

#### Step 3: Enable English Language Pack
The CoE Starter Kit requires the English language pack:

**Enable English Language:**
```
1. Go to Power Platform Admin Center
2. Select your CoE environment
3. Click "Edit" 
4. Under "Languages", ensure English is enabled
5. If not, add English language pack
6. Wait 10-15 minutes for propagation
7. Restart your browser and clear cache
```

#### Step 4: Verify Environment Setup
**Check Dataverse Database:**
```
1. Go to Power Platform Admin Center
2. Select your CoE environment
3. Verify it shows a Dataverse database is provisioned
4. If not, you need to create a Dataverse database first
```

#### Step 5: Clear Browser Cache and Retry
```
1. Clear browser cache and cookies
2. Try in an InPrivate/Incognito window
3. Disable browser extensions temporarily
4. Try a different browser (Edge, Chrome)
```

#### Step 6: Check Flow Runs and Error Messages
If apps still don't load, check the underlying flows:

```
1. Go to Power Automate
2. Navigate to your CoE environment
3. Check "Admin | Sync Template v3" and other inventory flows
4. Review run history for errors
5. Check for authentication failures or permission errors
```

### Template Response for Blank Screen Issues

```markdown
Thank you for reporting this issue. The blank screens you're seeing are typically caused by missing prerequisites or configuration issues. 

To help diagnose and resolve this, please verify the following:

**1. Prerequisites:**
- Do you have a Power Apps Premium or Per User license assigned?
- Do you have Global Admin, Power Platform Admin, or System Administrator role?
- Does your CoE environment have a Dataverse database provisioned?

**2. DLP Policies:**
- Are there any DLP policies applied to your CoE environment?
- Can you verify that these connectors are allowed:
  - Microsoft Dataverse
  - Power Apps for Admins
  - Power Automate Management
  - Office 365 Users

**3. Language Settings:**
- Is the English language pack enabled in your environment?
- Check: Power Platform Admin Center > Your environment > Edit > Languages

**4. Try these troubleshooting steps:**
- Clear browser cache
- Try InPrivate/Incognito mode
- Disable browser extensions
- Try a different browser

Please provide details on the above points, and we can help identify the specific issue.

Reference: [Setup Prerequisites](https://learn.microsoft.com/power-platform/guidance/coe/setup#prerequisites)
```

---

## Prerequisites and Setup Issues

### Complete Prerequisites Checklist

Before installing or using the CoE Starter Kit, verify:

**Environment Requirements:**
- [ ] Production environment (recommended)
- [ ] Dataverse database provisioned
- [ ] English language pack enabled
- [ ] Sufficient database capacity (minimum 1 GB recommended)

**License Requirements:**
- [ ] Power Apps Premium or Per User license
- [ ] Power Automate Premium license
- [ ] Microsoft 365 license
- [ ] Azure subscription (if using Azure components)

**Permission Requirements:**
- [ ] Global Administrator, Power Platform Administrator, or Dynamics 365 Administrator (for tenant-wide inventory)
- [ ] Environment Admin or System Administrator role in CoE environment
- [ ] Ability to create app registrations in Azure AD (for service principal setup)

**DLP Policy Requirements:**
- [ ] Verify connectors are not blocked by DLP policies
- [ ] Create DLP exemption for CoE environment if needed

**Setup Steps:**
1. Create or identify CoE environment
2. Install Core solution first
3. Configure environment variables
4. Set up connections
5. Share apps and flows with appropriate users
6. Turn on required flows

### Common Setup Errors

**Error: "You don't have permissions to view this app"**
- Solution: Assign System Administrator security role
- Verify user is in the CoE environment

**Error: "This app can't be opened"**
- Solution: Check DLP policies
- Verify all connectors are created and shared

**Error: Environment variables not configured**
- Solution: Run Setup Wizard or manually configure environment variables
- Reference: https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components

---

## BYODL (Data Lake) Status

**IMPORTANT: Bring Your Own Data Lake (BYODL) is no longer recommended.**

### Current Recommendation
- The CoE Starter Kit team is moving toward Microsoft Fabric integration
- Do NOT set up new BYODL implementations
- Existing BYODL implementations can continue but are not actively supported

### Alternative Approaches
1. **Cloud Flows** (Recommended): Use the standard cloud flow-based inventory collection
2. **Data Export Service**: For customers who previously used BYODL
3. **Microsoft Fabric** (Future): Upcoming integration for advanced analytics

### If You're Using BYODL
- Continue using it if already set up and working
- Plan migration to cloud flows or Fabric
- Monitor announcements for Fabric integration

---

## Pagination and Licensing Requirements

### Issue: Pagination Limits Hit During Inventory

**Symptoms:**
- Inventory flows fail with pagination errors
- Not all apps/flows/connectors are collected
- "Request limit exceeded" errors

**Root Cause:**
Trial licenses or insufficient license profiles have lower API pagination limits.

**Solution:**

**Test License Adequacy:**
```powershell
# Use PowerShell to test pagination limits
# Install Power Platform Administration module
Install-Module -Name Microsoft.PowerApps.Administration.PowerShell

# Connect
Add-PowerAppsAccount

# Test pagination
Get-AdminPowerApp -EnvironmentName [your-env] -Top 5000
```

**Requirements:**
- **Premium licenses required**: Power Apps Premium or Per User
- **Trial licenses insufficient**: Will hit pagination limits with large tenants
- **Per-app licenses insufficient**: Need premium/per-user licenses

**If hitting limits:**
1. Verify admin account has premium license
2. Upgrade from trial to premium license
3. Check license assignment in M365 admin center
4. Wait 24 hours after license assignment for propagation

---

## Language Pack Requirements

### Issue: Apps and Flows Require English Language Pack

The CoE Starter Kit is **English-only**. Environments must have the English language pack enabled.

**Symptoms:**
- Blank screens
- Missing labels or controls
- Localization errors

**Solution:**

**Enable English Language Pack:**
```
1. Power Platform Admin Center
2. Select your environment
3. Click "Edit"
4. Under "Languages", ensure "English" is enabled
5. Save changes
6. Wait 10-15 minutes for propagation
7. Restart browser and clear cache
```

**Note:** Even if your organization primarily uses another language, English must be enabled for CoE Starter Kit components to function correctly.

---

## DLP Policies and Connector Issues

### Required Connectors

The CoE Starter Kit requires these connectors to be allowed:

**Core Components:**
- Microsoft Dataverse
- Power Apps for Admins
- Power Automate Management
- Power Platform for Admins
- Office 365 Users
- Office 365 Outlook

**Governance Components:**
- All Core connectors
- Approvals
- Microsoft Teams (for notifications)

**Audit Log Components:**
- All Core connectors
- Office 365 Management APIs
- Azure AD

**Nurture Components:**
- All Core connectors
- Microsoft Teams
- SharePoint

### DLP Configuration

**Check Current DLP Policies:**
```
1. Power Platform Admin Center
2. Data policies
3. Review policies applied to CoE environment
4. Check connector classification (Business/Non-Business/Blocked)
```

**Recommended DLP Strategy:**

**Option 1: Environment Exclusion**
- Exclude CoE environment from restrictive DLP policies
- Create a separate DLP policy for CoE environment only

**Option 2: Connector Group Configuration**
- Ensure all required connectors are in "Business" group
- Create tenant-level policy with required connectors

**Important:** Work with your security and compliance teams to ensure DLP changes align with organizational policies.

---

## Cleanup Flows and Inventory

### Inventory Collection

**Driver Flows:**
The "Admin | Sync Template v3" flow is the primary inventory driver.

**Expected Behavior:**
- Runs on schedule (daily or weekly)
- Collects apps, flows, connectors, environments
- Writes to Dataverse tables
- Can take several hours for large tenants

**Common Issues:**

**Issue: Inventory not complete**
- Run full inventory flow manually
- Check flow run history for errors
- Verify API limits not exceeded

**Issue: Old data not cleaned up**
- Use cleanup flows to remove stale data
- Check orphaned records
- Review deleted resource cleanup

### Cleanup Flows

**Purpose:**
- Remove objects that no longer exist in the tenant
- Clean up orphaned records
- Maintain data quality

**Usage:**
```
1. Go to Power Automate
2. Find "Admin | Cleanup..." flows
3. Run manually when needed
4. Review run history
```

**Recommendation:**
- Run cleanup flows after major changes
- Schedule cleanup flows monthly or quarterly
- Always backup before running cleanup

---

## Unsupported Features

### What is NOT Supported

The CoE Starter Kit does **NOT** include official Microsoft support:

- No SLA for bug fixes
- No guaranteed response time
- No phone or email support
- Community-driven support only

### Limitations

**Tenant Size:**
- Very large tenants (10,000+ apps) may experience performance issues
- Pagination limits apply
- Consider segmented inventory collection

**Customizations:**
- Removing unmanaged layers required to receive updates
- Customizations may be overwritten during upgrades
- Document all customizations

**Licensing:**
- Trial licenses insufficient for production use
- Per-app licenses insufficient
- Premium licenses required

---

## Setup Wizard Guidance

### Using the Setup Wizard

The CoE Setup Wizard helps configure environment variables and connections.

**Access:**
```
1. Go to Power Apps
2. Select your CoE environment
3. Open "CoE Setup Wizard" app
4. Follow step-by-step configuration
```

### Common Setup Wizard Issues

**Issue: Wizard shows blank screen**
- See [Blank Screens / Apps Not Loading](#blank-screens--apps-not-loading) section above
- Verify prerequisites
- Check DLP policies
- Enable English language pack

**Issue: "Confirm pre-requisites" step won't complete**
- Verify you have required admin privileges
- Check that user meets all identity requirements
- Ensure Dataverse database exists
- Review license assignment

**Issue: Environment variables not saving**
- Check permissions
- Verify connection references are created
- Try manual environment variable configuration

### Manual Configuration Alternative

If Setup Wizard doesn't work, configure manually:

```
1. Power Apps > Solutions > Center of Excellence - Core Components
2. Select "Environment variables"
3. Set required values:
   - Admin Email
   - Company Name  
   - Community URL
   etc.
4. Save all changes
5. Set up connection references
6. Turn on flows
```

Reference: https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components

---

## Standard Issue Questionnaire

When an issue report lacks sufficient detail, use this questionnaire:

```markdown
Thank you for raising this issue. To help us resolve it efficiently, could you please provide the following details:

**Environment & Version:**
- Solution name and version (e.g., Core 4.50.6)
- What app or flow are you experiencing the issue with?
- What method are you using to get inventory and telemetry? (Cloud flows / Data Export)

**Issue Details:**
- Describe the issue in detail (what you're experiencing)
- Expected behavior (what should happen)
- Steps to reproduce the issue
- Any error messages or screenshots

**Configuration:**
- Do you have a Power Apps Premium license?
- What admin roles do you have?
- Are there DLP policies applied to your environment?
- Is the English language pack enabled?
- Have you completed the Setup Wizard?

**Additional Context:**
- Any other relevant information, logs, or screenshots
- Recent changes to your environment
- When did this issue start occurring?

This information will help us analyze and suggest the most appropriate fix.
```

---

## Quick Reference Links

- **Official Documentation**: https://learn.microsoft.com/power-platform/guidance/coe/starter-kit
- **Setup Guide**: https://learn.microsoft.com/power-platform/guidance/coe/setup
- **Prerequisites**: https://learn.microsoft.com/power-platform/guidance/coe/setup#prerequisites
- **GitHub Issues**: https://github.com/microsoft/coe-starter-kit/issues
- **Community Forum**: https://powerusers.microsoft.com/t5/Power-Apps-Governance-and/bd-p/Admin_PowerApps

---

## Update History

- **2025-12-03**: Initial creation with common troubleshooting scenarios
