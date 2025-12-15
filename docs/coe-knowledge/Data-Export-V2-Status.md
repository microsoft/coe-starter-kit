# Data Export V2 Status and Troubleshooting Guide

## Overview

This document provides detailed information about the Data Export V2 feature status in the CoE Starter Kit and troubleshooting steps for the common issue where the Data Export option appears greyed out in the Setup Wizard.

## Current Status

**Data Export V2 is NOT YET AVAILABLE** as of December 2025.

The Data Export option in the CoE Starter Kit Setup Wizard is intentionally greyed out because it depends on a Power Platform product feature (Data Export V2) that has not yet been released by Microsoft.

## Issue Description

### Symptoms

When setting up the CoE Starter Kit Core Components, users see:

1. The "Choose Data Source" step in the Initial Setup Wizard
2. Three options displayed:
   - **Cloud Flows** (available and recommended)
   - **BYODL - Bring your own data lake** (available but not recommended)
   - **Data Export** (greyed out/disabled)
3. A message stating: "_Today inventory is only available using cloud flows that crawl your tenant to store inventory in Dataverse. A new version of the kit which integrates with Data Export V2 will be available ~Fall 2024_"

### Affected Versions

- CoE Starter Kit v4.5.7
- All versions up to the current release
- This will remain until Data Export V2 is released by Microsoft

## Root Cause

The Data Export option is greyed out because:

1. **Product Dependency**: Data Export V2 is a Power Platform service that must be released and made generally available by the Microsoft product team before it can be used

2. **Proactive Implementation**: The CoE Starter Kit team has prepared the Setup Wizard UI to include this option so that when Data Export V2 is released, users can quickly adopt it

3. **Timeline Uncertainty**: The "~Fall 2024" mentioned in the message was an estimated timeframe that is subject to change based on the product team's release schedule

## This is NOT a Bug

**Important**: The greyed-out Data Export option is **intentional behavior**, not a bug or configuration issue. It is designed this way to:
- Inform users about the future availability of Data Export V2
- Provide a seamless upgrade path once the feature is released
- Prevent confusion by clearly showing all inventory methods in one place

## Resolution: Use Cloud Flows Method

### Recommended Action

**Use the Cloud Flows inventory method**, which is:
- ✅ Fully supported and actively maintained
- ✅ The recommended approach by the CoE Starter Kit team
- ✅ Provides complete inventory and telemetry capabilities
- ✅ Requires no additional Azure infrastructure
- ✅ Receives regular updates and improvements

### Setup Steps

1. **In the Setup Wizard**:
   - Navigate to the "Choose Data Source" step
   - Select **"Cloud Flows"** option
   - Click Next/Continue

