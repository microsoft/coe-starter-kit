# Troubleshooting Power BI Dashboard Embedded Apps

## Issue: "Manage App Access" and "Manage Flow Access" Not Working After Upgrade

### Symptoms
- Clicking "Drill Through > Manage App Access" or "Manage Flow Access" in the Power BI dashboard shows an error
- Error message: "Hmmm...can't reach this page" with URL like `https://apps.powerapps.com/play/e/appid`
- Admin Access This Flow app does not open
- Admin Access This App app does not open

### Root Cause
The Power BI dashboard template contains hardcoded App IDs for the embedded Power Apps ("Admin - Access this App" and "Admin - Access this Flow"). When you upgrade or import the CoE Starter Kit into your environment, these apps are recreated with new App IDs specific to your environment. The Power BI template still references the old App IDs, causing the embedded apps to fail.

### Solution: Update Embedded App IDs in Power BI Dashboard

#### Prerequisites
- Power BI Desktop installed
- Access to your Power Platform environment where CoE Starter Kit is installed
- Admin privileges to view and edit Power Apps

#### Step 1: Get the Correct App IDs from Your Environment

1. Navigate to [Power Apps](https://make.powerapps.com)
2. Select your environment where CoE Starter Kit is installed
3. Go to **Apps** in the left navigation
4. Find the following apps and note their App IDs:
   - **Admin - Access this App [works embedded in Power BI only]**
   - **Admin - Access this Flow [works embedded in Power BI only]**

To get the App ID:
- Click on the app's **...** (More Commands) menu
- Select **Details**
- Copy the **App ID** (GUID format: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)

Alternatively, you can get the App ID from the URL when you open the app in the maker portal:
- The URL will be like: `https://make.powerapps.com/environments/{environment-id}/apps/{app-id}/details`
- The `{app-id}` portion is what you need

#### Step 2: Update the Power BI Template

1. Open **Power BI Desktop**
2. Open your CoE Dashboard file (Production_CoEDashboard_*.pbix)
3. Navigate to the **Flow Deep Dive** page
4. Click on the **Manage Flow** embedded app visual
5. In the **Visualizations** pane, under **Format**, find **Power Apps > App ID**
6. Replace the existing App ID with the **Admin - Access this Flow** app ID from Step 1
7. Navigate to the **App Deep Dive** page
8. Click on the **Manage App** embedded app visual
9. In the **Visualizations** pane, under **Format**, find **Power Apps > App ID**
10. Replace the existing App ID with the **Admin - Access this App** app ID from Step 1

#### Step 3: Verify Data Mappings

While updating the embedded apps, ensure the following data field mappings are correct:

**For "Manage Flow" (Admin Access This Flow app):**
- Field 1: `admin_flowid` (maps to Flows.Flow ID)
- Field 2: `admin_environmentname` or `admin_flowenvironment` (maps to Flows.Environment ID)

**For "Manage App" (Admin Access This App app):**
- Field 1: `admin_appid` (maps to Power Apps.App ID)
- Field 2: `admin_environmentname` (maps to Power Apps.Environment ID)

#### Step 4: Save and Publish

1. Save your Power BI Desktop file
2. Publish the updated report to your Power BI workspace
3. Test the drill-through functionality

### Additional Notes

- These embedded apps are designed to work **only within Power BI**. They will not function correctly when launched directly from Power Apps.
- The apps rely on parameters passed from Power BI (the app/flow ID and environment ID) to function properly.
- After any solution upgrade, you may need to repeat these steps if the app IDs change.

### Alternative: Using Power BI Parameter

For advanced users, you can create Power BI parameters to make the app IDs configurable without editing the template each time:

1. In Power BI Desktop, go to **Transform data > Manage Parameters**
2. Create two new parameters:
   - `AdminAccessFlowAppID` (for the Flow management app)
   - `AdminAccessAppAppID` (for the App management app)
3. Use these parameters in the embedded app visual configurations
4. When publishing, users can update these parameters in the Power BI service without needing Power BI Desktop

### Related Documentation

- [Setup Power BI Dashboard](https://docs.microsoft.com/power-platform/guidance/coe/setup-powerbi)
- [Configure Embedded Apps in CoE Dashboard](https://docs.microsoft.com/power-platform/guidance/coe/setup-powerbi#optional-configure-embedded-apps-in-the-coe-dashboard)

### Support

If you continue to experience issues after following these steps, please report the issue at: [CoE Starter Kit Issues](https://github.com/microsoft/coe-starter-kit/issues)
