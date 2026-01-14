# PowerShell Alternative for Connection Identities Sync

## Overview

This folder contains PowerShell scripts that provide an alternative to the **"Admin | Sync Template v4 (Connection Identities)"** cloud flow when experiencing the 200MB pagination limitation issue.

## Background

The Power Automate connector **"Get Connections as Admin"** has a documented limitation where it fails when the aggregated page results exceed approximately 200MB (209,809,819 bytes). This limitation impacts environments with a large number of connections and prevents the cloud flow from successfully retrieving connection identity information.

**Related Issues:**
- [Issue #6276](https://github.com/microsoft/coe-starter-kit/issues/6276) - Reports the pagination limitation bug
- [Issue #8031](https://github.com/microsoft/coe-starter-kit/issues/8031) - Feature request for handling too-many-connections scenario
- [Issue #10331](https://github.com/microsoft/coe-starter-kit/issues/10331) - Consolidated enhancement for orphaned components

## Solution Components

This solution consists of two PowerShell scripts:

1. **Get-ConnectionIdentities.ps1** - Retrieves connection identities from Power Platform using PowerShell cmdlets
2. **Upload-ConnectionIdentitiesToDataverse.ps1** - Uploads the collected data to the CoE Dataverse table

## Prerequisites

### Required PowerShell Modules

```powershell
# For retrieving connections
Install-Module -Name Microsoft.PowerApps.Administration.PowerShell -Scope CurrentUser

# For uploading to Dataverse
Install-Module -Name MSAL.PS -Scope CurrentUser
```

### Required Permissions

- **Power Platform Administrator** or **System Administrator** role
- **Create/Update permissions** on the `admin_ConnectionReferenceIdentity` table in Dataverse
- CoE Starter Kit **Core Components** solution must be installed in the target environment

### System Requirements

- Windows PowerShell 5.1 or PowerShell 7+
- Internet connectivity
- Azure AD authentication capability

## Usage Instructions

### Step 1: Disable the Cloud Flow

Before using the PowerShell alternative, you should disable the existing cloud flow to prevent conflicts:

1. Navigate to your CoE environment in Power Automate
2. Find the flow: **"Admin | Sync Template v4 (Connection Identities)"**
3. Turn off the flow
4. (Optional) Add a note in the flow description indicating that PowerShell alternative is being used

### Step 2: Retrieve Connection Identities

Run the first script to retrieve all connection identities from your Power Platform environments:

```powershell
# Basic usage - retrieves from all environments
.\Get-ConnectionIdentities.ps1

# Filter to specific environment(s)
.\Get-ConnectionIdentities.ps1 -EnvironmentFilter "Default-*"

# Specify custom output path
.\Get-ConnectionIdentities.ps1 -OutputPath "C:\CoE\connections.json"
```

**Output:** A JSON file containing all connection identity information.

**Parameters:**
- `-TenantId` (Optional): Your Azure AD Tenant ID
- `-OutputPath` (Optional): Path for output file (default: `.\ConnectionIdentities.json`)
- `-EnvironmentFilter` (Optional): Filter environments using wildcards (default: `*` for all)

### Step 3: Upload to Dataverse

Run the second script to upload the connection identities to the CoE Dataverse table:

```powershell
# Basic usage
.\Upload-ConnectionIdentitiesToDataverse.ps1 -DataverseUrl "https://yourorg.crm.dynamics.com"

# With custom input file
.\Upload-ConnectionIdentitiesToDataverse.ps1 -DataverseUrl "https://yourorg.crm.dynamics.com" -InputPath "C:\CoE\connections.json"

# Adjust batch size for performance tuning
.\Upload-ConnectionIdentitiesToDataverse.ps1 -DataverseUrl "https://yourorg.crm.dynamics.com" -BatchSize 50

# For initial load (skip existing record checks)
.\Upload-ConnectionIdentitiesToDataverse.ps1 -DataverseUrl "https://yourorg.crm.dynamics.com" -SkipExistingCheck
```

**Parameters:**
- `-DataverseUrl` (Required): Your Dataverse environment URL (e.g., `https://contoso.crm.dynamics.com`)
- `-InputPath` (Optional): Path to input JSON file (default: `.\ConnectionIdentities.json`)
- `-BatchSize` (Optional): Number of records per batch, 1-1000 (default: 100)
- `-SkipExistingCheck` (Optional): Skip checking for existing records (faster for initial loads)

## Complete End-to-End Example

```powershell
# 1. Navigate to the scripts directory
cd "C:\CoE-StarterKit\Scripts\ConnectionIdentitiesSync"

# 2. Retrieve connection identities
.\Get-ConnectionIdentities.ps1 -OutputPath ".\connections.json"

# 3. Upload to Dataverse
.\Upload-ConnectionIdentitiesToDataverse.ps1 `
    -DataverseUrl "https://contoso.crm.dynamics.com" `
    -InputPath ".\connections.json" `
    -BatchSize 100
```

## Scheduling and Automation

### Option 1: Windows Task Scheduler

Create a scheduled task to run the scripts periodically:

1. Create a PowerShell script that combines both steps:

```powershell
# SyncConnectionIdentities.ps1
$ErrorActionPreference = "Stop"

$scriptPath = "C:\CoE-StarterKit\Scripts\ConnectionIdentitiesSync"
$dataverseUrl = "https://yourorg.crm.dynamics.com"
$outputPath = "$scriptPath\connections.json"

# Step 1: Get connections
& "$scriptPath\Get-ConnectionIdentities.ps1" -OutputPath $outputPath

# Step 2: Upload to Dataverse
& "$scriptPath\Upload-ConnectionIdentitiesToDataverse.ps1" `
    -DataverseUrl $dataverseUrl `
    -InputPath $outputPath
```

2. Create a scheduled task:
   - Program: `powershell.exe`
   - Arguments: `-ExecutionPolicy Bypass -File "C:\CoE-StarterKit\Scripts\SyncConnectionIdentities.ps1"`
   - Schedule: Daily or Weekly (align with your CoE sync schedule)

### Option 2: Azure Automation

For cloud-based scheduling:

1. Create an Azure Automation Account
2. Import the required PowerShell modules
3. Create a runbook with the combined script
4. Schedule the runbook execution
5. Use Azure Key Vault for secure credential management

### Option 3: Power Platform Scheduled Flow

Create a flow that triggers the PowerShell scripts using:
- Power Platform for Admins connector to trigger an Azure Function
- Azure Function hosts the PowerShell scripts
- Scheduled cloud flow triggers the Azure Function

## Performance Considerations

### Large Datasets

When dealing with very large numbers of connections:

1. **Use smaller batch sizes** (e.g., `-BatchSize 50`) for better error recovery
2. **Filter environments** to process high-priority environments first
3. **Run during off-peak hours** to minimize impact on tenant resources
4. **Monitor execution time** and adjust scheduling accordingly

### Optimization Tips

- **Caching:** The upload script caches environment, connector, and user lookups to minimize API calls
- **Batch Processing:** Both scripts process data in batches for memory efficiency
- **Error Handling:** Scripts include comprehensive error handling and will continue processing even if individual records fail
- **Progress Tracking:** Colored console output provides real-time progress updates

## Troubleshooting

### Common Issues

#### Issue: "Module not found"
**Solution:** Install the required PowerShell modules:
```powershell
Install-Module -Name Microsoft.PowerApps.Administration.PowerShell -Scope CurrentUser -Force
Install-Module -Name MSAL.PS -Scope CurrentUser -Force
```

#### Issue: "Access Denied" or "Unauthorized"
**Solution:** 
- Verify you have Power Platform Administrator role
- Ensure you have permissions on the `admin_ConnectionReferenceIdentity` table
- Try running `Add-PowerAppsAccount` manually to verify authentication

#### Issue: "Environment not found in CoE inventory"
**Solution:** 
- Ensure the Core Components solution is installed and environments are synced
- Run the **"Admin | Sync Template v4 (Environments)"** flow first
- Verify the environment exists in the `admin_environments` table

#### Issue: Script is slow or timing out
**Solution:**
- Reduce the `-BatchSize` parameter (e.g., to 50 or 25)
- Filter to specific environments using `-EnvironmentFilter`
- Check your network connection and latency to Dataverse

#### Issue: Duplicate records being created
**Solution:**
- The script uses upsert logic, but if you're seeing duplicates:
- Don't use the `-SkipExistingCheck` switch
- Run the cleanup flow: **"CLEANUP - Admin | Sync Template v3 (Delete Bad Data)"**

### Getting Help

- Review the inline help in the scripts: `Get-Help .\Get-ConnectionIdentities.ps1 -Full`
- Check the [CoE Starter Kit documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- Open an issue on the [GitHub repository](https://github.com/microsoft/coe-starter-kit/issues)
- Participate in [Office Hours](https://aka.ms/coeofficehours)

## Data Mapping

The scripts populate the following fields in the `admin_ConnectionReferenceIdentity` table:

| Dataverse Field | Source | Description |
|-----------------|--------|-------------|
| `admin_name` | ConnectorName | Name of the connector (e.g., "shared_sql") |
| `admin_accountname` | AccountName | Account name from the connection properties |
| `admin_connectionreferencecreatordisplayname` | CreatorUPN | User Principal Name of the connection creator |
| `admin_Environment` | EnvironmentName | Lookup to the Environment table |
| `admin_Connector` | ConnectorName | Lookup to the Connector table (if connector exists in inventory) |
| `admin_ConnectionReferenceCreator` | CreatorUPN | Lookup to the System User table (if user exists) |

## Limitations and Considerations

1. **Product Limitation:** This solution works around a known product limitation. Microsoft may address this in future updates.
2. **Authentication:** Scripts use interactive authentication. For fully automated scenarios, consider using service principals with certificate authentication.
3. **API Limits:** Be mindful of Dataverse API limits when processing large datasets.
4. **Data Sync:** This is a point-in-time snapshot. New connections won't be reflected until the scripts run again.
5. **Deleted Connections:** The scripts don't automatically remove deleted connections from Dataverse. Use the cleanup flows for this purpose.

## Alternative Approaches

### Using Power Platform CLI

If you prefer using the Power Platform CLI:

```bash
# List connections
pac admin list-connections --environment <environment-id>

# Export to JSON (custom scripting required)
```

### Using REST API Directly

For advanced scenarios, you can call the Power Platform REST API directly:

```powershell
# Example using Invoke-RestMethod
$headers = @{
    "Authorization" = "Bearer $accessToken"
}
Invoke-RestMethod -Uri "https://api.bap.microsoft.com/providers/Microsoft.BusinessAppPlatform/environments/<env-id>/connections?api-version=2016-11-01" -Headers $headers
```

## Related Resources

- [Get-AdminPowerAppConnection Documentation](https://learn.microsoft.com/powershell/module/microsoft.powerapps.administration.powershell/get-adminpowerappconnection)
- [Dataverse Web API Documentation](https://learn.microsoft.com/power-apps/developer/data-platform/webapi/overview)
- [Using PowerShell with Dataverse Web API](https://learn.microsoft.com/power-apps/developer/data-platform/webapi/use-ps-and-vscode-web-api)
- [Bulk Operations in Dataverse](https://learn.microsoft.com/power-apps/developer/data-platform/bulk-operations)
- [CoE Starter Kit Core Components](https://learn.microsoft.com/power-platform/guidance/coe/core-components)

## Contributing

If you have improvements or bug fixes for these scripts:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request
5. Follow the [contribution guidelines](../../../CONTRIBUTING.md)

## Support

This solution is part of the **CoE Starter Kit**, which is provided as a community-supported template. For support:

- Review the [CoE Starter Kit FAQ](https://learn.microsoft.com/power-platform/guidance/coe/faq)
- Check existing [GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues)
- Create a new issue using the appropriate template
- Join the [Power Platform Community](https://powerusers.microsoft.com/)

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2024-12 | Initial release - PowerShell alternative for Connection Identities sync |

## License

This project is licensed under the MIT License - see the [LICENSE](../../../LICENSE) file for details.

---

**Note:** These scripts are provided as a workaround for the current product limitation. As Microsoft continues to improve the Power Platform, the need for this workaround may be eliminated in future releases. Always check for the latest updates and best practices in the official documentation.
