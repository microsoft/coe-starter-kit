# Environment Variable Update Bug - Quick Reference

## The Problem 🐛
Admin Command Center tries to CREATE a new EnvironmentVariableValue instead of UPDATE when saving, causing a 400 error (unique constraint violation). UI shows success despite the failure.

## Location 📍
**File**: `CenterofExcellenceCoreComponents/SolutionPackage/src/CanvasApps/admin_commandcenterenvironmentvariablespage_9d99b_DocumentUri.msapp`  
**Control**: Control ID 20 (Panel with Save/Revert buttons)  
**Property**: OnButtonSelect event handler

## Root Cause 🔍
```powerFx
// Initialization uses placeholder GUID
CurrentID: "xxxxxxx-xxxx-Mxxx-Nxxx-xxxxxxxxxxxx"

// hasCurrent check is unreliable
hasCurrent: If(IsBlank(LookUp(...).Value), false, true)

// Save logic depends on hasCurrent
If(EnvVarsList.Selected.hasCurrent = true,
    UpdateIf(...),  // Update path
    Patch(..., Defaults(), {...})  // Create path - FAILS if record exists!
)
```

## The Fix ✅
Replace the conditional logic with a fresh lookup:

```powerFx
// Do a fresh lookup before save
Set(existingEnvVarValue, LookUp(
    'Environment Variable Values',
    'Environment Variable Definition'.'Environment Variable Definition' = EnvVarsList.Selected.DefnID
));

// Use the lookup result to decide
If(!IsBlank(existingEnvVarValue),
    // UPDATE: Patch with existing record
    Patch('Environment Variable Values', existingEnvVarValue, {Value: value_textbox.Value}),
    
    // CREATE: Only if truly doesn't exist
    Patch('Environment Variable Values', Defaults('Environment Variable Values'), {...})
);

// Add error handling
If(IsError(saveResult),
    Notify("Error saving...", NotificationType.Error),
    Notify("Saved successfully!", NotificationType.Success)
);
```

## Quick Workaround 🔧
If stuck, manually delete the Environment Variable Value record in Dataverse, then create new through the app.

## Testing Priorities ✓
1. Update existing value (most common case)
2. Create new value
3. Verify error notifications appear
4. Check browser console for 400 errors

## Key Changes Summary
| Issue | Fix |
|-------|-----|
| Placeholder GUID | Use `Blank()` instead |
| Stale `hasCurrent` flag | Use fresh lookup before save |
| `UpdateIf()` for updates | Use `Patch()` with specific record |
| No error handling | Add `IsError()` check and `Notify()` |
| Silent failures | Show error notifications |

## Impact
**Severity**: High  
**Users Affected**: Anyone configuring CoE Starter Kit environment variables  
**Workaround Available**: Yes (manual Dataverse edit)

## See Also
- Full analysis: `ENVIRONMENT-VARIABLE-BUG-ANALYSIS.md`
- Detailed code: Controls/20.json (OnButtonSelect property)
