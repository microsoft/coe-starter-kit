# CoE Kit Common GitHub Responses

This document contains ready-to-use explanations, limitations, workarounds, and guidance for common issues and questions in the CoE Starter Kit.

## Table of Contents
- [General Support and Limitations](#general-support-and-limitations)
- [Environment Variables and Managed Solutions](#environment-variables-and-managed-solutions)
- [Audit Logs Configuration](#audit-logs-configuration)
- [BYODL (Bring Your Own Data Lake)](#byodl-bring-your-own-data-lake)
- [Pagination and Licensing](#pagination-and-licensing)
- [Language and Localization](#language-and-localization)
- [Inventory and Cleanup Flows](#inventory-and-cleanup-flows)
- [Setup Wizard Guidance](#setup-wizard-guidance)

---

## General Support and Limitations

### CoE Starter Kit Support Status

The CoE Starter Kit is provided as a **best-effort, community-supported solution** and is **not officially supported** by Microsoft Product Support.

**Response Template:**
```
The CoE Starter Kit is provided as a best-effort solution and is not officially supported by Microsoft Product Support. 

For issues and questions:
- Search existing [GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues)
- Review the [official documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- Create a new issue if your problem hasn't been reported
- Engage with the community for assistance

There is no SLA for issue resolution. The community and maintainers provide support on a best-effort basis.
```

### Product vs. CoE Kit Issues

When determining if an issue is with the CoE Starter Kit or the Power Platform product:

**Response Template:**
```
To determine if this is a CoE Starter Kit issue or a Power Platform product issue:

**CoE Kit Issue** - Involves CoE-specific flows, apps, or components
- Create a GitHub issue here
- Include CoE solution version and affected component

**Power Platform Product Issue** - Core platform functionality not working as expected
- Contact Microsoft Product Support through your organization's support channel
- Post in [Power Apps Community Forums](https://powerusers.microsoft.com/t5/Power-Apps-Community/ct-p/PowerApps1)

If unsure, you can create an issue here and we'll help determine the appropriate channel.
```

---

## Environment Variables and Managed Solutions

### Environment Variables Cannot Be Edited in Managed Solutions

**Common Issue:** Users report that environment variable "Current Value" fields are locked/read-only after installing a managed solution.

**Root Cause:** In managed solutions, environment variables that were not initialized during solution import become read-only.

**Response Template:**
```
In a managed CoE Starter Kit installation, environment variable values must be provided during solution import or configured through the CoE Setup & Upgrade Wizard.

**Why are environment variables read-only?**
This is expected behavior for managed solutions. If values were not provided during the initial import, they become locked and cannot be edited directly.

**How to configure environment variables:**

1. **Use the CoE Setup & Upgrade Wizard (Recommended)**
   - Open the CoE Setup & Upgrade Wizard from within the Core Components solution
   - Navigate to the appropriate configuration section (e.g., Inventory, Audit Logs)
   - Provide the required values when prompted
   - The wizard will properly configure the environment variables

2. **Re-import the solution (if wizard doesn't work)**
   - Remove the managed solution (only if no dependencies exist)
   - Download the latest version from [GitHub Releases](https://github.com/microsoft/coe-starter-kit/releases)
   - During import, provide environment variable values on the "Connection references and environment variables" screen
   - This is your only opportunity to set these values for a managed solution

**Important:** Do not attempt to directly edit environment variables in managed solutions through the Solutions UI - changes will not be saved.

See: [Environment Variables in Managed Solutions Documentation](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components#configure-environment-variables)
```

---

## Audit Logs Configuration

### Office 365 Management API Subscription Flow Fails

**Common Error:** `Action 'Get_Azure_Secret' failed. Error occurred while reading secret: Value cannot be null. Parameter name: input`

**Response Template:**
```
This error indicates that the Office 365 Management API client secret is not configured. The flow requires specific environment variables to authenticate with the Office 365 Management API.

**Required Environment Variables:**
- `admin_auditlogsclientid` - Azure AD Application (Client) ID
- `admin_auditlogsclientsecret` - Client Secret VALUE (plain text) OR
- `admin_auditlogsclientazuresecret` - Azure Key Vault secret reference
- `admin_TenantID` - Azure Directory (Tenant) ID

**Prerequisites:**
1. Create an Azure AD App Registration
2. Grant `ActivityFeed.Read` permission for Office 365 Management APIs
3. Create a Client Secret
4. Have the Client ID, Secret VALUE, and Tenant ID ready

**Resolution:**
1. Use the CoE Setup & Upgrade Wizard to configure Audit Logs settings
2. In the wizard, navigate to Inventory / Audit Logs configuration
3. Provide:
   - Client ID
   - Client Secret VALUE (not the secret name or ID)
   - Tenant ID
4. Save and complete the wizard
5. Run the `Admin | Audit Logs | Office 365 Management API Subscription` flow

**Important:** 
- Enter the actual client secret VALUE, not the secret name or secret ID
- If environment variables are read-only, you must use the Setup Wizard or re-import the solution

Detailed troubleshooting: [docs/coe-knowledge/TROUBLESHOOT-AuditLogs-Office365ManagementAPI.md](./TROUBLESHOOT-AuditLogs-Office365ManagementAPI.md)
```

### Audit Logs Not Collecting Data

**Response Template:**
```
If audit logs are not collecting data after configuring the subscription flow:

**Verify Prerequisites:**
1. Office 365 Management API subscription is active (run flow with operation: `list`)
2. Azure AD app has correct permissions: `ActivityFeed.Read`
3. Admin consent granted for the permissions
4. Audit logging is enabled in Microsoft 365 (requires E3/E5 license)

**Check Flow Status:**
1. Verify `Admin | Audit Logs | Office 365 Management API Subscription` completed successfully
2. Check `Admin | Audit Logs | Sync Audit Logs V2` flow runs
3. Review flow run history for errors

**Common Issues:**
- **Delay in data availability**: Audit logs can take 12-24 hours to appear after subscription
- **Licensing**: Audit log retention requires Microsoft 365 E3 or E5 license
- **Permissions**: Ensure the service principal has Global Administrator or appropriate audit log permissions

**Data Retention:**
- By default, audit logs are retained for 90 days in Microsoft 365
- The CoE Kit stores processed audit log data in Dataverse

See: [Configure Audit Log Connector](https://learn.microsoft.com/power-platform/guidance/coe/setup-auditlog)
```

---

## BYODL (Bring Your Own Data Lake)

### BYODL Status and Recommendations

**Response Template:**
```
**IMPORTANT: BYODL (Bring Your Own Data Lake) is no longer recommended.**

**Current Status:**
- BYODL export functionality is deprecated
- No new features or improvements are planned for BYODL
- Existing BYODL implementations may continue to work but are not supported

**Recommended Alternative:**
- **Microsoft Fabric** is the recommended direction for data export and analytics
- Fabric provides enhanced capabilities for data storage, processing, and analysis
- Microsoft is investing in Fabric as the future data platform

**If You're Using BYODL:**
- Existing implementations can continue but expect no updates
- Plan migration to Microsoft Fabric for long-term support
- Reach out to your Microsoft account team for Fabric migration guidance

**For New Implementations:**
- Do not set up new BYODL exports
- Use Microsoft Fabric for data lake scenarios
- Consider native Dataverse analytics capabilities for basic reporting needs

See: [Data Export Options](https://learn.microsoft.com/power-platform/guidance/coe/setup-dataexport)
```

---

## Pagination and Licensing

### Pagination Limits and License Requirements

**Common Issue:** Flows fail with pagination errors or only retrieve partial data (e.g., 5,000 records).

**Response Template:**
```
Pagination limits in the CoE Starter Kit flows depend on the license assigned to the connection owner.

**License Requirements:**
- **Trial licenses** or **insufficient license profiles** will hit pagination limits at 5,000 records
- **Per-user plan** or **per-app plan** licenses are required for full pagination support
- The connector user needs appropriate licenses, not just the flow owner

**How to Verify Your License:**
Test your connector's pagination capability:
1. Use Power Automate connector for Dataverse
2. Attempt to list entities with pagination
3. If limited to 5,000 records, you have insufficient licensing

**Resolution:**
1. Assign a Power Apps per-user or per-app license to the connection owner
2. Recreate connections with the properly licensed account
3. Update flow connection references to use the new connections
4. Re-run inventory flows

**Note:** The CoE Starter Kit requires appropriate licensing for full functionality. Trial licenses are not recommended for production use.

See: [License Requirements](https://learn.microsoft.com/power-platform/guidance/coe/setup#what-identity-should-i-use-for-the-service-account)
```

---

## Language and Localization

### Language Pack Requirements

**Response Template:**
```
The CoE Starter Kit supports **English only** and requires the English language pack to be enabled in your Power Platform environment.

**Requirements:**
- Environment must have English language pack installed and enabled
- Canvas apps, flows, and model-driven apps are designed for English language
- Localization to other languages is not officially supported

**If You Need Multi-Language Support:**
- You can fork the repository and create your own localized version
- Community contributions for translations are welcome
- Be aware that maintenance of localized versions requires ongoing effort

**Setup:**
1. In Power Platform Admin Center, select your environment
2. Go to Settings → Product → Languages
3. Ensure English is enabled
4. Install the CoE Starter Kit

**Known Issue:** Installing in a non-English environment may cause:
- UI display issues in apps
- Flow failures due to language-specific formatting
- Data validation errors

See: [Language Requirements](https://learn.microsoft.com/power-platform/guidance/coe/setup#before-you-start)
```

---

## Inventory and Cleanup Flows

### Running Full Inventory

**Response Template:**
```
To run a full inventory in the CoE Starter Kit:

**Using Driver Flows:**
1. Turn on `Admin | Sync Template v4 (Driver)` flow
2. The driver flow will orchestrate child flows to collect inventory
3. Allow 2-4 hours for initial inventory to complete (depends on tenant size)

**Components Collected:**
- Power Apps (Canvas and Model-driven)
- Power Automate Flows
- Custom Connectors  
- Power BI Reports (if configured)
- Environments
- Makers (users who have created apps/flows)

**Expected Delays:**
- Initial run: 2-4 hours for medium-sized tenants (1,000+ apps)
- Subsequent runs: 30 minutes to 2 hours (incremental updates)
- API throttling may cause longer run times

**Troubleshooting:**
- Check flow run history for errors
- Verify connection permissions (admin role required)
- Ensure pagination licensing is correct
- Review individual child flow runs for specific failures

**Best Practice:**
- Schedule inventory to run daily during off-peak hours
- Monitor first few runs to ensure completion
- Check Dataverse for populated data after completion

See: [Inventory Setup](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components#set-up-inventory-components)
```

### Cleanup Flows and Archival

**Response Template:**
```
The CoE Starter Kit includes cleanup flows to archive and optionally delete inactive apps and flows:

**Cleanup Components:**
- `Admin | App and Flow Archive and Clean Up - Start Approval for Apps`
- `Admin | App and Flow Archive and Clean Up - Start Approval for Flows`
- Cleanup flows identify apps/flows inactive for specified period (e.g., 180 days)

**Process:**
1. Cleanup flow identifies inactive resources
2. Sends approval request to resource owner
3. If approved (or auto-approved after timeout):
   - Resource is turned off
   - Metadata is archived
   - Optionally deleted based on configuration

**Important Considerations:**
- **Backup first**: Archive doesn't create exportable backups
- **Dependencies**: Consider dependencies before deletion
- **Testing**: Test cleanup process in non-production environment first
- **Notifications**: Ensure owners receive and understand approval requests

**Configuration:**
- Set inactivity threshold (default: 180 days)
- Configure auto-approval timeout
- Choose whether to delete or only disable

**Receiving Updates:**
To receive updates after cleanup, you must remove unmanaged layers:
- Cleanup flows may be customized by users
- Custom changes create unmanaged layers
- Unmanaged layers prevent managed solution updates
- Use solution segmentation or remove customizations to receive updates

See: [Cleanup Documentation](https://learn.microsoft.com/power-platform/guidance/coe/setup-archive-components)
```

---

## Setup Wizard Guidance

### Using the CoE Setup & Upgrade Wizard

**Response Template:**
```
The CoE Setup & Upgrade Wizard is the recommended method for configuring the CoE Starter Kit.

**Where to Find It:**
1. Go to [Power Apps](https://make.powerapps.com)
2. Select your CoE environment
3. Go to Solutions → Center of Excellence – Core Components
4. Launch the **CoE Setup & Upgrade Wizard** (model-driven app)

**What the Wizard Configures:**
- Environment variables for all CoE components
- Connection references
- Inventory settings
- Audit log settings
- Compliance and governance features
- Nurture components (if installed)

**Wizard Sections:**
1. **Welcome** - Overview and prerequisites
2. **Inventory** - Configure inventory data collection
3. **Audit Logs** - Set up Office 365 Management API
4. **Compliance** - Configure compliance workflows
5. **Nurture** - Set up maker engagement features
6. **Summary** - Review and complete setup

**Best Practices:**
- Run the wizard after initial solution import
- Re-run after upgrading to new versions
- Have all required values ready before starting:
  - Azure AD App Registration details
  - Service account information
  - Azure Key Vault details (if using)
  - Admin email addresses
- Complete all sections for full functionality

**Common Issues:**
- Wizard doesn't save values → Ensure you have appropriate permissions
- Can't find the wizard → Check that Core Components solution is imported
- Values not persisting → For managed solutions, use the wizard (not direct env var edit)

See: [Setup Wizard Documentation](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components#use-the-setup-wizard)
```

### Upgrading CoE Starter Kit

**Response Template:**
```
To upgrade the CoE Starter Kit to a new version:

**Before You Upgrade:**
1. Review [release notes](https://github.com/microsoft/coe-starter-kit/releases) for breaking changes
2. Back up your environment (export solutions if possible)
3. Document any customizations you've made
4. Note current environment variable values

**Upgrade Process:**
1. Download the latest version from [GitHub Releases](https://github.com/microsoft/coe-starter-kit/releases)
2. Go to [Power Apps](https://make.powerapps.com) → Your CoE environment
3. Go to Solutions → Import solution
4. Select **Upgrade** (not Replace) for each component
5. Re-run the CoE Setup & Upgrade Wizard after import

**Components to Upgrade (in order):**
1. Core Components
2. Governance Components (if installed)
3. Nurture Components (if installed)
4. Audit Components (if installed)
5. Innovation Backlog (if installed)

**After Upgrade:**
- Run Setup Wizard to reconfigure settings
- Turn on new flows that may have been added
- Check flow run history for errors
- Review new features and documentation

**Troubleshooting:**
- Upgrade fails → Check for solution dependencies
- Flows don't work → Re-run Setup Wizard
- Missing features → Verify all solution components imported successfully
- Customizations lost → Customizations may be overwritten; use unmanaged layers carefully

**Unmanaged Customizations:**
If you've customized flows or apps, unmanaged layers may block updates. Options:
- Remove customizations before upgrade
- Export customizations, upgrade, then reapply
- Maintain separate customization layer

See: [Upgrade Documentation](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components#upgrade-the-coe-starter-kit)
```

---

## Quick Reference: Common Commands and Links

### Essential Links
- **Documentation**: https://learn.microsoft.com/power-platform/guidance/coe/starter-kit
- **GitHub Releases**: https://github.com/microsoft/coe-starter-kit/releases
- **GitHub Issues**: https://github.com/microsoft/coe-starter-kit/issues
- **Community Forums**: https://powerusers.microsoft.com/t5/Power-Apps-Governance-and/bd-p/Admin_PowerApps

### Common Environment Variables

| Variable | Component | Description |
|----------|-----------|-------------|
| `admin_auditlogsclientid` | Audit Logs | Azure AD App Client ID |
| `admin_auditlogsclientsecret` | Audit Logs | Client Secret (plain text) |
| `admin_auditlogsclientazuresecret` | Audit Logs | Azure Key Vault secret reference |
| `admin_TenantID` | Core | Azure Directory Tenant ID |
| `admin_PowerAutomateEnvironmentVariable` | Core | Power Automate environment URL |

### Troubleshooting Checklist

When investigating an issue, gather:
- [ ] CoE Starter Kit version
- [ ] Affected component (Core, Governance, Nurture, etc.)
- [ ] Specific app or flow name
- [ ] Error message (full text)
- [ ] Flow run history details
- [ ] Screenshots of error
- [ ] Steps to reproduce
- [ ] Environment configuration (managed/unmanaged solution)

---

## Contributing to This Document

This document is a living resource. When you encounter common questions or patterns:
1. Add the response template here
2. Reference this document when responding to issues
3. Keep responses concise and actionable
4. Include links to official documentation
5. Update as new patterns emerge

Last Updated: 2026-01-07
