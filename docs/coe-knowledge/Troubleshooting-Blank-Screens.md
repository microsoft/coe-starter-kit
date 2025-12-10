# Troubleshooting Blank Screens in CoE Starter Kit Apps

This guide addresses the common issue where CoE Starter Kit apps (Setup Wizard, Admin apps, etc.) display blank or white screens with only headers visible.

## Overview

Blank screens are the most frequently reported issue with the CoE Starter Kit. This is almost always caused by missing prerequisites, incorrect configuration, or DLP policies blocking required connectors.

## Affected Apps

Common apps that exhibit blank screen issues:
- **CoE Setup Wizard** - Shows "Confirm pre-requisites" with blank content area
- **Admin - Flow Permission Center** - Displays header but no flow list
- **Data Policy Impact Analysis** - Shows app shell with no content
- **Power Platform Admin View** - Blank main screen
- **Other admin canvas apps** - General rendering issues

## Quick Diagnosis Checklist

Use this checklist to quickly identify the most common causes:

- [ ] **Do you have a Power Apps Premium or Per User license?**
- [ ] **Are you a Global Admin, Power Platform Admin, or System Administrator?**
- [ ] **Does your environment have a Dataverse database provisioned?**
- [ ] **Is the English language pack enabled in your environment?**
- [ ] **Have you checked if DLP policies are blocking required connectors?**
- [ ] **Have you tried clearing your browser cache or using InPrivate mode?**

If you answered "No" or "I don't know" to any of the above, that's likely your issue.

## Root Causes and Solutions

### 1. Missing or Insufficient License (Most Common)

**Symptoms:**
- Blank screen immediately after opening app
- No error message displayed
- App shell loads but no components render

**Why This Happens:**
Canvas apps in the CoE Starter Kit use premium connectors (Dataverse, Power Apps for Admins, etc.) which require premium licensing.

**How to Verify:**
```
1. Go to Microsoft 365 Admin Center (admin.microsoft.com)
2. Navigate to Users > Active users
3. Find your account
4. Check assigned licenses
5. Look for:
   - Power Apps Premium, OR
   - Power Apps Per User, OR
   - Dynamics 365 license that includes Power Apps
```

**Solution:**
- Assign a Power Apps Premium or Per User license to your account
- Wait 15-30 minutes for license propagation
- Sign out and sign back in
- Clear browser cache
- Try accessing the app again

**Note:** Trial licenses work but may have limitations. Per-app licenses are NOT sufficient.

---

### 2. DLP Policies Blocking Connectors

**Symptoms:**
- Blank screen with no errors
- "Connection not available" errors in browser console (F12)
- Works for some users but not others

**Why This Happens:**
Data Loss Prevention policies can classify Power Platform admin connectors as "Blocked" or prevent them from being in the same data group as Dataverse.

**How to Verify:**
```
1. Go to Power Platform Admin Center (admin.powerplatform.microsoft.com)
2. Select "Data policies" from left navigation
3. Click on each policy to review
4. Check if any policies apply to your CoE environment
5. For each applied policy, verify these connectors are in "Business" group:
   - Microsoft Dataverse
   - Power Apps for Admins
   - Power Automate Management
   - Power Platform for Admins
   - Office 365 Users
```

**Solution Options:**

**Option A: Exclude CoE Environment**
```
1. Edit the DLP policy
2. Under "Environments", select "Exclude certain environments"
3. Add your CoE environment to exclusion list
4. Save policy
```

**Option B: Add Connectors to Business Group**
```
1. Edit the DLP policy
2. Find each required connector
3. Move to "Business" group
4. Ensure Dataverse is also in "Business" group
5. Save policy
```

**Option C: Create Separate Policy**
```
1. Create a new DLP policy specifically for CoE environment
2. Set all required connectors to "Business"
3. Apply only to CoE environment
4. Ensure no other policies apply to CoE environment
```

**Validation:**
After changing DLP policies:
1. Wait 5-10 minutes for policy propagation
2. Sign out and sign back in
3. Clear browser cache
4. Try accessing the app again

