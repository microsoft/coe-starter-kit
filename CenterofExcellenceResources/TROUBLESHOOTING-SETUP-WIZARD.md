# CoE Setup Wizard Troubleshooting Guide

This guide helps troubleshoot common issues encountered during the CoE Starter Kit setup and upgrade process, particularly with the Setup Wizard.

## Table of Contents
- [Error Loading Control](#error-loading-control)
- [Service Account Cannot Be Added as System Administrator](#service-account-cannot-be-added-as-system-administrator)
- [Prerequisites Checklist](#prerequisites-checklist)
- [Common Resolution Steps](#common-resolution-steps)

---

## Error Loading Control

### Symptom
When opening the CoE Setup and Upgrade Wizard, the "Confirm pre-requisites" page displays an **"Error loading control"** message instead of showing the prerequisites checklist.

![Error Loading Control Screenshot](https://github.com/user-attachments/assets/21c32469-db15-4581-a6d2-91a3faacac16)

### Root Cause
The Setup Wizard uses PowerApps Component Framework (PCF) controls from the **Creator Kit** (formerly PowerCAT components), specifically:
- **FluentDetailsList2** - Used to display the prerequisites checklist
- **Shimmer controls** - Used for loading animations

These controls may fail to load due to:
1. Missing or outdated Creator Kit solution
2. Browser caching issues
3. Environment language pack configuration
4. Missing dependencies after solution import

### Resolution Steps

#### Step 1: Verify Creator Kit Installation
The CoE Starter Kit requires the **Creator Kit** to be installed in the same environment. 

1. Navigate to **[Power Apps](https://make.powerapps.com)** > **Solutions**
2. Check if the **Creator Kit** solution is installed
3. If not installed, install it from **[Microsoft AppSource](https://appsource.microsoft.com/en-us/product/dynamics-365/microsoftpowercatarch.creatorkit1)**
4. If installed but outdated, upgrade to the latest version

**Note:** The Creator Kit must be installed **before** importing the CoE Starter Kit Core Components.

#### Step 2: Verify English Language Pack
The CoE Starter Kit requires the English language pack to be enabled in the environment.

1. Open **PowerShell** as Administrator
2. Run the following command to verify:
```powershell
Install-Module -Name Microsoft.PowerApps.Administration.PowerShell -Scope CurrentUser
Import-Module Microsoft.PowerApps.Administration.PowerShell

# Replace with your environment name
Get-AdminPowerAppEnvironmentLanguages -EnvironmentName "your-environment-name"
```
3. Ensure **1033 (English)** is listed
4. If not present, enable it via **Power Platform Admin Center** > **Environments** > Select environment > **Settings** > **Product** > **Languages**

#### Step 3: Clear Browser Cache
PCF controls are cached by browsers and may become stale after solution upgrades.

1. **Clear browser cache completely** (especially for Chromium-based browsers):
   - Chrome: Settings > Privacy and security > Clear browsing data > Select "Cached images and files" > Time range: "All time"
   - Edge: Settings > Privacy, search, and services > Clear browsing data > Choose what to clear > "Cached images and files"
2. Try opening the Setup Wizard in an **InPrivate/Incognito window**
3. If the issue persists, try a different browser

#### Step 4: Check for Unmanaged Customizations
Unmanaged layers on the Setup Wizard app can cause control loading failures.

1. Navigate to **Power Apps** > **Solutions** > **Center of Excellence - Core Components**
2. Find **CoE Setup and Upgrade Wizard** app
3. Select **...** > **See solution layers**
4. If unmanaged layers exist, remove them by:
   - Selecting **...** > **Remove unmanaged layer** for each unmanaged customization

#### Step 5: Re-import Creator Kit (Advanced)
If the above steps don't resolve the issue, the Creator Kit may need to be re-imported.

**⚠️ Warning:** Only do this if advised by Microsoft Support or if you have a backup.

1. Export any customizations dependent on Creator Kit controls
2. Delete the Creator Kit solution
3. Re-import the latest version from AppSource
4. Upgrade the CoE Starter Kit Core Components solution

#### Step 6: Check Browser Developer Console for Errors
1. Open the Setup Wizard in your browser
2. Press **F12** to open Developer Tools
3. Navigate to the **Console** tab
4. Look for JavaScript errors related to:
   - `FluentDetailsList`
   - `PowerCAT`
   - `PCF control`
5. Share these errors with Microsoft Support if needed

---

## Service Account Cannot Be Added as System Administrator

### Symptom
When attempting to add a service account as **System Administrator** to Power Platform environments (with or without Dataverse):
- Manual role assignment via Power Platform Admin Center **fails**
- Automated role assignment via Setup Wizard flows **fails**
- Error message appears or the "Get Role" button loops without assigning the role

### Root Cause
This issue typically occurs due to one of the following:

1. **Insufficient License Assignment**
   - Service account lacks a proper Power Apps license (Per User or Premium)
   - Trial licenses may have expired
   - License is assigned but not yet synchronized

2. **Account Type Issues**
   - Service account is an **App Registration** or **Service Principal** instead of a **User Account**
   - Service principal authentication is not supported for Dataverse System Administrator role assignment

3. **Power Platform Service API Issues**
   - Temporary platform API regression (check [Power Platform Service Health](https://admin.powerplatform.microsoft.com/servicehealth))
   - Environment is in administration mode or maintenance
   - Regional service disruption

### Resolution Steps

#### Step 1: Verify Service Account Type
The service account **must be a user account**, not a service principal or app registration.

1. Navigate to **[Microsoft Entra Admin Center](https://entra.microsoft.com)** > **Users** > **All users**
2. Search for the service account
3. Verify it appears in the **Users** list (not under **Enterprise applications** or **App registrations**)
4. If it's a service principal, you must create a **dedicated user account** instead

#### Step 2: Verify License Assignment
The service account needs a **Power Apps Per User** or **Power Apps Premium** license.

1. Navigate to **[Microsoft 365 Admin Center](https://admin.microsoft.com)** > **Users** > **Active users**
2. Select the service account
3. Go to the **Licenses and apps** tab
4. Verify one of the following licenses is assigned:
   - **Power Apps Per User**
   - **Power Apps Premium**
   - **Dynamics 365** (includes Power Apps)
5. If not assigned, assign the appropriate license
6. Wait 15-30 minutes for synchronization, then retry role assignment

**Note:** Having only **Power Platform Admin** or **Global Admin** roles in Entra ID is **not sufficient** - a Power Apps license is required.

#### Step 3: Test with a Different User
To isolate whether the issue is specific to the service account:

1. Try manually assigning **System Administrator** role to a different user (your own account)
2. If successful, the issue is specific to the service account (likely licensing)
3. If unsuccessful, the issue may be environment-level or a platform issue

#### Step 4: Test with a Different Security Role
Test if the service account can be assigned a **different** security role:

1. Go to **Power Platform Admin Center** > **Environments** > Select environment
2. Go to **Settings** > **Users + permissions** > **Users**
3. Try assigning the service account to **Basic User** or **Environment Maker** role
4. If successful, the issue is specific to **System Administrator** role assignment (likely licensing)

#### Step 5: Use PowerShell for Role Assignment
Try assigning the role via PowerShell as an alternative method:

```powershell
# Install the module if not already installed
Install-Module -Name Microsoft.PowerApps.Administration.PowerShell -Scope CurrentUser
Import-Module Microsoft.PowerApps.Administration.PowerShell

# Connect to Power Platform
Add-PowerAppsAccount

# Get environment ID
$envId = "your-environment-id"

# Get user ID (Object ID from Entra ID)
$userId = "user-object-id-guid"

# Get System Administrator role ID
$roleId = "system-administrator-role-guid"

# Assign role
Set-AdminPowerAppEnvironmentRoleAssignment -EnvironmentName $envId -RoleId $roleId -PrincipalType User -PrincipalObjectId $userId
```

#### Step 6: Check Power Platform Service Health
1. Navigate to **[Power Platform Admin Center](https://admin.powerplatform.microsoft.com)** > **Service health**
2. Check for any active incidents related to:
   - Dataverse
   - Security role assignment
   - Environment management
3. If incidents are active, wait for resolution before retrying

#### Step 7: Contact Microsoft Support
If all steps above fail, open a support ticket with Microsoft:
- Provide screenshots of the error
- Include service account details (Object ID, licenses assigned)
- Include browser console logs (F12 > Console tab)
- Mention troubleshooting steps already performed

---

## Prerequisites Checklist

Before installing or upgrading the CoE Starter Kit, ensure the following prerequisites are met:

### Environment Prerequisites
- [ ] Environment has Dataverse database provisioned
- [ ] English (1033) language pack is enabled
- [ ] Environment is not in administration mode
- [ ] No pending maintenance windows scheduled

### Service Account Prerequisites
- [ ] Service account is a **user account** (not service principal or app registration)
- [ ] Service account has **Power Apps Per User** or **Power Apps Premium** license assigned
- [ ] Service account has **Power Platform Admin** role in Entra ID
- [ ] Service account has **System Administrator** role in the CoE environment
- [ ] Service account can successfully authenticate to Power Platform

### Solution Prerequisites
- [ ] **Creator Kit** solution is installed (required for Setup Wizard)
- [ ] **Power Virtual Agents** is enabled (if using Copilot features)
- [ ] **Environment Variables** solution is available (usually pre-installed)
- [ ] No unmanaged customizations exist on CoE apps
- [ ] Previous CoE Starter Kit version (if upgrading) is on a supported upgrade path

### Network Prerequisites
- [ ] HTTP with Azure AD connector is in the same DLP policy group as Dataverse
- [ ] Office 365 Outlook connector is in the same DLP policy group (if using email features)
- [ ] Firewall/proxy allows access to `*.powerapps.com` and `*.dynamics.com`

### User Permissions
- [ ] Installing user has **System Administrator** role in the environment
- [ ] Installing user has **Environment Admin** or **Environment Maker** role
- [ ] Installing user has permission to create cloud flows

---

## Common Resolution Steps

### General Troubleshooting Tips

1. **Always clear browser cache** after solution upgrades
2. **Try InPrivate/Incognito mode** to isolate caching issues
3. **Check browser console (F12)** for JavaScript errors
4. **Verify licenses are synchronized** - wait 15-30 minutes after assigning licenses
5. **Check Power Platform Service Health** for platform-wide issues
6. **Remove unmanaged layers** before troubleshooting apps
7. **Follow the upgrade path** - don't skip major versions
8. **Read release notes** - check for breaking changes or new prerequisites

### When to Contact Microsoft Support

Contact Microsoft Support when:
- All troubleshooting steps have been exhausted
- Issue affects multiple users/environments
- Issue appears to be a platform-level regression
- Error messages reference internal system errors
- Setup Wizard flows fail with "Service unavailable" errors

### Useful Resources

- **Official CoE Starter Kit Documentation:** https://learn.microsoft.com/power-platform/guidance/coe/starter-kit
- **Setup Guide:** https://learn.microsoft.com/power-platform/guidance/coe/setup
- **FAQ:** https://learn.microsoft.com/power-platform/guidance/coe/faq
- **Creator Kit:** https://learn.microsoft.com/power-platform/guidance/creator-kit/overview
- **Power Platform Admin Center:** https://admin.powerplatform.microsoft.com
- **Power Platform Service Health:** https://admin.powerplatform.microsoft.com/servicehealth
- **AppForbidden/DLP Error Guide:** [../docs/troubleshooting/app-forbidden-dlp-error.md](../docs/troubleshooting/app-forbidden-dlp-error.md)

---

## Known Issues and Limitations

### Creator Kit Dependency
- The CoE Starter Kit Core Components version 4.50.7+ **requires** the Creator Kit to be installed
- The Creator Kit must be installed **before** the CoE Starter Kit
- Upgrading the Creator Kit may require upgrading the CoE Starter Kit afterward

### Service Principal Limitations
- Service principals (App Registrations) **cannot** be assigned the System Administrator role via UI
- Service principals **can** be used for authentication but need to be added via PowerShell
- For Setup Wizard automation, use a **dedicated user account** instead

### Language Pack Limitations
- The CoE Starter Kit is **English-only**
- Non-English language packs can cause control loading failures
- Always ensure English (1033) is the base language

### Browser Compatibility
- The Setup Wizard is optimized for **Chromium-based browsers** (Edge, Chrome)
- Internet Explorer is **not supported**
- Safari may have compatibility issues with PCF controls

---

## Contributing

Found a solution not listed here? Contribute to this troubleshooting guide by:
1. Opening an issue on [GitHub](https://github.com/microsoft/coe-starter-kit/issues)
2. Submitting a pull request with your solution
3. Sharing your experience in the [Power Platform Community](https://powerusers.microsoft.com)

---

**Last Updated:** January 2026  
**Applies To:** CoE Starter Kit v4.50.7 and later
