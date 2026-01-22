# GCC High Upgrade Quick Start Guide

## TL;DR - Can I Upgrade Now?

**YES!** If you're on a GCC High tenant and the "Power Platform for Admins V2" connector is available, you can now upgrade to the latest version of the CoE Starter Kit.

## Quick Check - Prerequisites

Before upgrading, verify these items:

✅ Power Platform for Admins V2 connector is visible in your GCC High tenant  
✅ You have Power Platform Admin permissions  
✅ You have access to the Power Platform Admin Center for GCC High  
✅ You've backed up your current environment variable configurations  

## Fast Track Upgrade Steps

### 1. Backup (15 minutes)

```
- Export current environment variables
- Document custom flows or modifications
- Note current version numbers
```

### 2. Download Latest Release (5 minutes)

Visit: https://github.com/microsoft/coe-starter-kit/releases
Download the managed solution files you need:
- Core Components (required)
- Governance/Audit Components (if installed)
- Nurture Components (if installed)

### 3. Import Solutions (30-60 minutes)

1. Go to Power Platform Admin Center (GCC High)
2. Select your CoE environment
3. Import solutions in this order:
   - Core Components first
   - Then Governance/Audit
   - Finally Nurture or other components

### 4. Update Connections (30 minutes)

For each solution:
1. Open Power Automate (GCC High instance)
2. Go to Connections
3. Create new connection using "Power Platform for Admins V2"
4. Edit each flow to use the new connection
5. Save and turn on flows

### 5. Trigger Initial Sync (15 minutes)

1. Find the "Admin | Sync Template v3" flow
2. Manually trigger it
3. Wait 2-4 hours for complete inventory refresh

### 6. Validate (30 minutes)

- Check flow run history for errors
- Open CoE apps and verify data appears
- Test key governance scenarios

## Coming from v4.42?

If you're upgrading from v4.42 (released in 2023), you're jumping about 2 years of releases. Key things to know:

**Major Changes:**
- Connection management completely revamped (use V2 connector)
- Many flows rewritten for better performance
- New environment variables added
- Power BI reports updated significantly

**Recommended Approach:**
- Review [closed milestones](https://github.com/microsoft/coe-starter-kit/milestones?state=closed) for major changes
- Plan for 4-6 hours of upgrade work
- Test in a non-production environment if possible

## Quick Troubleshooting

### Flows Keep Failing
- ➜ Update to use Power Platform for Admins V2 connector
- ➜ Check that connection authentication is successful
- ➜ Verify admin permissions are still current

### No Data in Apps
- ➜ Manually trigger "Admin | Sync Template v3"
- ➜ Wait at least 2 hours for initial sync
- ➜ Check flow run history for sync errors

### Power BI Dashboard Issues
- ➜ Confirm you're using Power BI Government cloud
- ➜ Update connection strings for GCC High endpoints
- ➜ Reconfigure scheduled refresh

## Need More Information?

📘 **Full Documentation**: See [sovereign-cloud-support.md](./sovereign-cloud-support.md)  
🔗 **Official Docs**: https://learn.microsoft.com/power-platform/guidance/coe/starter-kit  
🐛 **Issues**: https://github.com/microsoft/coe-starter-kit/issues  

## About Issue #8835

Issue #8835 was tracking the availability of the Power Platform for Admins V2 connector in GCC High. Now that the connector is available, the issue has been closed and upgrades are possible.

If you were following #8835 for updates: **You can now proceed with your upgrade!**

---

**Need Help?** Create an issue at https://github.com/microsoft/coe-starter-kit/issues with:
- Your current version (v4.42, v3.25, etc.)
- GCC High confirmation
- Specific error messages
- Steps you've already tried
