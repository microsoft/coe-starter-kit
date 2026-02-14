# FAQ: Copilot Agents Support in CoE Starter Kit

## Overview

This document clarifies the current support status for Microsoft Copilot Studio agents and related monitoring/alerting capabilities in the Center of Excellence (CoE) Starter Kit.

**Last Updated:** February 2025  
**Applies to:** CoE Starter Kit v4.45 and later

---

## Quick Answers

### Q: Does the CoE Starter Kit support Copilot Agents?

**A: It depends on the agent type.**

- ✅ **YES** - Classic Copilot Studio conversational bots (formerly Power Virtual Agents) are fully supported
- ❓ **UNKNOWN** - Newer Copilot agent types (declarative agents, autonomous agents) have unclear support status

### Q: Why isn't monitoring and alerting for my Copilot Agents working?

**A: Several possible reasons:**

1. **Wrong Agent Type**: If you have newer declarative or autonomous agents, they may not be supported yet
2. **Not Published**: Only published bots are inventoried
3. **Configuration Issue**: The CoE flows may not be configured correctly
4. **Incremental Inventory**: Older agents may not have been captured in the initial sync
5. **Different Storage**: Newer agent types may use different Dataverse tables

See [TROUBLESHOOTING-PVA-SYNC.md](./TROUBLESHOOTING-PVA-SYNC.md) for detailed diagnostic steps.

---

## Understanding Copilot Studio Agent Types

Microsoft Copilot Studio has evolved to support multiple agent architectures. The CoE Starter Kit was originally designed for Power Virtual Agents (PVA), which have been rebranded as classic Copilot Studio conversational bots.

### Agent Type Comparison

| Agent Type | Description | CoE Support Status | Storage Location |
|------------|-------------|-------------------|------------------|
| **Classic Conversational Bots** | Traditional dialog-based bots with topics and trigger phrases. Originally PVA. | ✅ **Fully Supported** | `bots` and `botcomponents` Dataverse tables |
| **Declarative Copilot Agents** | Manifest-based agents that extend Microsoft 365 Copilot with plugins and actions | ❓ **Unknown** | Possibly different tables or storage |
| **Autonomous Copilot Agents** | AI-driven agents that perform tasks independently using large language models | ❓ **Unknown** | Possibly different tables or storage |

---

## What IS Currently Supported

### Classic Copilot Studio Conversational Bots

The **Admin | Sync Template v4 (PVA)** flow fully supports:

**Inventory Captured:**
- Bot ID and display name
- Bot state (Published, Draft, Deleted)
- Bot language and template
- Bot components/topics
- Owner information
- Creation and modification dates
- Environment details
- Usage metrics (launches, sessions)

**Governance Features:**
- Compliance tracking
- Risk assessment fields
- Business justification tracking
- Archival support
- Orphaned bot detection

**Telemetry:**
- Bot launch counts via `admin_pvabotusage` table
- Session duration tracking
- Last launch date/time
- Component usage via `admin_pvacomponent`

**Visualizations:**
- Power BI dashboard reporting
- Environment-level summaries
- Maker-level summaries

### How It Works

1. The sync flow queries the **`bots`** Dataverse table in each environment
2. Bot metadata is extracted and stored in the **`admin_pva`** table in the CoE environment
3. Components/topics are stored in **`admin_pvacomponent`**
4. Usage data is captured in **`admin_pvabotusage`**
5. Power BI dashboards visualize the inventory and telemetry

---

## What Is NOT Currently Supported

### Built-in Alerting

**Important:** The CoE Starter Kit does **not** include pre-built alerting for Copilot Studio agents.

**What's Provided:**
- ✅ Inventory tracking (who has what agents, where)
- ✅ Telemetry collection (usage data, launch counts)
- ✅ Compliance workflows (request business justification)

