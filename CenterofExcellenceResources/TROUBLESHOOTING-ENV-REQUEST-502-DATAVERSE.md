# Troubleshooting 502 Bad Gateway Error During Dataverse Provisioning

## Issue Description

When creating a new environment request through the Environment Request maker page, users encounter a **502 Bad Gateway** error specifically during Dataverse provisioning. The environment itself is created successfully, but the Dataverse database fails to provision.

### Symptoms

- ✅ Environment creation succeeds
- ❌ Dataverse provisioning fails with `BadGateway` error
- ⏱️ 10 retries occur over extended period (hours)
- 🔄 Error is consistent across multiple environments
- 📊 Flow run shows status code: 502

![502 Error Example](https://github.com/user-attachments/assets/547a6664-b520-42c8-8bb7-ce967c8fcb7d)

## Root Cause

The `Create_Database` action in the "Env Request | Create Approved Environment" flow was missing two critical configurations:

1. **Missing `operationOptions: "DisableAsyncPattern"`** - Required for long-running operations
2. **Missing `api-version` parameter** - Ensures consistent API behavior

### Why This Causes 502 Errors

Database provisioning takes **5-15 minutes** to complete, but without proper async configuration:
- The flow waits synchronously for the operation to complete
- API gateway times out after 2-5 minutes
- Gateway returns 502 error even though provisioning continues in the background
- Database may actually be created successfully despite the error

## Fix Applied (v4.51+)

### Changes Made

Updated the `Create_Database` action in both:
- **Core Components**: `CenterofExcellenceCoreComponents/SolutionPackage/src/Workflows/EnvRequestCreateApprovedEnvironment-*.json`
- **Teams Components**: `CenterofExcellenceCoreComponentsTeams/SolutionPackage/Workflows/EnvRequestCreateapprovedenvironment-*.json`

**Before:**
```json
{
  "Create_Database": {
    "type": "OpenApiConnection",
    "inputs": {
      "host": {
        "operationId": "ProvisionInstance"
      },
      "parameters": {
        "environment": "@outputs('Get_Environment_as_Admin')?['body/name']",
        "body/baseLanguage": "...",
        "body/currency/code": "..."
      },
      "retryPolicy": {
        "type": "exponential",
        "count": 10,
        "interval": "PT10S"
      }
    }
  }
}
```

**After:**
```json
{
  "Create_Database": {
    "type": "OpenApiConnection",
    "inputs": {
      "host": {
        "operationId": "ProvisionInstance"
      },
      "parameters": {
        "api-version": "2021-03-01",  // ← ADDED
        "environment": "@outputs('Get_Environment_as_Admin')?['body/name']",
        "body/baseLanguage": "...",
        "body/currency/code": "..."
      },
      "retryPolicy": {
        "type": "exponential",
        "count": 10,
        "interval": "PT10S"
      }
    },
    "operationOptions": "DisableAsyncPattern"  // ← ADDED
  }
}
```

## How to Apply the Fix

### Option 1: Upgrade to Latest CoE Version (Recommended)

1. Download the latest CoE Starter Kit (v4.51+)
2. Follow the upgrade instructions in the [Upgrade Guide](https://learn.microsoft.com/power-platform/guidance/coe/setup-upgrade)
3. Import the updated Core Components solution

### Option 2: Manual Fix (For Immediate Resolution)

If you need immediate resolution before upgrading:

#### Step 1: Export Current Solution
1. Navigate to your CoE environment in [Power Apps](https://make.powerapps.com)
2. Go to **Solutions** > **Center of Excellence - Core Components**
3. Click **Export** > **Unmanaged**
4. Download the solution ZIP file

#### Step 2: Modify the Flow
1. Extract the solution ZIP file
2. Navigate to `Workflows/` folder
3. Find `EnvRequestCreateApprovedEnvironment-*.json`
4. Open in a text editor
5. Locate the `Create_Database` action (search for `"Create_Database"`)
6. Add the two missing properties as shown above
7. Save the file

#### Step 3: Repack and Import
1. Re-zip the solution folder
2. Import back to Power Platform as unmanaged solution
3. **Important**: This will convert your managed solution to unmanaged

> **Warning**: Modifying solutions manually should only be done as a temporary measure. Always upgrade to the official release as soon as possible.

### Option 3: Edit Flow Directly (Power Automate)

For advanced users only:

1. Open the flow in **Power Automate** editor
2. Find the `Create Database` action within `Condition - Provision Database`
3. Switch to **Code View** (three dots menu > **Peek code**)
4. Manually add:
   - `"api-version": "2021-03-01"` to parameters
   - `"operationOptions": "DisableAsyncPattern"` at root level
5. Save and test

> **Note**: This approach is not recommended as changes may be lost during upgrades.

## Verification Steps

After applying the fix:

### 1. Test Environment Request
1. Create a new environment request with Dataverse
2. Monitor the flow run
3. Verify no 502 errors occur
4. Confirm Dataverse is created within 15 minutes

### 2. Check Flow Run History
1. Navigate to **Power Automate** > **My flows**
2. Find "Env Request | Create Approved Environment"
3. Review recent runs
4. Verify `Create_Database` action succeeds

### 3. Validate Dataverse Creation
1. Check the environment in [Power Platform Admin Center](https://admin.powerplatforms.microsoft.com)
2. Verify Dataverse instance exists
3. Confirm base language and currency match request

## Additional Troubleshooting

### If Issue Persists After Fix

#### 1. Check Connection Health
- Verify the **Power Platform for Admins** connection is active
- Re-authenticate if needed
- Ensure the connection account has proper permissions:
  - Power Platform Administrator role
  - System Administrator in CoE environment

#### 2. Review Environment Limits
- Check tenant capacity: [Power Platform Admin Center](https://admin.powerplatforms.microsoft.com/resources/capacity)
- Verify database storage limits
- Confirm environment creation limits not exceeded

#### 3. Inspect Flow Run Details
```
Required Information for Support:
- Flow Run ID
- Environment ID
- Timestamp of failure
- Complete error message
- Region where environment is being created
```

#### 4. Check Service Health
- Review [Microsoft 365 Service Health](https://admin.microsoft.com/Adminportal/Home#/servicehealth)
- Check for Power Platform service degradation
- Verify no ongoing incidents affecting your region

### Common Related Issues

#### Database Appears After Error
**Symptom**: Flow fails with 502, but database appears later  
**Explanation**: This confirms the async timing issue. The database provisioning completed successfully in the background, but the flow timed out waiting for the response.  
**Solution**: Apply the fix above. This is expected behavior before the fix.

#### Multiple 502 Errors on Retry
**Symptom**: Each retry also returns 502  
**Explanation**: Retrying a long-running operation that's already in progress causes additional timeouts  
**Solution**: Check if database already exists before retrying. The fix prevents this scenario.

#### Environment Created Without Database
**Symptom**: Environment exists but no Dataverse instance  
**Explanation**: The provisioning API call never initiated successfully  
**Solution**: Check connection permissions and service health. This is different from the 502 timeout issue.

## Prevention Best Practices

1. **Keep CoE Updated**: Always use the latest version
2. **Monitor Flow Runs**: Set up alerts for flow failures
3. **Test After Changes**: Validate environment requests after any CoE updates
4. **Document Customizations**: Track any manual changes for future upgrades
5. **Regular Health Checks**: Periodically verify connections and permissions

## Related Documentation

- [CoE Starter Kit - Environment Management](https://learn.microsoft.com/power-platform/guidance/coe/env-mgmt)
- [Power Platform for Admins Connector](https://learn.microsoft.com/connectors/powerplatformforadmins/)
- [Service Protection API Limits](https://learn.microsoft.com/power-platform/admin/api-request-limits-allocations)
- [Troubleshooting Guide - General](./TROUBLESHOOTING.md)

## FAQs

**Q: Will this fix affect existing environment requests?**  
A: No, only new requests after the fix is applied will benefit. Existing failed requests may need to be resubmitted.

**Q: Do I need to update both Core and Teams components?**  
A: Yes, if you use both. The fix is required in both solutions.

**Q: Can I apply this fix to an managed solution?**  
A: Not directly. You'll need to export as unmanaged, modify, and reimport, which converts it to unmanaged. Best to upgrade to the official release.

**Q: Will the retry policy still work?**  
A: Yes, the retry policy remains unchanged. It will still retry on genuine failures.

**Q: What API version should I use?**  
A: Use `2021-03-01` as specified in the fix. This matches the version used by other admin operations in the flow.

**Q: Does this affect other flows?**  
A: No, this fix is specific to the Environment Request flow. Other flows using `ProvisionInstance` may need similar updates.

## Issue History

- **Reported**: v4.50.6
- **Root Cause Identified**: 2026-02-13
- **Fix Released**: v4.51.0 (pending)
- **Affected Versions**: 4.50.x and earlier
- **Status**: Fixed in latest release

## Support

If you continue experiencing issues after applying this fix:

1. **Check Existing Issues**: [CoE Starter Kit GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues)
2. **Create New Issue**: Include all diagnostic information listed above
3. **Community Support**: [Power Platform Community Forums](https://powerusers.microsoft.com/t5/Power-Platform-Administration/bd-p/PA_Admin)

---

*Last Updated: 2026-02-13*  
*Fix Version: 4.51.0*
