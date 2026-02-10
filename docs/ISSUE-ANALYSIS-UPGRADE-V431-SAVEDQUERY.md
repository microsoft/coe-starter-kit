# Issue Analysis: Upgrade Failure from v4.31 - SavedQuery Dependency Error

## Summary
Users upgrading CoE Starter Kit Core Components from v4.31 (June 2024) to any later version encounter an import failure due to a missing SavedQuery (view) that is referenced by the Power Platform Admin View app but not included in the Core Components solution package.

## Issue Details

**Error Message:**
```
Solution "Center of Excellence - Core Components" failed to import: ImportAsHolding failed with exception: 
The SavedQuery(f9d327af-b6b4-e911-a85b-000d3a372932) component cannot be deleted because it is referenced by 1 other component.
```

**Affected Versions:**
- **Source versions:** v4.31 (June 2024)
- **Target versions:** All versions after v4.31 through current (v4.50.8+)
- **Affected solution:** Center of Excellence - Core Components

## Root Cause Analysis

### Technical Details

1. **Missing View Definition**
   - SavedQuery GUID: `{f9d327af-b6b4-e911-a85b-000d3a372932}`
   - View Name: "Abandoned PowerApps"
   - Description: "List of PowerApps where the owner's user account has left the company"
   - Entity: `admin_App`
   - Filter: `cr5d5_appisorphaned = yes`

2. **Current State**
   - The "Abandoned PowerApps" view **exists** in: `CenterofExcellenceCoreComponentsTeams`
   - The "Abandoned PowerApps" view **does NOT exist** in: `CenterofExcellenceCoreComponents`
   - The Power Platform Admin View app is in `CenterofExcellenceCoreComponents`
   - The field `cr5d5_appisorphaned` **exists** in Core Components' `admin_App` entity

3. **Why the Error Occurs**
   During solution upgrade from v4.31:
   - The upgrade process attempts to remove components that no longer exist in the new solution version
   - The Power Platform Admin View app (in Core Components) may have previously referenced this view
   - When the system tries to delete the old SavedQuery, it fails because it detects a reference from the app
   - Even though the view isn't explicitly in the app's AppModule.xml anymore, dependency tracking from the old version causes the conflict

### Packaging Issue Classification

This is a **solution component dependency mismatch** issue:
- The view belongs to Core Components Teams solution
- The app that conceptually uses it belongs to Core Components solution
- During upgrade scenarios, residual dependencies from v4.31 cause conflicts

## Solution Approach

### Fix Implementation

Add the "Abandoned PowerApps" SavedQuery to the Core Components solution to ensure it's available where it's needed and prevents upgrade conflicts.

**File Added:**
```
CenterofExcellenceCoreComponents/SolutionPackage/src/Entities/admin_App/SavedQueries/{f9d327af-b6b4-e911-a85b-000d3a372932}.xml
```

**Content:**
The SavedQuery definition includes:
- Standard view configuration (customizable, can be deleted)
- Layout XML showing the display name column
- FetchXML filtering apps where `cr5d5_appisorphaned = yes`
- Localized name and description in English (language code 1033)

### Why This Fix Works

1. **Eliminates Dependency Conflict**
   - By including the view in Core Components, the upgrade process no longer needs to delete it
   - The view is properly tracked as part of the solution being upgraded
   - References (explicit or residual) are satisfied

2. **Maintains Functionality**
   - The `cr5d5_appisorphaned` field already exists in Core Components
   - The view provides legitimate functionality for identifying abandoned apps
   - Admins can use this view through the Power Platform Admin View app

3. **Backward Compatible**
   - Adding a view doesn't break existing deployments
   - Upgrades from v4.31 will now succeed
   - Fresh installs include the view from the start

4. **Aligns with Intent**
   - The "Abandoned PowerApps" view is functionally similar to "Abandoned Flows" view
   - Both provide governance capabilities for identifying orphaned resources
   - Having it in Core Components makes it consistently available

## Testing Recommendations

### Upgrade Testing

