# Troubleshooting Power Platform Admin View Data Refresh Issues

## Overview

The Power Platform Admin View app displays inventory data collected by the CoE Starter Kit's sync flows. If the app is not showing updated apps or missing environments, this typically indicates that the inventory sync flows are not running properly or have encountered errors.

## Common Symptoms

- Apps only showing data from a specific date (e.g., June 2024)
- Missing environments in the environment filter
- Environment list incomplete or outdated
- New apps not appearing in the inventory

## Root Causes

### 1. Inventory Sync Flows Not Running

The most common cause is that the inventory sync flows have stopped running or are failing.

**Key Flows:**
- **Admin | Sync Template v4 (Driver)** - The orchestrator flow that triggers all other sync flows
- **Admin | Sync Template v4 (Apps)** - Syncs PowerApps inventory
- **Admin | Sync Template v4 (Environments)** - Syncs environment information

### 2. Flow Connection Issues

Sync flows require properly configured connections with appropriate permissions.

**Required Connections:**
- Power Platform for Admins connector (requires admin privileges)
- Dataverse connector (to write to CoE tables)
- Office 365 Users connector (for user information)

### 3. Licensing and Pagination Limits

Trial licenses or insufficient license profiles can hit pagination limits, causing incomplete data collection.

### 4. Flow State or Configuration

Flows may be in "Suspended" or "Off" state, or have incorrect environment variable configurations.

## Resolution Steps

### Step 1: Verify Flow Status

1. Navigate to the CoE environment in Power Platform Admin Center
2. Go to **Solutions** → **Center of Excellence - Core Components**
3. Select **Cloud flows** from the left navigation
4. Check the status of these critical flows:
   - **Admin | Sync Template v4 (Driver)**
   - **Admin | Sync Template v4 (Apps)**
   - **Admin | Sync Template v4 (Environments)**

**Expected Status:** All flows should be "On" (not Suspended or Off)

### Step 2: Check Flow Run History

1. For each sync flow, click on the flow name
2. Select **Run history** or **28-day run history**
3. Look for:
   - **Last successful run date** - Should be recent (within the last day/week depending on schedule)
   - **Failed runs** - Review error messages
   - **Long-running flows** - May indicate throttling or performance issues

**Common Error Patterns:**
- **401/403 Errors**: Authentication or permission issues
- **429 Errors**: API throttling
- **Timeout Errors**: Large tenant or performance issues
- **Invalid Connection**: Connection needs to be re-authenticated

### Step 3: Verify Connection Health

1. In the CoE environment, go to **Connections**
2. Find these connections:
   - Power Platform for Admins
   - Dataverse (or Microsoft Dataverse)
   - Office 365 Users
3. Check for warning icons or "Fix connection" prompts
4. Re-authenticate connections if needed:
   - Click on the connection
   - Select **Edit**
   - Re-enter credentials
   - **Important:** Use admin credentials with appropriate permissions

### Step 4: Manually Trigger the Driver Flow

The Driver flow is the orchestrator that triggers all other sync flows:

1. Go to **Solutions** → **Center of Excellence - Core Components** → **Cloud flows**
2. Find **Admin | Sync Template v4 (Driver)**
3. Click **Run** (or **Test** → **Manually**)
4. Monitor the run progress:
   - Check for immediate errors
   - Wait for completion (may take 15-30 minutes for large tenants)
5. After completion, check the run history of dependent flows:
   - **Admin | Sync Template v4 (Environments)**
   - **Admin | Sync Template v4 (Apps)**

### Step 5: Verify Data in Dataverse Tables

After successful flow runs, verify data is being written to Dataverse:

1. In the CoE environment, go to **Tables**
2. Check these tables for recent data:
   - **Environment** - Should contain all your environments
   - **PowerApps App** - Should contain your apps inventory
3. Check the **Modified On** column to see when records were last updated
4. Filter by environment name to verify the missing environment exists

**To check for missing environment:**
1. Open the **Environment** table
2. Search for "Slaughter" (or your missing environment name)
3. If found, check:
   - **Environment Is Visible to Admin Mode** field (should be Yes)
   - **Environment Is Not Visible in Apps** field (should be No)
   - **Modified On** date (should be recent)

