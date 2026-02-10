# Implementation Guide: Fix Environment Variable Update Bug

## For Developers Implementing the Fix

### Quick Start
1. Open **CoE Admin Command Center** app in Power Apps Studio
2. Navigate to **Environment Variables** page
3. Find the **Panel control** (Control ID 20 in the JSON)
4. Update **OnButtonSelect** property with fixed code below
5. Update **Screen OnVisible** property with fixed initialization
6. Test thoroughly
7. Publish and export solution

---

## Control Identification

### How to Find Control 20 (Panel Control)
When the app is open in Power Apps Studio:

1. **Tree View Method**:
   - Look for a control named similar to:
     - `EditPanel`
     - `SidePanel`
     - `EnvVarEditPanel`
   - It should be a **PowerCAT.SidePanel.SidePanel** component
   - Should have buttons labeled "Save" and "Revert"

2. **Visual Method**:
   - Run the app in Studio
   - Click on an environment variable to edit
   - The panel that slides out from the right is Control 20
   - Select it in the Studio

3. **Search Method**:
   - Use Ctrl+F in Studio
   - Search for: "OnButtonSelect"
   - Look for the one with "Save" and "Revert" logic

### Verify You Have the Right Control
The control should have these properties:
- **Type**: PowerCAT.SidePanel.SidePanel
- **Buttons**: Two buttons with labels "Save" and "Revert"
- **OnButtonSelect**: Contains a Switch statement
- **References**: `EnvVarsList.Selected`, `value_textbox`, `AugmentedVariables`

---

## Property 1: OnButtonSelect (Panel Control)

### Current Code (To Replace)
```powerFx
Switch(Self.SelectedButton.Label,

"Save", 
Set(Loader, true);
Set(LoaderText, "Saving");

If(EnvVarsList.Selected.hasCurrent = true,
    UpdateIf('Environment Variable Values', 'Environment Variable Definition'.'Environment Variable Definition' = EnvVarsList.Selected.DefnID, 
        {Value: value_textbox.Value});
    UpdateIf(AugmentedVariables, DefnID = EnvVarsList.Selected.DefnID,
            {CurrentValue: value_textbox.Value, DisplayValue: value_textbox.Value, hasCurrent: true, hasValue: true, 
            customizedIcon: "icon:SkypeCircleCheck", customizedColor: ColorYes});,

    UpdateContext({newCurrentValueID: Patch('Environment Variable Values', Defaults('Environment Variable Values'),
            {'Environment Variable Definition': LookUp('Environment Variable Definitions', 'Schema Name' = EnvVarsList.Selected.SchemaName),
            'Schema Name': EnvVarsList.Selected.SchemaName, Value: value_textbox.Value})});
    UpdateIf(AugmentedVariables, DefnID = EnvVarsList.Selected.DefnID,
            {CurrentValue: value_textbox.Value, DisplayValue: value_textbox.Value, hasCurrent: true, hasValue: true,
            customizedIcon: "icon:SkypeCircleCheck", customizedColor: ColorYes,
            CurrentID: newCurrentValueID.'Environment Variable Value'
            });
    UpdateContext({x: "y"}));

Set(Loader, false);
Set(LoaderText, "");
UpdateContext({showPanel: false});,

"Revert", 
Set(Loader, true);
Set(LoaderText, "Reverting to default");

If(EnvVarsList.Selected.hasCurrent = false || EnvVarsList.Selected.hasDefault = false, Notify("Nothing to revert, no alternate reset value exists."));
If(EnvVarsList.Selected.hasCurrent = true && EnvVarsList.Selected.hasDefault = true,
    RemoveIf('Environment Variable Values', 'Environment Variable Definition'.'Environment Variable Definition' = EnvVarsList.Selected.DefnID);
    UpdateIf(AugmentedVariables, SchemaName = EnvVarsList.Selected.SchemaName,
            {CurrentValue: "", DisplayValue: EnvVarsList.Selected.DefaultValue, hasCurrent: false, hasValue: true,
            CurrentID: "", customizedColor: ColorNo, customizedIcon: ""}););

Set(Loader, false);
Set(LoaderText, "");
UpdateContext({showPanel: false});
)
```

