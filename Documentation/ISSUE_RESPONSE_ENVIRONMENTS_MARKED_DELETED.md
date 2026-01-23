# CoE Starter Kit - Issue Response: All Environments Marked as Deleted

## Issue Summary

Users report that after running the **Admin | Sync Template V4 (Driver)** flow, all environments in their CoE inventory are marked as deleted (`admin_environmentdeleted = true`). This causes concern that the CoE cleanup flows might delete all environments.

## Root Cause ✅

This was a **bug in version 4.50** of the Admin | Sync Template V4 (Driver) flow. The "Look_for_Deleted_Environments" action contained faulty comparison logic that could incorrectly mark all environments as deleted.

### Technical Details

The bug was in the `DeletedEnvts` Query action:

**Buggy Code:**
```json
{
  "from": "@body('Parse_Inventory_-_Deleted_Envts')",
  "where": "@not(contains(body('Parse_Actual_-_Deleted_Envts'), item()))"
}
```

This attempted to compare entire JSON objects like `{"EnvtName": "environment-name"}` using the `contains()` function. Object comparison in Power Automate's `contains()` function is unreliable and would fail to match environments, causing all environments to be marked as deleted.

**Fixed Code:**
```json
{
  "from": "@body('Parse_Inventory_-_Deleted_Envts')",
  "where": "@not(contains(body('Parse_Actual_-_Deleted_Envts'), item()['EnvtName']))"
}
```

The fix extracts the actual environment names as a simple string array (instead of objects), then compares the inventory environment name string against this array. String comparison with `contains()` is reliable.

## Immediate Impact Assessment 🛡️

**Good news:** This is a **sync flag issue only** - it does NOT cause actual environment deletion.

### What Happens:
1. ✅ **Environments are NOT deleted from your tenant** - The flag only updates CoE inventory records
2. ✅ **Next sync will correct the flag** - Once the fix is applied, the next driver run will set `admin_environmentdeleted = false` again
3. ⚠️ **Cleanup flows respect the deleted flag** - If cleanup flows run before the fix, they might take action on "deleted" environments

### What to Check:
- Check if any cleanup flows have run since the issue occurred
- Review the `CLEANUP - Admin | Sync Template v4 (Check Deleted)` flow run history
- Verify environment records in the `admin_environment` table

## Resolution Steps 🔧

### Step 1: Update to Fixed Version (Required)

The fix is included in version **4.50.x** (or later). Update your CoE Core Components solution:

1. Download the latest CoE Starter Kit release from [GitHub Releases](https://github.com/microsoft/coe-starter-kit/releases)
2. Import the updated **Center of Excellence - Core Components** solution
3. The Admin | Sync Template V4 (Driver) flow will be updated with the fix

### Step 2: Re-run the Driver Flow

After updating, manually trigger the **Admin | Sync Template V4 (Driver)** flow:

1. Go to Power Automate in your CoE environment
2. Find **Admin | Sync Template V4 (Driver)** flow
3. Click **Run** to trigger manually
4. Wait for completion (may take 30-60 minutes depending on tenant size)

The flow will:
- ✅ Correctly identify actual environments in your tenant
- ✅ Update `admin_environmentdeleted = false` for all existing environments
- ✅ Only mark environments as deleted if they were actually deleted from the tenant

### Step 3: Verify Environment Records

Check that environments are correctly marked:

1. Open the **CoE Admin Command Center** app
2. Navigate to **Environments** section
3. Filter for `Environment Deleted = Yes`
4. Verify that only actually-deleted environments appear
5. Check that all active environments show `Environment Deleted = No`

### Step 4: Review Cleanup Flow History (If Applicable)

If cleanup flows ran while environments were incorrectly marked as deleted:

1. Check **CLEANUP - Admin | Sync Template v4 (Check Deleted)** flow runs
2. Review what actions were taken
3. If environments were incorrectly processed, they should be restored in the next sync

## Prevention 💡

### For Administrators:

1. **Always update to the latest CoE version** - Bug fixes are continuously released
2. **Monitor the Driver flow runs** - Check for unexpected patterns (e.g., sudden spike in "deleted" environments)
3. **Set up alerts** - Configure failure notifications for critical flows
4. **Test in non-production first** - If possible, test CoE updates in a dev/test environment

### Environment Variable Configuration:

No environment variable changes are needed for this fix. The bug was in the flow logic itself.

## FAQ ❓

### Q: Will my environments be deleted?

**A:** No. The bug only affects the CoE inventory flag (`admin_environmentdeleted`). Your actual Power Platform environments are not affected unless cleanup flows have run and taken action based on the incorrect flag.

### Q: How do I know if I'm affected?

**A:** Check the `admin_environment` table in Dataverse:
1. Open **Advanced Find** or use the **CoE Admin Command Center**
2. Query environments where `admin_environmentdeleted = true`
3. If ALL or most environments show as deleted, you're affected

### Q: What about cleanup flows?

**A:** The `CLEANUP - Admin | Sync Template v4 (Check Deleted)` flow uses the `admin_environmentdeleted` flag. If it ran while environments were incorrectly marked as deleted, review its actions. By default, this flow typically only logs or notifies about deleted environments rather than taking destructive action.

### Q: Can I prevent this from happening again?

**A:** Yes:
1. Keep your CoE Starter Kit updated to the latest version
2. Review flow run histories regularly
3. Test updates in a non-production environment first
4. Configure monitoring and alerts for critical flows

## Related Documentation 📚

- [CoE Starter Kit Setup Guide](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup)
- [CoE Starter Kit After Setup](https://learn.microsoft.com/en-us/power-platform/guidance/coe/after-setup)
- [Environment Management](https://learn.microsoft.com/en-us/power-platform/admin/environments-overview)

## Version History

- **v4.50.x**: Fixed - Corrected comparison logic in Look_for_Deleted_Environments action
- **v4.50**: Affected - Contains the bug

---

**Issue Response Template Version**: 1.0  
**Last Updated**: January 2026  
**Fix Included In**: CoE Core Components v4.50.x+
