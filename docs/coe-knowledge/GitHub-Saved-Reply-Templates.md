# Saved Reply Templates for Common CoE Starter Kit Issues

These are pre-written response templates that can be saved as GitHub Saved Replies for quick responses to common issues.

## Table of Contents
- [Apps and Flows Not Appearing in Dashboards](#apps-and-flows-not-appearing-in-dashboards)
- [Inventory Flows Not Running](#inventory-flows-not-running)
- [Power BI Connection Issues](#power-bi-connection-issues)
- [License and Pagination Issues](#license-and-pagination-issues)
- [Request for More Information](#request-for-more-information)

---

## Apps and Flows Not Appearing in Dashboards

```markdown
Hi @{username},

Thanks for raising this issue! 

Apps and flows appear in the dashboards only after the inventory flows complete a successful run and Power BI is refreshed. This is a common issue during initial setup.

### Quick Resolution Steps

**Step 1: Turn ON Required Inventory Flows**

Navigate to: `Solutions → Center of Excellence – Core Components → Cloud flows`

Make sure the following flows are turned **ON**:
- `SETUP WIZARD | Admin | Sync Template v3 (Setup)`
- `Admin | Sync Template v3`
- `Admin | Sync Apps v2`
- `Admin | Sync Flows v3`

> **Note:** These flows are OFF by default after solution import.

**Step 2: Run the Initial Inventory Manually**

1. Open `SETUP WIZARD | Admin | Sync Template v3 (Setup)`
2. Click **Run**
3. Wait for the flow to complete successfully (this may take 10-30 minutes depending on tenant size)

**Step 3: Wait for Inventory to Complete**

Initial inventory collection is not immediate:
- **Small tenants**: 30–60 minutes
- **Medium tenants**: 2–4 hours
- **Large tenants**: up to 24 hours

Please wait until `Admin | Sync Template v3` shows a successful run in the run history.

**Step 4: Verify Data in Dataverse**

1. Go to https://make.powerapps.com
2. Select the CoE environment
3. Open **Tables**
4. Confirm records exist in:
   - Power Apps App table
   - Flow table
   - Environment table

If records exist, inventory data is being collected correctly.

**Step 5: Refresh Power BI**

After confirming data exists in Dataverse:
1. Refresh the Power BI dataset
2. Ensure the report is connected to the correct CoE environment

### Additional Resources

For more detailed troubleshooting:
- **Quick Reference**: [Dashboard Issues Guide](https://github.com/microsoft/coe-starter-kit/blob/main/docs/coe-knowledge/Quick-Reference-Dashboard-Issues.md)
- **Comprehensive Guide**: [Troubleshooting Inventory and Dashboards](https://github.com/microsoft/coe-starter-kit/blob/main/docs/coe-knowledge/Troubleshooting-Inventory-and-Dashboards.md)
- **Official Documentation**: [Setup Core Components](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components)

Please let us know if you continue to experience issues after following these steps!
```

---

## Inventory Flows Not Running

```markdown
Hi @{username},

Thank you for reporting this issue. Inventory flows not running is typically caused by one of these common issues:

### Checklist to Resolve

1. **Flows are turned ON**
   - Flows are OFF by default after import
   - Navigate to the Core Components solution → Cloud flows
   - Verify flows show "On" status (not "Suspended" or "Off")

2. **Setup Wizard has been run**
   - `SETUP WIZARD | Admin | Sync Template v3 (Setup)` must run first
   - This initializes environment variables and triggers first inventory
   - Run it manually if not already done

3. **Connection References are authenticated**
   - In the Core Components solution, go to Connection References
   - Ensure all connections show "Connected" status
   - Re-authenticate any expired connections

4. **Environment Variables are set**
   - Check that all required environment variables have values
   - Key variables: `Power Automate Environment Variable`, `Admin eMail`, `TenantID`

5. **Proper permissions are assigned**
   - Service account needs Environment Admin role on all environments
   - System Administrator role in the CoE environment
   - May need Global Admin or Power Platform Admin for full tenant inventory

6. **DLP policies allow required connectors**
   - Power Platform for Admins connector
   - Dataverse connector
   - Office 365 Users connector
   - Check in Power Platform Admin Center → Data policies

### Next Steps

Please check these items and let us know:
1. Which specific flows are not running?
2. Are there any error messages in the flow run history?
3. What is the status of your connection references?

For detailed troubleshooting steps, see our [Troubleshooting Guide](https://github.com/microsoft/coe-starter-kit/blob/main/docs/coe-knowledge/Troubleshooting-Inventory-and-Dashboards.md#issue-2-inventory-collection-not-starting).
```

---

## Power BI Connection Issues

```markdown
Hi @{username},

Power BI connection issues typically occur when the dataset is not properly connected to your CoE Dataverse environment.

### Resolution Steps

**Step 1: Verify Dataset Connection**

1. In Power BI Service, navigate to your workspace
2. Find the CoE dataset
3. Click **Settings** (gear icon)
4. Expand **Data source credentials**
5. Verify the Dataverse connection URL is correct

**Step 2: Update Connection if Needed**

If the connection URL is incorrect:
1. Click **Edit credentials**
2. Update Server to your CoE environment URL
   - Format: `https://[your-org].crm.dynamics.com`
   - Get this from Power Platform Admin Center → Environment details
3. Authentication: **OAuth2**
4. Sign in with appropriate account
5. Save changes

**Step 3: Verify Permissions**

The Power BI user account needs:
- A security role in the CoE environment
- Typically System Administrator or a custom role with read access to CoE tables

Assign permissions in Power Platform Admin Center:
- Select CoE environment → Users
- Find the Power BI user
- Assign appropriate security role
- Wait 15-30 minutes for permissions to propagate

**Step 4: Refresh Dataset**

1. Back in the workspace, find the dataset
2. Click **Refresh now**
3. Check **Refresh history** for any errors

For more details, see the [Power BI Connection Issues section](https://github.com/microsoft/coe-starter-kit/blob/main/docs/coe-knowledge/Troubleshooting-Inventory-and-Dashboards.md#issue-4-power-bi-connection-issues) in our troubleshooting guide.
```

---

## License and Pagination Issues

```markdown
Hi @{username},

Based on your description, this appears to be a licensing/pagination issue. This is very common with trial or insufficient licenses.

### The Problem

Trial licenses and some standard licenses do not support API pagination, which causes:
- Inventory collection to stop after 50-100 records
- Flows to fail with pagination errors
- Incomplete data in dashboards

### Required Licenses

The service account running the flows needs **one** of these licenses:
- Power Apps per user license (premium)
- Power Automate per user license
- Office 365 E3/E5
- Dynamics 365 license

**Trial licenses are NOT sufficient** for production CoE Starter Kit deployments.

### Test for License Adequacy

Create a test flow to verify:
1. New cloud flow in CoE environment
2. Add action: **List rows** (Dataverse connector)
3. Select table: **Environments**
4. Set **Row count**: 5000
5. Run the flow

**Results:**
- ✅ **Success with all records**: License is adequate
- ❌ **Pagination error**: License is insufficient
- ❌ **Returns exactly 100 records**: Trial license limitation

### Resolution

1. Assign a proper premium license to the service account
2. Verify license in Microsoft 365 admin center
3. Wait 24-48 hours for full license propagation
4. Re-run inventory flows

For more information, see our [Licensing and Pagination section](https://github.com/microsoft/coe-starter-kit/blob/main/docs/coe-knowledge/COE-Kit-Common-GitHub-Responses.md#licensing-and-pagination).
```

---

## Request for More Information

```markdown
Hi @{username},

Thank you for raising this issue. To help us resolve it efficiently, could you please provide the following details:

### Required Information

- **Solution name and version**: Which CoE component and what version? (e.g., Core 4.50.6)
- **Specific app or flow affected**: The exact name of the flow or app having issues
- **Inventory/telemetry method**: Cloud flows or Data Export?
- **Steps to reproduce**: Detailed steps that lead to the issue
- **Error messages**: Full text or screenshots of any error messages
- **What you've tried**: What troubleshooting steps have you already attempted?

### Additional Helpful Information

- Environment details (number of environments, apps, flows)
- License types for service accounts
- When the issue started (after initial setup, after update, suddenly stopped working)
- Screenshots of flow run history or error details

This information will help us analyze the issue and suggest the most appropriate fix.

Thank you!
```

---

## How to Use These Templates

### Creating Saved Replies in GitHub

1. Click on your profile picture → Settings
2. Scroll down to **Saved replies** in the left sidebar
3. Click **Add a saved reply**
4. Give it a name (e.g., "CoE: Dashboard Issues")
5. Paste the template content
6. Save

### Using Saved Replies

1. When commenting on an issue
2. Click the **Saved replies** button in the comment editor
3. Select your saved reply
4. Customize with specific details from the issue
5. Replace `{username}` with the actual GitHub username
6. Post the comment

### Customization Tips

- Replace `{username}` with the actual user's GitHub handle
- Add specific details from their issue description
- Include links to their specific version documentation if different
- Add relevant GitHub issue links if similar issues exist
- Adjust time estimates based on their reported tenant size

---

*These templates are based on the [CoE Kit Common GitHub Responses](./COE-Kit-Common-GitHub-Responses.md) playbook.*
