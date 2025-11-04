# Power BI Embedded Power Apps Connection Fix

## Issue Description

When opening the CoE Dashboard Power BI report (Production_CoEDashboard_July2024.pbit), users may encounter a "Sorry, there's been a disconnect" error on the following pages:
- **Manage Flow Access**
- **Manage App Access**

### Error Screenshot
The error appears as shown below:

![Disconnect Error](https://github.com/user-attachments/assets/920a4d59-108f-48c7-9957-cfd0e2771e4b)

### Root Cause

The Power BI template file contains **hardcoded Power App IDs** that reference apps from a specific development environment:
- `207e575c-6cf0-4d79-96f9-ffed8310be43` (Admin - Access this Flow)
- `2fd6105d-fd1e-4367-8d35-23fce69f33f4` (Admin - Access this App)

These App IDs don't exist in your environment, causing the embedded Power Apps to fail to load. Each environment generates unique App IDs when the CoE Core Components solution is installed, so the template needs to be updated with your environment-specific App IDs.

## Solution

There are two ways to fix this issue:

### Option 1: Automated Fix (Recommended)

Use the provided PowerShell script to automatically update the Power BI template with the correct App IDs from your environment.

#### Prerequisites
- PowerShell 5.1 or higher
- Power Apps Administration PowerShell module
  ```powershell
  Install-Module -Name Microsoft.PowerApps.Administration.PowerShell
  ```
- Access to the environment where CoE Core Components are installed
- Power Apps administrator or environment admin permissions

#### Steps

1. **Download the script**
   - The script is located at: `Update-PowerBIEmbeddedApps.ps1` (in the same folder as this document)

2. **Run the script**
   ```powershell
   .\Update-PowerBIEmbeddedApps.ps1 -EnvironmentName "your-environment-id"
   ```
   
   Or run without parameters to select your environment interactively:
   ```powershell
   .\Update-PowerBIEmbeddedApps.ps1
   ```

3. **Sign in when prompted**
   - The script will prompt you to sign in to Power Apps
   - Use an account that has access to the CoE environment

4. **Wait for completion**
   - The script will extract the template, update the App IDs, and create a new file
   - Default output: `Production_CoEDashboard_July2024_Updated.pbit`

5. **Open the updated template in Power BI Desktop**
   - Use the new `*_Updated.pbit` file instead of the original

#### Script Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `TemplatePath` | Path to the original .pbit file | `Production_CoEDashboard_July2024.pbit` |
| `OutputPath` | Path for the updated .pbit file | `Production_CoEDashboard_July2024_Updated.pbit` |
| `EnvironmentName` | Environment ID where CoE is installed | Interactive prompt if not provided |
| `FlowAccessAppName` | Display name of the Flow Access app | `Admin - Access this Flow [works embedded in Power BI only]` |
| `AppAccessAppName` | Display name of the App Access app | `Admin - Access this App [works embedded in Power BI only]` |

#### Example Usage

```powershell
# Update with custom paths
.\Update-PowerBIEmbeddedApps.ps1 `
    -TemplatePath "C:\CoE\Production_CoEDashboard_July2024.pbit" `
    -OutputPath "C:\CoE\Production_CoEDashboard_Fixed.pbit" `
    -EnvironmentName "00000000-0000-0000-0000-000000000000"
```

### Option 2: Manual Fix

If you prefer to manually update the Power BI template:

#### Prerequisites
- Power BI Desktop
- Access to your Power Platform environment
- 7-Zip or similar tool to extract/compress .pbit files

#### Steps

1. **Get the App IDs from your environment**
   
   Using PowerShell:
   ```powershell
   # Connect to Power Apps
   Add-PowerAppsAccount
   
   # Get apps from your environment
   $environmentId = "your-environment-id"
   $apps = Get-AdminPowerApp -EnvironmentName $environmentId
   
   # Find the admin access apps
   $flowApp = $apps | Where-Object { $_.DisplayName -like "*Access this Flow*" }
   $appApp = $apps | Where-Object { $_.DisplayName -like "*Access this App*" }
   
   Write-Host "Flow Access App ID: $($flowApp.AppName)"
   Write-Host "App Access App ID: $($appApp.AppName)"
   ```
   
   Or via the Power Apps Maker Portal:
   1. Go to https://make.powerapps.com
   2. Select your CoE environment
   3. Navigate to **Apps**
   4. Find "Admin - Access this Flow [works embedded in Power BI only]"
   5. Click on the **Details** button
   6. Copy the **App ID** from the details pane
   7. Repeat for "Admin - Access this App [works embedded in Power BI only]"

2. **Extract the .pbit file**
   - Rename the file from `.pbit` to `.zip`
   - Extract the contents to a folder

3. **Update the Layout file**
   - Open the `Report\Layout` file with a text editor that supports UTF-16 LE encoding (e.g., Visual Studio Code, Notepad++)
   - Search for `207e575c-6cf0-4d79-96f9-ffed8310be43` (old Flow Access App ID)
   - Replace with your Flow Access App ID
   - Search for `2fd6105d-fd1e-4367-8d35-23fce69f33f4` (old App Access App ID)
   - Replace with your App Access App ID
   - Save the file (ensure it remains UTF-16 LE encoded)

4. **Re-package the template**
   - Select all files in the extracted folder
   - Create a new ZIP archive
   - Rename from `.zip` to `.pbit`

5. **Test the updated template**
   - Open in Power BI Desktop
   - Navigate to the "Manage Flow Access" and "Manage App Access" pages
   - Verify the Power Apps load correctly

## Verification

After applying the fix:

1. Open the updated Power BI template in Power BI Desktop
2. Connect to your Dataverse environment when prompted
3. Navigate to the **Manage Flow Access** page
4. You should see the embedded Power App interface for managing flow access
5. Navigate to the **Manage App Access** page
6. You should see the embedded Power App interface for managing app access

### Expected Result
![Working Manage App Page](https://github.com/user-attachments/assets/4aa8c42a-9626-4b1a-93c3-74ce2696f054)

## Troubleshooting

### Issue: Apps Not Found by Script

**Problem**: The script reports it cannot find the admin access apps.

**Solution**:
- Verify that CoE Core Components solution is installed in the environment
- Check that the apps exist in the Power Apps Maker Portal
- Ensure you're connected to the correct environment
- If apps have different names, use the `-FlowAccessAppName` and `-AppAccessAppName` parameters

### Issue: Power Apps Still Don't Load

**Problem**: After updating, the embedded apps still show a disconnect error.

**Possible causes and solutions**:

1. **Apps not shared**
   - Solution: Share the admin access apps with the users who need to view the Power BI report
   - Go to https://make.powerapps.com
   - Select your CoE environment
   - Find the admin access apps
   - Share them with the appropriate users or security groups

2. **Power Apps visual not enabled**
   - Solution: Enable the Power Apps custom visual in Power BI
   - In Power BI Desktop: File > Options and settings > Options > Preview features
   - Check "Power Apps custom visual"
   - Restart Power BI Desktop

3. **Incorrect environment connection**
   - Solution: Ensure you're connecting to the same environment where the apps are located
   - When opening the Power BI report, verify you're using the correct environment URL

4. **Browser/Embedded content issues**
   - Solution: Check your organization's browser policies
   - Ensure Power Apps domains are not blocked
   - Try disabling browser extensions that might block embedded content

### Issue: Layout File Encoding Error

**Problem**: When manually editing, the Layout file becomes corrupted.

**Solution**:
- Use a text editor that preserves UTF-16 LE encoding
- Visual Studio Code: Save with encoding "UTF-16 LE"
- Notepad++: Encoding > Character sets > Unicode > UTF-16 LE
- Avoid using standard Notepad, which may change the encoding

### Issue: Template Won't Open After Update

**Problem**: Power BI Desktop can't open the updated template.

**Solution**:
- The .pbit file structure may have been corrupted
- Ensure all files from the original template are included in the re-packaged version
- Don't add extra folders or files to the root of the ZIP
- Make sure to compress the contents, not the folder containing them

## Additional Resources

- [CoE Starter Kit Documentation](https://docs.microsoft.com/power-platform/guidance/coe/starter-kit)
- [Power BI Dashboard Setup Guide](https://docs.microsoft.com/power-platform/guidance/coe/setup-powerbi)
- [Power Apps Admin Connectors](https://docs.microsoft.com/connectors/powerappsforadmins/)
- [Embed Power Apps in Power BI](https://docs.microsoft.com/power-bi/connect-data/service-connect-to-power-apps)

## Report Issues

If you continue to experience issues after following this guide, please report them at:
https://github.com/microsoft/coe-starter-kit/issues

When reporting, please include:
- The steps you followed
- Any error messages
- Screenshots of the issue
- Your Power BI Desktop version
- Your Power Apps version

---

**Last Updated**: November 2024  
**Applies To**: CoE Starter Kit Core Components 4.49.2+, Production_CoEDashboard_July2024.pbit
