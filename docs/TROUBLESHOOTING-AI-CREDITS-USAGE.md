# Troubleshooting: AI Credits Usage Data Not Updating

## Issue Description
AI Credits Usage data in the CoE Power BI report is not updating after a certain date, even though other data (Apps, Flows, etc.) is syncing regularly.

## Root Cause
The AI Credits Usage data is populated by the **Admin | Sync Template v4 (AI Usage)** flow, which retrieves AI Builder credit consumption information from the `msdyn_aievents` table in each environment.

### Key Technical Details
- **Flow Name**: Admin | Sync Template v4 (AI Usage)
- **Source Table**: `msdyn_aievents` (in each environment with Dataverse)
- **Target Table**: `admin_aicreditsusages` (in CoE environment)
- **Trigger**: Runs when an environment record is added or modified in the `admin_environment` table
- **Data Retrieval Window**: The flow uses `LastXDays(PropertyName='msdyn_processingdate',PropertyValue=1)`, which means it only retrieves AI events from the **last 1 day**

### Why Data Stops Updating
The flow only retrieves data from the last 1 day. If the flow:
- Is turned **OFF**
- Fails to run
- Encounters errors
- Is not triggered due to no environment changes

Then it will miss historical data, and the Power BI report will show stale information.

## Solution: Verify and Run the Sync Flow

### Step 1: Check if the Flow is Turned ON
1. Go to **Power Automate** → **Solutions** → **Core Components** (or **Audit Logs** solution)
2. Locate the flow: **Admin | Sync Template v4 (AI Usage)**
3. Verify the flow **State** is **On**
4. If it's **Off**, turn it on

### Step 2: Check if the Flow is Running Successfully
1. Open the **Admin | Sync Template v4 (AI Usage)** flow
2. Click **Run history** to see recent executions
3. Look for:
   - **Last Run**: Should show recent runs (daily basis expected)
   - **Status**: Should show **Succeeded**
4. If there are failures:
   - Click on the failed run to see error details
   - Common errors:
     - Connection authentication issues
     - Insufficient permissions (requires System Administrator role in each environment)
     - Environment access issues

### Step 3: Verify Prerequisites
The flow requires:
- **Dataverse environments**: The flow only works for environments with Dataverse (admin_hascds = true)
- **System Administrator privileges**: The user running the flow must have System Admin rights in each environment
- **AI Builder usage**: Only environments with AI Builder usage will have data in `msdyn_aievents` table

### Step 4: Manually Trigger the Flow
Since the flow is triggered by environment changes, you can manually trigger it:

#### Option A: Use the Driver Flow
1. Go to **Power Automate** → **Solutions** → **Core Components**
2. Find and run: **Admin | Sync Template v4 (Driver)**
3. This will trigger all Sync Template v4 flows, including AI Usage, for all environments

#### Option B: Trigger Environment Updates
1. Go to your CoE Dataverse environment
2. Open the **admin_environment** table
3. Make a minor edit to an environment record (e.g., add a space to description and save)
4. This will trigger the **Admin | Sync Template v4 (AI Usage)** flow for that environment

### Step 5: Check for New Data in Dataverse
After the flow runs successfully:
1. Go to your CoE Dataverse environment
2. Navigate to **Tables** → **AI Credits Usages** (`admin_aicreditsusages`)
3. Check if new records exist with recent **Processing Date** values
4. If no new records appear, verify that:
   - The source environments have AI Builder usage
   - The `msdyn_aievents` table in source environments contains data

### Step 6: Refresh the Power BI Report
Once new data is in Dataverse:
1. Open the **CoE Power BI report**
2. Click **Refresh** to reload data from Dataverse
3. Navigate to the **AI Credits Usage** page
4. Verify that new data appears

## Important Limitations

### 1-Day Data Retrieval Window
The flow only retrieves data from the **last 1 day** due to the filter:
```
$filter: msdyn_creditconsumed gt 0 and (Microsoft.Dynamics.CRM.LastXDays(PropertyName='msdyn_processingdate',PropertyValue=1))
```

**Impact**: If the flow is off for multiple days, it cannot retrieve historical data for the missed period. Only data from the last 1 day when the flow runs will be captured.

**Recommendation**: 
- Ensure the flow remains **On** at all times
- Monitor flow run history regularly
- Set up alerts for flow failures using the CoE Sync Flow Errors table

## Related Flows and Components

### Full Sync Pipeline
To ensure all CoE data (including AI Credits) updates correctly, verify these flows are **On** and running:

#### Audit Log Flows
- **Admin | Audit Logs | Office 365 Management API Subscription**
- **Admin | Audit Logs | Sync Audit Logs (V2)**
- **Admin | Audit Logs | Update Data (V2)**

#### Inventory Sync Flows (Sync Template v4)
- **Admin | Sync Template v4 (Driver)** - Triggers all other sync flows
- **Admin | Sync Template v4 (Apps)**
- **Admin | Sync Template v4 (Flows)**
- **Admin | Sync Template v4 (AI Usage)** ← This flow
- **Admin | Sync Template v4 (Connectors)**
- **Admin | Sync Template v4 (Environments)**
- All other Sync Template v4 flows

### Dataverse Tables
- **Source**: `msdyn_aievents` (in each environment)
- **Target**: `admin_aicreditsusages` (in CoE environment)
- **Lookup**: `admin_powerplatformusers` (users table)
- **Lookup**: `admin_environments` (environments table)

## Additional Resources
- [CoE Starter Kit Documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- [Audit Logs Setup](https://learn.microsoft.com/power-platform/guidance/coe/setup-auditlog)
- [Core Components Setup](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components)

## Need More Help?
If the issue persists after following these steps:
1. Check the **admin_syncflowerrorses** table for detailed error messages
2. Verify connection references are properly configured
3. Ensure environment variables are set correctly
4. Review the flow run history for specific error details
5. Open a [GitHub issue](https://github.com/microsoft/coe-starter-kit/issues) with:
   - CoE Starter Kit version
   - Flow run error details
   - Screenshots of the issue
   - Steps already attempted
