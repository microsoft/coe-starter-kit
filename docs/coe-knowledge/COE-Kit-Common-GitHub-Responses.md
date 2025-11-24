# CoE Starter Kit - Common GitHub Responses

This document contains ready-to-use explanations, known limits, workarounds, and troubleshooting guidance for common issues reported in the CoE Starter Kit GitHub repository.

## Table of Contents
- [General Support Policy](#general-support-policy)
- [Security and Permissions](#security-and-permissions)
- [Environment Request Issues](#environment-request-issues)
- [Licensing and Pagination](#licensing-and-pagination)
- [BYODL (Data Lake)](#byodl-data-lake)
- [Language Support](#language-support)
- [Cleanup Flows](#cleanup-flows)
- [Setup Wizard Issues](#setup-wizard-issues)

---

## General Support Policy

### CoE Starter Kit Support Status

**Response Template:**
```
The CoE Starter Kit is provided as a **best-effort, unsupported** solution. This means:

- ✅ We accept bug reports and feature requests via GitHub Issues only
- ✅ The community and Microsoft team provide help when available
- ❌ No SLA or guaranteed response time
- ❌ Not covered by Microsoft Support contracts
- ❌ No production support guarantees

For questions about Power Platform features (not specific to CoE Starter Kit), please use:
- [Power Apps Community Forum](https://powerusers.microsoft.com/t5/Power-Apps-Community/ct-p/PowerApps1)
- [Power Platform Admin Forum](https://powerusers.microsoft.com/t5/Power-Apps-Governance-and/bd-p/Admin_PowerApps)
```

---

## Security and Permissions

### Missing Buttons or Limited Functionality in Apps

**Root Causes:**
1. Incorrect security role assignment
2. App not shared with user
3. Missing table permissions
4. Row-level security restrictions

**Response Template:**
```
It appears you're experiencing missing functionality in the CoE app, which is typically caused by security role or permission issues.

**Please verify the following:**

1. **Security Role Assignment**
   - The user must have the **Power Platform Admin SR** role (not just Maker SR)
   - Go to Power Platform Admin Center > Your CoE Environment > Settings > Users + permissions > Users
   - Click on the user > Manage Roles > Ensure "Power Platform Admin SR" is checked

2. **App Sharing**
   - The app must be shared with the user with the correct security role
   - In make.powerapps.com, find the app > Share > Add user with "Power Platform Admin SR"

3. **Table Permissions**
   - Verify Global-level access to required tables in the security role
   - Settings > Security > Security Roles > Power Platform Admin SR > Custom Entities
   - All related entities should have filled circles (Global access)

4. **Clear Cache**
   - Close all Power Apps browser tabs
   - Clear browser cache (Ctrl+Shift+Delete)
   - Reopen the app

See our [Security Roles documentation](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components#security-roles) for more details.
```

### Security Role Differences

**Maker vs Admin Roles:**
- **Power Platform Maker SR**: Basic-level privileges (can only access their own records)
- **Power Platform Admin SR**: Global-level privileges (can access all records)

---

## Environment Request Issues

### Missing "View" or "Approve Request" Options

**Issue**: Buttons don't appear in the CoE Admin Environment Request app gallery.

**Response Template:**
```
The missing "View" and "Approve Request" options are typically caused by insufficient permissions. Here's how to resolve this:

**Required Security Role:** Power Platform Admin SR (not Maker SR)

**Verification Steps:**

1. Check your assigned security role:
   - Power Platform Admin Center > Environments > [Your CoE Environment]
   - Settings > Users + permissions > Users
   - Find your user > Manage Roles
   - Ensure "Power Platform Admin SR" is assigned

2. Verify table permissions for `coe_EnvironmentCreationRequest`:
   - The Admin SR role should have Global-level access (Read, Write, Create, Delete, Assign)
   - Maker SR only has Basic-level access, which is insufficient

3. Clear your app cache:
   - Close all Power Apps tabs
   - Clear browser cache
   - Reopen the app

4. Verify app sharing:
   - The app must be shared with you with the Admin SR role

**Why this happens:**
The buttons use conditional visibility based on user permissions. If you only have Basic-level access (Maker role), the buttons won't render because you lack the required privileges to perform those actions.

For more details, see:
- [Setup Core Components - Security Roles](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components#security-roles)
- [CoE Admin Command Center Setup](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components)
```

---

## Licensing and Pagination

### Pagination Limits and License Requirements

**Issue**: API pagination limits or inventory issues with Trial/lower licenses.

**Response Template:**
```
The CoE Starter Kit requires adequate Power Platform licensing to function properly. Trial licenses or insufficient license profiles will hit pagination limits.

**License Test:**
Test your license adequacy using the Power Platform Admin connector:
- The connector must be able to paginate through all environments/resources
- Trial licenses are limited and will cause incomplete inventory

**Recommended Licenses:**
- Power Apps Per User or Per App licenses (not Trial)
- Power Automate Per User or Per Flow licenses
- Premium connector access

**Known Limitations:**
- Trial environments have strict API throttling
- Some operations require specific license types
- DLP policies may block certain connectors

See: [CoE Starter Kit Prerequisites](https://learn.microsoft.com/power-platform/guidance/coe/setup#prerequisites)
```

---

## BYODL (Data Lake)

### BYODL Status and Recommendations

**Response Template:**
```
⚠️ **BYODL (Bring Your Own Data Lake) is no longer recommended** for new implementations.

**Current Guidance:**
- Microsoft is moving towards **Microsoft Fabric** for advanced analytics
- Existing BYODL implementations will continue to work but won't receive new features
- New customers should **NOT** set up BYODL

**Alternatives:**
- Use the built-in Dataverse storage and Power BI reports included in the CoE Starter Kit
- For advanced analytics, consider Microsoft Fabric integration (coming in future releases)
- Export data to Dataverse for Apps if needed

**If you must use BYODL:**
- Only for existing implementations
- No new feature development planned
- Community support only

See: [CoE Starter Kit Roadmap](https://github.com/microsoft/coe-starter-kit/milestones)
```

---

## Language Support

### English Language Pack Requirement

**Response Template:**
```
The CoE Starter Kit **only supports English localization**. 

**Requirements:**
- The CoE environment must have the **English language pack enabled**
- User language can be different, but the environment must support English
- Some apps and flows may not work correctly without English support

**How to Enable:**
1. Power Platform Admin Center > Environments > [Your CoE Environment]
2. Settings > Resources > All legacy settings
3. Administration > Languages
4. Ensure English is enabled and provisioned

This is a known limitation and multi-language support is not currently planned.
```

---

## Cleanup Flows

### Environment and Object Cleanup

**Response Template:**
```
**Cleanup Flows in CoE Starter Kit:**

The kit includes cleanup flows for:
- Orphaned objects (apps/flows without owners)
- Deleted environments
- Stale data

**Important Notes:**
- Cleanup flows have delays to prevent accidental deletions
- Run a **full inventory** before cleanup operations
- Some cleanup requires manual approval

**How to Run Cleanup:**
1. Ensure inventory flows have run successfully
2. Review items marked for cleanup
3. Use the cleanup wizard in the Command Center
4. Approve cleanup operations when prompted

**Remove Unmanaged Layers:**
To receive solution updates properly, remove unmanaged customizations:
- Check for unmanaged layers in your solutions
- Remove customizations before importing new versions
- See [Modify Components](https://learn.microsoft.com/power-platform/guidance/coe/modify-components)

**Cleanup Flow Schedule:**
- Daily: Inventory synchronization
- Weekly: Cleanup identification
- Manual: Cleanup execution (requires approval)
```

---

## Setup Wizard Issues

### Setup Wizard Not Working or Incomplete

**Response Template:**
```
**Common Setup Wizard Issues:**

1. **Wizard doesn't proceed to next step:**
   - Verify all connections are working (green checkmarks)
   - Check that flows are enabled
   - Review flow run history for errors

2. **Missing configuration values:**
   - Ensure you've completed all prerequisite steps
   - Verify environment variables are set
   - Check that you have the correct security role

3. **Setup wizard shows errors:**
   - Review the error message carefully
   - Check the flow run history in Power Automate
   - Common causes: Missing connections, DLP policy blocks, insufficient permissions

**Setup Wizard Best Practices:**
- Complete setup in one session if possible
- Don't refresh the page during setup
- Verify each step completes before proceeding
- Keep the setup wizard browser tab open

See: [CoE Starter Kit Setup](https://learn.microsoft.com/power-platform/guidance/coe/setup)
```

---

## DLP (Data Loss Prevention) Constraints

### DLP Policy Blocking Connectors

**Response Template:**
```
**DLP Policy Conflicts:**

The CoE Starter Kit requires several connectors that must be in the same DLP group:
- Dataverse (Microsoft Dataverse)
- Office 365 Outlook
- Office 365 Users
- Power Platform for Admins
- Approvals

**Resolution:**
1. Review your environment's DLP policies
2. Create an exception for the CoE environment, OR
3. Move required connectors to the same DLP group (typically "Business")

**Testing DLP Issues:**
- Test each connector manually in a flow
- Check connection creation in the environment
- Review DLP policy settings in Power Platform Admin Center

See: [DLP Policies](https://learn.microsoft.com/power-platform/admin/wp-data-loss-prevention)
```

---

## Unsupported Features and Product Limitations

### Feature Not Available in CoE Starter Kit

**Response Template:**
```
Thank you for the feature request! 

Please note that the CoE Starter Kit has some architectural limitations:

**Known Limitations:**
- Managed solution - cannot be customized directly (create separate unmanaged solution for extensions)
- Depends on Power Platform Admin connectors (limited by connector capabilities)
- English language only
- Requires specific licensing

**For Feature Requests:**
- Check [open Milestones](https://github.com/microsoft/coe-starter-kit/milestones) for planned features
- Upvote existing issues using 👍 reactions
- Provide clear use cases and business justification

**Product Limitations (outside CoE Starter Kit control):**
Some features may require changes to the Power Platform itself. For product feedback:
- [Power Platform Ideas Forum](https://ideas.powerapps.com/)
- [Power Automate Ideas Forum](https://ideas.powerautomate.com/)

**Custom Development:**
For organization-specific needs, consider:
- Extending the CoE Starter Kit in a separate solution
- Custom PowerShell scripts
- Power Platform CLI tools

See: [Modify Components](https://learn.microsoft.com/power-platform/guidance/coe/modify-components)
```

---

## Migration and Upgrade Issues

### Upgrading from Previous Versions

**Response Template:**
```
**Upgrade Best Practices:**

1. **Before Upgrade:**
   - Review [upgrade documentation](https://learn.microsoft.com/power-platform/guidance/coe/after-setup)
   - Note your customizations (these may be overwritten)
   - Backup environment variables and configuration

2. **During Upgrade:**
   - Import solutions in the correct order (Core → Governance → Nurture → Audit)
   - Wait for each import to complete
   - Don't enable flows until all solutions are imported

3. **After Upgrade:**
   - Verify environment variables
   - Re-enable flows
   - Reassign security roles if needed
   - Clear app cache for all users

4. **Common Upgrade Issues:**
   - Unmanaged layers prevent updates → Remove customizations
   - Missing dependencies → Import solutions in correct order
   - Changed connections → Update connection references

**Version-Specific Notes:**
Always check the release notes for version-specific upgrade instructions.
```

---

## How to Use This Document

When responding to GitHub issues:

1. **Identify the issue category** from the table of contents
2. **Copy the relevant response template**
3. **Customize** with specific details from the user's issue
4. **Add links** to related issues or documentation
5. **Be empathetic** - remember users may be frustrated

**Response Tone:**
- Professional and helpful
- Acknowledge the issue
- Provide clear, actionable steps
- Link to documentation
- Encourage community participation

**When to Escalate:**
- Security vulnerabilities → MSRC
- Product bugs (not CoE Kit) → Microsoft Support or Ideas Forum
- Urgent production issues → Remind user of unsupported status, provide workarounds

---

## Additional Resources

- [CoE Starter Kit Documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- [Setup Guide](https://learn.microsoft.com/power-platform/guidance/coe/setup)
- [FAQ](https://learn.microsoft.com/power-platform/guidance/coe/faq)
- [Known Limitations](https://learn.microsoft.com/power-platform/guidance/coe/limitations)
- [GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues)
- [Milestones](https://github.com/microsoft/coe-starter-kit/milestones)

---

*Last Updated: November 2025*
*Document Maintainers: CoE Starter Kit Team*
