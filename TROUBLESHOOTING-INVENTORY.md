# Troubleshooting Inventory Issues in Large Tenants

This document provides guidance for troubleshooting inventory issues in large Power Platform tenants (10,000+ resources).

## Issue: FullInventory Environment Variable Appears Locked

### Symptoms
- The `admin_FullInventory` environment variable shows "Current Value = Yes" in the Power Platform admin center
- The Current Value field appears read-only or disabled
- You cannot change the value even with System Administrator permissions

### Root Causes
1. **Managed Environment Variable Value**: If an environment variable value was included in a managed solution layer, it becomes read-only in the UI
2. **Multiple Solution Layers**: Unmanaged customizations on top of managed solutions can cause confusion
3. **Form Customizations**: Custom business rules or JavaScript on the environment variable form could disable the field

### Solutions

#### Option 1: Update via Power Platform CLI or PowerShell (Recommended)
Use the Power Apps PowerShell module to update the environment variable value programmatically:

```powershell
# Install the module if not already installed
Install-Module -Name Microsoft.PowerApps.Administration.PowerShell

# Connect to your environment
Add-PowerAppsAccount

# Get the environment variable definition
$envVarDef = Get-AdminPowerAppEnvironmentVariable -EnvironmentName "YOUR_ENVIRONMENT_ID" | Where-Object { $_.SchemaName -eq "admin_FullInventory" }

# Create or update the environment variable value
# Note: Use "no" for incremental inventory, "yes" for full inventory
Set-AdminPowerAppEnvironmentVariableValue -EnvironmentName "YOUR_ENVIRONMENT_ID" -EnvironmentVariableDefinitionId $envVarDef.EnvironmentVariableDefinitionId -Value "no"
```

#### Option 2: Remove Managed Environment Variable Value
If the value was shipped in a managed solution:

1. Check for any customizations.xml or environment variable value files in your solution
2. Remove the managed environment variable value using the Power Platform Admin Center:
   - Navigate to **Settings** > **Customizations** > **Solutions**
   - Find the CoE Core Components solution
   - Look for environment variable values components
   - Remove the value component if present
3. Reinstall the solution without environment variable values

#### Option 3: Use Advanced Settings in Dataverse
1. Navigate to **Advanced Settings** in your Dataverse environment
2. Go to **Settings** > **Customizations** > **Customize the System**
3. Expand **Components** > **Environment Variables**
4. Find `admin_FullInventory`
5. Edit the **Current Value** directly in the table view

#### Option 4: Direct API Update
Use the Dataverse Web API to update the environment variable value:

```http
PATCH [Organization URI]/api/data/v9.2/environmentvariablevalues(GUID)
Content-Type: application/json

{
  "value": "no"
}
```

## Issue: Flow Names Not Updating in Large Tenants

### Symptoms
- Admin | Sync Template v4 (Flows) runs for 20+ hours
- Flow inventory data is not accurate or up-to-date
- Flow names remain unchanged even after the flow has been renamed in the environment
- Owner information and other metadata is stale

### Root Causes
1. **Full Inventory on Large Tenants**: With FullInventory=Yes and 16,000+ flows, the inventory process tries to update EVERY flow, which can cause:
   - Timeouts (flows have a 30-day timeout limit)
   - Throttling limits being reached
   - Incomplete pagination
2. **Insufficient License for Pagination**: Trial or lower-tier licenses may hit pagination limits (100 records per page vs 100,000 for premium licenses)
3. **Dataverse Throttling**: Too many API calls in a short time period
4. **Environment Filtering Issues**: All environments being inventoried instead of a targeted subset

### Solutions

#### Solution 1: Switch to Incremental Inventory
For large tenants, use incremental inventory instead of full inventory:

1. Set `admin_FullInventory` to `no` (see solutions above)
2. The inventory will only update flows modified in the last N days (controlled by `admin_InventoryFilter_DaysToLookBack`, default 7 days)
3. This dramatically reduces the number of flows processed per run

**Trade-off**: Flow name changes won't be detected unless the flow is also modified. To capture name changes, you need to manually flag flows for inventory (see below).

#### Solution 2: Manually Flag Flows for Inventory
Even with incremental inventory, you can force specific flows to be re-inventoried:

1. In the CoE environment, navigate to the `admin_flows` table
2. Find the flow records that need updating
3. Set the `admin_inventoryme` field to `Yes`
4. The next inventory run will process these flows regardless of the FullInventory setting

