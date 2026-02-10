# Issue Response: Sync Template Flow Failures (Flow Management API)

## When to Use This Template

Use this response when users report:
- Failures in "Admin | Sync Template v3 (Flow action Details)" flow
- "Get flow as Admin" action failures
- Frequent failures in any Sync Template flow calling Flow Management API
- HTTP 429 (throttling) or transient API errors in sync flows

## Template Response

---

Thank you for reporting this issue!

### Issue Summary

You're experiencing failures with the **Admin | Sync Template v3 (Flow action Details)** flow, specifically with the "Get flow as Admin" action. This is a known issue that has been resolved in recent versions.

### Root Cause

The Flow Management API actions in several Sync Template flows were missing **retry policies**, causing them to fail immediately when encountering:
- API throttling (HTTP 429)
- Transient service issues (HTTP 503)
- Temporary network problems

Without retry policies, even temporary issues would cause the flow to fail instead of automatically retrying with exponential backoff.

### Resolution

This issue has been fixed by adding exponential retry policies to all Flow Management API calls in the affected flows. The fix is available in CoE Starter Kit versions released **after January 2026**.

### Affected Flows (Now Fixed)

1. Admin | Sync Template v3 (Flow action Details) - 3 actions
2. Admin | Sync Template v3 (CoE Solution Metadata) - 1 action
3. Admin | Sync Template v4 (BYODL Flow Properties) - 1 action
4. Admin | Sync Template v4 (Flows) - 1 action

### What You Need to Do

#### Option 1: Upgrade to Latest Version (Recommended)

1. Download the latest CoE Starter Kit release from [GitHub Releases](https://github.com/microsoft/coe-starter-kit/releases)
2. Follow the [upgrade guide](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components)
3. Import the updated Core Components solution
4. The retry policies will be applied automatically

#### Option 2: Apply Manual Fix (Advanced)

If you cannot upgrade immediately:

1. Open the affected flow in Power Automate
2. Navigate to the "Get flow as Admin" (or similar Flow Management API) action
3. Click on the action settings (⋮ menu)
4. Select "Settings"
5. Under "Retry Policy", configure:
   - **Type**: Exponential
   - **Count**: 10
   - **Interval**: PT10S (10 seconds)
6. Save and test the flow

### Expected Results After Fix

✅ **Improved reliability**: Transient failures automatically retried  
✅ **Better resilience**: API throttling handled gracefully  
✅ **Fewer failures**: Temporary issues resolved without manual intervention  
ℹ️ **Note**: Flow runs may take slightly longer if retries are needed, which is expected

### Detailed Documentation

For comprehensive troubleshooting information, see:

📖 **[Sync Template Flow Action Details Failures Guide](troubleshooting/sync-template-flow-action-details-failures.md)**

This guide includes:
- Detailed explanation of the issue
- Step-by-step resolution instructions
- Expected behavior after the fix
- When to seek additional help
- Best practices for monitoring

### Next Steps

1. **Upgrade to the latest version** (if not already done)
2. **Monitor flow runs** for 1-2 weeks after upgrade
3. **Report back** if failures continue despite retry attempts

If you continue experiencing issues after applying this fix:
- Provide flow run history screenshots showing the retry attempts
- Share any specific error messages from the failed runs
- Indicate how long the issue has persisted post-upgrade

### Related Issues

This fix also resolves similar issues reported in:
- Flow Management API throttling errors
- Intermittent sync failures
- "Connection timeout" errors in sync flows

---

Let me know if you have any questions or if the issue persists after upgrading!

---

## Closing Comment

**Use when closing the issue after user confirms resolution:**

---

I'm glad the upgrade resolved the issue! 🎉

The retry policies should significantly improve the reliability of your sync flows. You may still see occasional retries in the flow run history (which is normal and expected), but the flows should complete successfully.

If you notice any patterns of consistent failures even with the retries, please open a new issue with:
- Flow run details showing all retry attempts
- Specific error messages
- Environment details (region, scale, etc.)

Thank you for using the CoE Starter Kit and for reporting this issue!

---

## Technical Details for Maintainers

### Files Changed

- `AdminSyncTemplatev3FlowActionDetails-7EBB10A6-5041-EB11-A813-000D3A8F4AD6.json` (3 actions)
- `AdminSyncTemplatev3CoESolutionMetadata-F67E1E35-4CD5-EC11-A7B5-0022482783B7.json` (1 action)
- `AdminSyncTemplatev4BYODLFlowProperties-3A430A74-19E6-ED11-A7C7-0022480813FF.json` (1 action)
- `AdminSyncTemplatev4Flows-38613E1A-02DA-ED11-A7C7-0022480813FF.json` (1 action)

### Retry Policy Applied

```json
{
  "retryPolicy": {
    "type": "exponential",
    "count": 10,
    "interval": "PT10S"
  }
}
```

### Testing Validation

- JSON structure validated for all modified flows
- All Flow Management API actions now have retry policies
- No other actions modified (minimal change principle)

---

**Template Version**: 1.0  
**Last Updated**: February 2026  
**Related PR**: [Link to PR]
