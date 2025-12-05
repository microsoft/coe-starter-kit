# GitHub Issue Comment - Blank Screens in CoE Apps

**Copy this content and post as a comment on the GitHub issue**

---

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

I've created comprehensive troubleshooting guides to help with this issue:

- **[Troubleshooting Blank Screens Guide](https://github.com/microsoft/coe-starter-kit/blob/main/docs/coe-knowledge/Troubleshooting-Blank-Screens.md)** - Detailed step-by-step guide for blank screen issues
- **[Common GitHub Responses](https://github.com/microsoft/coe-starter-kit/blob/main/docs/coe-knowledge/COE-Kit-Common%20GitHub%20Responses.md)** - Additional common issues and solutions
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

---

## Note About CoE Starter Kit Support

The CoE Starter Kit is provided as **best-effort, unsupported** software. Microsoft does not provide official support through traditional support channels. All issues are investigated and resolved through GitHub on a best-effort basis with no SLA.

For more information, see: https://learn.microsoft.com/power-platform/guidance/coe/starter-kit
