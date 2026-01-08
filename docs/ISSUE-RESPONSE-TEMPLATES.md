# Issue Response Templates

This document contains ready-to-use response templates for common CoE Starter Kit issues. Maintainers can copy and paste these responses, customizing as needed.

## Table of Contents
- [Inventory Sync Issues](#inventory-sync-issues)
- [Missing Data in Admin View](#missing-data-in-admin-view)
- [Inventory Method "None"](#inventory-method-none)
- [After Upgrade Issues](#after-upgrade-issues)

---

## Inventory Sync Issues

### Template: General Inventory Not Updating

```markdown
Thank you for reporting this issue. Based on your description, this appears to be an inventory synchronization issue.

The CoE Starter Kit uses scheduled flows to collect data from your tenant. When data is missing or outdated, the most common cause is that the inventory sync flows are not running or haven't completed successfully.

### Immediate Actions:

1. **Verify inventory flows are running:**
   - Navigate to your CoE environment
   - Go to Solutions → Center of Excellence - Core Components → Cloud flows
   - Open **Admin | Sync Template v4 (Driver)** flow
   - Check the run history - is it running? Are runs succeeding?

2. **Run Full Inventory:**
   - Go to Solutions → Center of Excellence - Core Components → Environment Variables
   - Find `FullInventory` and set it to `Yes`
   - Manually trigger the **Admin | Sync Template v4 (Driver)** flow
   - Wait for completion (can take 2-8 hours for large tenants)

3. **Check connection references:**
   - Go to Solutions → Center of Excellence - Core Components → Connection References
   - Ensure all connections are configured with a service account that has:
     - Power Platform Administrator role
     - Appropriate licenses (Power Apps + Power Automate)

### Detailed Troubleshooting:

Please see our comprehensive troubleshooting guide:
- [Inventory Sync Troubleshooting](../docs/TROUBLESHOOTING-INVENTORY-SYNC.md)
- [Common Issues FAQ](../docs/FAQ-COMMON-ISSUES.md)

These guides include:
- Step-by-step diagnostic procedures
- Common causes and solutions
- Environment variable configuration
- Expected behavior after fixes

Please try these steps and let us know the results. If you continue to experience issues, please provide:
- Driver flow run history (last 7 days)
- Any error messages from child flows
- Environment variable values (FullInventory, InventoryFilter_DaysToLookBack)
- Service account permissions and licenses
```

---

## Missing Data in Admin View

### Template: Specific Environment Not Visible

```markdown
Thank you for reporting this issue. When a specific environment is not visible in the Admin View, this typically indicates that:

1. The environment was created after the last successful inventory sync
2. The inventory sync failed for that specific environment
3. The incremental sync hasn't picked it up yet

### Solution:

The recommended fix is to run a **Full Inventory**:

1. **Set FullInventory environment variable:**
   - Navigate to Solutions → Center of Excellence - Core Components → Environment Variables
   - Find `FullInventory` variable
   - Set the current value to `Yes`

2. **Manually trigger inventory:**
   - Open the **Admin | Sync Template v4 (Driver)** flow
   - Click "Run" to manually trigger it
   - This will sync ALL environments in your tenant

3. **Monitor progress:**
   - Check the flow run history
   - For large tenants, this can take several hours
   - Wait for the run to complete successfully

4. **Verify results:**
   - After successful completion, open Power Platform Admin View
   - Check if the missing environment now appears in the filter dropdown
   - Verify apps from that environment are now visible

5. **Return to incremental mode:**
   - Once verified, change `FullInventory` back to `No`
   - This enables efficient incremental syncing for daily operations

### Additional Resources:

- [Detailed troubleshooting steps](../docs/TROUBLESHOOTING-INVENTORY-SYNC.md#step-1-verify-inventory-method-configuration)
- [FAQ on environment visibility](../docs/FAQ-COMMON-ISSUES.md#q-a-specific-environment-is-not-showing-in-the-admin-view-filter-dropdown)

Please let us know if this resolves the issue or if you encounter any errors during the process.
```

### Template: Apps Only Showing Up to Certain Date

```markdown
Thank you for reporting this issue. When apps are only showing up to a specific date (in your case, June 2024), this indicates that the inventory sync stopped running or failing at that point.

### Root Cause:

The incremental sync mode (`FullInventory = No`) only updates resources that have changed within the lookback period (default: 7 days). If the sync stopped in June 2024, newer apps were never inventoried.

### Solution:

You need to run a **Full Inventory** to capture all apps created since June 2024:

1. **Configure for Full Inventory:**
   ```
   Environment Variable: FullInventory
   Set to: Yes
   ```

2. **Manually trigger the Driver flow:**
   - Navigate to **Admin | Sync Template v4 (Driver)** flow
   - Click "Run" button
   - **Important:** For large tenants, this can take 2-8 hours

3. **Monitor progress:**
   - Check flow run history periodically
   - Look for the **Admin | Sync Template v4 (Apps)** child flow
   - Verify it's processing environments and succeeding

4. **Verify data:**
   - After completion, open Power Platform Admin View
   - Filter to see apps created after June 2024
   - All recent apps should now be visible

5. **Resume incremental sync:**
   - Set `FullInventory` back to `No`
   - This enables daily incremental updates going forward

### Preventive Measures:

To avoid this in the future:
- Monitor the Driver flow weekly to ensure it's running
- Set up alerts for flow failures
- Run Full Inventory quarterly as maintenance

### Additional Help:

- [Full troubleshooting guide](../docs/TROUBLESHOOTING-INVENTORY-SYNC.md#solution-1-run-full-inventory-most-common-fix)
- [FAQ: Inventory stopped updating](../docs/FAQ-COMMON-ISSUES.md#scenario-everything-was-working-now-it-suddenly-stopped-updating)

Please let us know if this resolves your issue!
```

---

## Inventory Method "None"

### Template: User Reported "None" for Inventory Method

```markdown
Thank you for submitting this issue. I noticed in your issue description that you selected **"None"** for the inventory method.

### ⚠️ This is the core problem!

The CoE Starter Kit **requires** inventory flows to be configured and running. Without inventory running:
- The Admin View will be empty or show no data
- Dashboards will have no information
- Governance flows won't work
- You'll have no visibility into your tenant's resources

### What "None" Means:

"None" indicates that the inventory sync flows are either:
1. Not configured
2. Never been run
3. Not running on a schedule

### Required Actions:

You must set up and run the inventory flows:

1. **Configure Connection References:**
   - Go to Solutions → Center of Excellence - Core Components → Connection References
   - Configure each connection with a service account that has:
     - Power Platform Administrator role
     - Power Apps and Power Automate licenses

2. **Set Environment Variables:**
   - Most critical: `Power Automate Environment Variable`
   - Set to the correct URL for your region (e.g., `https://flow.microsoft.com/manage/environments/`)
   - Set `FullInventory` to `Yes` for initial run

3. **Run Initial Inventory:**
   - Open **Admin | Sync Template v4 (Driver)** flow
   - Manually trigger it (click "Run")
   - **This will take hours** for the first run - be patient
   - Monitor run history for completion

4. **Verify Success:**
   - After completion, open Power Platform Admin View
   - You should now see all your environments, apps, and flows
   - Data should be current

5. **Enable Ongoing Sync:**
   - Set `FullInventory` back to `No`
   - Ensure Driver flow is set to run on a schedule (daily)

### Setup Documentation:

Please follow the official setup guide:
- [Setup Core Components](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components)
- [Configure Inventory and Telemetry](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components#inventory-and-telemetry)

### Additional Resources:

- [FAQ: Inventory method "None"](../docs/FAQ-COMMON-ISSUES.md#q-my-data-is-showing-as-none-for-inventory-method-is-this-correct)
- [First-time setup scenario](../docs/FAQ-COMMON-ISSUES.md#scenario-i-just-installed-coe-starter-kit-but-admin-view-is-empty)
- [Troubleshooting guide](../docs/TROUBLESHOOTING-INVENTORY-SYNC.md)

The inventory is the foundation of the CoE Starter Kit. Once properly configured, all other features will work correctly.

Please let us know if you need help with any of these steps!
```

---

## After Upgrade Issues

### Template: Data Not Updating After Upgrade

```markdown
Thank you for reporting this issue. It's common to experience inventory sync issues after upgrading the CoE Starter Kit. This is usually due to connections or flow states needing to be reconfigured.

### Post-Upgrade Checklist:

Please work through these steps:

1. **✅ Verify Connection References:**
   - Navigate to Solutions → Center of Excellence - Core Components → Connection References
   - Check if any show "Not configured" or have errors
   - If needed, edit and re-select the connections
   - Ensure the service account credentials haven't changed

2. **✅ Verify Environment Variables:**
   - Go to Environment Variables
   - Check that all values are still correct
   - Most values should be preserved, but verify:
     - `Power Automate Environment Variable`
     - `FullInventory` (should be `No` for normal operations)
     - `InventoryFilter_DaysToLookBack`

3. **✅ Turn On Flows:**
   - Flows may be turned off after an upgrade
   - Go to Cloud flows
   - Check the **Admin | Sync Template v4 (Driver)** flow
   - If it's off, turn it on

4. **✅ Run Full Inventory:**
   - After upgrade, it's recommended to run a full inventory
   - Set `FullInventory = Yes`
   - Manually trigger the Driver flow
   - Wait for completion (can take hours)

5. **✅ Check for Unmanaged Layers:**
   - Unmanaged customizations can prevent updates
   - Go to Solutions → Center of Excellence - Core Components
   - Click "See solution layers" for key components
   - Remove any unmanaged layers if present

6. **✅ Verify Service Account:**
   - Ensure the service account still has:
     - Power Platform Administrator role
     - Valid licenses (not expired)
     - Access to all environments

### Expected Behavior:

After completing these steps:
- Driver flow should run successfully
- Admin View should show current data
- Missing environments and apps should appear

### Version Information:

You mentioned upgrading to **version 4.50.6** in November 2025. Please verify:
- Is this the current version installed?
- Did the upgrade complete successfully?
- Are there any error messages in the solution import?

### Additional Resources:

- [Post-upgrade troubleshooting](../docs/FAQ-COMMON-ISSUES.md#scenario-i-just-upgraded-and-now-nothing-works)
- [Upgrade documentation](https://learn.microsoft.com/power-platform/guidance/coe/after-setup#installing-upgrades)
- [Full inventory guide](../docs/TROUBLESHOOTING-INVENTORY-SYNC.md#solution-1-run-full-inventory-most-common-fix)

Please work through this checklist and let us know:
1. Which step(s) identified issues
2. Results after running full inventory
3. Any error messages encountered

We're here to help!
```

---

## How to Use These Templates

### For Maintainers:

1. **Read the issue carefully** to identify the specific problem
2. **Select the appropriate template** from above
3. **Customize the template** to match the specific issue details
4. **Copy and paste** into the GitHub issue response
5. **Update any specific details** mentioned by the user (versions, dates, environment names)
6. **Add empathy** - acknowledge the frustration and thank them for reporting

### Template Customization:

When using these templates, consider customizing:
- Specific environment names mentioned
- Version numbers
- Dates referenced
- Any unique error messages provided
- User's organization-specific details

### Follow-up:

After posting a template response:
1. **Label the issue** appropriately (e.g., `needs-info`, `inventory-sync`, `documentation`)
2. **Check back** within 48-72 hours for user response
3. **Escalate** if the standard troubleshooting doesn't work
4. **Close with resolution** once the user confirms it's fixed

---

## Contributing

If you develop new effective response templates:
1. Add them to this document
2. Follow the existing format
3. Include links to relevant documentation
4. Test the response on actual issues first

---

## Related Documentation

- [Troubleshooting Guide](../docs/TROUBLESHOOTING-INVENTORY-SYNC.md)
- [FAQ](../docs/FAQ-COMMON-ISSUES.md)
- [Official CoE Docs](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
