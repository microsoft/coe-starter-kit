# Quick Start Guide

## 5-Minute Setup

Follow these steps to set up the PowerShell alternative for Connection Identities sync.

## Prerequisites Check

Before you begin, ensure you have:
- ✅ Power Platform Administrator or System Administrator role
- ✅ PowerShell 5.1 or higher installed
- ✅ CoE Starter Kit Core Components solution installed in your environment

## Step-by-Step Instructions

### 1. Download Scripts

If you haven't already, clone or download the CoE Starter Kit repository:

```powershell
# Option A: Clone the repository
git clone https://github.com/microsoft/coe-starter-kit.git
cd coe-starter-kit/CenterofExcellenceResources/Release/Scripts/ConnectionIdentitiesSync

# Option B: Download just the scripts folder
# Navigate to the folder in GitHub and download the files
```

### 2. Install Required Modules

Open PowerShell as Administrator and run:

```powershell
# Install Power Apps Administration module
Install-Module -Name Microsoft.PowerApps.Administration.PowerShell -Scope CurrentUser -Force

# Install MSAL for authentication
Install-Module -Name MSAL.PS -Scope CurrentUser -Force
```

### 3. Disable the Cloud Flow

1. Navigate to [Power Automate](https://make.powerautomate.com)
2. Select your CoE environment
3. Find the flow: **"Admin | Sync Template v4 (Connection Identities)"**
4. Click **Turn off** to disable it

> **Why?** This prevents conflicts between the cloud flow and PowerShell scripts.

### 4. Run Your First Sync

Open PowerShell (does not need to be Administrator) and navigate to the scripts folder:

```powershell
cd "C:\path\to\coe-starter-kit\CenterofExcellenceResources\Release\Scripts\ConnectionIdentitiesSync"

# Run the complete sync process
.\Sync-ConnectionIdentities.ps1 -DataverseUrl "https://yourorg.crm.dynamics.com"
```

**Replace `yourorg.crm.dynamics.com` with your CoE environment URL.**

To find your environment URL:
1. Go to [Power Platform Admin Center](https://admin.powerplatform.microsoft.com)
2. Select your CoE environment
3. Look for the **Environment URL** (e.g., `https://contoso.crm.dynamics.com`)

### 5. Verify Results

After the script completes:

1. Navigate to your CoE environment
2. Open the **CoE Starter Kit - Core Components** app
3. Go to **Connection Reference Identities**
4. Verify that records are being created/updated

## What Happens During Sync?

The script performs these operations:

1. **Authenticates** to Power Platform (you'll see a login prompt)
2. **Retrieves** all environments in your tenant
3. **Gets** all connections from each environment
4. **Exports** connection identity data to a JSON file
5. **Authenticates** to Dataverse (second login prompt)
6. **Uploads** connection identities in batches
7. **Reports** success/error summary

## Troubleshooting

### "Module not found"
```powershell
# Install the missing module
Install-Module -Name Microsoft.PowerApps.Administration.PowerShell -Scope CurrentUser -Force
```

### "Cannot authenticate"
- Ensure you have the correct permissions
- Try running `Add-PowerAppsAccount` manually to test authentication

### "Environment not found in CoE inventory"
- Make sure you've run the environment sync flow first
- Verify the Core Components solution is installed

### Script is slow
- Use `-EnvironmentFilter` to process specific environments first:
```powershell
.\Sync-ConnectionIdentities.ps1 -DataverseUrl "https://yourorg.crm.dynamics.com" -EnvironmentFilter "Production*"
```

## Scheduling Automatic Sync

### Windows Task Scheduler

1. Create a batch file `RunSync.bat`:
```batch
@echo off
powershell.exe -ExecutionPolicy Bypass -File "C:\path\to\Sync-ConnectionIdentities.ps1" -DataverseUrl "https://yourorg.crm.dynamics.com"
```

2. Open Task Scheduler
3. Create a new task:
   - **Trigger**: Daily at 2:00 AM (or your preferred time)
   - **Action**: Run the batch file
   - **Settings**: Run whether user is logged on or not

### Azure Automation (Cloud-Based)

1. Create an Azure Automation Account
2. Import the PowerShell modules:
   - Microsoft.PowerApps.Administration.PowerShell
   - MSAL.PS
3. Create a new Runbook with the script content
4. Schedule the runbook to run daily/weekly

## Next Steps

- ✅ Review the full [README.md](README.md) for advanced options
- ✅ Explore the [C# example](CSHARP-EXAMPLE.md) for bulk operations
- ✅ Join [CoE Starter Kit Office Hours](https://aka.ms/coeofficehours) for support

## Getting Help

- 📖 [Full Documentation](README.md)
- 🐛 [Report Issues](https://github.com/microsoft/coe-starter-kit/issues)
- 💬 [Power Platform Community](https://powerusers.microsoft.com/)
- 📅 [Office Hours](https://aka.ms/coeofficehours)

## Common Command Examples

```powershell
# Basic sync
.\Sync-ConnectionIdentities.ps1 -DataverseUrl "https://yourorg.crm.dynamics.com"

# Sync specific environments only
.\Sync-ConnectionIdentities.ps1 -DataverseUrl "https://yourorg.crm.dynamics.com" -EnvironmentFilter "Default-*"

# Test run (retrieve data but don't upload)
.\Sync-ConnectionIdentities.ps1 -DataverseUrl "https://yourorg.crm.dynamics.com" -SkipUpload

# Sync with smaller batches (for large datasets)
.\Sync-ConnectionIdentities.ps1 -DataverseUrl "https://yourorg.crm.dynamics.com" -BatchSize 50

# Sync with auto-cleanup of temporary files
.\Sync-ConnectionIdentities.ps1 -DataverseUrl "https://yourorg.crm.dynamics.com" -CleanupJsonAfterUpload
```

---

**Remember:** This solution is a workaround for the current product limitation. Always check for the latest updates from Microsoft regarding the pagination issue.
