# Common Issue Responses for CoE Starter Kit

This document contains prepared responses for common questions and issues about the CoE Starter Kit.

## Table of Contents
- [AI Credits and Copilot](#ai-credits-and-copilot)
- [More sections to be added]

---

## AI Credits and Copilot

### Question: Are Copilot credits being collected like AI Builder credits?

**Short Answer**: Yes, Copilot credits are automatically collected by the same AI Usage flow that collects AI Builder credits.

**Detailed Response**:

Thank you for your question! Yes, **Copilot credits are being collected** by the CoE Starter Kit, along with AI Builder credits.

#### How It Works

The **Admin - Sync Template v4 (AI Usage)** flow, which is part of the Core Components solution (version 4.x+), collects AI credit consumption data from the `msdyn_aievents` table in Dataverse. This system table automatically logs all AI credit consumption events, including:

- ✅ **AI Builder credits** (custom models, prebuilt models, prompts)
- ✅ **Copilot credits** (Copilot Studio, embedded copilots, Copilot in Power Automate)
- ✅ **Other AI services** that log to the `msdyn_aievents` table

Both AI Builder and Copilot credits are stored in the same Dataverse table (`msdyn_aievents`), so the CoE Starter Kit AI Usage flow collects them all together without requiring any separate configuration.

#### What You Need to Know

1. **No Configuration Changes Needed**: If you're already collecting AI Builder credits, you're automatically collecting Copilot credits too.

2. **Same Data Structure**: Both types of credits are logged as events with:
   - Credits consumed
   - Processing date
   - User who triggered the operation
   - Environment where it occurred

3. **Daily Collection**: The AI Usage flow runs when environments are inventoried and collects AI events from the previous day.

4. **View the Data**: You can see AI credits consumption in:
   - Power Platform Admin View app (AI Credits Usage section)
   - Power BI dashboards (if configured)
   - Direct queries to the `admin_aicreditsusages` table

#### Troubleshooting

If you're not seeing Copilot credit data:

1. **Verify Copilot usage**: Ensure users are actively using Copilot features that consume credits
2. **Check environment inventory**: Confirm environments with Copilot usage are in your CoE inventory
3. **Review flow runs**: Check the AI Usage flow run history for any errors
4. **Validate permissions**: Ensure the CoE service account can read `msdyn_aievents` in target environments
5. **Wait for daily sync**: Recent usage may take up to 24 hours to appear after the daily sync

#### Additional Resources

For more detailed information, please see:
- [AI Credits Collection Documentation](../docs/ai-credits-collection.md)
- [CoE Starter Kit Setup Guide](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components)
- [Power Platform AI Builder Credits](https://learn.microsoft.com/power-platform/admin/power-automate-licensing/types#ai-builder-credits)

---

### Question: How can I differentiate between AI Builder and Copilot credit consumption?

**Answer**:

The `msdyn_aievents` table stores both AI Builder and Copilot credits in the same structure. While the CoE Starter Kit aggregates all AI credits together by default, you can differentiate between them by:

1. **Examining the event details**: The `msdyn_aievents` table contains fields that indicate the type of AI operation
2. **Custom reporting**: Create custom Power BI reports or Dataverse queries that filter based on operation type
3. **Future enhancements**: Consider contributing to or requesting an enhancement to the CoE Starter Kit to add built-in differentiation

For most governance scenarios, tracking total AI credit consumption is sufficient. However, if you need granular breakdowns, you may need to extend the default reporting.

---

### Question: Which version of CoE Starter Kit supports Copilot credit collection?

**Answer**:

Any version of the CoE Starter Kit that includes the **Admin - Sync Template v4 (AI Usage)** flow (typically version 4.0 and later) automatically collects Copilot credits. 

If you're using version 4.50.6 or later (as mentioned in your issue), you already have this capability. The AI Usage flow was designed to collect from the `msdyn_aievents` table, which Microsoft uses for all AI credit tracking, including Copilot.

**To verify your setup**:
1. Check that the AI Usage flow exists in your Core Components solution
2. Verify the flow has successfully run in the past
3. Confirm you have data in the `admin_aicreditsusages` table

---

## Template for Responding to Similar Questions

```markdown
Thank you for your question about [topic]!

Yes, [direct answer to their question].

The CoE Starter Kit [explanation of how it works]. You can find more detailed information in our documentation:
- [Relevant documentation link]

If you're experiencing any issues, please check:
- [Troubleshooting step 1]
- [Troubleshooting step 2]

Feel free to ask if you need any clarification!
```

---

## Contributing to This Document

If you encounter frequently asked questions that should be added to this document, please:
1. Create an issue with the question and suggested response
2. Submit a pull request with your addition
3. Ensure responses are clear, accurate, and helpful

---

**Last Updated**: 2026-01-05
**Maintained By**: CoE Starter Kit Team
