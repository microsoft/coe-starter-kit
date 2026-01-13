# Quick Reference: Apps and Flows Not Appearing in Power BI Dashboards

> **Common Issue**: After setting up the CoE Starter Kit, apps and flows are not appearing in the Power BI dashboards.

## Most Common Cause

**Inventory flows are not turned on.** They are OFF by default after solution import.

## Quick Fix (5 Steps)

### Step 1: Turn ON Inventory Flows

Navigate to: `Solutions → Center of Excellence – Core Components → Cloud flows`

Turn **ON** these flows:
- `SETUP WIZARD | Admin | Sync Template v3 (Setup)`
- `Admin | Sync Template v3`
- `Admin | Sync Apps v2`
- `Admin | Sync Flows v3`

### Step 2: Run Setup Wizard

1. Open `SETUP WIZARD | Admin | Sync Template v3 (Setup)`
2. Click **Run**
3. Wait for completion (10-30 minutes)

### Step 3: Wait for Inventory

- **Small tenants**: 30-60 minutes
- **Medium tenants**: 2-4 hours  
- **Large tenants**: up to 24 hours

### Step 4: Verify Data in Dataverse

1. Go to https://make.powerapps.com
2. Select your CoE environment
3. Open **Tables**
4. Check these tables have records:
   - Power Apps App
   - Flow
   - Environment

### Step 5: Refresh Power BI

1. Open Power BI workspace
2. Find CoE dataset
3. Click **Refresh now**
4. Wait for refresh to complete

## Still Not Working?

See the [Complete Troubleshooting Guide](./Troubleshooting-Inventory-and-Dashboards.md) for:
- Detailed diagnostic steps
- Flow failure troubleshooting
- Power BI connection issues
- License and pagination problems
- Architecture and monitoring guidance

## Common Mistakes

❌ **Don't**:
- Expect immediate results (inventory takes time)
- Skip enabling the flows (they're off by default)
- Forget to refresh Power BI after data is in Dataverse
- Use trial licenses for the service account

✅ **Do**:
- Enable all required inventory flows
- Run the Setup Wizard first
- Wait for inventory to complete before checking Power BI
- Verify data in Dataverse before refreshing Power BI
- Use proper premium licenses for service accounts

## Need More Help?

1. **Full Guide**: [Troubleshooting-Inventory-and-Dashboards.md](./Troubleshooting-Inventory-and-Dashboards.md)
2. **Common Issues**: [COE-Kit-Common-GitHub-Responses.md](./COE-Kit-Common-GitHub-Responses.md)
3. **Official Docs**: https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components
4. **GitHub Issues**: https://github.com/microsoft/coe-starter-kit/issues

---

*⏱ Expected time to resolve: 30 minutes - 24 hours depending on tenant size*