### Step 6: Check Environment Variables

Environment variables control sync flow behavior:

1. Go to **Solutions** → **Center of Excellence - Core Components**
2. Select **Environment variables** from the left navigation
3. Verify these key variables are configured:
   - **Admin eMail** - Email for notifications
   - **Power Platform Admin Service Principal Azure App ID** (if using service principal)
   - **PowerOps_TenantId**
   - **Is All Environments Inventory** - Should be "Yes" to sync all environments

### Step 7: Force Full Inventory Sync

If data is still stale after manual flow runs:

1. In the **Environment** table, find all records
2. For each environment (or the missing one):
   - Set **Environment Is Not Visible in Apps** to "Yes"
   - Save
   - Then set it back to "No"
   - Save
3. This will trigger dependent sync flows for those environments
4. Allow 30-60 minutes for sync to complete

### Step 8: Review Flow Execution Quotas

Check if you're hitting execution limits:

1. Go to **Power Platform Admin Center**
2. Select the CoE environment
3. Go to **Resources** → **Capacity**
4. Check **API request limits** and **Flow runs per day**
5. If limits are reached, consider:
   - Upgrading licenses
   - Spreading sync schedule across different times
   - Using service principal authentication

## Verification

After completing the resolution steps, verify the fix:

1. Wait 30-60 minutes after triggering sync flows
2. Open the **Power Platform Admin View** app
3. Navigate to **PowerApps Apps**
4. Filter by **Environment** column
5. Verify:
   - The missing environment appears in the filter list
   - Recent apps (created after June 2024) are visible
   - **Modified On** dates are current

## Best Practices

### Regular Monitoring

- Schedule weekly reviews of sync flow run history
- Set up flow failure notifications using the **Admin eMail** environment variable
- Monitor Dataverse table record counts for anomalies

### Recommended Sync Schedule

- **Driver Flow**: Daily (default is scheduled recurrence)
- **Dependent Flows**: Triggered automatically by Driver flow
- **Full Inventory**: Monthly (by clearing Environment visibility flags)

### Connection Maintenance

- Review connections quarterly
- Re-authenticate before credentials expire
- Use service principal authentication for unattended operations
- Document which admin account is used for connections

## Additional Resources

- [CoE Starter Kit Documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- [Setup CoE Starter Kit](https://learn.microsoft.com/power-platform/guidance/coe/setup)
- [Core Components Overview](https://learn.microsoft.com/power-platform/guidance/coe/core-components)
- [Admin | Sync Template v4 Flow](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components#inventory-flows)

## Related Issues

When troubleshooting, consider these related scenarios:

- **"Method not allowed"**: User lacks admin privileges on the connection
- **Partial data only**: Pagination limits or license constraints
- **Old data persists**: Cleanup flows not running
- **Missing makers**: Office 365 Users connection issue

## FAQ

**Q: How long does a full sync take?**
A: For small tenants (< 100 apps), 15-30 minutes. For large tenants (1000+ apps), 1-2 hours or more.

**Q: Can I run sync flows more frequently?**
A: Yes, but be aware of API throttling limits. The default daily schedule is recommended.

**Q: The Driver flow succeeded but dependent flows didn't run**
A: Check the flow triggers. Dependent flows are triggered when the Driver flow updates Environment records. Verify triggers are enabled.

**Q: I see the environment in Dataverse but not in the app**
A: Check the **Environment Is Visible to Admin Mode** field in the Environment record. It must be set to "Yes".

**Q: Should I use "None" for inventory method?**
A: "None" means you're not using audit logs. This is acceptable for basic inventory. Consider using audit logs for compliance tracking.

## Support

For additional help:
- Check [GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues)
- Review [closed issues](https://github.com/microsoft/coe-starter-kit/issues?q=is%3Aissue+is%3Aclosed) for similar problems
- Post a question using the [question template](https://github.com/microsoft/coe-starter-kit/issues/new/choose)

---

**Note**: The CoE Starter Kit is provided as-is without official Microsoft support. Community support is available through GitHub issues.
