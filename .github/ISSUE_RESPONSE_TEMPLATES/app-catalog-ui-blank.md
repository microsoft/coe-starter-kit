# Response Template: App Catalog UI Blank/Incomplete

Use this template when users report that the App Catalog (or other Core Component apps) are displaying a blank or incomplete UI.

---

## Response

Thank you for reporting this issue. Based on your description and screenshot, it appears that the **Power Platform Creator Kit** is either not installed in your environment or is at an incompatible version.

### Root Cause
The App Catalog app (and several other apps in the CoE Starter Kit Core Components) use PCF (PowerApps Component Framework) controls from the **Creator Kit**. These controls provide modern UI components like search boxes, pivots, command bars, and data grids. When the Creator Kit is not installed, these controls fail to render, resulting in the blank UI you're seeing.

### Solution
Please install the **Power Platform Creator Kit** in your CoE environment:

#### Option 1: Install from AppSource (Recommended)
1. Navigate to [Microsoft Creator Kit on AppSource](https://aka.ms/creatorkitdownload)
2. Click "Get it now"
3. Select the environment where you have installed the CoE Starter Kit
4. Complete the installation
5. After installation, perform a hard refresh of the App Catalog app (Ctrl+Shift+R or Cmd+Shift+R on Mac)

#### Option 2: Install via Power Platform Admin Center
1. Go to [Power Platform Admin Center](https://admin.powerplatform.microsoft.com/)
2. Navigate to your environment
3. Go to **Resources** > **Dynamics 365 apps**
4. Click **Install app**
5. Search for and install "Creator Kit"

### Verification
After installation, verify that the following solutions are present in your environment:
- Creator Kit Core
- PowerCAT Toolkit (or Power CAT Component Library)
- Center of Excellence - Core Components

### Additional Resources
For detailed troubleshooting steps and other common issues, please see:
- [Core Components Troubleshooting Guide](https://github.com/microsoft/coe-starter-kit/blob/main/CenterofExcellenceCoreComponents/TROUBLESHOOTING.md#app-catalog-ui-not-displaying-correctly)
- [Official CoE Setup Documentation](https://learn.microsoft.com/power-platform/guidance/coe/setup)

Please let us know if this resolves your issue or if you need further assistance.

---

## Related Issues
This template can be used for similar issues with these apps:
- App Catalog
- Admin - Command Center
- DLP Editor v2
- Power BI Dashboard Manager
- Set App Permissions
- Template Catalog Wizard

## Keywords to Watch For
- "blank screen"
- "UI not displaying"
- "missing controls"
- "empty app"
- "nothing showing"
- "controls not rendering"
- "PCF"
