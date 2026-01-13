# AI Credits Collection - Frequently Asked Questions

## Overview

The CoE Starter Kit collects AI credit consumption data through the Core Components solution. This document answers common questions about AI credits collection, including AI Builder and Copilot credits.

## Frequently Asked Questions

### Q: Does the CoE Starter Kit collect Copilot credits?

**Yes.** The CoE Starter Kit collects both AI Builder credits and Copilot credits.

Starting with CoE Starter Kit Core Components v4.50.6 (and earlier versions that include the AI Usage sync flow), the **Admin | Sync Template v4 (AI Usage)** flow automatically collects all AI credit consumption from the Dataverse system table `msdyn_aievents`.

This includes credits from:
- **AI Builder** (models, prompts, etc.)
- **Copilot Studio** (conversational bots, copilots)
- **Copilot in Power Automate** (AI-powered automation)
- **Embedded copilots** in Power Apps and Power Pages

### Q: Are AI Builder and Copilot credits shown separately?

**No.** The CoE Starter Kit currently aggregates all AI credits together in the `admin_AICreditsUsage` table and does not show AI Builder and Copilot as separate categories by default.

Both types of credits are logged to the same Dataverse system table (`msdyn_aievents`) by the Power Platform, and the CoE Starter Kit collects them as a combined total.

If you need to view AI Builder and Copilot credits separately, you would need to customize the solution to parse and categorize the data from `msdyn_aievents` based on the event types or other distinguishing attributes.

### Q: How do I know if Copilot credits are being collected?

If AI Builder credits are appearing correctly in your CoE Starter Kit dashboards and reports, then Copilot credits are also being captured in the same way. Both types of credits flow through the same data collection mechanism.

### Q: How often are AI credits synced?

The **Admin | Sync Template v4 (AI Usage)** flow runs on a schedule (typically daily). AI credit usage data may take up to 24 hours to appear in the CoE Starter Kit after the actual consumption occurs, as the data must first be logged by the Power Platform to the `msdyn_aievents` table and then synced by the CoE flow.

### Q: What data is stored about AI credit usage?

The `admin_AICreditsUsage` table stores the following information:
- **Credits Consumption**: The number of AI credits consumed
- **User**: The user who consumed the credits (via the `admin_creditsuser` field)
- **Environment**: The environment where the credits were consumed
- **Processing Date**: The date when the credits were consumed

### Q: Where can I view AI credits data?

AI credits data can be viewed in:
1. **Power Platform Admin View** app - includes an AI Credits Usage section
2. **CoE Power BI Dashboard** - if configured to display AI credits
3. **Dataverse directly** - by querying the `admin_aicreditsusages` table

### Q: Do I need any special configuration to collect Copilot credits?

No additional configuration is required. If the **Admin | Sync Template v4 (AI Usage)** flow is enabled and running successfully, both AI Builder and Copilot credits are automatically collected.

The only requirement is that:
- The Core Components solution is installed (v4.29 or later for AI Usage tracking)
- The sync flows are turned on and running
- The appropriate Dataverse connections are configured

### Q: What versions of the CoE Starter Kit support AI credits collection?

AI credits collection was introduced in CoE Starter Kit version **4.29** with the **Admin | Sync Template v4 (AI Usage)** flow. Any version from 4.29 onwards supports collecting both AI Builder and Copilot credits from the `msdyn_aievents` table.

### Q: Can I customize how AI credits are categorized?

Yes. Since the CoE Starter Kit is designed to be customized, you can:
1. Modify the **Admin | Sync Template v4 (AI Usage)** flow to add additional fields or categorization logic
2. Extend the `admin_AICreditsUsage` table to include a category field (e.g., "AI Builder" vs "Copilot")
3. Parse the data from `msdyn_aievents` to determine the source type based on event attributes
4. Create custom reports or views that separate the credits by type

For more information on customizing the CoE Starter Kit, see: https://docs.microsoft.com/en-us/power-platform/guidance/coe/modify-components

## Additional Resources

- [CoE Starter Kit Documentation](https://docs.microsoft.com/power-platform/guidance/coe/starter-kit)
- [Core Components Overview](https://docs.microsoft.com/power-platform/guidance/coe/core-components)
- [Setup Core Components](https://docs.microsoft.com/en-us/power-platform/guidance/coe/setup-core-components)
- [Customizing the CoE Starter Kit](https://docs.microsoft.com/en-us/power-platform/guidance/coe/modify-components)

## Related Issues

- [Issue #XXXX] - Copilot credits collection question

## Contributing

If you have additional questions about AI credits or suggestions for improving this documentation, please:
1. Check existing issues: https://github.com/microsoft/coe-starter-kit/issues
2. Submit a new question using the question template: https://github.com/microsoft/coe-starter-kit/issues/new/choose

---

*Last Updated: January 2026*
*CoE Starter Kit Version: 4.50.6+*
