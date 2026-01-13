# Response Template: Power BI Dashboard Not Showing Apps and Flows

## When to Use This Template
Use this response when a user reports that apps and flows are not appearing in their Power BI dashboards after setting up the CoE Starter Kit.

## Template Response

---

Thank you for reporting this issue! This is a common challenge during initial CoE Starter Kit setup. The most frequent cause is that the inventory flows haven't completed their first run yet, or there may be configuration issues.

## Immediate Troubleshooting Steps

I've created a comprehensive troubleshooting guide that addresses this exact issue. Please follow the steps in this guide:

**📖 [Apps and Flows Not Appearing in Power BI Dashboards - Troubleshooting Guide](../../Troubleshooting/PowerBI-Dashboard-No-Data.md)**

## Quick Checklist

Before diving into the full guide, please verify these critical points:

1. **Have the inventory flows run successfully?**
   - Check if `SETUP WIZARD | Admin | Sync Template v3 (Setup)` has completed
   - Verify `Admin | Sync Template v3`, `Admin | Sync Flows v3`, and `Admin | Sync Apps v2` are turned ON
   - Review flow run history for errors

2. **Has enough time passed?**
   - Initial inventory collection can take 24+ hours for the first run
   - Flows run on a schedule (typically daily)

3. **Is data in Dataverse?**
   - Check the `Power Apps App` and `Flow` tables in your CoE environment
   - Verify records exist with recent creation dates

4. **Is Power BI configured correctly?**
   - Verify the report is connected to the correct environment
   - Refresh the data after flows have completed

## What Information Would Help Us Assist You?

If the troubleshooting guide doesn't resolve your issue, please provide:

- [ ] **Flow Status**: Screenshots of the run history for:
  - SETUP WIZARD | Admin | Sync Template v3 (Setup)
  - Admin | Sync Template v3
  - Admin | Sync Flows v3
  - Admin | Sync Apps v2
- [ ] **Any error messages** from flow runs
- [ ] **Dataverse verification**: How many records exist in the Power Apps App and Flow tables?
- [ ] **Time elapsed**: How long has it been since you completed the setup?
- [ ] **Environment details**: 
  - CoE Starter Kit version: [from your issue]
  - Inventory method: [from your issue]
  - Environment type (Production, Dataverse for Teams, etc.)

## Related Resources

- **Official Setup Guide**: https://docs.microsoft.com/power-platform/guidance/coe/setup-core-components
- **Core Components Documentation**: https://docs.microsoft.com/power-platform/guidance/coe/core-components
- **Power BI Setup**: https://docs.microsoft.com/power-platform/guidance/coe/setup-powerbi
- **FAQ**: https://docs.microsoft.com/power-platform/guidance/coe/faq

## Next Steps

1. Follow the troubleshooting guide linked above
2. Complete the verification checklist
3. If issues persist after following all steps, reply with the requested information and screenshots
4. For urgent issues, consider posting in the [Power Apps Community forum](https://powerusers.microsoft.com/t5/Power-Apps-Governance-and/bd-p/Admin_PowerApps) as well

---

## Customization Notes for Maintainers

When using this template:

1. **Update version references** if the user specified a specific version
2. **Reference specific error messages** if the user provided them
3. **Adjust timeline expectations** based on tenant size if known
4. **Add specific guidance** if you notice patterns in their setup description
5. **Close with encouragement** - this is a common and solvable issue!

## Common Follow-up Scenarios

### User confirms flows haven't run
→ Point them to Step 2 in the troubleshooting guide (Run flows manually)

### User has flow errors
→ Ask for specific error messages and review connection/permission configuration

### Data is in Dataverse but not Power BI
→ Focus on Steps 4-5 (Power BI configuration and refresh)

### Everything looks correct but still no data
→ Ask about pagination limits, licensing, and language pack configuration (Advanced Troubleshooting section)
