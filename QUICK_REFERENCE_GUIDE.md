# Quick Reference: Where to Apply the Fix

## Location Map

### 1️⃣ Bots Page (Copilot Agents)

```
Power Apps Studio
└── Developer Compliance Center Bots page
    └── Tree View (left panel)
        └── panSupportDetails_6 ◄── SELECT THIS
            └── Properties (top dropdown)
                └── OnButtonSelect ◄── MODIFY THIS
                    └── PowerFx Formula ◄── EDIT HERE
```

**Exact Property Path:**
- **App**: Developer Compliance Center Bots page
- **Component**: `panSupportDetails_6`
- **Property**: `OnButtonSelect`
- **File** (if importing): `admin_developercompliancecenterbotspage_208a6_DocumentUri.msapp`
- **Internal JSON**: `Controls\87.json` (in extracted .msapp)

---

### 2️⃣ Custom Connectors Page

```
Power Apps Studio
└── Developer Compliance Center Custom Connector page
    └── Tree View (left panel)
        └── panSupportDetails_7 ◄── SELECT THIS
            └── Properties (top dropdown)
                └── OnButtonSelect ◄── MODIFY THIS
                    └── PowerFx Formula ◄── EDIT HERE
```

**Exact Property Path:**
- **App**: Developer Compliance Center Custom Connector page
- **Component**: `panSupportDetails_7`
- **Property**: `OnButtonSelect`
- **File** (if importing): `admin_developercompliancecentercustomconnecto80628_DocumentUri.msapp`
- **Internal JSON**: `Controls\57.json` (in extracted .msapp)

---

## Visual: What Code Section to Change

### Finding the Code

1. Open the app in Power Apps Studio
2. Select the component (panSupportDetails_6 or panSupportDetails_7)
3. Look for the `OnButtonSelect` property in the formula bar
4. Scroll to find this comment: `//check if all requirements met`
5. The code to change starts there

### The Change Pattern

```
┌────────────────────────────────────────────────────────────┐
│ BEFORE (Current - WRONG)                                   │
├────────────────────────────────────────────────────────────┤
│                                                            │
│ SubmitForm(...);                                           │
│ Set(...);                                                  │
│ ResetForm(...);                                            │
│                                                            │
│ //check if all requirements met                           │
│ If(                                    ◄── PROBLEM        │
│     And(                                                   │
│         !IsBlank(field1),                                  │
│         !IsBlank(field2),                                  │
│         ...                                                │
│     ),                                                     │
│                                                            │
│     UpdateIf(...                       ◄── Wrapped in If  │
│         state = Submitted                                  │
│     );                                                     │
│     RemoveIf(...);                                         │
│     Collect(...);                                          │
│     Set(...);                                              │
│ )                                      ◄── Closing paren  │
└────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────┐
│ AFTER (Fixed - CORRECT)                                    │
├────────────────────────────────────────────────────────────┤
│                                                            │
│ SubmitForm(...);                                           │
│ Set(...);                                                  │
│ ResetForm(...);                                            │
│                                                            │
│ /*                                     ◄── OPEN COMMENT   │
│ //check if all requirements met                           │
│ If(                                                        │
│     And(                                                   │
│         !IsBlank(field1),                                  │
│         !IsBlank(field2),                                  │
│         ...                                                │
│     ),                                                     │
│ */                                     ◄── CLOSE COMMENT  │
│                                                            │
│ UpdateIf(...                           ◄── Now executes   │
│     state = Submitted                     unconditionally │
│ );                                                         │
│ RemoveIf(...);                                             │
│ Collect(...);                                              │
│ Set(...);                                                  │
│                                                            │
│ //)                                    ◄── Comment marker │
└────────────────────────────────────────────────────────────┘
```

---

## Line Count Reference

### Bots Page (panSupportDetails_6)
- **Total lines in OnButtonSelect**: ~40 lines
- **Lines to modify**: Lines 11-31 (approximately)
- **Action**: Wrap lines 11-18 in `/* */`, add `//)` after line 30

### Custom Connectors Page (panSupportDetails_7)
- **Total lines in OnButtonSelect**: ~35 lines
- **Lines to modify**: Lines 11-26 (approximately)
- **Action**: Wrap lines 11-16 in `/* */`, add `//)` after line 25

---

## Field Validation Checks Being Removed

