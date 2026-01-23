# Issue Response: Missing CoE Viewer and CoE Maker Viewer Roles

## Summary

The security roles "CoE Viewer" and "CoE Maker Viewer" **do not exist** in the CoE Starter Kit Core Components solution. These role names appear to be from outdated or incorrect documentation.

## The Actual Security Roles

The CoE Starter Kit Core Components includes **three security roles** with these names:

1. **Power Platform Admin SR** - For CoE administrators
2. **Power Platform Maker SR** - For Power Platform makers
3. **Power Platform User SR** - For end users

These have been the official role names since **at least April 2023** (over 2 years).

## Root Cause Analysis

Based on repository analysis:
- ✅ The Roles directory has existed since April 2023
- ✅ The role names have been consistent: "Power Platform Admin SR", "Power Platform Maker SR", "Power Platform User SR"
- ❌ No evidence of "CoE Viewer" or "CoE Maker Viewer" ever existing in the Core Components solution
- ❌ No git history showing these names were ever used

**Hypothesis**: The user encountered outdated documentation (possibly from third-party sources, very old blog posts, or documentation that predates April 2023 or refers to custom implementations).

## How to Grant Users Access to CoE Apps

To share CoE apps with users, follow these steps:

### Step 1: Assign the Appropriate Security Role

1. Navigate to [Power Platform admin center](https://admin.powerplatform.microsoft.com/)
2. Select **Environments** → Choose your CoE environment
3. Select **Settings** → **Users + permissions** → **Users**
4. Select the user → **Manage security roles**
5. Assign one of:
   - **Power Platform Admin SR** - For CoE administrators who need full access
   - **Power Platform Maker SR** - For makers who need to view resources and submit requests
   - **Power Platform User SR** - For users who only need App Catalog access (read-only)

### Step 2: Share the Canvas App

1. Go to [Power Apps](https://make.powerapps.com/) → Select your CoE environment
2. Select **Apps**
3. Find the CoE app (e.g., "CoE Admin Command Center" or "CoE Maker Command Center")
4. Select the app → **Share**
5. Add users or security groups

**Important**: Users need BOTH the security role (for data access) AND app sharing (to open the app).

## Role Purpose and Mapping

| If the user needs... | Assign this role |
|---|---|
| Full CoE administration access | **Power Platform Admin SR** |
| Ability to view their apps/flows and submit requests | **Power Platform Maker SR** |
| Read-only access to browse the App Catalog | **Power Platform User SR** |

## Why the Roles Weren't Found After Re-Import

The roles **were imported successfully**. The issue is that you were looking for the wrong role names.

To verify the roles exist in your environment:
1. Power Platform admin center → Your CoE Environment
2. Settings → Users + permissions → **Security roles**
3. Look for roles starting with "Power Platform" (not "CoE Viewer")

## Documentation Created

I've created comprehensive documentation to prevent this confusion for other users:

1. **[FAQ: Security Roles](../CenterofExcellenceResources/FAQ-SecurityRoles.md)**
   - Complete guide explaining all three security roles
   - Step-by-step instructions for granting access
   - Common questions and troubleshooting
   - Clarifies that "CoE Viewer" doesn't exist

2. **[Security Roles Quick Reference](../Documentation/SECURITY-ROLES-QUICK-REFERENCE.md)**
   - One-page quick reference
   - Quick setup steps
   - Common issues addressed

3. **Updated Core Components README**
   - Added link to security roles documentation
   - Makes it easier to find this information

## Next Steps for the User

1. Stop looking for "CoE Viewer" and "CoE Maker Viewer" - they don't exist
2. Look for "Power Platform Admin SR", "Power Platform Maker SR", and "Power Platform User SR" in your security roles
3. These roles were imported when you installed Core Components
4. Assign these roles to users as described above
5. Share the Canvas apps with users
6. Refer to the new FAQ documentation for detailed guidance

## References

- Microsoft official docs: https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components
- GitHub repo role files: `CenterofExcellenceCoreComponents/SolutionPackage/src/Roles/`
- Security role analysis: Roles have used current names since April 2023 release

---

**Resolution**: Documentation created to clarify the correct security role names and how to use them. The roles exist in the solution with different names than the user expected.
