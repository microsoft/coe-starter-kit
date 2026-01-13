# Enhancement Analysis: CoE Utility to Update Owner/Derived Owner for Orphaned SharePointFormApps

## 1. Understanding & Summary

### Enhancement Request Summary
The enhancement request seeks a CoE Starter Kit utility that enables administrators to update the owner or derived owner for orphaned SharePoint Form Apps (SharePointFormApps). 

### Core Problem
- **Issue**: SharePoint Form Apps become orphaned when the original owner leaves the organization
- **Current Limitation**: SharePoint Form Apps cannot have their owner changed through native Power Platform administration interfaces or the SharePoint interface
- **Business Impact**: Orphaned SharePointFormApps cannot be properly managed, maintained, or reassigned, creating governance and operational challenges
- **User Pain Point**: While another user can modify the app from SharePoint, the owner field doesn't change in Power Platform, making it impossible to track accountability and manage the app lifecycle

### Context
- **Consolidation Note**: This issue has been marked as closed by @AmarSaiRam and consolidated into issue #10319: "Centralized Management for Orphaned Components (Apps, Flows, Connection References)"
- **Related Feature**: The CoE Starter Kit already has a similar "derived owner" concept for Flows (see `admin_setflowpermissions` app)
- **Reddit Discussion**: Community members have reported similar challenges (https://www.reddit.com/r/PowerApps/comments/wwt2mb/change_owner_of_sharepointformapp_pa_in_spo_not/)

## 2. Feasibility Assessment

### FEASIBLE ✅

The enhancement is **technically feasible** based on the following evidence:

#### Evidence of Feasibility

1. **Existing Pattern**: The CoE Starter Kit already implements "Derived Owner" functionality for Flows
   - Location: `CenterofExcellenceCoreComponentsTeams/SolutionPackage/CanvasApps/admin_setflowpermissions_ce2bb`
   - Implementation: Uses `admin_derivedowner` field in `admin_Flow` entity
   - Rationale: "Because you cannot change the owner of a flow, we will have this second field called DerivedOwner which will start as the creator but which can be assigned to someone else."

2. **SharePointFormApp Support**: The CoE Starter Kit already tracks SharePointFormApps
   - App Type Enum: `597910002: "SharePointFormApp"` in `admin_powerappstype` option set
   - Field Available: `admin_sharepointformurl` in `admin_App` entity
   - View Available: View ID `4a18d717-6641-eb11-a813-000d3a8f4ad6` named "Sharepoint"

3. **Orphaned App Tracking**: Infrastructure exists for tracking orphaned apps
   - Field: `cr5d5_appisorphaned` ("App is Orphaned") in `admin_App` entity
   - UI: `OrphanedAppScreen` in `admin_setapppermissions` app
   - Filtering: Existing screen filters for orphaned Canvas apps

4. **Data Model Foundation**: The `admin_App` entity is extensible and can support new fields

### Limitations & Constraints

1. **Platform Limitation**: Native Power Platform APIs do not support changing the owner of SharePointFormApps
   - This is a product-level constraint, not a CoE Starter Kit limitation
   - Similar to Flow ownership, which cannot be changed via Power Automate APIs

2. **Derived Owner Scope**: The "Derived Owner" approach is a CoE Starter Kit-specific construct
   - It only affects CoE reporting and governance
   - It does NOT change the actual owner in Power Platform system records
   - Apps will still appear as owned by the original (orphaned) user in Power Platform Admin Center

3. **No Actual Ownership Transfer**: Unlike connection reassignment or permission changes, this solution provides tracking/reporting only
   - Useful for: CoE governance reporting, identifying responsible parties, audit trails
   - Not useful for: Technical ownership transfer, API authentication, license attribution

## 3. Proposed Implementation Approach

### High-Level Architecture

The implementation follows the existing pattern used for Flow Derived Owner management:

```
┌─────────────────────────────────────────────────────────────┐
│                    CoE Starter Kit Components                │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  admin_App Entity (Dataverse)                          │ │
│  │  ┌──────────────────────────────────────────────────┐ │ │
│  │  │  NEW: admin_DerivedOwner (Lookup to admin_Maker) │ │ │
│  │  └──────────────────────────────────────────────────┘ │ │
│  └────────────────────────────────────────────────────────┘ │
│                            │                                  │
│                            │                                  │
│  ┌────────────────────────▼───────────────────────────────┐ │
│  │  admin_setapppermissions Canvas App                    │ │
│  │  ┌──────────────────────────────────────────────────┐ │ │
│  │  │  UPDATED: OrphanedAppScreen.fx.yaml              │ │ │
│  │  │  - Add filter for SharePointFormApp type        │ │ │
│  │  │  - Add DerivedOwner lookup on select            │ │ │
│  │  └──────────────────────────────────────────────────┘ │ │
│  │  ┌──────────────────────────────────────────────────┐ │ │
│  │  │  UPDATED: AppDetailsScreen.fx.yaml               │ │ │
│  │  │  - Add DerivedOwner display                      │ │ │
│  │  │  - Add "Set Derived Owner" button               │ │ │
│  │  │  - Add UpdateIf logic for DerivedOwner           │ │ │
│  │  │  - Add role indicator (Owner vs Creator)        │ │ │
│  │  └──────────────────────────────────────────────────┘ │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

### Affected Components

#### 1. Dataverse Schema Changes
**File**: `CenterofExcellenceCoreComponents/SolutionPackage/src/Entities/admin_App/Entity.xml`

- **Change**: Add new lookup field `admin_DerivedOwner` 
- **Type**: Lookup (N:1) to `admin_Maker` entity
- **Purpose**: Store the derived/administrative owner for reporting purposes
- **Initial Value**: Should default to the current app owner (for new records)
- **Description**: "Because you cannot change the owner of a SharePointFormApp, this field provides a derived owner which can be assigned to someone else for CoE governance and reporting purposes."

#### 2. Canvas App: Set App Permissions
**Location**: `CenterofExcellenceCoreComponentsTeams/SolutionPackage/CanvasApps/admin_setapppermissions_37e74_DocumentUri_msapp_src/`

##### File: `DataSources/PowerApps Apps.json`
- **Change**: Add `admin_DerivedOwner` to NativeCDSDataSourceInfoNameMapping
- **Example**: `"admin_DerivedOwner": "DerivedOwner"`

##### File: `Src/OrphanedAppScreen.fx.yaml`
- **Current Filter**: Only shows Canvas apps (`'App Type'= 'PowerApps Type'.Canvas`)
- **Updated Filter**: Include SharePointFormApps
  ```powerFx
  Filter(
      'PowerApps Apps', 
      'App is Orphaned'= "yes" 
      And ('App Type'= 'PowerApps Type'.Canvas Or 'App Type'= 'PowerApps Type'.SharePointFormApp)
      And 'App Deleted' = 'App Deleted (PowerApps Apps)'.No
  )
  ```
- **OnSelect Enhancement**: Add DerivedOwner lookup (similar to Flow pattern)
  ```powerFx
  Set(SelectedApp, galApps_2.Selected);
  Set(AppDerivedOwner, LookUp('PowerApps Apps', App=SelectedApp.App).DerivedOwner.Maker);
  If(IsBlank(AppDerivedOwner), Set(AppDerivedOwner, LookUp('PowerApps Apps', App=SelectedApp.App).'App Owner'.Maker));
  Navigate(AppDetailsScreen)
  ```

##### File: `Src/AppDetailsScreen.fx.yaml` (NEW FUNCTIONALITY)
- **Add Display Label**: Show current derived owner (if set) or creator
- **Add Button**: "Set as Derived Owner" for user permissions
  - **OnSelect Logic**:
    ```powerFx
    UpdateIf('PowerApps Apps', App=SelectedApp.App, {DerivedOwner: LookUp(Makers, Maker=GUID(ThisItem.properties.principal.id))});
    Set(AppDerivedOwner, LookUp('PowerApps Apps', App=SelectedApp.App).DerivedOwner.Maker);
    ```
- **Update Role Display**: Show "Owner" for derived owner, "Creator" for original owner
  ```powerFx
  "Role: " & If(ThisItem.properties.principal.id=AppDerivedOwner, "Owner", If(ThisItem.properties.roleName="Owner", "Creator", ThisItem.properties.roleName))
  ```
- **Add Informational Text**: Explain the derived owner concept
  ```
  "Changing app ownership for SharePointFormApps is not possible through Power Platform, so changing it here only changes it in the context of your CoE Toolkit. It is stored and used as a property of the CoE App table: DerivedOwner"
  ```

#### 3. Documentation Updates
**Affected Files**: 
- CoE Starter Kit documentation (external Microsoft Learn site)
- In-app help text and tooltips

**Key Documentation Points**:
- Explain what Derived Owner means for SharePointFormApps
- Clarify limitations (CoE-only, not platform-level)
- Provide use cases (governance, reporting, accountability)
- Document migration path from orphaned to derived owner assignment

### Potential Risks & Considerations

#### Technical Risks
1. **Schema Upgrade Path**: Existing CoE installations will need to handle the new field
   - **Mitigation**: Use standard Dataverse field addition with null-allowed
   - **Migration**: Provide script/flow to auto-populate initial DerivedOwner values from existing owners

2. **Performance Impact**: Additional lookup field could impact query performance
   - **Risk Level**: LOW - lookup fields are standard and indexed
   - **Mitigation**: Ensure proper indexes on `admin_DerivedOwner`

3. **Data Consistency**: DerivedOwner could get out of sync
   - **Scenario**: App transferred via SharePoint permissions but DerivedOwner not updated
   - **Mitigation**: Document that DerivedOwner is administrative/governance field, not technical truth

#### User Experience Risks
1. **Confusion About Scope**: Users may expect Derived Owner to change actual ownership
   - **Mitigation**: Clear messaging in UI and documentation
   - **Example**: Use information icons, help text, and disclaimers

2. **SharePointFormApp Identification**: Users may not understand which apps are SharePointFormApps
   - **Mitigation**: Add visual indicator (icon, label, or color) in the gallery
   - **Implementation**: Check `'App Type'= 'PowerApps Type'.SharePointFormApp` and display accordingly

#### Compatibility Considerations
1. **Solution Layering**: Teams vs Core components
   - **Current**: DerivedOwner exists in Core but UI changes needed in Teams variant
   - **Decision**: Add field to Core, update both Teams and Core UI variants

2. **Backward Compatibility**: Existing installations without DerivedOwner field
   - **Approach**: Make field nullable, use `IsBlank()` checks in formulas
   - **Fallback**: Show original owner if DerivedOwner is blank

## 4. Step-by-Step Implementation Plan

### Phase 1: Data Model Changes (Core Components)

#### Step 1.1: Add DerivedOwner Field to admin_App Entity
**File**: `CenterofExcellenceCoreComponents/SolutionPackage/src/Entities/admin_App/Entity.xml`

1. Locate the attributes section in Entity.xml
2. Add new attribute definition:
```xml
<attribute PhysicalName="admin_DerivedOwner">
  <Name>admin_derivedowner</Name>
  <LogicalName>admin_derivedowner</LogicalName>
  <Type>lookup</Type>
  <displayname description="DerivedOwner" languagecode="1033" />
  <Description description="Because you cannot change the owner of a SharePointFormApp through Power Platform, this field provides a derived owner which can be assigned to someone else for CoE governance and reporting purposes. This is an administrative field and does not change actual app ownership." languagecode="1033" />
  <RequiredLevel>none</RequiredLevel>
  <ValidForAdvancedFind>1</ValidForAdvancedFind>
  <ValidForForm>1</ValidForForm>
  <ValidForGrid>1</ValidForGrid>
  <Targets>
    <target>admin_maker</target>
  </Targets>
</attribute>
```

3. Add relationship definition (N:1 to admin_Maker):
```xml
<EntityRelationship Name="admin_Maker_admin_App_DerivedOwner">
  <EntityRelationshipType>OneToMany</EntityRelationshipType>
  <IsCustomizable>1</IsCustomizable>
  <IntroducedVersion>1.0.0.0</IntroducedVersion>
  <IsHierarchical>0</IsHierarchical>
  <ReferencingEntityName>admin_App</ReferencingEntityName>
  <ReferencedEntityName>admin_Maker</ReferencedEntityName>
  <ReferencingAttributeName>admin_derivedowner</ReferencingAttributeName>
  <CascadeAssign>NoCascade</CascadeAssign>
  <CascadeDelete>RemoveLink</CascadeDelete>
  <CascadeReparent>NoCascade</CascadeReparent>
  <CascadeShare>NoCascade</CascadeShare>
  <CascadeUnshare>NoCascade</CascadeUnshare>
</EntityRelationship>
```

**Rationale**: Following the same pattern as `admin_Flow.admin_derivedowner` to maintain consistency across the CoE Starter Kit.

#### Step 1.2: Update Solution Version
**File**: `CenterofExcellenceCoreComponents/SolutionPackage/solution.xml`

1. Increment solution version to indicate schema change
2. Add to release notes: "Added DerivedOwner field to admin_App entity for SharePointFormApp ownership management"

### Phase 2: UI Updates - Set App Permissions (Teams Variant)

#### Step 2.1: Update Data Source Definition
**File**: `CenterofExcellenceCoreComponentsTeams/SolutionPackage/CanvasApps/admin_setapppermissions_37e74_DocumentUri_msapp_src/DataSources/PowerApps Apps.json`

1. Locate `NativeCDSDataSourceInfoNameMapping` section
2. Add new mapping after `admin_AppOwner`:
```json
"admin_DerivedOwner": "DerivedOwner",
```

**Rationale**: Exposes the new field to the Power Apps canvas app with a friendly name.

#### Step 2.2: Update Orphaned App Screen Filter
**File**: `CenterofExcellenceCoreComponentsTeams/SolutionPackage/CanvasApps/admin_setapppermissions_37e74_DocumentUri_msapp_src/Src/OrphanedAppScreen.fx.yaml`

1. Locate the `galApps_2.Items` property (approximately line 17-23)
2. Update the filter to include SharePointFormApps:

**OLD**:
```yaml
Items: |-
    =SortByColumns(Filter(
        Filter(
            'PowerApps Apps', 'App is Orphaned'= "yes" And 'App Type'= 'PowerApps Type'.Canvas And 'App Deleted' = 'App Deleted (PowerApps Apps)'.No
        ),
        txtSearchText_4.Text in 'App Display Name'
    ), "admin_displayname")
```

**NEW**:
```yaml
Items: |-
    =SortByColumns(Filter(
        Filter(
            'PowerApps Apps', 
            'App is Orphaned'= "yes" 
            And ('App Type'= 'PowerApps Type'.Canvas Or 'App Type'= 'PowerApps Type'.SharePointFormApp)
            And 'App Deleted' = 'App Deleted (PowerApps Apps)'.No
        ),
        txtSearchText_4.Text in 'App Display Name'
    ), "admin_displayname")
```

**Rationale**: Includes SharePointFormApps in the orphaned app list while maintaining all other filtering logic.

3. Add visual indicator for SharePointFormApps in the gallery template:
   - Add a label or icon showing when `ThisItem.'App Type' = 'PowerApps Type'.SharePointFormApp`
   - Use formula: `If(ThisItem.'App Type' = 'PowerApps Type'.SharePointFormApp, "SharePoint Form", "Canvas")`

#### Step 2.3: Update Orphaned App Screen Navigation
**File**: Same as 2.2

1. Locate `galApps_2.OnSelect` property (approximately line 26-28)
2. Update to include DerivedOwner lookup:

**OLD**:
```yaml
OnSelect: |-
    =Set(SelectedApp, galApps_2.Selected);
    Navigate(AppDetailsScreen)
```

**NEW**:
```yaml
OnSelect: |-
    =Set(SelectedApp, galApps_2.Selected);
    Set(AppDerivedOwner, LookUp('PowerApps Apps', App=SelectedApp.App).DerivedOwner.Maker);
    If(IsBlank(AppDerivedOwner), Set(AppDerivedOwner, LookUp('PowerApps Apps', App=SelectedApp.App).'App Owner'.Maker));
    Navigate(AppDetailsScreen)
```

**Rationale**: Loads the derived owner (if set) or falls back to the app owner, similar to the Flow pattern.

#### Step 2.4: Enhance App Details Screen
**File**: `CenterofExcellenceCoreComponentsTeams/SolutionPackage/CanvasApps/admin_setapppermissions_37e74_DocumentUri_msapp_src/Src/AppDetailsScreen.fx.yaml`

##### Change 2.4a: Update Permission Gallery Role Display
1. Locate the gallery that shows app permissions (look for role display)
2. Update the role text to account for DerivedOwner:

**Example Pattern** (adapt to actual gallery structure):
```powerFx
Text: ="Role: " & If(
    ThisItem.properties.principal.id=AppDerivedOwner, 
    "Owner (Derived)", 
    If(
        ThisItem.properties.roleName="Owner", 
        "Creator", 
        ThisItem.properties.roleName
    )
)
```

##### Change 2.4b: Add "Set as Derived Owner" Button
1. Add a new button control in the permission gallery or details section
2. Configure button properties:

```yaml
btnSetDerivedOwner As button:
    Text: "Set as Derived Owner"
    Visible: |-
        =// Only show for SharePointFormApps and for users who are not already the derived owner
        SelectedApp.'App Type' = 'PowerApps Type'.SharePointFormApp
        And ThisItem.properties.principal.type = "User"
        And ThisItem.properties.principal.id <> AppDerivedOwner
    OnSelect: |-
        =UpdateIf(
            'PowerApps Apps', 
            App=SelectedApp.App, 
            {DerivedOwner: LookUp(Makers, Maker=GUID(ThisItem.properties.principal.id))}
        );
        Set(AppDerivedOwner, LookUp('PowerApps Apps', App=SelectedApp.App).DerivedOwner.Maker);
        Notify("Derived owner updated successfully", NotificationType.Success)
    DisplayMode: =If(ThisItem.properties.roleName="CanView", DisplayMode.Disabled, DisplayMode.Edit)
```

**Rationale**: 
- Only shows for SharePointFormApps where derived owner can be updated
- Only shows for user principals (not groups/services)
- Updates the DerivedOwner field and refreshes the local variable

##### Change 2.4c: Add Informational Message
1. Add an HTML text or label control explaining the derived owner concept
2. Position near the derived owner controls

```yaml
lblDerivedOwnerInfo As label:
    Text: |-
        ="ℹ️ Changing SharePointFormApp ownership is not possible through Power Platform. Setting a derived owner here only affects CoE Toolkit reporting and does not change the actual app owner in Power Platform."
    Visible: =SelectedApp.'App Type' = 'PowerApps Type'.SharePointFormApp
    Color: =RGBA(47, 41, 43, 1)
    Font: =Font.'Segoe UI'
    FontWeight: =FontWeight.Semibold
    Size: =12
```

### Phase 3: Duplicate Changes for Core Variant (Optional)

**Note**: If the Core Components also have a `admin_setapppermissions` app, repeat Phase 2 steps for:
- `CenterofExcellenceCoreComponents/SolutionPackage/CanvasApps/admin_setapppermissions_*/`

### Phase 4: Testing & Validation

#### Test Case 1: Schema Upgrade
1. Install previous version of CoE Core Components
2. Upgrade to new version with DerivedOwner field
3. Verify field is created successfully
4. Verify no data loss in existing App records

#### Test Case 2: SharePointFormApp Visibility
1. Create or identify an orphaned SharePointFormApp
2. Navigate to Set App Permissions > Orphaned Apps screen
3. Verify SharePointFormApp appears in the list
4. Verify visual indicator shows it's a SharePoint Form type

#### Test Case 3: Derived Owner Assignment
1. Select an orphaned SharePointFormApp
2. Navigate to App Details screen
3. Verify permission list loads correctly
4. Click "Set as Derived Owner" for a user
5. Verify success notification
6. Verify derived owner is persisted in Dataverse

#### Test Case 4: Reporting Consistency
1. Update a SharePointFormApp's DerivedOwner
2. Run CoE Power BI reports or other dashboards
3. Verify DerivedOwner appears in reports (may require report updates)

#### Test Case 5: Backward Compatibility
1. Test app functionality with apps that have NULL DerivedOwner
2. Verify IsBlank() fallback logic works correctly
3. Verify no errors when DerivedOwner is not set

### Phase 5: Documentation

#### Internal Code Documentation
1. Add comments in formulas explaining DerivedOwner logic
2. Update CanvasApp properties with descriptions

#### User Documentation (Microsoft Learn)
1. Create new documentation page or update existing "Manage Orphaned Objects" page
2. Include:
   - What is a Derived Owner for SharePointFormApps
   - How to assign a Derived Owner
   - Limitations and scope of Derived Owner
   - Screenshots of the updated UI
   - FAQ addressing common questions

3. Update CoE Starter Kit setup guide:
   - Add DerivedOwner field to data model reference
   - Document the field in Dataverse schema section

#### In-App Help
1. Add tooltip to "Set as Derived Owner" button
2. Add help icon with popup explanation
3. Update any in-app wizards or setup guides

### Phase 6: Release & Communication

#### Release Notes
```markdown
## New Feature: Derived Owner for SharePointFormApps

The CoE Starter Kit now supports assigning a "Derived Owner" for orphaned SharePointFormApps. 
This allows administrators to designate a responsible party for governance and reporting purposes 
when the original owner has left the organization.

**Key Features:**
- New `DerivedOwner` field on the PowerApps App table
- Updated "Set App Permissions" app to support SharePointFormApps in Orphaned Apps view
- Ability to assign any app user as the Derived Owner
- Clear indication in UI that this is a CoE-specific field, not a platform ownership change

**Limitations:**
- Derived Owner is for CoE reporting only and does not change actual app ownership in Power Platform
- SharePointFormApps still appear as owned by original user in Power Platform Admin Center

**Migration:**
- Existing CoE installations will automatically add the DerivedOwner field during upgrade
- No data migration required - field will be null for existing apps until manually set
```

#### Community Communication
1. Announce in GitHub discussions
2. Update issue #10319 with implementation details
3. Blog post or video walkthrough (if appropriate)

## 5. Alternative Approaches Considered

### Alternative 1: Custom Flow-Based Solution
**Description**: Create a standalone flow that uses Dataverse APIs to update owner fields

**Pros**:
- Could be distributed independently
- Easier for users to customize

**Cons**:
- Requires separate installation and maintenance
- Doesn't integrate with existing CoE UI
- Users must remember to run the flow manually

**Decision**: NOT RECOMMENDED - Less integrated, harder to discover

### Alternative 2: PowerShell Script
**Description**: Provide a PowerShell script using Power Platform admin cmdlets

**Pros**:
- No schema changes needed
- Advanced admins prefer scripting

**Cons**:
- SharePointFormApp owner cannot be changed via PowerShell either (platform limitation)
- Would still only be a workaround, not a solution
- Doesn't help with reporting/governance
- Less accessible to non-technical admins

**Decision**: NOT RECOMMENDED - Doesn't solve the core problem

### Alternative 3: Power BI Report Only
**Description**: Add a custom column in Power BI that lets admins manually map orphaned apps to new owners

**Pros**:
- No code changes needed
- Quick to implement

**Cons**:
- Data stored outside CoE Starter Kit (hard to maintain)
- No single source of truth
- Can't be used by other components
- Poor user experience

**Decision**: NOT RECOMMENDED - Not a sustainable solution

## 6. Conclusion & Recommendation

### Recommendation: PROCEED WITH IMPLEMENTATION ✅

The enhancement is **feasible, valuable, and aligned** with existing CoE Starter Kit patterns. The implementation:

1. **Follows Established Patterns**: Uses the same DerivedOwner approach already successfully implemented for Flows
2. **Addresses Real Pain Point**: Solves a documented community problem with orphaned SharePointFormApps
3. **Low Risk**: Uses standard Dataverse capabilities with minimal schema changes
4. **High Value**: Improves governance capabilities for a specific app type that has no other solution
5. **Backward Compatible**: New field is nullable and won't break existing installations

### Success Criteria

The implementation will be considered successful when:

1. ✅ Orphaned SharePointFormApps appear in the Set App Permissions app
2. ✅ Administrators can assign a Derived Owner to SharePointFormApps
3. ✅ DerivedOwner field is stored and retrievable in Dataverse
4. ✅ UI clearly communicates the limitations (CoE-only, not platform-level)
5. ✅ Solution is backward compatible with existing CoE installations
6. ✅ Documentation clearly explains the feature and limitations

### Next Steps

1. **Create GitHub Issue** (if #10319 doesn't fully capture this): Document the implementation plan
2. **Get Stakeholder Approval**: Review with CoE Starter Kit maintainers
3. **Implement Phase 1**: Add DerivedOwner field to schema
4. **Implement Phase 2**: Update Set App Permissions UI
5. **Test Thoroughly**: Execute all test cases
6. **Document**: Update Microsoft Learn documentation
7. **Release**: Include in next CoE Starter Kit release

---

**Document Version**: 1.0  
**Date**: 2025-12-17  
**Author**: GitHub Copilot Coding Agent  
**Status**: Analysis Complete - Awaiting Implementation Approval  
**Related Issues**: Issue #10319 (Consolidated Orphaned Component Management)
