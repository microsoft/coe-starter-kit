# Troubleshooting Environment Variables in Power Automate Flows

## Issue: Environment Variables Not Updating in Flows After Republishing Customizations

### Symptoms
- You have updated environment variable values in your Power Platform environment
- You have republished all customizations
- The flows still use old environment variable values
- Specifically affects flows like:
  - Admin | Inactivity Notifications v2 (Start Approval for Apps)
  - Admin | Inactivity Notifications v2 (Start Approval for Flows)
  - Other flows using environment variables such as `InactivityNotifications-PastTime-Interval` and `InactivityNotifications-PastTime-Unit`

### Root Cause
Power Automate flows cache environment variable values when they are saved or updated. Simply republishing customizations or importing a solution does not force flows to refresh their cached environment variable values. The flow must be explicitly updated to re-read the environment variables from the Dataverse environment.

### Resolution Steps

#### Option 1: Turn Off and Turn On the Flow (Recommended)
This is the simplest and most reliable method to force the flow to pick up updated environment variable values.

1. Navigate to the Power Automate portal: `https://make.powerautomate.com`
2. Select your CoE environment
3. Go to **Solutions** → Select your CoE solution (e.g., "Center of Excellence - Audit Components")
4. Find the affected flow (e.g., "Admin | Inactivity Notifications v2 (Start Approval for Apps)")
5. **Turn off** the flow
6. Wait a few seconds
7. **Turn on** the flow
8. The flow will now use the updated environment variable values

#### Option 2: Edit and Save the Flow
If you have access to edit the flow, you can force it to refresh by making a minor edit:

1. Open the flow in edit mode
2. Make a trivial change (e.g., add a space to a comment or description)
3. **Save** the flow
4. The flow will re-read all environment variable values during the save operation

#### Option 3: Re-import the Solution (Last Resort)
If the above options don't work or you need to update multiple flows:

1. Export your current solution as a backup
2. Re-import the CoE Starter Kit solution using the **Upgrade** option
3. After import completes, turn off and turn on each affected flow

### Verification Steps

After applying the resolution, verify that the environment variables are being used correctly:

1. Run the flow manually or wait for the scheduled trigger
2. Check the flow run history
3. Expand the "Get past time" action (or similar action that uses the environment variable)
4. Verify that the inputs show your updated values:
   - `interval`: Should match your `InactivityNotifications-PastTime-Interval` value
   - `timeUnit`: Should match your `InactivityNotifications-PastTime-Unit` value

### Prevention

To avoid this issue in the future:

1. **After updating environment variables**, always turn affected flows off and back on
2. **Document your environment variable changes** and which flows are affected
3. **Test in a development environment first** before applying changes to production
4. Consider creating a checklist for environment variable updates that includes the flow restart step

### Related Environment Variables

The following environment variables are commonly used in Inactivity Notification flows:

- `InactivityNotifications-PastTime-Interval` (Schema: `admin_ArchivalPastTimeInterval`)
  - Type: Decimal number
  - Default: 6
  - Description: The interval for the past time for how far back to go to see if an app/flow is inactive

- `InactivityNotifications-PastTime-Unit` (Schema: `admin_ArchivalPastTimeUnit`)
  - Type: Text
  - Default: Month
  - Description: The units for the past time (Day, Week, Month, Year)
  - Must match the Time Unit options in Power Automate's "Add to time" action

### Additional Resources

- [CoE Starter Kit Documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- [Environment Variables in Power Platform](https://learn.microsoft.com/power-platform/admin/environment-variables)
- [CoE Starter Kit - Governance Components](https://learn.microsoft.com/power-platform/guidance/coe/governance-components)

### Still Having Issues?

If you continue to experience problems after following these steps:

1. Check that your environment variables are correctly configured:
   - Navigate to **Solutions** → Your CoE solution → **Environment variables**
   - Verify that Current Values are set (not just Default Values)

2. Verify that the flows have the necessary permissions:
   - Check connection references are working
   - Ensure the flow has not been suspended due to errors

3. Review flow run history for specific error messages

4. Report the issue on the [CoE Starter Kit GitHub](https://github.com/microsoft/coe-starter-kit/issues) with:
   - Environment details
   - Steps you've already tried
   - Flow run history screenshots
   - Environment variable configuration screenshots
