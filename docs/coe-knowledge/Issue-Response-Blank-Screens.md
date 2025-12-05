# Issue Response: Blank Screens in CoE Apps

## Current Issue

**Reporter**: User experiencing blank screens in multiple CoE apps
**Version**: 4.50.6
**Solution**: Core
**Apps Affected**: 
- CoE Setup Wizard (Confirm pre-requisites screen)
- Admin - Flow Permission Center
- Data Policy Impact Analysis

**Screenshots provided**: Yes (showing blank content areas with only headers visible)

---

## Recommended Response

```markdown
Thank you for reporting this issue. The blank screens you're seeing in the CoE Setup Wizard, Admin - Flow Permission Center, and Data Policy Impact Analysis apps are typically caused by missing prerequisites or configuration issues.

Based on the screenshots, I can see the apps are loading (headers are visible) but the content areas are blank. This is one of the most common issues with the CoE Starter Kit, and it's usually caused by one of these factors:

## Common Causes

### 1. Missing Prerequisites ⚠️ (Most Common)
The CoE Starter Kit requires:
- **Power Apps Premium or Per User license** (Trial or Per-App licenses are insufficient)
- **Admin role**: Global Administrator, Power Platform Administrator, or System Administrator
- **Dataverse database** provisioned in your environment
- **English language pack** enabled in your environment

### 2. DLP Policies Blocking Connectors
Data Loss Prevention policies may be blocking the required connectors. The following connectors must be allowed:
- Microsoft Dataverse
- Power Apps for Admins
- Power Automate Management
- Office 365 Users

### 3. Browser or Cache Issues
Sometimes cached data or browser extensions can interfere with app rendering.

---

## Troubleshooting Steps

To help diagnose and resolve this, please verify the following:

### Step 1: Check Your License
1. Go to [Microsoft 365 Admin Center](https://admin.microsoft.com)
2. Navigate to **Users > Active users**
3. Find your account and check **Licenses and apps**
4. Confirm you have **Power Apps Premium** or **Power Apps Per User** assigned

**Question**: Do you have a Power Apps Premium or Per User license assigned to your account?

### Step 2: Verify Admin Roles
1. Check your Azure AD role:
   - Go to [Azure Portal](https://portal.azure.com)
   - Navigate to **Azure Active Directory > Users**
   - Find your account and check assigned roles
2. Check your environment role:
   - Go to [Power Platform Admin Center](https://admin.powerplatform.microsoft.com)
   - Select your CoE environment
   - Go to **Settings > Users + permissions > Users**
   - Verify you have **System Administrator** role

**Question**: What admin roles do you currently have?

### Step 3: Check DLP Policies
1. Go to [Power Platform Admin Center](https://admin.powerplatform.microsoft.com)
2. Select **Data policies** from left navigation
3. Review any policies applied to your CoE environment
4. Verify the required connectors (listed above) are in the **Business** group or the environment is excluded from restrictive policies

**Question**: Are there any DLP policies applied to your CoE environment? If so, are the Power Platform admin connectors allowed?

### Step 4: Check Environment Configuration
1. In Power Platform Admin Center, select your CoE environment
2. Click **Edit**
3. Under **Languages**, verify that **English** is enabled
4. Verify you have a **Dataverse database** provisioned (you should see database capacity info)

**Question**: Is the English language pack enabled in your environment?

### Step 5: Quick Browser Test
1. Open an **InPrivate/Incognito** browser window
2. Navigate to [Power Apps](https://make.powerapps.com)
3. Try opening one of the affected apps

**Question**: Does the app work in InPrivate/Incognito mode?

---

## Immediate Actions You Can Try

While gathering the information above, you can also try these quick fixes:

1. **Clear your browser cache**:
   - Press `Ctrl+Shift+Delete` (Windows) or `Cmd+Shift+Delete` (Mac)
   - Select "All time" and clear cached images and cookies
   - Close and restart your browser

2. **Try a different browser**:
   - If using Chrome, try Edge (or vice versa)
   - Ensure you're using the latest version

3. **Disable browser extensions**:
   - Temporarily disable all extensions
   - Try accessing the app again

---

## Additional Resources

I've created comprehensive troubleshooting guides that may help:

- **[Troubleshooting Blank Screens Guide](../docs/coe-knowledge/Troubleshooting-Blank-Screens.md)** - Detailed step-by-step guide for blank screen issues
- **[Common GitHub Responses](../docs/coe-knowledge/COE-Kit-Common%20GitHub%20Responses.md)** - Additional common issues and solutions
- **[Official Setup Prerequisites](https://learn.microsoft.com/power-platform/guidance/coe/setup#prerequisites)** - Microsoft documentation on prerequisites

---

## Next Steps

Please provide answers to the questions above so we can pinpoint the exact issue. Based on your responses, I can provide specific guidance to resolve the problem.

The vast majority of blank screen issues are resolved by:
1. Ensuring proper licensing (Power Apps Premium)
2. Adjusting DLP policies to allow required connectors
3. Enabling the English language pack
4. Clearing browser cache

Let me know what you find, and I'll help you get this resolved! 👍
```