---

### 3. Missing English Language Pack

**Symptoms:**
- Blank screen
- Missing labels or buttons
- Partial rendering of controls

**Why This Happens:**
The CoE Starter Kit is built using English language resources. If English is not enabled in the environment, localization fails and components don't render.

**How to Verify:**
```
1. Go to Power Platform Admin Center
2. Select Environments
3. Find and click on your CoE environment
4. Click "Edit" at the top
5. Scroll to "Languages" section
6. Check if "English" is in the enabled languages list
```

**Solution:**
```
1. In the environment edit screen, under "Languages"
2. If English is not enabled, click "Add language"
3. Select "English" from the dropdown
4. Click "Add"
5. Click "Save" to save environment changes
6. Wait 10-15 minutes for language pack provisioning
7. Sign out of Power Apps
8. Clear browser cache
9. Sign back in and try accessing the app
```

**Important Notes:**
- Your organization can use other languages, but English must also be enabled
- This is a requirement, not a preference
- Even if your user profile is set to another language, English must be available in the environment

---

### 4. Insufficient Permissions

**Symptoms:**
- Blank screen
- "You don't have permissions" error
- App loads for some users but not others

**Why This Happens:**
CoE apps require elevated permissions to read tenant-wide data and administrative information.

**Required Roles:**

For **tenant-wide inventory**:
- Global Administrator, OR
- Power Platform Administrator, OR
- Dynamics 365 Administrator

For **environment-level access**:
- Environment Admin, OR
- System Administrator (in the CoE environment)

**How to Verify:**
```
1. Check Azure AD role:
   - Go to Azure Portal (portal.azure.com)
   - Navigate to Azure Active Directory > Users
   - Find your user and check assigned roles
   
2. Check Power Platform role:
   - Go to Power Platform Admin Center
   - Select your CoE environment
   - Click "Settings" > "Users + permissions" > "Users"
   - Find your user
   - Verify "Security roles" includes "System Administrator"
```

**Solution:**

**For Tenant-Wide Admin Role:**
```
1. Contact your Global Administrator
2. Request assignment of one of these roles:
   - Power Platform Administrator (recommended for CoE)
   - Global Administrator
   - Dynamics 365 Administrator
3. After assignment, sign out and back in
4. Wait 15-30 minutes for role propagation
```

**For Environment-Level Access:**
```
1. Have an existing admin of the CoE environment:
   - Go to Power Platform Admin Center
   - Select the CoE environment
   - Go to Settings > Users + permissions > Users
   - Select your user
   - Click "Manage security roles"
   - Ensure "System Administrator" is checked
   - Save changes
2. Sign out and back in
3. Clear browser cache
4. Try accessing the app again
```

---

### 5. Missing Dataverse Database

**Symptoms:**
- Blank screen
- Error: "This environment does not have a Dataverse database"
- App won't launch at all

**Why This Happens:**
The CoE Starter Kit stores all data in Dataverse tables. Without a Dataverse database, there's nowhere to read/write data.

**How to Verify:**
```
1. Go to Power Platform Admin Center
2. Select Environments
3. Find your CoE environment
4. Check the "Type" column - should show "Production" or "Sandbox"
5. Check if Dataverse database size is shown (e.g., "1.2 GB / 10 GB")
6. If it says "None" or no database info, Dataverse is not provisioned
```

**Solution:**
```
1. Go to Power Platform Admin Center
2. Select your environment
3. If prompted "Add database", click it
4. Configure database settings:
   - Language: English
   - Currency: Your preferred currency
   - Security group: Leave empty or select specific group
5. Click "Add"
6. Wait 5-10 minutes for database provisioning
7. Verify database is provisioned (refresh the page)
8. Proceed with CoE Starter Kit installation
```

**Important:** You cannot install CoE Starter Kit without a Dataverse database.

---

### 6. Browser or Cache Issues

**Symptoms:**
- Blank screen
- Inconsistent behavior (works sometimes, not others)
- Works in one browser, not another

