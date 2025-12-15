# Troubleshooting: Environments Not Listed in Power Platform Admin App

## Issue Description
Some environments are not appearing in the Power Platform Admin App (part of the CoE Starter Kit Core Components solution).

## Common Causes

### 1. **Excuse From Inventory Flag**
The most common reason environments don't appear is the "Excuse From Inventory" field setting on the Environment record.

#### Understanding the Setting
The CoE Starter Kit includes an "Excuse From Inventory" field on each Environment record that controls whether the environment is tracked:
- **Yes (True)**: The environment is excluded from inventory tracking and won't appear in the Admin App
- **No (False)**: The environment is included in inventory tracking and will appear in the Admin App

#### Default Behavior
The default behavior is controlled by the **Track All Environments** environment variable:
- **True (Default)**: New environments are automatically tracked (Excuse From Inventory = No)
- **False**: New environments are NOT automatically tracked (Excuse From Inventory = Yes), requiring manual opt-in

### 2. **Sync Flow Has Not Run**
The Admin Sync Template v4 Driver flow must run successfully to discover and sync environment data.

### 3. **Sync Flow Errors**
The sync flow may have encountered errors preventing environment data from being retrieved or stored.

### 4. **Insufficient Permissions**
The account running the sync flows must have appropriate permissions to list all environments in the tenant.

### 5. **Pagination Limits**
Insufficient licensing for the service account can cause pagination issues, preventing all environments from being retrieved.

## Resolution Steps

### Step 1: Verify Sync Flow Execution
1. Navigate to the CoE environment in Power Automate
2. Locate the **Admin | Sync Template v4 (Driver)** flow
3. Check the run history:
   - Verify the flow has run recently
   - Check if the flow completed successfully
   - Review any error messages in failed runs

### Step 2: Check "Excuse From Inventory" Settings

#### Option A: Check Individual Environment Records
1. Open the **Power Platform Admin View** app
2. Navigate to **Environments**
3. Search for the missing environment(s)
4. Open the environment record
5. Check the **Excuse From Inventory** field:
   - If set to **Yes**, change it to **No** to include the environment in inventory
   - Save the record

#### Option B: Check Multiple Environments with Advanced Find
1. In the Power Platform Admin View app, use Advanced Find
2. Create a query for **Environments** where:
   - **Excuse From Inventory** equals **Yes**
3. Review the results and update as needed

### Step 3: Verify "Track All Environments" Setting
1. Navigate to **Solutions** in Power Apps
2. Open the **Center of Excellence - Core Components** solution
3. Go to **Environment variables**
4. Find **Track All Environments** variable
5. Check the current value:
   - **True**: All new environments should be tracked automatically
   - **False**: Environments must be manually opted in
6. Update if necessary to match your desired behavior

### Step 4: Force a Sync
After making any changes:
1. Navigate to the **Admin | Sync Template v4 (Driver)** flow
2. Click **Run** to manually trigger a sync
3. Monitor the flow run to ensure it completes successfully
4. Check the **Sync Flow Errors** table in Dataverse for any issues

### Step 5: Verify Permissions
Ensure the account used for the sync flows has:
- **Power Platform Administrator** or **Dynamics 365 Administrator** role
- Access to all environments you want to inventory
- Appropriate license (not trial) to avoid pagination limits

### Step 6: Check for Pagination Issues
If you have many environments (100+):
1. Verify the service account has a proper license (Power Apps Premium or equivalent)
2. Check the flow run history for truncated results
3. Review the Microsoft official documentation on pagination requirements

## Verification
After applying fixes:
1. Wait for the next scheduled sync or manually trigger the Driver flow
2. Refresh the Power Platform Admin View app
3. Navigate to Environments and verify the missing environments now appear
4. Check that environment details are populated correctly

## Additional Resources
- [CoE Starter Kit Documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- [Setup Instructions](https://learn.microsoft.com/power-platform/guidance/coe/setup)
- [Inventory and Telemetry](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components)

## Still Having Issues?
If environments are still not appearing after following these steps:
1. Review the detailed flow run history for error messages
2. Check the **Sync Flow Errors** table for logged issues
3. Verify all connection references are properly configured
4. Check that the CoE environment has sufficient storage capacity
5. File an issue on the [CoE Starter Kit GitHub repository](https://github.com/microsoft/coe-starter-kit/issues) with:
   - Solution version
   - Inventory method (Cloud flows or Data Export)
   - Screenshots of flow run history
   - Any error messages encountered
   - List of steps already attempted

## Related Configuration

### Environment Variables to Review
- **Track All Environments** (`admin_TrackAllEnvironments`)
- **Power Automate Environment Variable** (`admin_PowerAutomateEnvironmentVariable`)

### Key Flows
- **Admin | Sync Template v4 (Driver)**: Main orchestrator flow
- **Setup Wizard | Get Current Environment**: Initial setup flow

### Key Tables
- **Environment** (`admin_Environment`): Stores environment inventory data
- **Sync Flow Errors** (`admin_syncflowerrors`): Logs sync issues