### New Code (Fixed - Copy and Paste This)
```powerFx
Switch(Self.SelectedButton.Label,

"Save", 
// Turn on spinner
Set(Loader, true);
Set(LoaderText, "Saving");

// Perform a fresh lookup to determine if record exists
Set(
    existingEnvVarValue, 
    LookUp(
        'Environment Variable Values',
        'Environment Variable Definition'.'Environment Variable Definition' = EnvVarsList.Selected.DefnID
    )
);

// Decide whether to UPDATE or CREATE based on fresh lookup
If(
    !IsBlank(existingEnvVarValue),
    
    // UPDATE: Patch the existing record
    Set(
        saveResult,
        Patch(
            'Environment Variable Values',
            existingEnvVarValue,
            {Value: value_textbox.Value}
        )
    );
    
    // Update local collection
    UpdateIf(
        AugmentedVariables, 
        DefnID = EnvVarsList.Selected.DefnID,
        {
            CurrentValue: value_textbox.Value, 
            DisplayValue: value_textbox.Value, 
            hasCurrent: true, 
            hasValue: true, 
            customizedIcon: "icon:SkypeCircleCheck", 
            customizedColor: ColorYes
        }
    ),
    
    // CREATE: Insert new record only if truly doesn't exist
    Set(
        saveResult,
        Patch(
            'Environment Variable Values', 
            Defaults('Environment Variable Values'),
            {
                'Environment Variable Definition': LookUp(
                    'Environment Variable Definitions', 
                    'Schema Name' = EnvVarsList.Selected.SchemaName
                ),
                Value: value_textbox.Value
            }
        )
    );
    
    // Update local collection with new record ID
    UpdateIf(
        AugmentedVariables, 
        DefnID = EnvVarsList.Selected.DefnID,
        {
            CurrentValue: value_textbox.Value, 
            DisplayValue: value_textbox.Value, 
            hasCurrent: true, 
            hasValue: true,
            customizedIcon: "icon:SkypeCircleCheck", 
            customizedColor: ColorYes,
            CurrentID: saveResult.'Environment Variable Value'
        }
    )
);

// Error handling with user notification
If(
    IsError(saveResult),
    
    // Show error notification
    Notify(
        "Error saving environment variable: " & FirstError(saveResult).Message & ". The value may already exist or you may lack permissions.", 
        NotificationType.Error
    );
    
    // Keep panel open so user can retry
    Set(Loader, false);
    Set(LoaderText, ""),
    
    // Show success notification
    Notify("Environment variable saved successfully.", NotificationType.Success);
    
    // Turn off spinner
    Set(Loader, false);
    Set(LoaderText, "");
    
    // Close panel
    UpdateContext({showPanel: false})
);,

"Revert", 
// Turn on spinner
Set(Loader, true);
Set(LoaderText, "Reverting to default");

// Show notification if nothing to revert
If(
    EnvVarsList.Selected.hasCurrent = false || EnvVarsList.Selected.hasDefault = false, 
    Notify("Nothing to revert, no alternate reset value exists.")
);

// Perform revert if both current and default exist
If(
    EnvVarsList.Selected.hasCurrent = true && EnvVarsList.Selected.hasDefault = true,
    
    // Remove current value record
    RemoveIf(
        'Environment Variable Values', 
        'Environment Variable Definition'.'Environment Variable Definition' = EnvVarsList.Selected.DefnID
    );
    
    // Update local collection
    UpdateIf(
        AugmentedVariables, 
        SchemaName = EnvVarsList.Selected.SchemaName,
        {
            CurrentValue: "", 
            DisplayValue: EnvVarsList.Selected.DefaultValue, 
            hasCurrent: false, 
            hasValue: true,
            CurrentID: "", 
            customizedColor: ColorNo, 
            customizedIcon: ""
        }
    );
);

// Turn off spinner
Set(Loader, false);
Set(LoaderText, "");

// Close panel
UpdateContext({showPanel: false});
)
```

