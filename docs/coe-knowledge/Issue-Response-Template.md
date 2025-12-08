# GitHub Issue Response Template

Use this template when responding to issues about flows and apps tables not populating.

---

## Template: Flows/Apps Tables Not Populating

Thank you for reporting this issue. When flows and apps tables are not populating with new records, this is typically related to the CoE inventory flow dependencies.

### Understanding the Issue

The CoE Starter Kit uses a hierarchical inventory system:

1. **Admin - Sync Template v4 (Driver)** flow runs first and populates the **Environments table**
2. Once environments are synced, **child flows** automatically trigger to collect Apps, Flows, and other resources
3. **Critical dependency**: All child flows depend on the Environments table being populated first

If the Environments table is empty or the Driver flow hasn't completed successfully, the Apps and Flows tables will not populate.

### Immediate Troubleshooting Steps

Please check the following:

1. **Driver Flow Status**
   - Navigate to Power Automate > Cloud flows
   - Search for "Admin - Sync Template v4 (Driver)"
   - Review the Run history - is it completing successfully (green checkmark)?
   - Note: This flow can take 1-4 hours to complete depending on tenant size

2. **Environments Table**
   - Open the Power Platform Admin View app or CoE Admin Command Center
   - Go to Environments table
   - Do you see environment records with recent "Modified On" timestamps?

3. **Child Flows Status**
   - In Power Automate, search for "Admin - Sync Template v4"
   - Check if these flows are turned **ON**:
     - Admin - Sync Template v4 (Apps)
     - Admin - Sync Template v4 (Flows)
   - Review their Run history - are they executing after the Driver flow completes?

4. **Connection References**
   - Go to Solutions > Center of Excellence - Core Components > Connection References
   - Verify all connections show as valid/configured

### After Upgrades (November 11th or later)

If you recently upgraded the CoE Starter Kit:
- Allow **24-48 hours** for the full inventory to complete
- Flows may need to be turned back ON after upgrade
- Check for unmanaged layers that could block updates

### Expected Timeline

For reference, here are typical completion times:

| Tenant Size | Expected Duration |
|-------------|------------------|
| Small (<100 apps) | 30-60 minutes |
| Medium (100-500 apps) | 1-2 hours |
| Large (500-2000 apps) | 2-4 hours |
| Extra Large (>2000 apps) | 4-8 hours |

### Next Steps

Could you please provide the following information to help us diagnose further:

- [ ] **Solution version**: What version of the Core Components are you running?
- [ ] **Upgrade date**: When did you upgrade to the current version (you mentioned 11/11)?
- [ ] **Driver flow status**: 
  - Is it turned ON?
  - When did it last run?
  - Did the last run complete successfully or fail?
  - How long did it take to run?
- [ ] **Environments table**: Does it contain environment records?
- [ ] **Child flows status**: 
  - Are "Admin - Sync Template v4 (Apps)" and "Admin - Sync Template v4 (Flows)" turned ON?
  - Do they show any run history?
- [ ] **Error messages**: Any specific error messages in flow run history?
- [ ] **Tenant size**: Approximately how many environments and apps do you have?

### Detailed Documentation

For comprehensive troubleshooting guidance, please see:
- [Troubleshooting Inventory Flows](Troubleshooting-Inventory-Flows.md) - Complete troubleshooting guide
- [Flow Dependencies Quick Reference](Flow-Dependencies-Quick-Reference.md) - Quick diagnostic checklist
- [Common GitHub Responses](COE-Kit-Common-GitHub-Responses.md#flows-and-apps-tables-not-populating) - Standard response library

### Additional Resources

- [Official CoE Starter Kit Documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- [Core Components Setup Guide](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components)
- [Inventory Flows Overview](https://learn.microsoft.com/power-platform/guidance/coe/core-components#inventory-flows)

---

## Template: Long-Running Flows

Thank you for reaching out. Long-running inventory flows are expected behavior in the CoE Starter Kit, especially for larger tenants.

### Why Flows Run for Extended Periods

The inventory flows process large amounts of data and include:
- API calls to multiple Power Platform services
- Pagination through results (can be hundreds of pages)
- Retry logic for transient errors
- Throttling protection to avoid API limits
- Processing data for every environment and resource

### Expected Duration

| Tenant Size | Expected Duration |
|-------------|------------------|
| Small (<100 apps) | 30-60 minutes |
| Medium (100-500 apps) | 1-2 hours |
| Large (500-2000 apps) | 2-4 hours |
| Extra Large (>2000 apps) | 4-8 hours |

### When to Be Concerned

Flows running for extended periods are **normal** unless:
- The flow has been running for more than 24 hours continuously
- The flow shows throttling errors (429 responses) repeatedly
- The flow is stuck on a specific step without progress
- Multiple runs are queued and not starting

### Monitoring Tips

To track progress:
1. Check the flow run history periodically (every 30-60 minutes)
2. Look for "Apply to each" loops showing incremental progress
3. Verify data is appearing in Dataverse tables even while flow runs
4. Review for any error messages or warnings

### Next Steps

If your flows have been running longer than expected:

Could you please provide:
- [ ] Which specific flow is running long? (Driver, Apps, Flows, etc.)
- [ ] How long has it been running?
- [ ] Approximate tenant size (number of environments, apps, flows)
- [ ] Any error messages in the run history?
- [ ] Is this the first run or a recurring run?

See also: [Common GitHub Responses - Long-Running Flows](COE-Kit-Common-GitHub-Responses.md#long-running-flows)

---

## Template: Missing Connection/Permission Issues

Thank you for reporting this issue. Connection and permission problems are common after installing or upgrading the CoE Starter Kit.

### Required Connections

The inventory flows require these connections:
- **Power Platform for Admins** - Get environments and resources
- **Dataverse** - Store inventory data
- **Office 365 Users** - Get user information
- **Office 365 Groups** (optional) - Get group ownership

### Required Permissions

The account running the flows needs:
- **Power Platform Administrator** or **Global Administrator** role
- **Full** (non-trial) Power Apps and Power Automate licenses
- Access to all environments being inventoried

### Troubleshooting Steps

1. **Check Connection References**
   - Solutions > Center of Excellence - Core Components
   - Connection References
   - Each should show "Connection set" status
   - If invalid, click to select/create new connection

2. **Verify Connection Ownership**
   - All connections should use the same admin account
   - Don't mix personal and service accounts

3. **Test Connection**
   - Try creating a new flow with each connector
   - Verify you can list environments and apps

### Next Steps

Please confirm:
- [ ] What role does the account running flows have?
- [ ] What license does the account have?
- [ ] Are all connection references showing as valid?
- [ ] Any specific error messages about connections?

---

## Quick Reference Links

### For Common Issues
- Not populating: [Troubleshooting-Inventory-Flows.md](Troubleshooting-Inventory-Flows.md)
- Dependencies: [Flow-Dependencies-Quick-Reference.md](Flow-Dependencies-Quick-Reference.md)
- Responses: [COE-Kit-Common-GitHub-Responses.md](COE-Kit-Common-GitHub-Responses.md)

### For Official Docs
- [CoE Starter Kit Overview](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- [Setup Guide](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components)
- [Troubleshooting](https://learn.microsoft.com/power-platform/guidance/coe/troubleshoot)

---

*Use these templates as starting points and customize based on the specific issue details.*