**What's NOT Provided:**
- ❌ Automated alerts when agents are created
- ❌ Automated alerts when agent usage exceeds thresholds
- ❌ Automated alerts for security or compliance violations
- ❌ Proactive notifications for agent performance issues

**How to Build Custom Alerts:**

You can create custom alerting using:

1. **Power Automate Flows**
   - Trigger on `admin_pva` table changes (when a record is created/modified)
   - Monitor `admin_pvabotusage` for usage thresholds
   - Send notifications via email, Teams, or other channels

2. **Power BI Alerts**
   - Set up data-driven alerts in Power BI reports
   - Configure thresholds for metrics like bot count, usage, or compliance status
   - Subscribe to scheduled report deliveries

3. **Custom Apps**
   - Build Canvas or Model-Driven apps that provide monitoring dashboards
   - Implement custom business logic for your alerting requirements

**Example Alert Scenarios:**
- Alert when a new bot is published in a production environment
- Alert when bot usage drops below expected levels
- Alert when a bot hasn't been reviewed in 90 days
- Alert when a bot owner leaves the organization

### Newer Agent Types (Declarative/Autonomous)

**Status:** The CoE Starter Kit does not explicitly document support for these agent types.

**Why:**
- These are newer features in Copilot Studio
- They may use different underlying storage mechanisms
- Microsoft's admin APIs and Dataverse schema may differ
- The CoE team has not yet confirmed compatibility

**What to Do:**

1. **Test in Your Environment**
   - Create a declarative or autonomous agent
   - Run the Admin Sync v4 (PVA) flow
   - Check if the agent appears in the `admin_pva` table

2. **Check Source Storage**
   - Navigate to your environment in Power Apps
   - Browse the Dataverse tables
   - Identify which table stores your agent (e.g., `bots`, `conversationalai`, `copilot_*`)

3. **Report Findings**
   - If the agent is in the `bots` table and appears in inventory → Great! Report success
   - If the agent uses a different table → File a feature request on GitHub
   - Share your findings to help the community

---

## Common Misunderstandings

### "Monitoring" vs "Alerting"

**Monitoring** = Observing and tracking (what the CoE Kit provides)
- Inventory: What agents exist and where
- Telemetry: How agents are being used
- Compliance: What governance state agents are in

**Alerting** = Proactive notifications (requires custom configuration)
- Real-time notifications when events occur
- Threshold-based alerts for metrics
- Escalation workflows for violations

The CoE Starter Kit provides **monitoring** out-of-the-box but requires you to build **alerting** based on your needs.

### "Copilot Agents" vs "Copilot Studio Agents"

**Terminology Confusion:**
- "Copilot Studio" is the product name (formerly Power Virtual Agents)
- "Copilot Studio agents" or "bots" refer to the entities created in Copilot Studio
- "Copilot Agents" sometimes refers specifically to the newer declarative/autonomous types

When reporting issues or asking questions, always specify:
- The type of agent (classic conversational, declarative, autonomous)
- How you created it (Copilot Studio portal, API, Teams)
- Where it's stored (which Dataverse table)

### "Never Worked" vs "Not Configured"

If you say monitoring/alerting "never worked," consider:
- **For classic bots:** It should work by default if flows are running
- **For newer agent types:** Support may not exist yet (not a bug, but a gap)
- **For custom alerts:** You may need to build them yourself (not provided out-of-box)

---

## Troubleshooting Decision Tree

```
Do you have Copilot Studio agents?
├─ YES → What type?
│   ├─ Classic conversational (topics/trigger phrases)
│   │   └─ Are they appearing in admin_pva table?
│   │       ├─ YES → Monitoring is working! Build custom alerts if needed
│   │       └─ NO → See TROUBLESHOOTING-PVA-SYNC.md
│   │
│   └─ Declarative/Autonomous (AI-driven, manifest-based)
│       └─ Check which Dataverse table stores them
│           ├─ Same "bots" table → Should be inventoried (run full sync)
│           └─ Different table → File feature request on GitHub
│
└─ NO → You may not have Copilot Studio licenses or agents created yet
```

