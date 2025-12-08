# CoE Starter Kit - Common GitHub Responses

This document contains ready-to-use explanations, limits, and workarounds for common CoE Starter Kit questions and issues.

## Table of Contents

1. [Support and SLA](#support-and-sla)
2. [Orphaned Resources](#orphaned-resources)
3. [Data Lake (BYODL)](#data-lake-byodl)
4. [Language and Localization](#language-and-localization)
5. [Pagination and Licensing](#pagination-and-licensing)
6. [Inventory and Cleanup Flows](#inventory-and-cleanup-flows)
7. [Setup Wizard](#setup-wizard)
8. [Unsupported Features](#unsupported-features)

---

## Support and SLA

**Response:**
The CoE Starter Kit is provided as **best-effort/unsupported** by Microsoft. While we actively maintain the kit and address issues through GitHub, there is no formal SLA or support commitment.

For issues:
- Use GitHub Issues for bug reports and questions
- Check [existing issues](https://github.com/microsoft/coe-starter-kit/issues) first
- Search [closed issues](https://github.com/microsoft/coe-starter-kit/issues?q=is%3Aissue+is%3Aclosed) for similar problems
- Refer to [official documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)

**When to use:** Any time someone asks about support, SLA, or Microsoft commitment

---

## Orphaned Resources

**Question:** Why do orphaned resource counts differ between CoE Starter Kit and PPAC Advisor?

**Response:**
The CoE Starter Kit and Power Platform Admin Center (PPAC) Advisor use different methodologies to calculate orphaned resources:

**Key Differences:**
1. **Timing** - CoE runs on your configured schedule; PPAC updates more frequently
2. **Scope** - CoE scans configured environments; PPAC scans all tenant environments
3. **Definition** - Different criteria for what qualifies as "orphaned"
4. **Resource Types** - May include/exclude different resource types

**Troubleshooting:**
- Ensure sync flows are running successfully
- Check the `Admin | Sync Template v4 (Driver)` flow history
- Run cleanup flows: `CLEANUP - Admin | Sync Template v4 (Check Deleted)`
- Verify all environments are included in inventory

For detailed explanation, see: [Orphaned Resources FAQ](orphaned-resources-faq.md)

**When to use:** Questions about discrepancies between CoE and PPAC orphaned resource counts

---

## Data Lake (BYODL)

**Status:** BYODL (Bring Your Own Data Lake) is **no longer recommended**

**Response:**
Microsoft is moving toward Fabric as the future direction for data analytics with Power Platform. We recommend:

1. **For New Implementations:**
   - Do NOT set up new BYODL configurations
   - Wait for Fabric integration guidance
   - Use CoE Dataverse tables and Power BI reports directly

2. **For Existing BYODL Users:**
   - Continue using current setup until Fabric migration path is available
   - Monitor announcements for migration guidance
   - Plan for eventual migration to Fabric

3. **Current Limitations:**
   - BYODL setup is complex and error-prone
   - Limited support for troubleshooting
   - Will be deprecated in favor of Fabric

**Resources:**
- [Microsoft Fabric Documentation](https://learn.microsoft.com/fabric/)
- Watch for CoE Starter Kit updates regarding Fabric integration

**When to use:** Questions about BYODL, data lake setup, or analytics export

---

## Language and Localization

**Requirement:** English language pack must be enabled

**Response:**
The CoE Starter Kit currently supports **English only**. This is a known limitation.

**Requirements:**
- Environment must have English (1033) language pack enabled
- Even in multi-language environments, English must be available
- Some components may not work correctly in non-English environments

**Workaround:**
1. Enable English language pack in your environment
2. Set English as the base language
3. Users can still use other languages, but CoE components expect English

**Known Issues:**
- Display names and labels may not localize
- Some flows may fail if English is not available
- Date/time formats should follow environment settings

**When to use:** Language errors, localization issues, non-English environment problems

---

## Pagination and Licensing

**Issue:** Inventory flows fail or timeout with pagination errors

**Response:**
Pagination issues typically occur due to insufficient license profiles or trial environments.

**Root Cause:**
- Power Automate connector API calls are limited by license type
- Trial licenses have stricter pagination limits
- Premium connectors require appropriate licenses

**Testing License Adequacy:**
Run this test in your environment:
1. Create a simple flow using Power Platform for Admins connector
2. Try to list apps or flows with pagination
3. If you hit limits quickly, license is insufficient

**Solutions:**
1. **Upgrade License:**
   - Ensure service account has appropriate Power Apps/Power Automate licenses
   - Premium license recommended for large tenants
   - Per-user or per-flow licenses may be needed

2. **Optimize Flows:**
   - Reduce frequency of sync flows
   - Process fewer environments per run
   - Use incremental sync where possible

3. **Contact Admin:**
   - Request license upgrade for CoE service account
   - Discuss tenant size and appropriate licensing

**When to use:** Pagination errors, timeout issues, connector limit errors

---

## Inventory and Cleanup Flows

**Best Practices:**

**Sync Flow Schedule:**
- Run at least daily for accurate data
- More frequent = more accurate counts
- Consider off-hours to reduce impact

**Full Inventory:**
- Run periodically (weekly/monthly) to catch missed items
- Required after major tenant changes
- Ensures data completeness

**Cleanup Flows:**
- Delete orphaned records
- Remove outdated data
- Run after sync flows complete

**Expected Delays:**
- First-time inventory can take hours for large tenants
- Incremental syncs are faster
- Check flow run history for progress

**Unmanaged Layers:**
- Remove unmanaged customizations to receive updates
- Unmanaged layers block solution upgrades
- Document any intentional customizations

**Common Issues:**
1. **Flows not triggering:** Check connections and flow state
2. **Partial data:** Ensure all helper flows are enabled
3. **Stale data:** Verify sync schedule and run history
4. **Missing environments:** Check environment filter configuration

**When to use:** Questions about sync timing, data freshness, inventory completeness

---

## Setup Wizard

**Guidance:**

The Setup Wizard helps configure the CoE Starter Kit, but **manual verification is recommended**.

**Best Practices:**
1. **Follow Documentation:**
   - Use official setup guide: [CoE Setup](https://learn.microsoft.com/power-platform/guidance/coe/setup)
   - Don't skip prerequisite steps
   - Review each section before proceeding

2. **Verify Connections:**
   - Ensure all connections are created with correct identity
   - Test connections before proceeding
   - Use service account credentials where specified

3. **Environment Variables:**
   - Review and set all required variables
   - Double-check URLs and IDs
   - Document custom values

4. **Enable Flows:**
   - Not all flows auto-enable
   - Check each flow's state after wizard completes
   - Start with core sync flows first

5. **Monitor Initial Run:**
   - First sync takes longest
   - Watch for errors in flow run history
   - Address issues before proceeding

**Common Setup Issues:**
- Missing prerequisites (licenses, permissions)
- Incorrect environment variable values
- Connection authentication failures
- Flow trigger conditions not met

**When to use:** Setup questions, wizard issues, initial configuration problems

---

## Unsupported Features

**Known Limitations:**

1. **Non-English Environments:**
   - English language pack required
   - Localization limited

2. **Custom Connectors in DLP:**
   - Some DLP operations may not work as expected
   - Known product limitations

3. **Multi-Geo Tenants:**
   - Additional configuration may be needed
   - Some features may have limitations

4. **Sandbox/Trial Environments:**
   - May hit API limits more quickly
   - Not recommended for production CoE

5. **Sovereign Clouds:**
   - Additional configuration required
   - Some features may not be available

**Alternative Solutions:**

When CoE Starter Kit doesn't meet needs:
- PowerShell scripts for specific tasks
- Direct API calls for advanced scenarios
- Custom solutions built on CoE data model
- Native PPAC features where available

**When to use:** Feature requests that are known limitations, alternative solution questions

---

## Additional Resources

- [Official Documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- [GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues)
- [Release Notes](https://github.com/microsoft/coe-starter-kit/releases)
- [Power Apps Community](https://powerusers.microsoft.com/t5/Power-Apps-Governance-and/bd-p/Admin_PowerApps)

---

## How to Use This Document

**For Maintainers:**
- Copy relevant section when responding to issues
- Customize based on specific situation
- Add links to related issues or documentation
- Update this document with new common responses

**For Contributors:**
- Suggest new sections for common questions
- Submit PRs to improve existing responses
- Keep responses concise and actionable

**Revision History:**
- Initial version: 2025-12-08
