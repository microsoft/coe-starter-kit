# Security Role Assignment Changes

## Summary of Changes

This document details the changes made to fix the issue where Power Platform User SR and Maker SR security roles were not visible when sharing CoE Starter Kit apps.

## Problem

Users could not see the **Power Platform User SR** or **Power Platform Maker SR** roles when attempting to share model-driven apps in the CoE Starter Kit. Only high-privilege roles (System Administrator, System Customizer, Power Platform Admin SR) were visible in the sharing dialog.

## Root Cause

Model-driven apps in Power Platform only display security roles in the sharing dialog if those roles are explicitly assigned to the app module. The Power Platform User SR and Maker SR roles existed in the solution with proper privileges but were not assigned to the app modules.

## Solution

Added the missing security role IDs to the AppModuleRoleMaps section of affected app modules:

- **Power Platform Admin SR**: `{1d04a95b-cc80-e911-a82e-000d3a11eb35}` ✓ (already assigned)
- **Power Platform Maker SR**: `{3e6126b5-2589-e911-a856-000d3a372932}` ✓ (added where missing)
- **Power Platform User SR**: `{0173e729-2b89-e911-a856-000d3a372932}` ✓ (added to all)

## Apps Modified

### 1. Power Platform Admin View (admin_PowerPlatformAdminView)

**Before:**
```xml
<AppModuleRoleMaps>
  <Role id="{1d04a95b-cc80-e911-a82e-000d3a11eb35}" /> <!-- Admin SR -->
  <Role id="{627090ff-40a3-4053-8790-584edc5be201}" /> <!-- System Administrator -->
  <Role id="{119f245c-3cc8-4b62-b31c-d1a046ced15d}" /> <!-- System Customizer -->
</AppModuleRoleMaps>
```

**After:**
```xml
<AppModuleRoleMaps>
  <Role id="{1d04a95b-cc80-e911-a82e-000d3a11eb35}" /> <!-- Admin SR -->
  <Role id="{3e6126b5-2589-e911-a856-000d3a372932}" /> <!-- Maker SR ✓ ADDED -->
  <Role id="{0173e729-2b89-e911-a856-000d3a372932}" /> <!-- User SR ✓ ADDED -->
  <Role id="{627090ff-40a3-4053-8790-584edc5be201}" /> <!-- System Administrator -->
  <Role id="{119f245c-3cc8-4b62-b31c-d1a046ced15d}" /> <!-- System Customizer -->
</AppModuleRoleMaps>
```

### 2. CoE Admin Command Center (admin_CoEAdminCommandCenter)

**Before:**
```xml
<AppModuleRoleMaps>
  <Role id="{1d04a95b-cc80-e911-a82e-000d3a11eb35}" /> <!-- Admin SR -->
  <Role id="{3e6126b5-2589-e911-a856-000d3a372932}" /> <!-- Maker SR -->
  <Role id="{627090ff-40a3-4053-8790-584edc5be201}" /> <!-- System Administrator -->
  <Role id="{119f245c-3cc8-4b62-b31c-d1a046ced15d}" /> <!-- System Customizer -->
</AppModuleRoleMaps>
```

**After:**
```xml
<AppModuleRoleMaps>
  <Role id="{1d04a95b-cc80-e911-a82e-000d3a11eb35}" /> <!-- Admin SR -->
  <Role id="{3e6126b5-2589-e911-a856-000d3a372932}" /> <!-- Maker SR -->
  <Role id="{0173e729-2b89-e911-a856-000d3a372932}" /> <!-- User SR ✓ ADDED -->
  <Role id="{627090ff-40a3-4053-8790-584edc5be201}" /> <!-- System Administrator -->
  <Role id="{119f245c-3cc8-4b62-b31c-d1a046ced15d}" /> <!-- System Customizer -->
</AppModuleRoleMaps>
```

### 3. CoE Maker Command Center (admin_CoEMakerCommandCenter)

