# CoE Starter Kit - Frequently Asked Questions

This document provides quick answers to common questions and issues with the CoE Starter Kit.

## Table of Contents

- [Inventory and Data Sync](#inventory-and-data-sync)
- [Admin View Issues](#admin-view-issues)
- [Setup and Configuration](#setup-and-configuration)
- [Permissions and Licensing](#permissions-and-licensing)

## Inventory and Data Sync

### Q: My Admin View is not showing all my apps/flows/environments. What's wrong?

**A:** This is typically an inventory synchronization issue. The CoE Starter Kit uses scheduled flows to collect inventory data from your tenant.

**Quick Fix:**
1. Verify the **Admin | Sync Template v4 (Driver)** flow is running
2. Set `FullInventory` environment variable to `Yes`
3. Manually trigger the Driver flow
4. Wait for completion (can take hours for large tenants)
5. Check Admin View for updated data

See [detailed troubleshooting guide](TROUBLESHOOTING-INVENTORY-SYNC.md) for step-by-step instructions.

---

### Q: My data is showing as "None" for inventory method. Is this correct?

**A:** No, "None" means inventory is not configured or running.

**Action Required:**
You must configure and run the inventory sync flows for the CoE Starter Kit to function. The inventory flows collect data about apps, flows, environments, and other resources in your tenant.

Follow the [Setup Core Components](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components) documentation to configure inventory properly.

---

### Q: How often does the inventory sync run?

**A:** By default, the **Admin | Sync Template v4 (Driver)** flow runs on a schedule (typically daily). However:
- Initial setup requires a **Full Inventory** run (can take hours)
- Ongoing syncs use incremental mode (only changed items)
- You can manually trigger anytime

---

### Q: What's the difference between Full Inventory and Incremental Sync?

**A:** 

| Mode | When to Use | Duration | Environment Variable |
|------|-------------|----------|---------------------|
| **Full Inventory** | Initial setup, missing data, quarterly refresh | Hours (2-8+ hours) | `FullInventory = Yes` |
| **Incremental Sync** | Daily operations | Minutes to 1-2 hours | `FullInventory = No` |

**Best Practice:**
- Run Full Inventory when first setting up or when data is missing
- Use Incremental Sync for daily operations
- Run Full Inventory quarterly to catch any missed items

---

### Q: My inventory stopped updating after an upgrade. What should I do?

**A:** After upgrading the CoE Starter Kit:

1. **Check Connection References:** May need to be reconfigured after upgrade
2. **Verify Environment Variables:** Values should be preserved but verify they're correct
3. **Turn On Flows:** Flows may be turned off after upgrade
4. **Run Full Inventory:** Recommended after major upgrades to ensure data consistency

---

## Admin View Issues

### Q: A specific environment is not showing in the Admin View filter dropdown

**A:** This usually means:
1. Environment was created after last inventory sync
2. Inventory sync failed for that environment
3. Environment is excluded from inventory

**Solution:**
- Run Full Inventory (`FullInventory = Yes`)
- Check Driver flow history for errors related to that environment
- Verify environment is not in any exclusion lists

---

### Q: Apps are showing but with outdated information (last modified date, owner, etc.)

**A:** The incremental sync uses `InventoryFilter_DaysToLookBack` (default: 7 days) to determine what to update.

**Solutions:**
- If changes are older than the lookback period, run Full Inventory
- Increase `InventoryFilter_DaysToLookBack` value (e.g., 30 or 90 days)
- Note: Larger lookback = more API calls = longer sync time

---

### Q: Some apps show in the Admin View but others don't, even in the same environment

**A:** This can happen when:
1. Incremental sync hasn't picked up newer apps yet
2. API throttling caused some apps to be skipped
3. Specific app errors during sync

**Solution:**
- Run Full Inventory to ensure all apps are captured
- Check child flow **Admin | Sync Template v4 (Apps)** for specific error messages
- If throttling issues, enable `DelayObjectInventory = Yes`

---

## Setup and Configuration

### Q: Which environment variables are required for inventory to work?

**A:** Critical environment variables:

| Variable | Required | Typical Value | Purpose |
|----------|----------|---------------|---------|
| `Power Automate Environment Variable` | **YES** | `https://flow.microsoft.com/manage/environments/` | Base URL for your region |
| `FullInventory` | **YES** | `No` (Yes for initial run) | Full vs incremental sync |
| `InventoryFilter_DaysToLookBack` | No | `7` | Days to look back for changes |
| `Inventory and Telemetry in Azure Data Storage account` | No | `No` | BYODL feature (not recommended) |
| `DelayObjectInventory` | No | `No` | Enable delays for throttling |

---

### Q: Do I need to configure connections for the CoE Starter Kit?

**A:** Yes, connection references must be configured with a service account that has:

**Required Connections:**
- Power Platform for Admins
- Power Apps for Admins
- Dataverse
- Office 365 Users (recommended)
- Office 365 Groups (optional)
- Teams (optional)

Each connection should use the same service account with appropriate permissions.

---

### Q: What happens if I don't run inventory flows?

**A:** Without inventory flows running:
- Admin View will be empty or show no data
- Dashboard reports will have no data
- Compliance and governance flows won't work
- You won't have visibility into your tenant's Power Platform resources

**The inventory is the foundation of the CoE Starter Kit.**

---

## Permissions and Licensing

### Q: What permissions does the service account need?

**A:** The service account used for connections requires:

**Admin Roles:**
- **Power Platform Administrator** role OR
- **Dynamics 365 Administrator** role

**Plus:**
- System Administrator role on the CoE Dataverse environment
- Ability to access all environments (comes with admin roles above)

---

### Q: What licenses does the service account need?

**A:** Required licenses:
- **Power Apps** license (Per User or Per App)
- **Power Automate** license (Per User)
- Office 365 license (for O365 Users connector, if used)

**Note:** Trial licenses may have limitations (API throttling, pagination limits). Production licenses recommended.

---

### Q: Can I use my personal account for the service account?

**A:** While technically possible, it's **not recommended**:

**Best Practice:** Create a dedicated service account (e.g., `svc-coe@contoso.com`) because:
- Personal accounts may leave the organization
- Password changes can break flows
- MFA complications (service accounts should not have MFA)
- Clear audit trail
- Easier to manage permissions

---

## Performance and Throttling

### Q: My inventory flows are timing out or failing with "Rate limit exceeded"

**A:** This is API throttling. Solutions:

1. **Enable Delays:**
   - Set `DelayObjectInventory = Yes`
   - Adds delays between API calls to reduce rate

2. **Check License:**
   - Trial licenses have stricter throttling limits
   - Production licenses recommended for large tenants

3. **Split Inventory:**
   - Consider running inventory during off-peak hours
   - May need to exclude some environments temporarily

4. **Review Pagination:**
   - Large result sets can hit pagination limits
   - Ensure service account has proper license to avoid pagination issues

---

### Q: How long should inventory take for my tenant?

**A:** Approximate durations (Full Inventory):

| Tenant Size | Environments | Apps/Flows | Estimated Duration |
|-------------|--------------|------------|-------------------|
| Small | < 10 | < 100 | 30 min - 1 hour |
| Medium | 10-50 | 100-500 | 1-3 hours |
| Large | 50-200 | 500-2000 | 3-6 hours |
| Enterprise | 200+ | 2000+ | 6-12+ hours |

**Notes:**
- Incremental sync is much faster (minutes to 1-2 hours)
- API throttling can extend durations
- Network speed and API response times vary

---

## General Best Practices

### Q: What's the recommended maintenance schedule for CoE Starter Kit?

**A:** 

**Weekly:**
- Check Driver flow run history for failures
- Monitor Power BI dashboard for data freshness

**Monthly:**
- Review environment variable settings
- Check service account licenses/permissions
- Review connection references for expiration

**Quarterly:**
- Run Full Inventory to catch any missed items
- Review and update compliance policies
- Check for CoE Starter Kit updates

---

### Q: How do I know if my inventory is working correctly?

**A:** Signs of healthy inventory:

✅ Driver flow runs daily without errors
✅ Child flows all succeed (Apps, Flows, Environments, etc.)
✅ Last successful run within last 24 hours
✅ Admin View shows resources created in last 24 hours
✅ Environment count matches your actual tenant
✅ No gaps in data (all environments represented)

---

### Q: Should I use BYODL (Bring Your Own Data Lake)?

**A:** **Not recommended** for new installations.

Microsoft is moving towards Fabric integration. The BYODL feature adds complexity without significant benefit for most organizations. 

Use the default Dataverse storage unless you have a specific, documented need for BYODL.

---

## Getting Help

### Q: Where can I get help with CoE Starter Kit issues?

**A:** 

1. **Check Documentation First:**
   - [Official CoE Starter Kit Docs](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
   - [Troubleshooting Guide](TROUBLESHOOTING-INVENTORY-SYNC.md)
   - This FAQ

2. **Search Existing Issues:**
   - [GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues)
   - Someone may have already reported and solved your issue

3. **Report New Issue:**
   - Use [CoE Starter Kit Bug Template](https://github.com/microsoft/coe-starter-kit/issues/new/choose)
   - Provide detailed information (version, error messages, flow history)

4. **Community:**
   - [Power Apps Community Forum](https://powerusers.microsoft.com/t5/Power-Apps-Governance-and/bd-p/Admin_PowerApps)

**Note:** The CoE Starter Kit is a best-effort, community-supported toolkit. Microsoft Support can help with underlying platform issues but not with the kit itself.

---

### Q: How do I check which version of CoE Starter Kit I'm running?

**A:** 

1. Navigate to Power Platform admin center
2. Go to your CoE environment
3. Navigate to Solutions
4. Find "Center of Excellence - Core Components"
5. Check the version number (e.g., 4.50.6)

---

### Q: Should I upgrade to the latest version?

**A:** Generally **yes**, but:

**Pros:**
- Bug fixes
- New features
- Security updates
- Better performance

**Cons:**
- Requires testing in non-production first
- May need to reconfigure connections
- Flows may turn off during upgrade

**Best Practice:**
- Review [Release Notes](https://github.com/microsoft/coe-starter-kit/releases)
- Test in non-production environment first
- Follow [upgrade documentation](https://learn.microsoft.com/power-platform/guidance/coe/after-setup#installing-upgrades)
- Plan for brief downtime (hours)
- Run Full Inventory after upgrade

---

## Issue-Specific Scenarios

### Scenario: "I just upgraded and now nothing works"

**Checklist:**
1. ✅ Reconfigure connection references (may have been reset)
2. ✅ Verify environment variables (should be preserved but check)
3. ✅ Turn on all flows (they may be off after upgrade)
4. ✅ Run Full Inventory
5. ✅ Check for unmanaged layers (remove if present)

---

### Scenario: "I installed CoE Starter Kit but Admin View is empty"

**This means inventory has never run.**

**First-Time Setup:**
1. Configure all connection references with service account
2. Set environment variables (especially `Power Automate Environment Variable`)
3. Set `FullInventory = Yes`
4. Manually trigger **Admin | Sync Template v4 (Driver)** flow
5. Wait for completion (can take hours)
6. Check Admin View for data
7. Set `FullInventory = No` for incremental sync

---

### Scenario: "Everything was working, now it suddenly stopped updating"

**Common Causes:**
1. Service account password changed → Update connections
2. Service account license expired → Renew license
3. Flow failed due to temporary API issue → Re-run flow
4. Environment capacity full → Check environment capacity
5. API throttling increased → Enable delays

**Diagnostic:**
Check Driver flow run history for first failure date and error message.

---

## Additional Resources

- [Official Documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- [GitHub Repository](https://github.com/microsoft/coe-starter-kit)
- [Release Notes](https://github.com/microsoft/coe-starter-kit/releases)
- [Setup Guide](https://learn.microsoft.com/power-platform/guidance/coe/setup)
- [Detailed Troubleshooting](TROUBLESHOOTING-INVENTORY-SYNC.md)