---

## Property 2: OnVisible (Screen Control)

### Find the Screen Control
- In Tree View, it's the top-level control (usually called "Screen1" or the page name)
- Should contain all other controls as children
- Has an "OnVisible" property

### Current OnVisible Initialization Code (Find This Section)
Look for this in the OnVisible property:
```powerFx
Clear(AugmentedVariables);
ForAll(Filter('Environment Variable Definitions', "admin_" in 'Schema Name'),
    Collect(AugmentedVariables, 
        {DefnID: 'Environment Variable Definition',
        CurrentID: "xxxxxxx-xxxx-Mxxx-Nxxx-xxxxxxxxxxxx",  // ⬅️ FIND THIS LINE
        ...
```

### Change Required
**Find this line:**
```powerFx
CurrentID: "xxxxxxx-xxxx-Mxxx-Nxxx-xxxxxxxxxxxx",
```

**Replace with:**
```powerFx
CurrentID: Blank(),
```

### Also Update the hasCurrent Logic
**Find this section:**
```powerFx
UpdateIf(AugmentedVariables, true, 
{   CurrentID: LookUp('Environment Variable Values', 'Environment Variable Definition'.'Environment Variable Definition' = DefnID).'Environment Variable Value',
    CurrentValue: LookUp('Environment Variable Values', 'Environment Variable Definition'.'Environment Variable Definition' = DefnID).Value,
    hasCurrent: If(IsBlank(LookUp('Environment Variable Values', 'Environment Variable Definition'.'Environment Variable Definition' = DefnID).Value), false, true),
    ...
```

**Replace with this more efficient version:**
```powerFx
UpdateIf(AugmentedVariables, true,
    With(
        {
            envVarValue: LookUp(
                'Environment Variable Values',
                'Environment Variable Definition'.'Environment Variable Definition' = DefnID
            )
        },
        {   
            CurrentID: envVarValue.'Environment Variable Value',
            CurrentValue: envVarValue.Value,
            hasCurrent: !IsBlank(envVarValue),  // Check record existence, not value
            customizedColor: If(!IsBlank(envVarValue.Value), ColorYes, ColorNo),
            customizedIcon: If(!IsBlank(envVarValue.Value), "icon:SkypeCircleCheck", ""),
            DisplayValue: Coalesce(envVarValue.Value, DefaultValue),
            hasValue: !IsBlank(DefaultValue) || !IsBlank(envVarValue.Value)
        }
    )
);
```

---

## Testing in Studio

### Test Scenario 1: Update Existing Value
1. Run the app in Studio (Play mode)
2. Navigate to Environment Variables page
3. Select a variable that has a current value (green checkmark)
4. Change the value
5. Click "Save"
6. ✅ Should see green success notification
7. ✅ Panel should close
8. ✅ Value should update in the list
9. ✅ No errors in Monitor

### Test Scenario 2: Create New Value
1. Select a variable that only has a default value (no green checkmark)
2. Enter a new value
3. Click "Save"
4. ✅ Should see green success notification
5. ✅ Panel should close
6. ✅ Green checkmark should appear
7. ✅ Value should show in the list

### Test Scenario 3: Error Handling
1. Open Monitor (Alt+Shift+M or Ctrl+Alt+Shift+M)
2. To test error: temporarily remove your permissions OR modify code to force error
3. Try to save
4. ✅ Should see red error notification
5. ✅ Panel should stay open
6. ✅ Error details in notification

### Test Scenario 4: Revert
1. Select a variable with both default and current value
2. Click "Revert"
3. ✅ Should remove current value
4. ✅ Should show default value
5. ✅ Green checkmark should disappear

---

## Variables and References Used

Make sure these exist in your app (they should already):

