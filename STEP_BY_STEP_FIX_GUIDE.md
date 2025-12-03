# Step-by-Step Fix Guide for Risk Assessment State Issue

## Overview
This guide provides exact steps to fix the Developer Compliance Center Risk Assessment State inconsistency for Bots (Copilot Agents) and Custom Connectors.

## Problem Summary
- **Current Issue**: Bots and Custom Connectors require ALL fields to be filled before the Risk Assessment State changes from "Requested" to "Submitted"
- **Expected Behavior**: Any submission should change the state to "Submitted" (like Apps and Flows do)
- **Impact**: Users see "saved" message but state stays "Requested", causing continued email notifications

---

## STEP-BY-STEP FIX INSTRUCTIONS

### Prerequisites
- Access to Power Platform environment where Developer Compliance Center is installed
- Power Apps Studio access or ability to import solutions
- Either:
  - **Option A**: Download the fixed .msapp files from this PR, OR
  - **Option B**: Manually edit the Canvas Apps following the instructions below

---

## Option A: Using the Fixed Files (RECOMMENDED)

### Step 1: Download Fixed Files
Download these two modified files from this PR:
1. `CenterofExcellenceAuditComponents/SolutionPackage/src/CanvasApps/admin_developercompliancecenterbotspage_208a6_DocumentUri.msapp`
2. `CenterofExcellenceAuditComponents/SolutionPackage/src/CanvasApps/admin_developercompliancecentercustomconnecto80628_DocumentUri.msapp`

### Step 2: Import to Your Environment

**For Bots Page:**
1. Open Power Apps Studio (make.powerapps.com)
2. Go to Apps → Select "Developer Compliance Center Bots page"
3. Click "Edit" to open in Power Apps Studio
4. File → Save As → Download the current version (backup)
5. File → Open → Browse and select `admin_developercompliancecenterbotspage_208a6_DocumentUri.msapp`
6. Click "Save" then "Publish"

**For Custom Connectors Page:**
1. In Power Apps Studio, go to Apps
2. Select "Developer Compliance Center Custom Connector page"
3. Click "Edit" to open in Power Apps Studio
4. File → Save As → Download the current version (backup)
5. File → Open → Browse and select `admin_developercompliancecentercustomconnecto80628_DocumentUri.msapp`
6. Click "Save" then "Publish"

### Step 3: Test the Fix
1. Request compliance information for a Bot
2. Fill in only some fields (leave "Mitigation Plan Provided" as "No")
3. Click "Save"
4. Verify that the Risk Assessment State changes to "Submitted" ✅
5. Repeat for Custom Connectors

---

## Option B: Manual Code Changes (ADVANCED)

If you need to make the changes manually in Power Apps Studio:

### Part 1: Fix Bots Page

1. **Open the App**
   - Go to make.powerapps.com
   - Apps → "Developer Compliance Center Bots page"
   - Click "Edit" to open in Power Apps Studio

2. **Locate the Component**
   - In the Tree View (left panel), find: `panSupportDetails_6`
   - This is the Support Details Panel component

3. **Find the OnButtonSelect Property**
   - Select `panSupportDetails_6`
   - In the Properties dropdown (top), select: `OnButtonSelect`
   - You'll see the PowerFx formula

4. **Identify the Code to Change**
   Look for this section (around line 11-30):
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

5. **Replace with Fixed Code**
   Replace the section above with:
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

6. **Save and Publish**
   - Click "Save"
   - Click "Publish"
   - Confirm the publish

### Part 2: Fix Custom Connectors Page

1. **Open the App**
   - Go to make.powerapps.com
   - Apps → "Developer Compliance Center Custom Connector page"
   - Click "Edit" to open in Power Apps Studio

2. **Locate the Component**
   - In the Tree View (left panel), find: `panSupportDetails_7`
   - This is the Support Details Panel component

3. **Find the OnButtonSelect Property**
   - Select `panSupportDetails_7`
   - In the Properties dropdown (top), select: `OnButtonSelect`
   - You'll see the PowerFx formula

4. **Identify the Code to Change**
   Look for this section:
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

5. **Replace with Fixed Code**
   Replace the section above with:
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

6. **Save and Publish**
   - Click "Save"
   - Click "Publish"
   - Confirm the publish

---

## Verification & Testing

### Test Case 1: Bots (Copilot Agents)
1. In Developer Compliance Center, request compliance for a Bot
2. Open the compliance form for that Bot
3. Fill in these fields:
   - Bot Description: "Test description"
   - Business Justification: "Test justification"
   - Leave other fields blank or incomplete
   - **Important**: Leave "Mitigation Plan Provided" set to "No"
4. Click "Save"
5. **Expected Result**: Risk Assessment State should change to "Submitted" ✅
6. Email notifications should stop ✅

### Test Case 2: Custom Connectors
1. In Developer Compliance Center, request compliance for a Custom Connector
2. Open the compliance form for that connector
3. Fill in only 1-2 fields (not all)
4. Click "Save"
5. **Expected Result**: Risk Assessment State should change to "Submitted" ✅
6. Email notifications should stop ✅

### Test Case 3: Verify Other Pages Still Work
1. Test Apps page - should still accept partial submissions
2. Test Flows page - should still accept partial submissions
3. Test that admin review workflow still functions properly

---

## What Changed Technically

### Key Change
**Moved the validation checks from being REQUIRED to being COMMENTED OUT**

### Before (WRONG):
```powerfx
If(All fields are filled AND Mitigation Plan = Yes,
    // ONLY THEN update the state
    UpdateIf(...state = Submitted);
)
```

### After (CORRECT):
```powerfx
/* Commented out the validation checks */

// ALWAYS update the state
UpdateIf(...state = Submitted);
```

### Why This Works
- The `UpdateIf()` statement now executes **unconditionally** after form submission
- Matches the behavior of Apps, Flows, and other resource types
- Allows admins to determine completeness through the review process
- Users get immediate feedback that their submission was received

---

## Rollback Instructions

If you need to revert the changes:

1. Restore the backed-up versions you downloaded in Step 2
2. Or manually remove the `/* */` comment markers and `//)` to restore the original If condition logic

---

## Additional Resources

- **Full Technical Documentation**: See `RISK_ASSESSMENT_STATE_FIX.md` in this PR
- **Before/After Code Comparison**: See `CHANGE_DETAILS.md` in this PR
- **Visual Diagrams**: See `VISUAL_FLOW_DIAGRAM.md` in this PR
- **Historical Context**: Original fix for Apps/Flows in 2022 - [Issue #2092](https://github.com/microsoft/coe-starter-kit/issues/2092#issuecomment-1047815113)

---

## Support

If you encounter issues:
1. Verify you're editing the correct app (Bots page or Custom Connectors page)
2. Ensure you have the correct component selected (`panSupportDetails_6` or `panSupportDetails_7`)
3. Check that the PowerFx formula syntax is correct (no missing parentheses or quotes)
4. Test in a development environment first before applying to production

---

## Summary

**Files Modified**: 2 Canvas Apps  
**Components Modified**: 2 form panels (panSupportDetails_6 and panSupportDetails_7)  
**Properties Modified**: OnButtonSelect event handlers  
**Lines Changed**: ~15 lines per file (wrapped in comments)  
**Risk Level**: LOW (makes behavior more permissive, not restrictive)  
**Breaking Changes**: NONE  
**Testing Required**: Manual testing in Power Platform environment  
**Estimated Time**: 15-30 minutes for Option A, 30-60 minutes for Option B