**Why This Happens:**
- Cached authentication tokens
- Cached app data from previous versions
- Browser extensions interfering
- Pop-up blockers preventing authentication

**How to Verify:**
Try these tests in order:
```
1. Open InPrivate/Incognito window
2. Navigate to Power Apps (make.powerapps.com)
3. Try to open the app
4. If it works, it's a cache/extension issue
```

**Solution:**

**Clear Cache:**
```
Microsoft Edge / Chrome:
1. Press Ctrl+Shift+Delete (Windows) or Cmd+Shift+Delete (Mac)
2. Select "All time" for time range
3. Check "Cookies and other site data"
4. Check "Cached images and files"
5. Click "Clear data"
6. Close and reopen browser
```

**Disable Extensions:**
```
1. Open browser settings
2. Navigate to Extensions
3. Disable all extensions temporarily
4. Try accessing the app
5. If it works, enable extensions one by one to find the culprit
```

**Check Pop-up Blocker:**
```
1. Look for pop-up blocker icon in address bar
2. Allow pop-ups from make.powerapps.com
3. Allow pop-ups from your tenant domain (e.g., contoso.onmicrosoft.com)
```

**Try Different Browser:**
```
1. If using Chrome, try Edge
2. If using Edge, try Chrome
3. Avoid Internet Explorer (not supported)
4. Use latest browser version
```

---

### 7. Connection References Not Configured

**Symptoms:**
- Blank screen
- Error in browser console: "Connection reference not found"
- Apps work for some users, not for others

**Why This Happens:**
Canvas apps in solutions use "connection references" which must be configured during installation.

**How to Verify:**
```
1. Go to Power Apps (make.powerapps.com)
2. Select your CoE environment
3. Go to Solutions
4. Open "Center of Excellence - Core Components" solution
5. Select "Connection references" from left navigation
6. Check status of all connection references:
   - Should show connected user (your account or service account)
   - Should not show "New connection reference" or error icon
```

**Solution:**

**If Connection References Are Missing:**
```
1. In the solution, select "Connection references"
2. For each connection reference:
   a. Click on it
   b. Click "Edit"
   c. Select existing connection or create new one
   d. Save
3. Repeat for all connection references
4. Close and reopen the app
```

**If You Need to Share Connections:**
```
1. Go to Power Apps > Connections
2. Find each connection used by CoE (Dataverse, Office 365 Users, etc.)
3. Click "..." menu
4. Select "Share"
5. Add users who need access to the apps
6. Grant "Can use" permission
7. Save
```

---

## Step-by-Step Troubleshooting Process

Follow this process to systematically diagnose and fix blank screen issues:

### Step 1: Verify Basic Prerequisites (5 minutes)

1. **Check your license:**
   - Go to https://admin.microsoft.com
   - Users > Active users > (your account)
   - Verify Power Apps Premium or Per User license

2. **Check your role:**
   - Go to https://portal.azure.com
   - Azure AD > Users > (your account)
   - Check assigned roles
   - Should have Power Platform Admin or Global Admin

3. **Check Dataverse database:**
   - Go to https://admin.powerplatform.microsoft.com
   - Environments > (CoE environment)
   - Verify Dataverse database is provisioned

### Step 2: Check Environment Configuration (5 minutes)

4. **Check language pack:**
   - In Power Platform Admin Center
   - Edit your environment
   - Verify English language is enabled

5. **Check environment type:**
   - Should be Production or Sandbox
   - Not Trial (trial is limited)

### Step 3: Check DLP Policies (10 minutes)

6. **Review DLP policies:**
   - Power Platform Admin Center > Data policies
   - For each policy, check if it applies to your CoE environment
   - Verify required connectors are in Business group or environment is excluded

### Step 4: Check Connection References (5 minutes)

7. **Verify connections:**
   - Power Apps > Solutions > Core Components
   - Connection references > verify all are configured

### Step 5: Browser Troubleshooting (5 minutes)

8. **Clear cache and try InPrivate:**
   - Clear browser cache
   - Try InPrivate/Incognito mode
   - Try different browser