### Global Variables
- `Loader` (boolean) - Controls spinner visibility
- `LoaderText` (string) - Spinner message
- `ColorYes` (color) - Green color for customized values
- `ColorNo` (color) - Gray color for default values

### Collections
- `AugmentedVariables` - In-memory collection of environment variables with metadata

### Controls Referenced
- `EnvVarsList` - Gallery/list control showing environment variables
- `value_textbox` - Text input for editing the value
- `Self.SelectedButton.Label` - The clicked button ("Save" or "Revert")

### Data Sources
- `'Environment Variable Definitions'` - Dataverse table
- `'Environment Variable Values'` - Dataverse table

---

## Pre-Flight Checklist

Before implementing:
- [ ] Back up the app (export a copy)
- [ ] Have Power Apps Monitor open (for debugging)
- [ ] Have Edit permissions on the app
- [ ] Have permissions to create/update Environment Variable Values
- [ ] Notify team members of the update

During implementation:
- [ ] Copy code exactly as provided
- [ ] Verify no syntax errors (red squiggly lines)
- [ ] Test in Studio before publishing
- [ ] Test all 4 scenarios above

After implementation:
- [ ] Publish the app
- [ ] Test in published version
- [ ] Export solution as unmanaged
- [ ] Commit updated .msapp file to repository
- [ ] Update version number in solution
- [ ] Create release notes

---

## Troubleshooting

### "Name isn't valid" Error
- **Cause**: Typo in data source name or control name
- **Fix**: Verify data source names match exactly (case-sensitive)

### "The requested operation is invalid" Error
- **Cause**: Missing permissions on Environment Variable tables
- **Fix**: Grant user "Create", "Read", "Write" on EnvironmentVariableValue table

### Code Too Long Error
- **Cause**: OnButtonSelect exceeds Power Apps formula length limit
- **Fix**: The fixed code is optimized and should fit; if not, split into helper functions

### saveResult Variable Not Found
- **Cause**: Power Apps may require explicit declaration
- **Fix**: Use `Set(saveResult, ...)` syntax as shown above

### IsError Not Working
- **Cause**: Some Power Fx versions don't support IsError
- **Alternative**: Use `IsBlankOrError()` or check specific error properties

---

## Rollback Plan

If the fix causes issues:

1. **Immediate Rollback**:
   - Revert the app to previous version in Power Apps portal
   - Go to Versions tab → Restore previous version

2. **Code Rollback**:
   - Copy the "Current Code (To Replace)" back into OnButtonSelect
   - Restore original OnVisible code

3. **Solution Rollback**:
   - Re-import previous solution export
   - Overwrite current version

---

## Post-Implementation

After successful implementation:

1. **Update Documentation**:
   - Add to release notes
   - Update troubleshooting docs
   - Add to known issues (resolved)

2. **Monitor**:
   - Watch for any error reports
   - Check telemetry for save success rate
   - Gather user feedback

3. **Communicate**:
   - Notify users of the fix
   - Update setup wizard if affected
   - Update training materials

4. **Version Control**:
   - Commit updated .msapp file
   - Tag release in git
   - Update solution version
   - Export both managed and unmanaged

---

## Support

If you encounter issues during implementation:

- Review full analysis: `ENVIRONMENT-VARIABLE-BUG-ANALYSIS.md`
- Check quick reference: `ENVIRONMENT-VARIABLE-BUG-QUICK-REFERENCE.md`
- View flow diagram: `ENVIRONMENT-VARIABLE-BUG-FLOW-DIAGRAM.txt`
- Open GitHub issue with details
- Check Power Apps Monitor for detailed errors

---

## Success Criteria

The fix is successful when:
- ✅ Users can update existing environment variables
- ✅ Users can create new environment variables
- ✅ Error notifications appear for failures
- ✅ Success notifications appear for successful saves
- ✅ No 400 errors in browser console
- ✅ No unique constraint violations
- ✅ Panel behavior is correct (closes on success, stays open on error)
- ✅ All test scenarios pass