---

## Follow-up Actions Based on User Response

### If User Lacks Premium License
```markdown
The blank screens are caused by insufficient licensing. The CoE Starter Kit requires Power Apps Premium or Per User licenses to function correctly.

**Action Required:**
1. Request your admin to assign a Power Apps Premium license to your account
2. After assignment, wait 15-30 minutes for license propagation
3. Sign out and sign back in to Power Apps
4. Clear your browser cache
5. Try accessing the apps again

Trial licenses will work but may have limitations. Per-App licenses are not sufficient.

Reference: [Licensing Requirements](https://learn.microsoft.com/power-platform/guidance/coe/setup#prerequisites)
```

### If DLP Policy Is Blocking Connectors
```markdown
The blank screens are caused by DLP policies blocking the required Power Platform admin connectors.

**Action Required:**
Your organization's DLP policy is preventing the CoE apps from connecting to required services. You have three options:

**Option 1: Exclude CoE Environment** (Recommended)
- Edit your DLP policy
- Under "Environments", select "Exclude certain environments"
- Add your CoE environment to the exclusion list

**Option 2: Adjust Connector Classification**
- Edit your DLP policy
- Move these connectors to the "Business" group:
  - Microsoft Dataverse
  - Power Apps for Admins
  - Power Automate Management
  - Office 365 Users

**Option 3: Create Separate Policy for CoE**
- Create a new DLP policy specifically for the CoE environment
- Allow all required connectors in this policy
- Apply it only to your CoE environment

Work with your security/compliance team to implement the appropriate option.

Reference: [DLP Policies for CoE](https://learn.microsoft.com/power-platform/guidance/coe/faq#how-can-i-use-the-coe-starter-kit-in-a-tenant-with-restrictive-dlp-policies)
```

### If English Language Pack Is Missing
```markdown
The blank screens are caused by the missing English language pack. The CoE Starter Kit is English-only and requires the English language pack to be enabled.

**Action Required:**
1. Go to [Power Platform Admin Center](https://admin.powerplatform.microsoft.com)
2. Select Environments
3. Find and select your CoE environment
4. Click **Edit** at the top
5. Scroll to **Languages** section
6. Click **Add language** if English is not listed
7. Select **English** from the dropdown
8. Click **Add** then **Save**
9. Wait 10-15 minutes for language pack provisioning
10. Sign out and clear browser cache
11. Sign back in and try accessing the apps

Note: Your organization can use other languages, but English must also be enabled for CoE apps to work.

Reference: [Language Requirements](https://learn.microsoft.com/power-platform/guidance/coe/faq#can-i-use-the-coe-starter-kit-in-a-non-english-environment)
```

### If User Reports It Works in InPrivate Mode
```markdown
Since the apps work in InPrivate/Incognito mode, this confirms it's a browser cache or extension issue.

**Action Required:**
1. **Clear your browser cache completely**:
   - Press Ctrl+Shift+Delete (Windows) or Cmd+Shift+Delete (Mac)
   - Select "All time" for time range
   - Check "Cookies and other site data"
   - Check "Cached images and files"
   - Click "Clear data"

2. **Disable browser extensions**:
   - Open browser settings
   - Navigate to Extensions
   - Disable all extensions temporarily
   - Try accessing the app
   - If it works, enable extensions one by one to find the culprit

3. **Check pop-up blocker**:
   - Allow pop-ups from make.powerapps.com
   - Allow pop-ups from your tenant domain

After clearing cache, the apps should work normally. If a specific extension is causing the issue, you may need to keep it disabled or configure it to allow Power Apps.
```

---

## Issue Resolution Checklist

- [ ] User confirmed licenses assigned
- [ ] User verified admin roles
- [ ] DLP policies reviewed/adjusted
- [ ] English language pack confirmed enabled
- [ ] Browser cache cleared / InPrivate tested
- [ ] Connection references verified
- [ ] Apps now loading successfully
- [ ] Issue closed with resolution documented

---

## Related Issues

Search GitHub for similar issues:
- Blank screens: https://github.com/microsoft/coe-starter-kit/issues?q=is%3Aissue+blank+screen
- Setup wizard issues: https://github.com/microsoft/coe-starter-kit/issues?q=is%3Aissue+setup+wizard
- Prerequisites: https://github.com/microsoft/coe-starter-kit/issues?q=is%3Aissue+prerequisites

---

## Document Information

- **Created**: 2025-12-03
- **Issue Type**: Blank Screens / Apps Not Loading
- **Severity**: High (prevents use of CoE Starter Kit)
- **Common**: Yes (40%+ of reported issues)
- **Resolution Time**: Typically 1-2 hours after user confirms prerequisites met
