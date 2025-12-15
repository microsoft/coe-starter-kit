# BYODL Dataflow Refresh - Quick Reference

## Issue: Dataflows Not Refreshing Automatically

### Most Common Causes & Quick Fixes

#### 1. Future Start Date ⏰
**Check:** Dataflow > Settings > Refresh settings > "Start at" field
**Fix:** Change date to current date or past date

#### 2. Manual Refresh Mode Selected 🔧
**Check:** Dataflow > Settings > Refresh settings
**Fix:** Select "Refresh automatically" (NOT "Refresh manually")

#### 3. First Manual Trigger Needed 🚀
**Issue:** Dataflows never manually refreshed after setup
**Fix:** Manually refresh in this order:
1. Makers dataflow (wait for completion)
2. Environments dataflow  
3. Apps and Flows dataflows
4. All remaining dataflows (Apps Connections, Last Launch Date, etc.)

#### 4. Insufficient Licensing 📋
**Check:** Admin account license (Trial licenses won't work)
**Fix:** Assign Power Apps Plan 2 or Per App license

#### 5. Data Lake Connection Issues 🔌
**Check:** Refresh history for authentication errors
**Fix:** Verify Azure Data Lake Storage Gen2 permissions and connection

### Detailed Documentation

For comprehensive troubleshooting, see: [BYODL Dataflow Refresh Issues](byodl-dataflow-refresh-issues.md)

### BYODL Deprecation Notice

⚠️ **Important:** BYODL is no longer recommended. Consider migrating to Dataverse inventory method.

See: https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup-core-components#what-data-source-should-i-use-for-my-power-platform-inventory

---

## Quick Diagnostic Checklist

- [ ] Refresh schedule "Start at" date is NOT in the future
- [ ] "Refresh automatically" is selected (not manual)
- [ ] Makers dataflow was successfully refreshed at least once
- [ ] Other dataflows were manually triggered after Makers refresh
- [ ] Admin account has Power Apps Plan 2 (NOT trial license)
- [ ] Data Export service is enabled in environment
- [ ] Azure Data Lake connection is valid and authenticated
- [ ] Service principal has "Storage Blob Data Contributor" role

## Need More Help?

1. Review [full troubleshooting guide](byodl-dataflow-refresh-issues.md)
2. Check [existing GitHub issues](https://github.com/microsoft/coe-starter-kit/issues?q=is%3Aissue+dataflow)
3. Create [new issue](https://github.com/microsoft/coe-starter-kit/issues/new/choose) with:
   - CoE version
   - Screenshot of refresh settings
   - Refresh history errors
   - Steps already tried
