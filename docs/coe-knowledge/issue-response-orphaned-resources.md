# Issue Response Template: Orphaned Resources Count Discrepancy

## For GitHub Issue Response

Use this template when responding to questions about differences between CoE Starter Kit and PPAC Advisor orphaned resource counts.

---

Thank you for raising this question! This is a common observation, and there are several reasons why the orphaned resource counts differ between the CoE Starter Kit and Power Platform Admin Center (PPAC) Advisor.

### Quick Answer

The CoE Starter Kit and PPAC Advisor use **different methodologies, timing, and scopes** to calculate orphaned resources. Neither count is necessarily "wrong" - they represent different views of the same data at different points in time.

### Key Differences

1. **Data Synchronization Timing**
   - **CoE Starter Kit:** Updates based on your configured schedule (typically daily). The orphaned status is calculated during sync and cleanup flows.
   - **PPAC Advisor:** Updates more frequently with near real-time data from Microsoft's servers.

2. **Detection Logic**
   - **CoE Starter Kit:** Marks resources as orphaned when the owner account no longer exists in Azure AD (tracked via `cr5d5_appisorphaned` and similar fields).
   - **PPAC Advisor:** Uses Microsoft's internal logic which may have different criteria for what qualifies as "orphaned."

3. **Scope of Scanning**
   - **CoE Starter Kit:** Only scans environments configured in your CoE setup and where sync flows have successfully run.
   - **PPAC Advisor:** Automatically scans all environments in your tenant.

### Troubleshooting Steps

To ensure your CoE Starter Kit data is accurate:

1. **Check Sync Flow Status:**
   - Verify that `Admin | Sync Template v4 (Driver)` is running successfully
   - Review the run history for any errors

2. **Run Cleanup Flows:**
   - Ensure `CLEANUP - Admin | Sync Template v4 (Check Deleted)` is enabled and running
   - Check `CLEANUP - Admin | Sync Template v3 (Orphaned Makers)` and `CLEANUP - Admin | Sync Template v3 (Orphaned Users)`

3. **Verify Environment Coverage:**
   - Confirm all environments are included in your CoE inventory
   - Compare the environment list in CoE vs. PPAC

4. **Check Data Freshness:**
   - Look at the `modifiedon` dates in CoE entities
   - Ensure sync flows are running on your expected schedule

### Best Practices

- **Use CoE for detailed tracking:** Better for historical data, reporting, and compliance workflows
- **Use PPAC for quick checks:** Good for immediate health assessment and urgent issues
- **Cross-reference both sources:** Use both tools together for a complete picture
- **Schedule regular syncs:** Daily (or more frequent) syncs provide more accurate counts

### Detailed Documentation

For a comprehensive explanation of all differences and troubleshooting steps, please see:
- [Orphaned Resources FAQ](./orphaned-resources-faq.md)
- [Common GitHub Responses](./COE-Kit-Common%20GitHub%20Responses.md#orphaned-resources)

### Expected Behavior

It's **normal and expected** for these counts to differ slightly, especially if:
- CoE sync flows haven't run recently
- Users were removed very recently
- Resources were reassigned or deleted
- Different environments are being scanned

### Additional Questions?

If you continue to see significant discrepancies after following these troubleshooting steps, please provide:
- When your sync flows last ran successfully
- The approximate difference in counts (e.g., 150 in CoE vs. 70 in PPAC)
- Whether the discrepancy is for specific resource types (Apps, Flows, etc.)
- Screenshots of both views if possible

This will help us provide more specific guidance.

---

## Related Issues

- Search for [other orphaned resources questions](https://github.com/microsoft/coe-starter-kit/issues?q=is%3Aissue+orphaned)
- See [closed issues](https://github.com/microsoft/coe-starter-kit/issues?q=is%3Aissue+is%3Aclosed+orphaned) for resolved cases

## Official Documentation

- [CoE Starter Kit Setup](https://learn.microsoft.com/power-platform/guidance/coe/setup)
- [Core Components Setup](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components)
- [Power Platform Admin Center](https://learn.microsoft.com/power-platform/admin/)
