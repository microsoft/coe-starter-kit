# Troubleshooting: Power Platform Admin View Not Updating

This guide helps you troubleshoot issues where the Power Platform Admin View app is not showing updated apps, flows, or environments.

## Common Symptoms

- Apps/flows/environments not appearing in Admin View
- Data only shows resources created before a certain date
- Missing environments in filter dropdown
- Outdated information in the Admin View

## Root Causes

The most common causes for inventory sync issues are:

1. **Inventory flows not running** - The sync flows need to run regularly to update data
2. **FullInventory setting is Off** - Incremental sync only updates changed items
3. **Connection references not configured** - Flows cannot authenticate to Power Platform
4. **Environment variables not set** - Required configuration is missing
5. **Throttling or API limits** - Flows are being throttled and failing
6. **Insufficient permissions** - Service account lacks required admin permissions

## Diagnostic Steps

### Step 1: Verify Inventory Method Configuration

The issue description mentions "What method are you using to get inventory and telemetry: **None**"

**This is the problem!** You must configure and run the inventory sync flows.

**Action Required:**
1. Open the Power Platform Admin View environment
2. Navigate to Solutions → Center of Excellence - Core Components
3. Navigate to Cloud flows
4. Locate the **Admin | Sync Template v4 (Driver)** flow

### Step 2: Check if Inventory Flows are Running

The Driver flow orchestrates the entire inventory process. It should run on a schedule.

**Check Flow Run History:**
1. Open **Admin | Sync Template v4 (Driver)** flow
2. Check the run history (last 28 days)
3. Verify:
   - Is it running at all?
   - Are runs succeeding or failing?
   - When was the last successful run?

**Common Issues:**
- Flow is turned off
- Flow never been manually triggered after installation
- Flow is failing due to connection or permission errors

### Step 3: Verify Environment Variables

Several environment variables control inventory behavior:

| Environment Variable | Purpose | Common Issue |
|---------------------|---------|--------------|
| `FullInventory` | When `Yes`, syncs ALL resources. When `No`, only syncs changed items | Set to `No` but initial inventory never completed |
| `InventoryFilter_DaysToLookBack` | Days to look back for changes (default: 7) | Set too low, missing older changes |
| `Power Automate Environment Variable` | Base URL for Power Automate | Not set correctly for your geographic region |
| `Inventory and Telemetry in Azure Data Storage account` | BYODL enabled | Should typically be `No` |

**How to Check:**
1. Navigate to Solutions → Center of Excellence - Core Components
2. Click on Environment Variables
3. Review current values for the variables above

**For Your Issue:**
Since apps are only showing before June 2024, you likely need to:
- Set `FullInventory` to `Yes` temporarily
- Run the Driver flow manually
- Wait for complete inventory (can take hours for large tenants)
- Set `FullInventory` back to `No` for incremental updates

### Step 4: Verify Connection References

All flows require properly configured connection references:

**Required Connections:**
- Power Platform for Admins
- Power Apps for Admins  
- Dataverse
- Office 365 Users (optional but recommended)

**How to Check:**
1. Navigate to Solutions → Center of Excellence - Core Components
2. Click on Connection References
3. Ensure all are configured and using appropriate service account
4. Service account must have:
   - Power Platform Administrator or Dynamics 365 Administrator role
   - Licenses: Power Apps Per User or Per App, Power Automate Per User

### Step 5: Check Child Flow Status

The Driver flow triggers child flows for each environment and resource type:

**Key Child Flows:**
- **Admin | Sync Template v4 (Apps)** - Syncs Canvas Apps
- **Admin | Sync Template v4 (Model Driven Apps)** - Syncs Model-Driven Apps
- **Admin | Sync Template v4 (Flows)** - Syncs Power Automate flows
- **Admin | Sync Template v4 (Environments)** - Syncs environment information

**Action:**
1. Check run history of each child flow
2. Look for error messages in failed runs
3. Common errors:
   - "Rate limit exceeded" - Throttling issue
   - "Unauthorized" - Permission issue
   - "Environment variable not found" - Configuration issue

## Solution Steps

### Solution 1: Run Full Inventory (Most Common Fix)

This is the **recommended first step** when data is missing or outdated:

