# Quick Summary: Copilot Agents Support in CoE Starter Kit v4.45

**TL;DR**: Classic Copilot Studio bots (formerly PVA) are fully supported. New Copilot Agent types (declarative/autonomous) support is **unclear** and requires testing.

---

## 1. Is Copilot Agent support intended in v4.45?

**Answer**: The CoE Starter Kit v4.45 (latest v4.50.9) supports **classic Copilot Studio bots** (the rebranded Power Virtual Agents), but there's **no explicit mention** of support for the newer **Copilot Agent types** introduced in 2024-2025.

**What's Supported:**
- ✅ **Copilot Studio Conversational Bots** (classic PVA-style bots)
  - Uses topics, trigger phrases, dialog trees
  - Stored in `bots` and `botcomponents` Dataverse tables
  - Inventoried by `Admin | Sync Template v4 (PVA)` flow

**What's Unknown:**
- ❓ **Declarative Copilot Agents** (manifest-based, extend M365 Copilot)
- ❓ **Autonomous Copilot Agents** (AI-driven task automation)
- ❓ Whether these new agent types use the same `bots` table or different storage

**Documentation Language:**
- The troubleshooting guide uses "Copilot Studio agents" interchangeably with "PVA Bots"
- This suggests awareness of the rebrand, but not necessarily of new agent architectures

---

## 2. What do Admin Sync V3/V4 flows currently inventory?

### Admin | Sync Template v4 (PVA)

**Dataverse Tables Queried:**
1. **`bots`** - Main bot records
   - Fields: `botid`, `name`, `modifiedon`
   - Filter: `botid ne null`

2. **`botcomponents`** - Bot components/topics
   - Fields: `name`, `createdon`, `modifiedon`, `botcomponentid`, `componenttype`, `componentstate`, `schemaname`, `description`, `_parentbotid_value`

3. **`bot_botcomponentset`** - Bot-to-component relationships

4. **`botcomponent_workflowset`** - Component-to-flow relationships
   - Links bot topics to Power Automate flows

5. **`systemusers`** - To identify bot owners

**CoE Tables Written:**
- `admin_pvas` - Main bot inventory
- `admin_pvacomponents` - Bot components/topics
- `admin_pvacomponentflowlookups` - Component-to-flow mappings
- `admin_pvabotusage` - Usage metrics
- `admin_makers` - Bot owners

**What's NOT Queried:**
- ❌ No `conversationalai` table
- ❌ No `copilot_*` tables
- ❌ No agent-type specific queries
- ❌ No declarative agent manifest queries

**Inventory Modes:**
- **Incremental** (default): New bots + modified in last 7 days + manually flagged
- **Full**: ALL bots in `bots` table across all environments

---

## 3. Official Documentation References

**Searched:** https://learn.microsoft.com/power-platform/guidance/coe/starter-kit

**Terminology Found:**
- ✅ "Power Virtual Agents" - Extensively documented (legacy name)
- ✅ "PVA" - Abbreviated form used in flows/tables
- ✅ "Chatbots" - Used interchangeably
- ⚠️ "Copilot Studio" - Mentioned in recent troubleshooting docs
- ❌ "Copilot Agents" - No specific documentation found
- ❌ "Declarative Agents" - Not mentioned
- ❌ "Autonomous Agents" - Not mentioned

**Key Finding:**
The TROUBLESHOOTING-PVA-SYNC.md document title uses "Copilot Studio Agents (PVA Bots)" which suggests:
- Awareness of Copilot Studio rebrand
- Treating them as equivalent to classic PVA bots
- No distinction made between agent types

---

## 4. GitHub Issues Search

**Status**: Could not search GitHub issues in current environment (requires GH_TOKEN)

**Recommended Manual Searches:**
```
repo:microsoft/coe-starter-kit "copilot agent"
repo:microsoft/coe-starter-kit "declarative agent"
repo:microsoft/coe-starter-kit "autonomous agent"
repo:microsoft/coe-starter-kit "copilot studio" type:issue
```

**Search URLs:**
- All issues: https://github.com/microsoft/coe-starter-kit/issues
- Closed issues: https://github.com/microsoft/coe-starter-kit/issues?q=is%3Aissue+is%3Aclosed

---

## 5. Data Model for Copilot Agents

### admin_PVA Entity Schema

**Table Name**: `admin_pva`  
**Display Name**: "PVA Bot"

**Key Fields:**
- `admin_pvaid` - Primary key
- `admin_botid` - Bot ID from source environment
- `admin_pvadisplayname` - Bot display name
- `admin_botstatecode` - Bot state
- `admin_pvaenvironment` - Environment lookup
- `admin_pvaowner` - Owner (maker)
- `admin_numberofcomponents` - Component count
- `admin_pvanumberlaunches` - Usage metrics
- `admin_pvadeleted` - Deletion flag
- `admin_pvaisorphaned` - Orphaned flag

**Governance Fields:**
- `admin_adminrequirementreviewedbot`
- `admin_chatbotexcusedfromcompliance`
- `admin_makerrequirementbusinessjustification`
- `admin_makerrequirementbusinessimpact`
- ... (many governance/compliance fields)

**Missing Fields for New Agent Types:**
- ❌ No `admin_agenttype` or `admin_bottype` field
- ❌ No `admin_isdeclarative` field
- ❌ No `admin_isautonomous` field
- ❌ No `admin_copilotmanifest` field
- ❌ Cannot distinguish between conversational, declarative, or autonomous agents