**Before:**
```xml
<AppModuleRoleMaps>
  <Role id="{1d04a95b-cc80-e911-a82e-000d3a11eb35}" /> <!-- Admin SR -->
  <Role id="{3e6126b5-2589-e911-a856-000d3a372932}" /> <!-- Maker SR -->
  <Role id="{627090ff-40a3-4053-8790-584edc5be201}" /> <!-- System Administrator -->
  <Role id="{119f245c-3cc8-4b62-b31c-d1a046ced15d}" /> <!-- System Customizer -->
</AppModuleRoleMaps>
```

**After:**
```xml
<AppModuleRoleMaps>
  <Role id="{1d04a95b-cc80-e911-a82e-000d3a11eb35}" /> <!-- Admin SR -->
  <Role id="{3e6126b5-2589-e911-a856-000d3a372932}" /> <!-- Maker SR -->
  <Role id="{0173e729-2b89-e911-a856-000d3a372932}" /> <!-- User SR ✓ ADDED -->
  <Role id="{627090ff-40a3-4053-8790-584edc5be201}" /> <!-- System Administrator -->
  <Role id="{119f245c-3cc8-4b62-b31c-d1a046ced15d}" /> <!-- System Customizer -->
</AppModuleRoleMaps>
```

## Files Changed

### AppModule XML Files (Unmanaged)
- `CenterofExcellenceCoreComponents/SolutionPackage/src/AppModules/admin_PowerPlatformAdminView/AppModule.xml`
- `CenterofExcellenceCoreComponents/SolutionPackage/src/AppModules/admin_CoEAdminCommandCenter/AppModule.xml`
- `CenterofExcellenceCoreComponents/SolutionPackage/src/AppModules/admin_CoEMakerCommandCenter/AppModule.xml`

### AppModule XML Files (Managed)
- `CenterofExcellenceCoreComponents/SolutionPackage/src/AppModules/admin_PowerPlatformAdminView/AppModule_managed.xml`
- `CenterofExcellenceCoreComponents/SolutionPackage/src/AppModules/admin_CoEAdminCommandCenter/AppModule_managed.xml`
- `CenterofExcellenceCoreComponents/SolutionPackage/src/AppModules/admin_CoEMakerCommandCenter/AppModule_managed.xml`

### New Documentation
- `docs/README.md` - Documentation directory index
- `docs/security-roles.md` - Comprehensive guide to security roles and app access

## Impact

### Positive Impact
- Users can now grant view-only access using the Power Platform User SR role
- Users can grant maker/contributor access using the Power Platform Maker SR role
- Improved alignment with principle of least privilege
- Better security model for CoE Starter Kit deployments

### No Breaking Changes
- Existing role assignments remain unchanged
- No impact on current users or permissions
- Backward compatible with existing installations
- Adding roles to app modules is a non-breaking change

## Testing Recommendations

1. **Upgrade Test**
   - Install or upgrade to the updated solution
   - Verify all three security roles appear in app sharing dialogs
   - Confirm existing permissions are not affected

2. **Permission Test**
   - Assign Power Platform User SR to a test user
   - Share Power Platform Admin View with that user
   - Verify user can view data but cannot modify/delete

3. **Maker Test**
   - Assign Power Platform Maker SR to a test user
   - Share apps with that user
   - Verify appropriate create/edit permissions

## Security Role Privileges Summary

### Power Platform User SR (View-Only)
- **Read**: Global read access to all CoE custom tables
- **Write**: Limited to notes and feedback only
- **Create/Delete**: Very limited, notes only
- **Ideal for**: Executives, stakeholders, auditors

### Power Platform Maker SR (Contributor)
- **Read**: Global read access to all CoE tables
- **Write**: Can submit requests and update own records
- **Create**: Can create approval requests and feedback
- **Ideal for**: Makers, app creators, flow developers

### Power Platform Admin SR (Full Access)
- **Read/Write/Create/Delete**: Full access to all CoE tables
- **Configure**: Can modify environment variables and settings
- **Ideal for**: CoE administrators, platform admins

## References

- Issue: "How to Grant View Access to Power Platform CoE Toolkit Model driven apps"
- [Security Roles Documentation](./security-roles.md)
- [CoE Starter Kit Official Docs](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
