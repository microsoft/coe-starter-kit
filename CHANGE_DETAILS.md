# Change Summary: Risk Assessment State Fix

## What Was Changed

### File 1: Bots Page
**Location:** `CenterofExcellenceAuditComponents/SolutionPackage/src/CanvasApps/admin_developercompliancecenterbotspage_208a6_DocumentUri.msapp`

**Component:** `panSupportDetails_6` (Support Details Panel)  
**Property:** `OnButtonSelect` (Save button click handler)  
**Control File:** `Controls\87.json` inside the .msapp archive

**Change Type:** Logic modification - removed conditional wrapper

### File 2: Custom Connectors Page  
**Location:** `CenterofExcellenceAuditComponents/SolutionPackage/src/CanvasApps/admin_developercompliancecentercustomconnecto80628_DocumentUri.msapp`

**Component:** `panSupportDetails_7` (Support Details Panel)  
**Property:** `OnButtonSelect` (Save button click handler)  
**Control File:** `Controls\57.json` inside the .msapp archive

**Change Type:** Logic modification - removed conditional wrapper

## Exact Changes Made

### Before (Bots - Lines affected in OnButtonSelect)
```powerfx
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

        //and change state to submitted and recollect the app
        UpdateIf(
            'PVA Bots',
            PVA=vSelectedBot.PVA, 
            {
                'Admin Requirement - Risk Assessment State': 'Risk Assessment State Choice'.Submitted
            }
        );
        
        RemoveIf(myBots, PVA=vSelectedBot.PVA);
        Collect(myBots, LookUp('PVA Bots', PVA=vSelectedBot.PVA));
        
        Set(vSelectedBot, LookUp(myBots, PVA=vSelectedBot.PVA))
    )
```

### After (Bots - Same section updated)
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

    //and change state to submitted and recollect the app
    UpdateIf(
        'PVA Bots',
        PVA=vSelectedBot.PVA, 
        {
            'Admin Requirement - Risk Assessment State': 'Risk Assessment State Choice'.Submitted
        }
    );
    
    RemoveIf(myBots, PVA=vSelectedBot.PVA);
    Collect(myBots, LookUp('PVA Bots', PVA=vSelectedBot.PVA));
    
    Set(vSelectedBot, LookUp(myBots, PVA=vSelectedBot.PVA))

    //)
```

### Before (Custom Connectors - Lines affected in OnButtonSelect)
```powerfx
    //check if all requirements met
    If(
        And(
            !IsBlank(vSelectedCC.'Maker Requirement - Business Justification'), 
            !IsBlank(vSelectedCC.'Maker Requirement - Access Management'), 
            !IsBlank(vSelectedCC.'Maker Requirement - Dependencies'), 
            !IsBlank(vSelectedCC.'Maker Requirement - Conditions of Use')
        ), 

        //and change state to submitted and recollect the app
        UpdateIf(
            'PowerApps Connectors',
            Connector=vSelectedCC.Connector,
            {
                'Admin Requirement - Risk Assessment State': 'Risk Assessment State Choice'.Submitted
            }
        );

        RemoveIf(myConnectors, Connector=vSelectedCC.Connector);
        Collect(myConnectors, LookUp('PowerApps Connectors', Connector=vSelectedCC.Connector));

        Set(vSelectedCC, LookUp(myConnectors, Connector=vSelectedCC.Connector))
    )
```

### After (Custom Connectors - Same section updated)
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

    //and change state to submitted and recollect the app
    UpdateIf(
        'PowerApps Connectors',
        Connector=vSelectedCC.Connector,
        {
            'Admin Requirement - Risk Assessment State': 'Risk Assessment State Choice'.Submitted
        }
    );

    RemoveIf(myConnectors, Connector=vSelectedCC.Connector);
    Collect(myConnectors, LookUp('PowerApps Connectors', Connector=vSelectedCC.Connector));

    Set(vSelectedCC, LookUp(myConnectors, Connector=vSelectedCC.Connector))

    //)
```

## Summary of Changes

### What was removed:
- The outer `If()` statement that checked if all fields were filled
- The opening `If(And(...))` and closing `)` of the validation condition

### What was added:
- Multi-line comment markers `/*` and `*/` to preserve the validation logic
- Comment marker `//)` to show where the If statement used to close

### What stayed the same:
- All the actual business logic (UpdateIf, RemoveIf, Collect, Set statements)
- The form submission logic
- The button label check
- All field names and data source references

### Net effect:
The `UpdateIf()` statement that changes the Risk Assessment State now executes **unconditionally** after form submission, rather than only when all validation checks pass. This makes Bots and Custom Connectors behave consistently with Apps, Flows, and other resource types.

## Why This Approach

1. **Minimal Change:** Only the problematic validation wrapper was modified
2. **Preserved History:** The validation logic remains visible as commented code
3. **Consistency:** Aligns with the pattern established in Apps and Flows pages in 2022
4. **Maintainability:** Future developers can see what was changed and why
5. **Non-Breaking:** The change makes the behavior more permissive, not more restrictive

## Files Modified

```
CenterofExcellenceAuditComponents/SolutionPackage/src/CanvasApps/
├── admin_developercompliancecenterbotspage_208a6_DocumentUri.msapp
└── admin_developercompliancecentercustomconnecto80628_DocumentUri.msapp
```

## No Changes to These Files (Already Correct)

```
CenterofExcellenceAuditComponents/SolutionPackage/src/CanvasApps/
├── admin_developercompliancecenterapppage_775de_DocumentUri.msapp (Apps - already correct)
├── admin_developercompliancecenterflowspage_a9c6a_DocumentUri.msapp (Flows - already correct)
├── admin_developercompliancecenterdesktopflowspa13941_DocumentUri.msapp (Desktop Flows - already correct)
├── admin_developercompliancecentermdapage_6aa97_DocumentUri.msapp (Model-Driven Apps - already correct)
└── admin_developercompliancecenterenvironmentspa90940_DocumentUri.msapp (Environments - already correct)
```
