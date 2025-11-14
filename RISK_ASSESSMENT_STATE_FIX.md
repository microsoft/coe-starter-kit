# Developer Compliance Center - Risk Assessment State Fix

## Issue
The Developer Compliance Center had inconsistent behavior when setting the Risk Assessment State for different resource types:
- **Bots (Copilot Agents)** and **Custom Connectors** required ALL fields to be populated before moving the state from "Requested" to "Submitted"
- **Canvas Apps**, **Cloud Flows**, **Desktop Flows**, **Model-Driven Apps**, and **Environments** allowed ANY submission to change the state to "Submitted"

This inconsistency caused confusion for makers who would:
1. Submit compliance information for Bots or Custom Connectors
2. See a "successful save" message
3. Continue to receive email notifications requesting compliance information
4. Not realize their submission didn't move the state to "Submitted"

## Root Cause
In the Bots and Custom Connectors pages, the `UpdateIf()` PowerFx statement that changes the Risk Assessment State to "Submitted" was wrapped inside an `If()` condition that validated all required fields were populated. This validation wrapper prevented partial submissions from being recognized as submitted.

In contrast, the Apps and Flows pages had this validation logic commented out (as per historical issue #2092 from 2022), allowing any submission to update the state to "Submitted" regardless of field completion.

## Solution
The fix aligns the behavior of Bots and Custom Connectors pages with the existing behavior of Apps and Flows pages by:
1. Commenting out the field validation wrapper around the Risk Assessment State update
2. Allowing the `UpdateIf()` statement to execute unconditionally after form submission
3. Preserving the validation logic as commented code for reference

### Files Modified
1. **admin_developercompliancecenterbotspage_208a6_DocumentUri.msapp**
   - Controls\87.json - OnButtonSelect property of panSupportDetails_6 component

2. **admin_developercompliancecentercustomconnecto80628_DocumentUri.msapp**
   - Controls\57.json - OnButtonSelect property of panSupportDetails_7 component

## Changes Detail

### Before (Bots Page)
```powerfx
If(
    Self.SelectedButton.Label = "Save",
    SubmitForm(formSupportDetails_6); 
    Set(vSelectedBot, formSupportDetails_6.LastSubmit); 
    ResetForm(formSupportDetails_6);

    // UpdateIf was INSIDE this If condition
    If(
        And(
            !IsBlank(vSelectedBot.'Bot Description'), 
            !IsBlank(vSelectedBot.'Maker Requirement - Business Justification'), 
            !IsBlank(vSelectedBot.'Maker Requirement - Access Management'), 
            !IsBlank(vSelectedBot.'Maker Requirement - Dependencies'), 
            !IsBlank(vSelectedBot.'Maker Requirement - Business Impact'), 
            vSelectedBot.'Mitigation Plan Provided'='Mitigation Plan Provided (PVA Bots)'.Yes
        ), 
        UpdateIf('PVA Bots', PVA=vSelectedBot.PVA, 
            {'Admin Requirement - Risk Assessment State': 'Risk Assessment State Choice'.Submitted}
        );
        // ... rest of logic
    )
);
```

### After (Bots Page)
```powerfx
If(
    Self.SelectedButton.Label = "Save",
    SubmitForm(formSupportDetails_6); 
    Set(vSelectedBot, formSupportDetails_6.LastSubmit); 
    ResetForm(formSupportDetails_6);

    /* Validation checks commented out
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

    // UpdateIf now runs unconditionally
    UpdateIf('PVA Bots', PVA=vSelectedBot.PVA, 
        {'Admin Requirement - Risk Assessment State': 'Risk Assessment State Choice'.Submitted}
    );
    RemoveIf(myBots, PVA=vSelectedBot.PVA);
    Collect(myBots, LookUp('PVA Bots', PVA=vSelectedBot.PVA));
    Set(vSelectedBot, LookUp(myBots, PVA=vSelectedBot.PVA))
    //)
);
```

The same pattern was applied to the Custom Connectors page.

## Impact
After this fix:
- Makers can submit partial compliance information for Bots and Custom Connectors
- The Risk Assessment State will change from "Requested" to "Submitted" on any submission
- Email notifications will stop after the first submission
- Admins can review submissions and return them for additional information if needed
- Behavior is now consistent across all resource types in the Developer Compliance Center

## Policy Consideration
This fix aligns with the principle that platform admins and internal policies should drive what information is required from end users, rather than enforcing it through the submission mechanism. The Developer Compliance Center workflow allows admins to:
1. Request compliance information
2. Receive any level of submission from makers
3. Review submissions and determine if they're complete
4. Return submissions for more information if needed
5. Mark submissions as complete when satisfactory

This provides flexibility for different organizational requirements while maintaining a consistent user experience.

## Testing Recommendations
1. Request compliance information for a Bot
2. Submit with only partial information (e.g., leaving "Mitigation Plan Provided" as "No")
3. Verify the Risk Assessment State changes to "Submitted"
4. Verify email notifications stop being sent
5. Repeat for Custom Connectors
6. Verify existing behavior for Apps, Flows, and other resources remains unchanged

## References
- Original issue: [GitHub Issue discussing inconsistent behavior]
- Historical context: [GitHub Issue #2092 (2022)](https://github.com/microsoft/coe-starter-kit/issues/2092#issuecomment-1047815113) - When this validation was removed from Apps and Flows
