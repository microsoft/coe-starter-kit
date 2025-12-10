# CoE Starter Kit - Common GitHub Responses

This document provides ready-to-use explanations, limits, workarounds, and guidance for common issues reported in the CoE Starter Kit GitHub repository.

## Table of Contents

1. [General Guidelines](#general-guidelines)
2. [Setup Wizard Issues](#setup-wizard-issues)
3. [Power BI Dashboard Issues](#power-bi-dashboard-issues)
4. [Data Export and Dataflows](#data-export-and-dataflows)
5. [Inventory and Telemetry](#inventory-and-telemetry)
6. [Licensing and Pagination](#licensing-and-pagination)
7. [Language and Localization](#language-and-localization)
8. [Standard Questionnaire](#standard-questionnaire)

---

## General Guidelines

### Support Model

The CoE Starter Kit is provided as **best-effort/unsupported**. Issues should be investigated through GitHub only, and there is no SLA for resolution. The kit is designed as a template and starting point that organizations should customize for their specific needs.

**Standard Response:**
> Thank you for reporting this issue. The CoE Starter Kit is provided as a community-supported template without formal SLA. We'll investigate through this GitHub issue. For immediate assistance, please review the [official documentation](https://learn.microsoft.com/en-us/power-platform/guidance/coe/starter-kit) and check for similar resolved issues in our repository.

### Where to Get Help

- **CoE Starter Kit specific issues**: [GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues)
- **General Power Platform governance questions**: [Power Apps Community Forum](https://powerusers.microsoft.com/t5/Power-Apps-Governance-and/bd-p/Admin_PowerApps)
- **Product support issues**: Microsoft Support (for licensed customers)

---

## Setup Wizard Issues

### Configure Dataflows (Data Export) Step Skipped

**Issue:** After successfully completing "Run Inventory Flows" step, the setup wizard skips the "Configure dataflows (Data export)" step and moves directly to "Share Apps".

**Root Cause:** This is expected behavior in most scenarios. The "Configure dataflows (Data export)" step is **optional** and only appears when specific conditions are met:

1. You must select "Data Export" as your inventory method in earlier steps
2. Data Export features must be enabled in your environment
3. Your tenant must have the appropriate licensing for Dataverse Data Export

**Standard Response:**
> The "Configure dataflows (Data export)" step being skipped is expected behavior. This step only appears when:
> 
> 1. You selected "Data Export" as your inventory and telemetry method
> 2. Data Export features are enabled in your environment
> 
> If you selected "Cloud flows" (recommended for most scenarios) or "None" as your inventory method, the setup wizard will skip the dataflow configuration step. This is by design.
> 
> **Note on Data Export / BYODL:** As of recent guidance, BYODL (Bring Your Own Data Lake) is no longer the recommended approach. Microsoft is moving toward Fabric integration for advanced analytics scenarios. For most organizations, using Cloud flows for inventory collection is sufficient.
> 
> Reference: [Choose your inventory and telemetry method](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup-core-components#inventory-and-telemetry)

---

## Power BI Dashboard Issues

### Power BI Dashboard Shows Blank/No Data

**Issue:** After completing setup wizard and opening the Power BI dashboard, charts show no data or display "There are no Environments in this view to create a Environments chart."

**Root Causes:**

1. **Inventory flows haven't run yet** - First-time inventory collection can take several hours
2. **Inventory flows haven't completed successfully** - Check flow run history
3. **Data refresh not configured** - Power BI dashboard needs connection to Dataverse
4. **Insufficient permissions** - User doesn't have read access to CoE tables
5. **Wrong environment connection** - Power BI connected to different environment than where CoE is installed

**Troubleshooting Steps:**

1. **Verify inventory flows have run:**
   - Navigate to Cloud flows in your CoE environment
   - Check the run history of "Admin | Sync Template v3" and other inventory flows
   - Flows should show successful runs (green checkmarks)
   - First run can take 4-8 hours depending on tenant size

2. **Check data in Dataverse:**
   - Open the CoE environment in Power Apps
   - Navigate to Tables (under Dataverse)
   - Check if tables like "Environment", "Power Apps App", "Flow" contain data
   - If tables are empty, inventory flows haven't completed successfully

3. **Configure Power BI Dashboard Connection:**
   - Download the Power BI template file (.pbit) from the solution
   - Open in Power BI Desktop
   - When prompted, enter your Dataverse environment URL
   - Format: `https://[orgname].crm.dynamics.com/` or `https://[orgname].crm[region].dynamics.com/`
   - Click "Load" and sign in with appropriate credentials
   - Publish to Power BI Service if needed

4. **Verify Permissions:**
   - User viewing dashboard needs read access to CoE Dataverse tables
   - Check security roles in the CoE environment

**Standard Response:**
> Thank you for reporting this issue. A blank Power BI dashboard is typically caused by one of the following:
> 
> 1. **Inventory collection hasn't completed yet** - First-time inventory can take 4-8 hours depending on tenant size
> 2. **Power BI connection not configured correctly** - The dashboard needs to be connected to your CoE Dataverse environment
> 
> **Steps to resolve:**
> 
> 1. Verify inventory flows have run successfully:
>    - Navigate to Cloud flows in your CoE environment
>    - Check run history of "Admin | Sync Template v3" and related flows
>    - Wait for all flows to complete (check every hour)
> 
> 2. Configure Power BI connection:
>    - Open the downloaded .pbit file in Power BI Desktop
>    - Enter your CoE environment URL when prompted: `https://[orgname].crm.dynamics.com/`
>    - Sign in with credentials that have access to the CoE environment
>    - Refresh the data
> 
> 3. Verify data in tables:
>    - In Power Apps, open your CoE environment
>    - Navigate to Dataverse > Tables
>    - Check if "Environment", "Power Apps App", "Flow" tables contain records
> 
> Reference: [Set up the Power BI dashboard](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup-powerbi)

---

## Data Export and Dataflows

### BYODL (Bring Your Own Data Lake) Status

**Current Recommendation:** BYODL is **no longer recommended** for new implementations.

**Reasons:**
- Microsoft is moving toward Microsoft Fabric integration for advanced analytics
- BYODL setup is complex and has ongoing maintenance requirements
- Cloud flows provide sufficient inventory for most scenarios
- Fabric will be the recommended path for advanced analytics integration

**Standard Response:**
> **Note on BYODL/Data Export:** As of current guidance, BYODL (Bring Your Own Data Lake) is no longer the recommended approach for the CoE Starter Kit. Microsoft is moving toward integration with Microsoft Fabric for advanced analytics scenarios.
> 
> For most organizations, using **Cloud flows** for inventory collection is the recommended and sufficient approach. This method:
> - Is easier to set up and maintain
> - Works within standard Power Platform licensing
> - Provides all necessary data for CoE dashboards and apps
> 
> We recommend avoiding new BYODL setups and using Cloud flows instead.
> 
> Reference: [Choose your inventory method](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup-core-components)

---

## Inventory and Telemetry

### Inventory Collection Takes Long Time

**Expected Behavior:** 
- First-time inventory: 4-8 hours (can be longer for very large tenants)
- Incremental updates: 1-2 hours
- Depends on: Number of environments, apps, flows, and tenant size

**Standard Response:**
> Inventory collection is expected to take several hours, especially on first run:
> - **First-time inventory**: 4-8 hours (can be longer for large tenants)
> - **Incremental updates**: 1-2 hours
> 
> This is normal behavior due to API rate limits and the volume of data being collected. Please wait for the flows to complete before expecting data in dashboards.

### Cleanup and Full Inventory

**When to run full inventory:**
- After initial setup
- When data appears incorrect or incomplete
- After major tenant changes
- When troubleshooting data issues

**How to trigger:**
1. Navigate to "Admin | Sync Template v3" flow
2. Manually trigger with appropriate parameters
3. Wait for completion

---

## Licensing and Pagination

### Pagination Limits and License Requirements

**Issue:** Some users experience pagination limits when running inventory flows, causing incomplete data collection.

**Root Cause:** Trial licenses or insufficient license profiles may hit API pagination limits.

**License Requirements:**
- Power Apps Per App or Per User license (or included with Microsoft 365 licenses)
- Power Automate Per User license (recommended for reliability)
- Appropriate admin roles (Power Platform Admin, Global Admin, or delegated admin)

**Testing License Adequacy:**

To test if your license is adequate for CoE Starter Kit:

1. Check your Power Platform license assignment
2. Verify you have one of:
   - Power Apps Per User license
   - Power Automate Per User license  
   - Microsoft 365 E3/E5 (includes limited Power Platform)
3. Test inventory flow runs for pagination errors

**Standard Response:**
> Pagination limits typically indicate insufficient licensing. The CoE Starter Kit requires adequate Power Platform licensing to function properly.
> 
> **Required licenses:**
> - Power Apps Per User or Per App license
> - Power Automate Per User license (recommended)
> - Appropriate admin roles
> 
> **To verify:**
> 1. Check your license assignment in Microsoft 365 admin center
> 2. Ensure you're not using trial licenses for production CoE
> 3. Review flow run history for specific pagination errors
> 
> Trial licenses may work initially but can hit limitations. For production CoE deployment, proper licensing is essential.

---

## Language and Localization

### English Language Pack Requirement

**Issue:** CoE Starter Kit has issues in non-English environments.

**Limitation:** The CoE Starter Kit currently supports **English only**. The environment where CoE is installed must have the English language pack enabled.

**Standard Response:**
> The CoE Starter Kit currently supports **English language only**. Please ensure:
> 
> 1. Your Power Platform environment has the English language pack installed
> 2. The base language or a secondary language in your environment is English
> 3. Flows and apps may not function correctly in non-English-only environments
> 
> We recommend creating a dedicated CoE environment with English as the primary language for best results.

---

## Standard Questionnaire

When an issue lacks sufficient detail, use this questionnaire template:

> Thank you for raising this issue. To help us resolve it efficiently, could you please provide the following details:
> 
> 1. **Solution name and version**: Which CoE solution are you using (Core, Governance, Nurture, etc.) and what version?
> 2. **App or flow affected**: Specific app or flow name where you're experiencing the issue
> 3. **Inventory/telemetry method**: Are you using Cloud flows, Data Export, or None?
> 4. **Environment details**: 
>    - Is this a production or trial environment?
>    - What region is your environment in?
>    - What licensing do you have?
> 5. **Steps to reproduce**: Detailed steps that led to the issue
> 6. **Expected vs Actual behavior**: What did you expect to happen vs. what actually happened?
> 7. **Screenshots/errors**: Any error messages, screenshots, or flow run history
> 8. **Timing**: When did this issue start? After an upgrade, initial setup, or has it always been an issue?
> 
> This information will help us analyze and suggest the most appropriate fix. Thank you!

---

## Additional Common Issues

### Unmanaged Layers Preventing Updates

**Issue:** Solution updates fail due to unmanaged customizations.

**Standard Response:**
> Solution updates can fail if you have unmanaged customizations (unmanaged layers) on top of the managed CoE solution.
> 
> **To resolve:**
> 1. In Power Apps, go to Solutions
> 2. Select the CoE solution
> 3. Check for "See solution layers" on affected components
> 4. Remove unmanaged customizations before updating
> 
> **Best practice:** Don't customize managed CoE components directly. Instead:
> - Extend functionality in separate solutions
> - Copy and customize components you need to modify
> - Keep the base CoE solution unmodified for easier updates

### DLP Policies Blocking Flows

**Issue:** Flows fail with connector policy violations.

**Standard Response:**
> DLP (Data Loss Prevention) policies can block CoE flows if required connectors are in different policy groups.
> 
> **Required connectors for CoE (must be in same DLP group):**
> - Dataverse
> - Office 365 Users
> - Office 365 Outlook
> - Power Apps for Admins
> - Power Automate for Admins
> - Power Platform for Admins
> - HTTP (for some scenarios)
> 
> **Resolution:**
> 1. Check DLP policies applied to your CoE environment
> 2. Create a DLP policy exception for the CoE environment, or
> 3. Ensure all required connectors are in the "Business" data group
> 
> Reference: [DLP considerations](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup-core-components#dlp-impact)

---

## References

- [CoE Starter Kit Overview](https://learn.microsoft.com/en-us/power-platform/guidance/coe/starter-kit)
- [Setup Core Components](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup-core-components)
- [Setup Power BI Dashboard](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup-powerbi)
- [Troubleshooting Guide](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup-core-components#troubleshooting)
- [GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues)
- [Power Apps Community Forum](https://powerusers.microsoft.com/t5/Power-Apps-Governance-and/bd-p/Admin_PowerApps)

---

## Contributing to This Document

This document is maintained by the CoE Starter Kit community. If you have additional common responses, troubleshooting steps, or resolved issue patterns, please contribute via pull request.

**Update process:**
1. Identify recurring issue pattern
2. Document root cause and resolution
3. Create standard response template
4. Add to appropriate section
5. Submit PR with changes

---

*Last updated: 2025-12-10*