2. **Follow the Official Documentation**:
   - Complete setup guide: [Setup Core Components](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup-core-components#choose-data-source)
   - Configure environment variables as documented
   - Turn on and run inventory flows

3. **Verify Setup**:
   - Check that inventory flows are running successfully
   - Verify data is being collected in Dataverse
   - Monitor flow run history for any errors

## Why Not BYODL?

While BYODL (Bring Your Own Data Lake) is still available in the Setup Wizard, it is **NOT RECOMMENDED** for the following reasons:

- ❌ Legacy approach with limited ongoing support
- ❌ Complex setup requiring Azure Data Lake Storage infrastructure
- ❌ Higher maintenance overhead
- ❌ Microsoft is moving towards Fabric for data lake scenarios
- ❌ Not the focus of future CoE Starter Kit enhancements

**Recommendation**: Do not choose BYODL unless you have a specific business requirement that absolutely necessitates it, and you understand the maintenance implications.

## What is Data Export V2?

Data Export V2 is a planned Power Platform feature that will:
- Provide a native, scalable way to export Power Platform data
- Likely integrate with Microsoft Fabric or similar Microsoft data services
- Simplify the data export process compared to custom flow-based solutions
- Be supported directly by the Power Platform product team

### Benefits (When Available)

Once released, Data Export V2 is expected to offer:
- Potentially better performance for very large tenants
- Native platform capability (no custom flows required)
- Direct support from Microsoft product team
- Possibly tighter integration with Microsoft analytics tools

## Timeline and Availability

### Current Status
- **Status**: Not Generally Available
- **ETA**: To Be Announced by Microsoft
- **Original Estimate**: ~Fall 2024 (subject to change)

### How to Stay Informed

1. **Watch CoE Starter Kit Releases**:
   - Subscribe to [GitHub Release Notifications](https://github.com/microsoft/coe-starter-kit/releases)
   - The CoE Starter Kit will be updated when Data Export V2 becomes available

2. **Monitor Power Platform Release Notes**:
   - Check [Power Platform Release Plans](https://learn.microsoft.com/en-us/power-platform/release-plan/)
   - Review monthly release notes for new features

3. **Follow Microsoft 365 Roadmap**:
   - Check [Microsoft 365 Roadmap](https://www.microsoft.com/en-us/microsoft-365/roadmap) for Data Export features

## Migration Path (Future)

When Data Export V2 becomes available:

1. **Announcement**: The CoE Starter Kit team will release an updated version with Data Export V2 support enabled

2. **Documentation**: Step-by-step migration guides will be provided

3. **Coexistence**: Cloud Flows method will likely continue to be supported, allowing gradual migration

4. **Choice**: Organizations can choose to migrate or continue with Cloud Flows based on their needs

## Frequently Asked Questions (FAQ)

### Q: Why is the Data Export option shown if it's not available?

**A**: It's shown to provide transparency about future options and to prepare the UI for quick adoption once the feature is released. This is better than suddenly adding a new option without context.

### Q: Can I enable Data Export somehow?

**A**: No. Data Export V2 is a Power Platform product feature that must be released by Microsoft first. There is no workaround or configuration that will enable it before general availability.

### Q: Will my Cloud Flows setup work when Data Export V2 is released?

**A**: Yes. Cloud Flows is and will remain a supported method. You can migrate to Data Export V2 later if you choose, but you won't be forced to.

### Q: Is there a performance difference between Cloud Flows and Data Export V2?

**A**: Not currently, since Data Export V2 isn't available yet. When it is released, Microsoft will provide guidance on scenarios and performance characteristics.

### Q: Should I wait for Data Export V2 before setting up CoE?

**A**: No. Set up the CoE Starter Kit with Cloud Flows now. You can always migrate to Data Export V2 later if it better suits your needs. Waiting means you miss out on the current benefits of the CoE Starter Kit.

### Q: I saw a message about "Fall 2024" but we're past that date. What happened?

**A**: Software release timelines often shift due to various factors including feature completeness, testing, and prioritization. The date shown is an estimate and is subject to change by the Microsoft product team.

### Q: Can I use both Cloud Flows and Data Export V2 at the same time?

**A**: This is unknown until Data Export V2 is released. The recommended approach is to use one inventory method at a time to avoid data duplication or conflicts.

### Q: Where can I request priority or ETA for Data Export V2?

**A**: Data Export V2 is a Power Platform product feature. For product feature requests and timelines, contact Microsoft support or your Microsoft account team. The CoE Starter Kit team does not control the product roadmap.

## Troubleshooting

### Problem: I cannot select any data source option

**Possible Causes and Solutions**:

1. **Insufficient Permissions**
   - Ensure you have System Administrator role in the environment
   - Verify you have appropriate licenses

2. **Browser Issues**
   - Clear browser cache and cookies
   - Try a different browser (Microsoft Edge or Chrome recommended)
   - Disable browser extensions that might interfere

3. **Setup State**
   - Verify you've completed all previous setup steps
   - Check that prerequisite configuration is complete
   - Review environment variables are properly configured

### Problem: Setup Wizard shows an error when I select Cloud Flows

**Resolution Steps**:

1. Check flow connections are authenticated
2. Verify all required flows are turned on
3. Review flow run history for specific error messages
4. Consult the [Setup Troubleshooting Guide](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup-core-components#troubleshooting)

### Problem: The message about Fall 2024 is confusing/outdated

**Explanation**:
- The message reflects an estimated timeframe that is subject to change
- Product release dates are determined by the Microsoft product team, not the CoE Starter Kit team
- Future versions of the Setup Wizard may update this messaging

**Action**:
- Ignore the specific date and focus on the current recommendation: use Cloud Flows
- Subscribe to release notifications to be informed when Data Export V2 becomes available

## Additional Resources

- **CoE Starter Kit Documentation**: https://learn.microsoft.com/en-us/power-platform/guidance/coe/starter-kit
- **Setup Core Components**: https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup-core-components
- **Choose Data Source**: https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup-core-components#choose-data-source
- **GitHub Issues**: https://github.com/microsoft/coe-starter-kit/issues
- **GitHub Releases**: https://github.com/microsoft/coe-starter-kit/releases

## Reporting Issues

If you encounter issues with the **Cloud Flows** inventory method (not the greyed-out Data Export option), please report them:

1. Check [existing issues](https://github.com/microsoft/coe-starter-kit/issues) to see if it's already reported
2. If not found, create a new issue using the bug report template
3. Provide detailed information including:
   - CoE Starter Kit version
   - Environment details
   - Steps to reproduce
   - Error messages or screenshots
   - Flow run history (if applicable)

## Summary

- ✅ **Use Cloud Flows method** - This is the current recommended approach
- ❌ **Do not use BYODL** - Legacy approach, not recommended
- ⏳ **Data Export V2 is not yet available** - The greyed-out option is intentional
- 📢 **Stay informed** - Subscribe to release notifications
- 🚀 **Don't wait** - Set up CoE Starter Kit with Cloud Flows now

---

*Document Version: 1.0*
*Last Updated: December 2025*
*Status: Data Export V2 - Not Yet Available*