#### Solution 3: Exclude Environments from Inventory
Reduce the scope by excluding environments that don't need frequent inventory:

1. Navigate to the `admin_environment` table in your CoE environment
2. For each environment you want to exclude, set the `admin_ExcuseFromInventory` field to `Yes`
3. The Sync Template flows will skip these environments

**Note**: The CoE Starter Kit 4.50.6 does not have a built-in UI for managing the Excuse From Inventory flag. You can:
- Use the Advanced Find feature in Dataverse
- Create a custom canvas app or model-driven app view to manage this field
- Use PowerShell or the Web API to bulk-update environments

#### Solution 4: Enable Delay for Object Inventory
To help with Dataverse throttling:

1. Set the `admin_DelayObjectInventory` environment variable to `Yes`
2. This adds delays between inventory operations to stay within throttling limits
3. **Trade-off**: Inventory will take longer but be more reliable

#### Solution 5: Stagger Inventory Runs
Instead of running inventory for all environments at once:

1. Create separate inventory schedules for different environment groups
2. Disable the default trigger on Admin | Sync Template v4 (Flows)
3. Create multiple schedule-based flows that trigger inventory for specific environments
4. Space out the schedules (e.g., Group A on Mondays, Group B on Tuesdays, etc.)

#### Solution 6: Increase License Tier
Ensure your inventory service account has:
- Power Apps Per User Plan or
- Power Automate Per User Plan with Attended RPA
- NOT a trial license

This ensures proper pagination support (100,000 records per page vs 100 for trial licenses).

To test your license adequacy:
```powershell
# Check pagination limits in your flows
# Premium licenses should see minimumItemCount: 100000 in flow runs
# Trial licenses will show much lower limits
```

## Issue: Inventory Not Running at All

### Symptoms
- Admin | Sync Template v4 (Flows) shows no recent runs
- Environment records show no Last Inventory Date

### Solutions
1. **Check Flow State**: Ensure the flow is turned ON
2. **Check Triggers**: Verify that environment records are being created/updated to trigger the flow
3. **Check Connection References**: Ensure all connections are properly authenticated
4. **Check Environment Variable Values**: Verify all required environment variables have values set

## Performance Recommendations for Large Tenants (10,000+ Resources)

1. **Use Incremental Inventory** (`admin_FullInventory` = no)
2. **Exclude Non-Critical Environments** (`admin_ExcuseFromInventory` = Yes)
3. **Reduce LookBack Days** (Set `admin_InventoryFilter_DaysToLookBack` to 3-5 days instead of 7)
4. **Enable Delays** (`admin_DelayObjectInventory` = Yes)
5. **Use Premium Licenses** for the service account running inventory
6. **Monitor Flow Runs** regularly in the CoE Admin Command Center
7. **Consider BYODL (Bring Your Own Data Lake)** for very large tenants (16,000+ flows), though this is being deprecated in favor of Microsoft Fabric

## Expected Inventory Times

For reference, expected inventory completion times:

| Tenant Size | Full Inventory | Incremental Inventory (7 days) |
|-------------|---------------|--------------------------------|
| 1,000 flows | 1-2 hours | 15-30 minutes |
| 5,000 flows | 4-8 hours | 30-60 minutes |
| 10,000 flows | 10-15 hours | 1-2 hours |
| 16,000+ flows | 20-30 hours | 2-4 hours |

**Note**: These are estimates and can vary based on:
- Number of connections per flow
- Number of actions per flow
- API throttling limits
- License tier
- Whether delays are enabled

## Getting Help

If you continue to experience issues:

1. Check the [CoE Starter Kit GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues) for similar problems
2. Review the [official documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
3. Post a question in the [Power Platform Community Forums](https://powerusers.microsoft.com/t5/Power-Apps-Governance-and/bd-p/Admin_PowerApps)
4. Open a new issue in the [CoE Starter Kit GitHub repository](https://github.com/microsoft/coe-starter-kit/issues/new/choose)

When reporting inventory issues, please include:
- Solution version (e.g., 4.50.6)
- Approximate number of flows in your tenant
- Current FullInventory setting (yes/no)
- Whether you're using trial or premium licenses
- Flow run history showing errors or timeouts
- Any throttling errors from the flow run history