1. **Test Upgrade Path from v4.31:**
   ```
   Prerequisites:
   - Environment with CoE Core Components v4.31 installed
   - Verify no unmanaged layers exist
   
   Steps:
   1. Remove all unmanaged layers using CoE Admin Command Center
   2. Import the patched Core Components solution as an Upgrade
   3. Verify import succeeds without SavedQuery errors
   4. Verify the "Abandoned PowerApps" view appears in the admin_App entity
   5. Test opening Power Platform Admin View app
   ```

2. **Test Fresh Install:**
   ```
   Prerequisites:
   - Clean environment without CoE solutions
   
   Steps:
   1. Install Core Components solution (latest version with fix)
   2. Verify installation succeeds
   3. Confirm "Abandoned PowerApps" view is available
   4. Test the view shows expected data when cr5d5_appisorphaned field is populated
   ```

3. **Test Incremental Upgrades:**
   ```
   Test paths:
   - v4.31 → v4.35 → v4.40 → v4.45 → v4.50.8
   - v4.31 → v4.50.8 (direct upgrade)
   
   Verify both paths succeed with the fix applied
   ```

### Functional Testing

1. **View Functionality:**
   - Populate `cr5d5_appisorphaned` field on test app records
   - Open "Abandoned PowerApps" view
   - Verify it displays only apps where field = "yes"
   - Verify display name column shows correctly

2. **App Module Integration:**
   - Open Power Platform Admin View app
   - Navigate to Apps entity
   - Verify "Abandoned PowerApps" view is accessible in view selector
   - Test switching between different app views

## Prevention Measures

### For Future Development

1. **Solution Component Alignment:**
   - When creating views that filter on solution-specific fields, include the view in the same solution as the field definition
   - Document which solution owns which views in the architecture documentation

2. **Dependency Tracking:**
   - Use solution dependency checker before releases
   - Validate that all referenced components (SavedQueries, Forms, etc.) exist in the solution or its dependencies
   - Test upgrade paths from previous versions, not just fresh installs

3. **View Management Guidelines:**
   - Entity-specific views should be packaged with the solution containing the entity
   - App-specific views should be packaged with the solution containing the app (or its dependencies)
   - Shared/common views should be in Core Components

4. **Upgrade Testing Protocol:**
   - Include upgrade tests from N-1, N-2, and N-3 versions in the test matrix
   - Test both direct upgrades and incremental upgrade paths
   - Monitor for dependency-related import errors

## Related Documentation

- [CoE Starter Kit Upgrade Guide](https://learn.microsoft.com/en-us/power-platform/guidance/coe/after-setup)
- [Troubleshooting Upgrades](../TROUBLESHOOTING-UPGRADES.md)
- [Solution Layering and Upgrades](https://learn.microsoft.com/en-us/power-platform/alm/solution-layers-alm)

## References

- SavedQuery GUID: `f9d327af-b6b4-e911-a85b-000d3a372932`
- Entity: `admin_App`
- Field: `cr5d5_appisorphaned`
- App: Power Platform Admin View (`admin_PowerPlatformAdminView`)
- Component Type: SavedQuery (type 26 in AppModuleComponent)

## Impact Assessment

**Severity:** High - Blocks all upgrades from v4.31

**Scope:** 
- All customers on v4.31 attempting to upgrade
- Potentially affects thousands of CoE deployments

**Workarounds (Prior to Fix):**
- None - The error completely blocks the upgrade process
- Manual database manipulation would be required (not supported)

**With Fix:**
- Upgrades proceed normally
- No customer action required beyond standard upgrade process
- Fix is transparent and automatic

## Conclusion

This issue represents a classic solution packaging dependency problem that emerged during the transition from v4.31 to later versions. The fix is straightforward: include the "Abandoned PowerApps" SavedQuery in the Core Components solution where it's functionally needed and where its dependent field exists. This resolves the upgrade blocker while maintaining all intended functionality.

The fix aligns with CoE Starter Kit packaging best practices and ensures consistent availability of governance views across both fresh installations and upgrade scenarios.
