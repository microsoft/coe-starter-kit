# Quick Fix: Active Sync Flow Errors

**Issue**: Seeing "Failed to escalate privileges" or other sync flow errors in CoE Admin Command Center.

## 5-Minute Quick Fix

### 1. Re-authenticate All Connections (Most Common Fix)

1. Go to https://make.powerautomate.com
2. Select your CoE environment
3. Navigate to **Data** > **Connections**
4. For EACH connection showing a warning icon:
   - Click **Edit**
   - Sign in again
   - Click **Save**
5. Key connections to check:
   - Power Platform for Admins
   - Office 365 Users
   - Dataverse
   - HTTP with Azure AD

### 2. Update Flow Connection References

1. Go to **Solutions** > **Center of Excellence - Core Components**
2. Find the failing flow (check Admin Command Center for flow names)
3. **Edit** the flow
4. For each action with a warning:
   - Click the "..." menu
   - Select the authenticated connection
5. **Save** the flow
6. **Turn off** then **turn on** the flow

### 3. Verify Admin Permissions

Ensure your admin account has:
- ✅ Power Platform Administrator OR Global Administrator role
- ✅ System Administrator in the CoE environment
- ✅ Environment Admin in environments being inventoried

Check at: https://admin.powerplatform.microsoft.com

## Still Not Working?

See the [complete troubleshooting guide](TROUBLESHOOTING-SYNC-FLOW-ERRORS.md) for:
- Detailed error message solutions
- API throttling fixes
- Permission verification steps
- Flow reimport procedures

## Common Mistakes to Avoid

❌ Using a personal account instead of a service account  
❌ Not running the setup wizard after upgrade  
❌ Forgetting to re-authenticate connections after solution import  
❌ Having multiple admins with different permission levels  

## When to Escalate

Create a GitHub issue if:
- You've completed all steps above
- Errors persist after 24 hours
- You see new/different error messages

Report at: https://aka.ms/coe-starter-kit-issues