---

## How to Check Your Agent Type

### Method 1: Copilot Studio Portal

1. Navigate to [Copilot Studio](https://copilotstudio.microsoft.com)
2. Open your agent
3. Check the authoring canvas:
   - **Classic**: You'll see "Topics", "Entities", "Trigger phrases"
   - **Declarative**: You'll see "Actions", "Knowledge sources", "Instructions"
   - **Autonomous**: You'll see "Goals", "Triggers", "AI configuration"

### Method 2: Dataverse Table Check

1. Navigate to [Power Apps](https://make.powerapps.com)
2. Select your environment
3. Go to **Tables**
4. Search for `bot` or `copilot`
5. Open the relevant table and check if your agent is listed:
   - **`bots`** table → Classic conversational bot
   - **`conversationalai`** or **`copilot_*`** tables → Possibly newer types

### Method 3: Power Platform Admin Center

1. Navigate to [Power Platform Admin Center](https://admin.powerplatform.microsoft.com)
2. Select **Resources** → **Copilot Studio**
3. View the list of agents and their types (if exposed in the UI)

---

## Feature Requests and Feedback

### How to Request Support for Newer Agent Types

If you need CoE Starter Kit to support declarative or autonomous Copilot agents:

1. **Before filing a request:**
   - Test whether they're already captured (they might be!)
   - Identify the Dataverse table they use
   - Document how they differ from classic bots

2. **File a GitHub Issue:**
   - Go to https://github.com/microsoft/coe-starter-kit/issues
   - Click **New Issue**
   - Choose **Feature Request** template
   - Title: "Support for [Agent Type] in Admin Sync flows"
   - Include:
     - Agent type and creation method
     - Dataverse table schema
     - Expected inventory fields
     - Use case for monitoring these agents

3. **Contribute (Optional):**
   - If you've built custom flows to inventory these agents, share them
   - Contribute PRs to extend the Admin Sync flows
   - Help test pre-release features

### How to Request Alerting Features

If you need specific alerting capabilities:

1. **Check existing features:**
   - Review the Power BI dashboards
   - Check if custom flows already exist in the solution
   - Look for samples in the CoE Starter Kit GitHub

2. **Build your own first:**
   - Create a proof-of-concept alert flow
   - Test with your specific use case
   - Document the business need

3. **Share with community:**
   - File a feature request with your working solution
   - Consider contributing it as a sample
   - Help others with similar needs

---

## Related Resources

### Documentation
- [TROUBLESHOOTING-PVA-SYNC.md](./TROUBLESHOOTING-PVA-SYNC.md) - Detailed troubleshooting for bot inventory issues
- [CoE Starter Kit Setup Guide](https://learn.microsoft.com/power-platform/guidance/coe/setup) - Official setup documentation
- [Inventory and Telemetry](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components) - How inventory works

### External Links
- [Copilot Studio Documentation](https://learn.microsoft.com/microsoft-copilot-studio/) - Microsoft's official docs
- [CoE Starter Kit GitHub](https://github.com/microsoft/coe-starter-kit) - Source code and issue tracking
- [Power Platform Admin Center](https://admin.powerplatform.microsoft.com) - Tenant administration

### Community Support
- [Power Platform Community Forums](https://powerusers.microsoft.com/t5/Power-Platform-Community/ct-p/PowerPlatform) - Ask questions
- [CoE Starter Kit Discussions](https://github.com/microsoft/coe-starter-kit/discussions) - GitHub discussions

---

## Version History

| Date | Version | Changes |
|------|---------|---------|
| Feb 2025 | 1.0 | Initial version clarifying agent type support and alerting capabilities |

---

## Feedback

This FAQ is a living document. If you find:
- Missing information
- Outdated content
- Errors or unclear explanations

Please file an issue on GitHub or contribute updates via pull request.