### Bots (6 checks)
1. ✓ `!IsBlank(vSelectedBot.'Bot Description')`
2. ✓ `!IsBlank(vSelectedBot.'Maker Requirement - Business Justification')`
3. ✓ `!IsBlank(vSelectedBot.'Maker Requirement - Access Management')`
4. ✓ `!IsBlank(vSelectedBot.'Maker Requirement - Dependencies')`
5. ✓ `!IsBlank(vSelectedBot.'Maker Requirement - Business Impact')`
6. ✓ `vSelectedBot.'Mitigation Plan Provided'='Mitigation Plan Provided (PVA Bots)'.Yes`

### Custom Connectors (4 checks)
1. ✓ `!IsBlank(vSelectedCC.'Maker Requirement - Business Justification')`
2. ✓ `!IsBlank(vSelectedCC.'Maker Requirement - Access Management')`
3. ✓ `!IsBlank(vSelectedCC.'Maker Requirement - Dependencies')`
4. ✓ `!IsBlank(vSelectedCC.'Maker Requirement - Conditions of Use')`

**Note**: These checks are being commented out, NOT deleted. They remain visible in the code for reference.

---

## Variables Used in the Code

### Bots Page
- `vSelectedBot` - Current bot being edited
- `formSupportDetails_6` - The form control
- `myBots` - Collection of bots
- `PVA Bots` - Data source for bots

### Custom Connectors Page
- `vSelectedCC` - Current custom connector being edited
- `formSupportDetails_7` - The form control
- `myConnectors` - Collection of connectors
- `PowerApps Connectors` - Data source for connectors

---

## Common Mistakes to Avoid

❌ **Don't**: Delete the validation code entirely  
✅ **Do**: Comment it out with `/* */`

❌ **Don't**: Forget to add the `//)` marker at the end  
✅ **Do**: Add `//)` where the closing parenthesis used to be

❌ **Don't**: Modify the UpdateIf, RemoveIf, Collect, or Set statements  
✅ **Do**: Only add comment markers around the If/And validation

❌ **Don't**: Change the indentation significantly  
✅ **Do**: Keep the code readable with proper indentation

❌ **Don't**: Apply the fix to Apps or Flows pages  
✅ **Do**: Only modify Bots and Custom Connectors pages (they already work correctly)

---

## Verification Checklist

After making changes, verify:

- [ ] The If(And(...)) section is wrapped in `/* */`
- [ ] The UpdateIf statement is outside the comment block
- [ ] The `//)` marker is present after the last Set statement
- [ ] No syntax errors in Power Apps Studio
- [ ] The app saves successfully
- [ ] The app publishes successfully
- [ ] Test submission with partial data works
- [ ] Risk Assessment State changes to "Submitted"

---

## File Identifiers

If you need to identify the exact files:

### Bots Page
- **Display Name**: Developer Compliance Center Bots page
- **Internal Name**: admin_developercompliancecenterbotspage_208a6
- **File Extension**: .msapp
- **Full Filename**: admin_developercompliancecenterbotspage_208a6_DocumentUri.msapp
- **Repository Path**: CenterofExcellenceAuditComponents/SolutionPackage/src/CanvasApps/

### Custom Connectors Page  
- **Display Name**: Developer Compliance Center Custom Connector page
- **Internal Name**: admin_developercompliancecentercustomconnecto80628
- **File Extension**: .msapp
- **Full Filename**: admin_developercompliancecentercustomconnecto80628_DocumentUri.msapp
- **Repository Path**: CenterofExcellenceAuditComponents/SolutionPackage/src/CanvasApps/

---

## Quick Copy-Paste Templates

### For Bots Page - Opening Comment
```powerfx
/*
//check if all requirements met
If(
    And(
        !IsBlank(vSelectedBot.'Bot Description'), 
        !IsBlank(vSelectedBot.'Maker Requirement - Business Justification'), 
        !IsBlank(vSelectedBot.'Maker Requirement - Access Management'), 
        !IsBlank(vSelectedBot.'Maker Requirement - Dependencies'), 
        !IsBlank(vSelectedBot.'Maker Requirement - Business Impact'), 
        vSelectedBot.'Mitigation Plan Provided'='Mitigation Plan Provided (PVA Bots)'.Yes
    ), 
*/
```

### For Bots Page - Closing Comment
```powerfx
//)
```

### For Custom Connectors Page - Opening Comment
```powerfx
/*
//check if all requirements met
If(
    And(
        !IsBlank(vSelectedCC.'Maker Requirement - Business Justification'), 
        !IsBlank(vSelectedCC.'Maker Requirement - Access Management'), 
        !IsBlank(vSelectedCC.'Maker Requirement - Dependencies'), 
        !IsBlank(vSelectedCC.'Maker Requirement - Conditions of Use')
    ), 
*/
```

### For Custom Connectors Page - Closing Comment
```powerfx
//)
```
