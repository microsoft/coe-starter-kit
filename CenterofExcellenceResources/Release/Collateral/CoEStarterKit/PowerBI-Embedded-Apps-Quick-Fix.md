# Quick Fix: Power BI Embedded Apps After CoE Upgrade

## Problem
After upgrading CoE Starter Kit, clicking "Manage App Access" or "Manage Flow Access" in Power BI shows an error.

## Solution (5 Steps)

### 1. Get Your App IDs

**Option A: Use PowerShell Script (Recommended)**
```powershell
.\Get-CoEEmbeddedAppIDs.ps1 -EnvironmentUrl "https://yourorg.crm.dynamics.com"
```

**Option B: Manual Lookup**
1. Go to [make.powerapps.com](https://make.powerapps.com)
2. Select your CoE environment
3. Go to **Apps**
4. Find these apps and copy their IDs:
   - `Admin - Access this App [works embedded in Power BI only]`
   - `Admin - Access this Flow [works embedded in Power BI only]`

### 2. Open Power BI Desktop
Open your CoE Dashboard .pbix file

### 3. Update "Manage App" Visual
1. Go to **App Deep Dive** page
2. Click the **Manage App** visual (embedded Power App)
3. In **Visualizations** pane → **Format** → **Power Apps**
4. Replace **App ID** with your "Admin - Access this App" ID
5. Verify data fields:
   - `admin_appid` → Power Apps.App ID
   - `admin_environmentname` → Power Apps.Environment ID

### 4. Update "Manage Flow" Visual
1. Go to **Flow Deep Dive** page
2. Click the **Manage Flow** visual (embedded Power App)
3. In **Visualizations** pane → **Format** → **Power Apps**
4. Replace **App ID** with your "Admin - Access this Flow" ID
5. Verify data fields:
   - `admin_flowid` → Flows.Flow ID
   - `admin_environmentname` → Flows.Environment ID

### 5. Save and Publish
1. Save your .pbix file
2. Publish to Power BI Service
3. Test the drill-through functionality

## Need More Help?
See [PowerBI-Embedded-Apps-Troubleshooting.md](PowerBI-Embedded-Apps-Troubleshooting.md) for detailed instructions.

## Why Does This Happen?
The Power BI template contains hardcoded App IDs from the development environment. When you import the CoE solution, new apps are created with different IDs. This is a known limitation and requires manual configuration after each upgrade.

## Prevent This Issue
Consider using Power BI parameters to make App IDs configurable. See [PowerBI-Embedded-Apps-Design-Considerations.md](PowerBI-Embedded-Apps-Design-Considerations.md) for details.