1. **Set FullInventory to Yes:**
   - Navigate to Environment Variables
   - Find `FullInventory` variable
   - Change current value to `Yes`
   - Save

2. **Manually Trigger Driver Flow:**
   - Open **Admin | Sync Template v4 (Driver)** flow
   - Click "Run" to manually trigger
   - This will sync ALL environments and resources

3. **Monitor Progress:**
   - Check flow run history
   - For large tenants (100+ environments, 1000+ apps), this can take 4-8 hours
   - Be patient and let it complete

4. **Verify Data:**
   - After successful completion, open Power Platform Admin View
   - Check if missing apps and environments now appear
   - Filter by environment to verify "Slaughter and May Development" is visible

5. **Set Back to Incremental:**
   - After full inventory completes successfully
   - Change `FullInventory` back to `No`
   - This enables efficient incremental syncing going forward

### Solution 2: Verify and Fix Connection References

If flows are failing:

1. **Check Connection References:**
   - Solutions → Connection References
   - Identify any with status "Not configured" or errors

2. **Update Connections:**
   - Click on each connection reference
   - Click "Edit"
   - Select or create a new connection using service account
   - Ensure service account has proper permissions

3. **Test:**
   - Manually run Driver flow after updating connections
   - Verify flows succeed

### Solution 3: Adjust Throttling Settings

If seeing rate limit errors:

1. **Enable Delay:**
   - Find environment variable `DelayObjectInventory`
   - Set to `Yes`
   - This adds delays to reduce API call rate

2. **Reduce Scope:**
   - Consider syncing fewer environments initially
   - Use environment exclusion features if needed

### Solution 4: Check Service Account Permissions

Verify the service account used in connections has:

**Required Roles:**
- Power Platform Administrator **OR** Dynamics 365 Administrator
- Environment Admin on CoE environment

**Required Licenses:**
- Power Apps license (Per User or Per App)
- Power Automate license (Per User)

**How to Verify:**
1. Go to Power Platform Admin Center
2. Navigate to Admin → Security roles
3. Find the service account
4. Verify roles are assigned

## Expected Behavior After Fix

Once inventory sync is working correctly:

1. **Initial Full Run:** Can take 2-8 hours depending on tenant size
2. **All environments visible:** Including "Slaughter and May Development"
3. **All apps showing:** Including apps created after June 2024
4. **Regular Updates:** Incremental sync runs daily (when FullInventory = No)
5. **Up-to-date Data:** Admin View reflects current state within 24 hours

## Preventive Measures

To avoid future inventory issues:

1. **Monitor Driver Flow:** Check weekly that it's running successfully
2. **Use Incremental Sync:** Keep `FullInventory = No` for normal operations
3. **Run Full Inventory:** Quarterly or when you suspect missing data
4. **Set Up Alerts:** Create alerts for flow failures
5. **Maintain Service Account:** Ensure licenses and permissions don't expire

## Additional Resources

- [Official CoE Starter Kit Documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- [Setup Core Components](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components)
- [Inventory and Telemetry](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components#inventory-and-telemetry)

## Need More Help?

If the above steps don't resolve your issue:

1. **Gather Information:**
   - Driver flow run history (last 7 days)
   - Child flow error messages
   - Environment variable values
   - Service account permissions

2. **Report Issue:**
   - Create an issue at: https://github.com/microsoft/coe-starter-kit/issues
   - Use the CoE Starter Kit Bug template
   - Include all diagnostic information gathered

## Summary for This Specific Issue

Based on the issue description:

**Problem:** 
- Apps only showing before June 2024
- Environment "Slaughter and May Development" not visible
- Inventory method: "None"

**Root Cause:** 
Inventory sync flows are not running or never completed successfully after the November 2025 upgrade.

**Solution:**
1. Set `FullInventory` environment variable to `Yes`
2. Manually trigger **Admin | Sync Template v4 (Driver)** flow
3. Wait for complete inventory (may take several hours)
4. Verify missing data now appears in Admin View
5. Set `FullInventory` back to `No` for ongoing incremental sync
6. Ensure Driver flow is scheduled to run regularly (daily recommended)

**Expected Outcome:**
After full inventory completes, all environments including "Slaughter and May Development" and all apps including those created after June 2024 will be visible in the Power Platform Admin View.