### Implication

If new Copilot Agent types:
- ✅ **Use the same `bots` table** → They WILL be inventoried (but without type differentiation)
- ❌ **Use different tables** (e.g., `conversationalai`, `copilot_agent`) → They WILL NOT be inventoried

---

## 6. Key Findings Summary

| Aspect | Finding |
|--------|---------|
| **Classic PVA/Copilot Studio Bots** | ✅ Fully supported via Admin Sync v4 (PVA) |
| **New Copilot Agent Types** | ❓ Unknown - requires testing |
| **Documentation** | ⚠️ Uses "Copilot Studio" but no agent type distinction |
| **Data Model** | ❌ No field to differentiate agent types |
| **Dataverse Tables** | Queries `bots` and `botcomponents` only |
| **GitHub Issues** | 🔍 Manual search required |
| **Official CoE Docs** | ❌ No explicit mention of declarative/autonomous agents |

---

## 7. Recommended Actions

### For Users Wanting Copilot Agent Inventory

**Step 1: Test Current Inventory**
1. Create a test Copilot agent (declarative or autonomous type)
2. Wait for or trigger the Admin | Sync Template v4 (PVA) flow
3. Check the `admin_pva` table in your CoE environment
4. Verify if the agent appears in the inventory

**Step 2: Manual Verification**
1. Open your Copilot Studio environment in Dataverse
2. Use Advanced Find or Dataverse Web API
3. Query for tables: `bots`, `conversationalai`, `copilot_*`
4. Identify which table stores your new agent type
5. Compare agent records in source table vs. `admin_pva` in CoE

**Step 3: Report Findings**
- If new agents ARE captured → Great! No action needed
- If new agents are NOT captured → File a GitHub issue with:
  - Agent type (conversational, declarative, autonomous)
  - Dataverse table/entity used
  - Table schema and key fields
  - Screenshots showing agent in Copilot Studio

### For CoE Maintainers

**Short-term:**
1. Update documentation to clarify supported agent types
2. Add FAQ: "Does CoE support new Copilot Agent types?"
3. Create issue template for Copilot Agent inventory questions

**Medium-term:**
1. Test all Copilot Agent types (conversational, declarative, autonomous)
2. Identify Dataverse tables and storage mechanisms
3. Update Admin Sync flows if new tables need to be queried
4. Add `admin_agenttype` field to `admin_pva` table for differentiation

**Long-term:**
1. Support all Copilot agent architectures
2. Add Power BI visualizations by agent type
3. Extend governance workflows for declarative/autonomous agents

---

## 8. Workarounds

### If New Agents Aren't Being Inventoried

**Option 1: Force Full Inventory**
- Set environment variable `admin_FullInventory` to `Yes`
- This ensures ALL records in the `bots` table are synced
- See: [TROUBLESHOOTING-PVA-SYNC.md](./CenterofExcellenceCoreComponents/TROUBLESHOOTING-PVA-SYNC.md)

**Option 2: Manual Flagging**
- Find or create the agent record in `admin_pva` table
- Set `admin_inventoryme` to `Yes`
- Wait for next sync cycle

**Option 3: Custom Flow**
- If new agents use different tables, create a custom sync flow
- Model it after Admin Sync v4 (PVA)
- Query the appropriate Dataverse table
- Write to `admin_pva` with a custom prefix/flag

---

## 9. Related Files

**Analysis Document:**
- [COPILOT-AGENTS-ANALYSIS.md](./COPILOT-AGENTS-ANALYSIS.md) - Full detailed analysis

**Troubleshooting:**
- [CenterofExcellenceCoreComponents/TROUBLESHOOTING-PVA-SYNC.md](./CenterofExcellenceCoreComponents/TROUBLESHOOTING-PVA-SYNC.md) - PVA sync issues

**Flow Definitions:**
- `CenterofExcellenceCoreComponents/SolutionPackage/src/Workflows/AdminSyncTemplatev4PVA-*.json`

**Entity Definitions:**
- `CenterofExcellenceCoreComponents/SolutionPackage/src/Entities/admin_PVA/Entity.xml`

**Solution Version:**
- `CenterofExcellenceCoreComponents/SolutionPackage/src/Other/Solution.xml` - Shows version 4.50.9

---

## 10. Questions to Ask Microsoft

1. **Do all Copilot Studio agent types use the same `bots` Dataverse table?**
   - If yes → Current inventory should work
   - If no → Which tables store declarative/autonomous agents?

2. **Are declarative agents environment-scoped or tenant-scoped?**
   - If tenant-scoped → Current environment-based inventory won't work

3. **What's the recommended API/connector for inventorying all agent types?**
   - Should we continue using Dataverse connector?
   - Or is there a Microsoft Copilot Studio API?

4. **Will there be a `bottype` or `agenttype` field in Dataverse?**
   - To distinguish conversational vs. declarative vs. autonomous

5. **Are new agent types covered under the same admin/governance APIs?**
   - Or do they require separate monitoring approaches?

---

**Document Version**: 1.0  
**Date**: February 13, 2025  
**Status**: Ready for Community Review

For full analysis, see: [COPILOT-AGENTS-ANALYSIS.md](./COPILOT-AGENTS-ANALYSIS.md)
