# Testing and Validation Guide

## Testing the Fix

### Prerequisites
1. CoE Starter Kit installed with version 5.40.6 or later
2. Multiple user accounts:
   - Service account that installed CoE
   - A user with System Administrator security role in the CoE environment
   - A user with System Administrator role who has been shared the CoE flows (as co-owner or run-only user)

### Test Scenarios

#### Scenario 1: Service Account (Should work before and after fix)
1. Log in as the service account that installed the CoE
2. Open "CoE Admin Command Center" app
3. Navigate to "CoE Flows" section
4. **Expected Result**: All flow states display correctly (On/Off based on actual state)

#### Scenario 2: System Administrator without flow permissions (Issue case - FIXED)
1. Log in as a user with System Administrator role who is NOT a co-owner of CoE flows
2. Open "CoE Admin Command Center" app
3. Navigate to "CoE Flows" section
4. **Before Fix**: All flows show as "Off" regardless of actual state
5. **After Fix**: Flows show their actual state if user has view permissions, or "Err" if no permissions

#### Scenario 3: System Administrator with flow permissions (Should work after fix)
1. Share CoE flows with a user who has System Administrator role (as co-owner or with run-only permissions)
2. Log in as that user
3. Open "CoE Admin Command Center" app
4. Navigate to "CoE Flows" section
5. **Expected Result**: Flow states display correctly for flows the user has access to

### Validation Steps

1. **Verify the msapp file was updated**:
   ```bash
   # Check file size changed
   ls -lh CenterofExcellenceCoreComponents/SolutionPackage/src/CanvasApps/admin_commandcentercoeflowspage_bd424_DocumentUri.msapp
   ```

2. **Verify the source code change**:
   ```bash
   # Unpack and check the change
   pac canvas unpack --msapp admin_commandcentercoeflowspage_bd424_DocumentUri.msapp --sources temp_src
   grep "GetFlow" temp_src/Src/Screen1.fx.yaml
   # Should show: PowerAutomateManagement.GetFlow (not AdminGetFlow)
   ```

3. **Import and test in a test environment**:
   - Import the updated solution into a test environment
   - Test with different user personas
   - Verify flow states display correctly

### Technical Details

#### API Comparison

**AdminGetFlow**:
- Requires: Power Platform Service Admin or Dynamics 365 admin role
- AND: Owner or co-owner permissions on the specific flow
- Use case: Administrators managing flows they own
- Limitation: Fails for flows owned by other users

**GetFlow**:
- Requires: User permissions to the flow (owner, co-owner, or viewer)
- Returns flow details based on user's access level
- Use case: Users viewing flows they have permissions to
- Benefit: Works for shared flows and respects permission boundaries

#### Code Change Details

**File**: `CenterofExcellenceCoreComponents/SolutionPackage/src/CanvasApps/admin_commandcentercoeflowspage_bd424_DocumentUri.msapp`

**Screen**: Screen1 (Main screen of CoE Flows page)

**Property**: OnVisible

**Line**: 97 in Screen1.fx.yaml

**Before**:
```yaml
theState: IfError(PowerAutomateManagement.AdminGetFlow(CoE_Envt, ThisRecord.theGUID).properties.state, "Err"),
//    theState: IfError(PowerAutomateManagement.GetFlow(CoE_Envt, ThisRecord.theGUID).properties.state, "Error"), //switch to this so Admin SR can use
```

**After**:
```yaml
theState: IfError(PowerAutomateManagement.GetFlow(CoE_Envt, ThisRecord.theGUID).properties.state, "Err"),
```

### Rollback Plan

If issues are discovered after deploying this fix:

1. **Revert to previous version**:
   - Re-import the previous version of the Core solution
   - OR restore from backup

2. **Alternative workaround** (if rollback not feasible):
   - Share all CoE flows with users who need to view them
   - Grant co-owner permissions to System Administrators
   - Note: This is not ideal from a security perspective

### Known Limitations

After this fix:
- Users will only see flow states for flows they have permissions to view
- Flows not shared with a user may show "Err" state
- This is expected behavior and respects the Power Platform security model

### Security Considerations

This change:
- ✅ Respects flow-level permissions
- ✅ Does not grant unauthorized access to flows
- ✅ Follows principle of least privilege
- ✅ Aligns with Power Platform security model
- ✅ Users only see what they're authorized to see

The previous implementation using `AdminGetFlow` was overly restrictive and prevented legitimate users from viewing flow states they should have access to.
