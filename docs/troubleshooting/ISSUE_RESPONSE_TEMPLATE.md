# GitHub Issue Response Template - BYODL Dataflow Refresh Issues

## Standard Response for Dataflow Refresh Issues

Use this template when responding to issues where BYODL dataflows are not refreshing automatically.

---

### Response Template:

```markdown
## Summary

Thank you for reporting this issue. This is a common problem with BYODL (Bring Your Own Data Lake) dataflows where only the Makers dataflow refreshes automatically while other dataflows remain stuck at their initial publication date.

Based on the screenshot provided, I can see that the refresh settings show a **future start date (15/12/2025 at 08:30)**. This is the most likely cause of your issue.

## Immediate Fix

### Issue: Future Start Date
The "Start at" field in your refresh settings is set to a **future date**. Dataflows will not refresh until that date arrives.

**Resolution:**
1. Go to **Power Apps** (make.powerapps.com)
2. Select your CoE environment
3. Navigate to **Dataflows**
4. For each non-refreshing dataflow:
   - Click on the dataflow name
   - Select **Settings** > **Refresh settings**
   - Ensure **"Refresh automatically"** is selected (NOT "Refresh manually")
   - Change the **"Start at"** date to the **current date** or a **past date**
   - Save the settings

### Initial Manual Refresh Required
After fixing the start date, you need to manually trigger each dataflow once to establish the refresh chain:

1. **First**: Manually refresh the **Makers** dataflow (wait for completion)
2. **Second**: Manually refresh the **Environments** dataflow
3. **Third**: Manually refresh **Apps** and **Flows** dataflows (can do in parallel)
4. **Fourth**: Manually refresh all remaining dataflows:
   - Model Driven Apps
   - Apps Connections  
   - Apps Last Launch Date
   - Flows Connections
   - Flows Last Run Date

After this initial manual refresh sequence, the dataflows should begin refreshing automatically according to their schedule.

## Important Notice: BYODL Deprecation

⚠️ **BYODL (Bring Your Own Data Lake) is no longer the recommended approach.**

Microsoft is moving toward **Microsoft Fabric** as the preferred data lake solution. For new CoE Starter Kit deployments, we strongly recommend using the **Dataverse inventory method** instead of Data Export (BYODL).

**Benefits of Dataverse method:**
- Simpler setup and maintenance
- No external Azure Data Lake dependency
- Better integration with Power Platform
- Lower licensing requirements
- Official Microsoft recommended approach

**Migration guidance:** https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup-core-components#what-data-source-should-i-use-for-my-power-platform-inventory

## Additional Troubleshooting

If the above doesn't resolve your issue, please review our comprehensive troubleshooting guides:

- **Quick Reference**: [BYODL Dataflow Quick Reference](../docs/troubleshooting/byodl-dataflow-quick-reference.md)
- **Comprehensive Guide**: [BYODL Dataflow Refresh Issues](../docs/troubleshooting/byodl-dataflow-refresh-issues.md)

Common additional issues to check:
- [ ] Refresh schedule "Start at" date is NOT in the future ✅ (Fix this first)
- [ ] "Refresh automatically" is selected (not manual)
- [ ] Admin account has Power Apps Plan 2 license (NOT trial license)
- [ ] Data Export service is enabled in environment
- [ ] Azure Data Lake connection is valid and authenticated

## Next Steps

1. **Fix the future start date** in all dataflow refresh settings
2. **Manually refresh** each dataflow in the order specified above
3. **Wait 24 hours** to verify automatic refresh is working
4. If issues persist after following these steps, please provide:
   - Screenshots of the refresh history showing any errors
   - Confirmation that start dates have been updated
   - License type assigned to the admin account performing refreshes

Please let us know if this resolves your issue or if you need further assistance!

---

**Additional Resources:**
- [CoE Starter Kit Documentation](https://learn.microsoft.com/en-us/power-platform/guidance/coe/starter-kit)
- [CoE Setup Guide](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup)
```

---

## Notes for Maintainers

### Key Points to Emphasize:
1. **Future start date** is the most common cause (visible in the screenshot)
2. **Manual refresh required** after initial setup to establish dependency chain
3. **BYODL is deprecated** - recommend Dataverse method for new deployments
4. **Licensing matters** - Trial licenses won't work properly

### Escalation Criteria:
If user has already:
- Fixed the start date
- Manually refreshed in correct order
- Verified licensing is adequate
- Checked Data Lake connections

Then escalate to check:
- Data Export service configuration
- Azure Data Lake permissions
- Dataflow refresh history for specific error messages
- Power Platform service health status

### Related Issues:
Search for similar issues using: `is:issue label:coe-starter-kit dataflow OR BYODL`