### Step 6: Check Flow Run History (10 minutes)

9. **Review inventory flows:**
   - Power Automate > Flows
   - Find "Admin | Sync Template v3"
   - Check run history
   - Look for errors or failures

### Step 7: If Still Not Working (Contact Support)

10. **Gather diagnostic information:**
    - Screenshot of blank screen
    - Browser console errors (F12 > Console tab)
    - License assignment screenshot
    - DLP policy configuration screenshot
    - Post issue on GitHub with all details

---

## Preventive Measures

To avoid blank screen issues when setting up CoE Starter Kit:

### Before Installation

1. **Verify prerequisites checklist:**
   - [ ] Premium licenses assigned
   - [ ] Admin roles assigned
   - [ ] Dataverse environment ready
   - [ ] English language pack enabled
   - [ ] DLP policies reviewed and adjusted

2. **Prepare the environment:**
   - Create dedicated Production environment for CoE
   - Ensure sufficient Dataverse capacity (1GB+ available)
   - Document your DLP policy strategy

### During Installation

3. **Follow setup guide exactly:**
   - Install solutions in order: Core → Governance → Nurture → Audit
   - Configure environment variables before turning on flows
   - Test each component before moving to next

4. **Use the Setup Wizard:**
   - Run CoE Setup Wizard app
   - Follow each step carefully
   - Don't skip prerequisite confirmations

### After Installation

5. **Validate installation:**
   - Open each admin app to verify it loads
   - Check flow run history
   - Review data collection in Dataverse tables
   - Test with non-admin user (if appropriate)

6. **Document your configuration:**
   - Keep notes on environment variables
   - Document DLP policy exemptions
   - Record service account details (if used)
   - Note any customizations made

---

## Getting Help

If you've followed this guide and still experience blank screens:

### Gather This Information

1. **Environment details:**
   - Environment name and ID
   - Environment type (Production/Sandbox/Trial)
   - Dataverse database size
   - Languages enabled

2. **User details:**
   - Your licenses assigned
   - Your admin roles
   - Security roles in CoE environment

3. **Configuration details:**
   - CoE Starter Kit version
   - Which specific app(s) show blank screens
   - DLP policies applied
   - Connection reference status

4. **Diagnostic data:**
   - Screenshot of blank screen
   - Browser console errors (F12 > Console, screenshot any red errors)
   - Flow run history (any failures?)
   - Any error messages received

### Post on GitHub

Create a detailed issue at: https://github.com/microsoft/coe-starter-kit/issues

Use this template:

```markdown
**Issue:** Blank screens in CoE apps

**Apps Affected:**
- CoE Setup Wizard
- Admin - Flow Permission Center
(list all affected apps)

**Environment Details:**
- Solution Version: 4.50.6
- Environment Type: Production
- Dataverse: Yes, 2GB available
- Languages: English (enabled)

**User Details:**
- License: Power Apps Premium
- Azure AD Role: Power Platform Administrator
- Environment Role: System Administrator

**DLP Policies:**
- Policy Name: "Corporate DLP Policy"
- Applied to CoE environment: Yes
- Connectors allowed: [list]

**What I've Tried:**
1. Cleared browser cache
2. Tried InPrivate mode
3. Verified language pack
4. Checked connection references
5. (list all troubleshooting steps completed)

**Screenshots:**
(attach screenshots)

**Browser Console Errors:**
(paste any red errors from F12 console)

**Additional Context:**
(any other relevant information)
```

---

## Related Documentation

- [Official CoE Starter Kit Documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- [Setup Prerequisites](https://learn.microsoft.com/power-platform/guidance/coe/setup#prerequisites)
- [Setup Core Components](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components)
- [Troubleshooting Guide](https://learn.microsoft.com/power-platform/guidance/coe/faq)
- [GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues)
- [Common GitHub Responses](./COE-Kit-Common%20GitHub%20Responses.md)

---

## Document History

- **2025-12-03**: Initial creation based on common blank screen issues reported in GitHub
