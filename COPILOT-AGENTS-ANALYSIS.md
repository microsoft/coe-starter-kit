# CoE Starter Kit: Copilot Agents Support Analysis

**Version Analyzed**: 4.50.9  
**Analysis Date**: February 13, 2025  
**Analyzed By**: CoE Custom Agent

---

## Executive Summary

The CoE Starter Kit **v4.45/v4.50** currently supports **Power Virtual Agents (PVA) / Copilot Studio bots** through the `Admin | Sync Template v4 (PVA)` flow. However, the inventory is designed around the legacy **bot/botcomponents** Dataverse tables that were used by the original Power Virtual Agents platform.

**Key Findings:**
1. ✅ **Classic Copilot Studio bots (formerly PVA)** are supported and inventoried
2. ❓ **New Copilot Agents (declarative/autonomous agents)** support is **unclear** - they may use different underlying tables
3. 🔍 **No specific mention** of "Copilot Agents", "declarative agents", or "autonomous agents" in current documentation
4. 📊 **Data model** is based on `bots` and `botcomponents` Dataverse entities

---

## 1. Current PVA/Copilot Studio Bot Support

### What IS Currently Inventoried

The **Admin | Sync Template v4 (PVA)** flow inventories traditional Power Virtual Agents / Copilot Studio bots by:

**Data Source:**
- Queries the **`bots`** Dataverse table in each environment
- Queries the **`botcomponents`** table for bot components/topics
- Uses standard Dataverse connector (no special Copilot connector)

**Information Captured:**
- Bot ID (`admin_botid`)
- Bot Display Name (`admin_pvadisplayname`)
- Bot State (`admin_botstatecode`)
- Component State (Published/Unpublished/Deleted)
- Bot Language (`admin_botlanguage`)
- Bot Template (`admin_bottemplate`)
- Number of Components (`admin_numberofcomponents`)
- Owner information (`admin_pvaowner`)
- Usage metrics (launches, last launched)
- Environment details
- Compliance/governance fields

**Storage Location:**
- CoE Dataverse table: **`admin_pva`** (Display name: "PVA Bot")
- Components table: **`admin_pvacomponent`**
- Component-flow lookup: **`admin_pvacomponentflowlookup`**
- Usage table: **`admin_pvabotusage`**

### Flow Behavior

The PVA sync flow:
1. Triggers when an environment record is modified
2. Checks if the environment has Dataverse and is not excluded
3. Queries the `bots` table for all bots where `botid ne null`
4. Operates in two modes:
   - **Incremental** (default): Syncs new, modified (last 7 days), or manually flagged bots
   - **Full**: Syncs ALL bots regardless of modification date
5. Captures bot metadata and components
6. Links bot components to Power Automate flows if applicable

**Limitations:**
- Only queries the `bots` and `botcomponents` tables
- No explicit filtering by bot type (conversational, declarative, autonomous)
- Assumes all bots follow the classic PVA architecture

---

## 2. Copilot Agents - What We Need to Know

### Microsoft Copilot Studio Agent Types

As of 2024-2025, Microsoft Copilot Studio offers different types of agents:

1. **Conversational Agents** (Classic PVA-style)
   - Built on the original Power Virtual Agents platform
   - Use topics, trigger phrases, and dialog trees
   - Stored in `bots` and `botcomponents` tables
   - **Likely supported** by current CoE inventory

2. **Declarative Copilot Agents** (new)
   - Extend Microsoft 365 Copilot
   - Use declarative manifest files
   - May use different underlying storage (possibly `copilot_*` tables or different entities)
   - **Support unknown** in current CoE kit

3. **Autonomous Agents** (new)
   - Use AI models to perform tasks independently
   - May use different data structures
   - **Support unknown** in current CoE kit

### Key Questions

**Q1: Do new Copilot Agent types use the same `bots` Dataverse table?**
- 🔍 **Unknown** - Need to verify with Microsoft documentation or test environment
- If they use different tables (e.g., `conversationalai`, `copilot_agent`), they would NOT be inventoried

**Q2: Are Copilot Agents environment-specific or tenant-wide?**
- Classic bots are environment-scoped
- Declarative agents extending M365 Copilot may be tenant-scoped
- CoE inventory currently only processes environment-scoped resources

**Q3: What APIs/connectors are needed to inventory new agent types?**
- Current flow uses **Dataverse** connector only
- New agent types may require **Microsoft Copilot Studio** connector or different API endpoints

---

## 3. What the Admin Sync V3/V4 Flows Currently Inventory

### Admin | Sync Template v4 (PVA) - Flow Details

**Introduced**: v4.17.10  
**Description**: "This flow retrieves Power Virtual Agents (bot) information. This information is retrieved from underlying Dataverse tables and requires the user running the flow to have system administrator privileges in the environment."

**Dataverse Entities Queried:**
1. **`bots`** - Main bot records
   - Fields: `botid`, `name`, `modifiedon`
   - Filter: `botid ne null`

2. **`botcomponents`** - Bot components/topics
   - Fields: `name`, `createdon`, `modifiedon`, `botcomponentid`, `componenttype`, `componentstate`, `schemaname`, `description`, `_parentbotid_value`
   - Filter: `botcomponentid ne null`

3. **`bot_botcomponentset`** - Bot to component relationship

4. **`botcomponent_workflowset`** - Component to workflow (flow) relationship
   - Fields: `botcomponentid`, `workflowid`, `botcomponent_workflowid`
   - Used to link bot topics to Power Automate flows

5. **`systemusers`** - To identify bot owners

**CoE Tables Written To:**
- `admin_pvas` - Main bot inventory
- `admin_pvacomponents` - Bot components
- `admin_pvacomponentflowlookups` - Component-to-flow mappings
- `admin_makers` - Bot owner information
- `admin_syncflowerrorses` - Sync errors

**What's NOT Queried:**
- ❌ No `conversationalai` table
- ❌ No `copilot_*` tables
- ❌ No agent-type filtering
- ❌ No declarative agent manifest queries

### Admin | Sync Template v3 vs v4 Differences

Both v3 and v4 PVA sync flows:
- Query the same `bots` and `botcomponents` tables
- Use the same data model (`admin_pva` table)
- Have similar inventory logic

**v4 Improvements over v3:**
- Better error handling
- Improved pagination
- More efficient queries
- Better handling of deleted bots
- Enhanced component tracking

---

## 4. Data Schema Analysis

### admin_PVA Entity (Table: `admin_pva`)

The CoE Starter Kit stores bot/agent data in the `admin_pva` table. Here are ALL the fields:

**Identity & Core Fields:**
- `admin_pvaid` - Primary key (GUID)
- `admin_name` - Internal name
- `admin_pvadisplayname` - Display name
- `admin_botid` - Bot ID from source environment
- `admin_botschemaname` - Bot schema name
- `admin_recordguidasstring` - String representation of GUID

**Environment & Ownership:**
- `admin_pvaenvironment` - Environment lookup
- `admin_environmentdisplayname` - Environment display name
- `admin_pvaenvironmentdisplayname` - PVA environment display name
- `admin_pvaowner` - Owner (Maker) lookup
- `admin_pvaisorphaned` - Boolean: Is orphaned?

**State & Status:**
- `admin_botstatecode` - Bot state code
- `admin_pvastate` - PVA state
- `admin_pvadeleted` - Boolean: Is deleted?
- `admin_pvadeletedon` - Deletion date

**Metadata:**
- `admin_pvacreatedon` - Created on date
- `admin_pvamodifiedon` - Modified on date
- `admin_botlanguage` - Bot language
- `admin_bottemplate` - Bot template
- `admin_botcomponentidunique` - Unique component ID

**Components & Usage:**
- `admin_numberofcomponents` - Number of components
- `admin_pvanumberlaunches` - Number of launches
- `admin_lastlaunchedon` - Last launched date
- `admin_pvalastlaunchedon` - PVA last launched date
- `admin_chatbotdescription` - Description

**Governance & Compliance:**
- `admin_adminrequirementreviewedbot` - Admin reviewed?
- `admin_adminrequirementriskassessment` - Risk assessment
- `admin_adminrequirementriskassessmentstate` - Risk assessment state
- `admin_chatbotexcusedfromcompliance` - Excused from compliance?
- `admin_compliancerequestedon` - Compliance requested date
- `admin_chatbotapprovedsessions` - Approved sessions
- `admin_makersubmittedrequirements` - Maker submitted requirements?
- `admin_makerrequirementbusinessjustification` - Business justification
- `admin_makerrequirementbusinessimpact` - Business impact
- `admin_makerrequirementaccessmanagement` - Access management
- `admin_makerrequirementdependencies` - Dependencies
- `admin_mitigationplanprovided` - Mitigation plan provided?

**Inventory Control:**
- `admin_inventoryme` - Boolean: Force inventory?

**Missing Fields for New Agent Types:**
- ❌ No `admin_agenttype` or `admin_bottype` field
- ❌ No `admin_isdeclarative` field
- ❌ No `admin_isautonomous` field
- ❌ No `admin_copilotmanifest` field
- ❌ No differentiation between agent types

### Implication

The current data model is **generic** and doesn't distinguish between:
- Classic conversational bots
- Declarative Copilot agents
- Autonomous agents
- M365 Copilot extensions

If new agent types are stored in the same `bots` table, they will be inventoried but without type differentiation. If they use different tables, they won't be captured at all.

---

## 5. Official Documentation Check

### CoE Starter Kit Documentation

**Source**: https://learn.microsoft.com/en-us/power-platform/guidance/coe/starter-kit

**Terminology Used:**
- ✅ "Power Virtual Agents" - Extensively documented
- ✅ "PVA" - Abbreviated form used throughout
- ✅ "Chatbots" - Used interchangeably with PVA
- ✅ "Bots" - Generic term
- ⚠️ "Copilot Studio" - Mentioned in TROUBLESHOOTING-PVA-SYNC.md as the current name
- ❌ "Copilot Agents" - No specific mention found
- ❌ "Declarative Agents" - No mention
- ❌ "Autonomous Agents" - No mention
- ❌ "Conversational AI" - No mention

**Key Documentation Files:**
1. **TROUBLESHOOTING-PVA-SYNC.md** 
   - Title: "Not All Copilot Studio Agents (PVA Bots) Appearing in Inventory"
   - Uses "Copilot Studio agents" interchangeably with "PVA Bots"
   - Suggests the docs acknowledge Copilot Studio rebrand but not new agent types

2. **Admin Sync Flow Descriptions**
   - Flow name: "Admin | Sync Template v4 (PVA)"
   - Description: "This flow retrieves Power Virtual Agents (bot) information"
   - Still uses "Power Virtual Agents" terminology

### Microsoft Copilot Studio Documentation

**What We Know from Public Docs:**
- Microsoft rebranded Power Virtual Agents to Microsoft Copilot Studio (2023)
- Copilot Studio now offers multiple agent types (conversational, declarative, autonomous)
- Declarative agents use manifest-based architecture
- Classic bots continue to use the conversational topics model

**What's Unclear:**
- Do all agent types share the same `bots` Dataverse table?
- Are there new tables like `conversationalai`, `copilot_agent`, or similar?
- Do declarative/autonomous agents require different inventory approaches?

---

## 6. GitHub Issues Search Results

**Search Performed:**
- Searched for: "copilot agent", "copilot studio agent", "declarative agent", "autonomous agent"
- Repository: microsoft/coe-starter-kit
- State: Open and Closed

**Results:**
- ❌ No GitHub API access in current environment (requires GH_TOKEN)
- Manual search recommended: https://github.com/microsoft/coe-starter-kit/issues

**Recommended Search Queries:**
```
repo:microsoft/coe-starter-kit "copilot agent"
repo:microsoft/coe-starter-kit "declarative agent"
repo:microsoft/coe-starter-kit "autonomous agent"
repo:microsoft/coe-starter-kit "copilot studio" type:issue
repo:microsoft/coe-starter-kit "agent type" OR "bot type"
```

---

## 7. Conclusions & Recommendations

### Current State Assessment

**✅ What IS Supported:**
1. **Classic PVA/Copilot Studio Conversational Bots**
   - Fully supported through v4 Admin Sync flows
   - Stored in `admin_pva` table
   - Components tracked in `admin_pvacomponent`
   - Usage data in `admin_pvabotusage`
   - Governance workflows available

2. **Bot Metadata & Governance**
   - Owner tracking
   - Compliance workflows
   - Business justification processes
   - Component-to-flow mapping

**❓ What Needs Verification:**
1. **New Copilot Agent Types (Declarative/Autonomous)**
   - Unknown if they use `bots` table or new tables
   - Unknown if they're environment-scoped or tenant-scoped
   - Unknown if current flow captures them

2. **Agent Type Differentiation**
   - No field in data model to distinguish agent types
   - Cannot filter reports by conversational vs. declarative vs. autonomous

**❌ What's Missing:**
1. **Explicit Copilot Agent Type Support**
   - No documentation about new agent types
   - No agent type field in data model
   - No filtering/reporting by agent architecture

2. **M365 Copilot Extension Agents**
   - If declarative agents are tenant-wide (not environment-scoped), current approach won't work
   - May need different API/connector

### Recommendations

#### For CoE Starter Kit Users (v4.45+)

**If you're only using classic conversational bots:**
- ✅ Current version supports your needs
- Continue using Admin Sync v4 PVA flow

**If you're using new Copilot Agent types:**
1. **Test the current inventory**
   - Create a test declarative or autonomous agent
   - Check if it appears in the `admin_pva` table after sync
   - Verify in Power BI Dashboard

2. **Manual verification**
   - Query the `bots` table directly in your Copilot Studio environment
   - Compare with CoE inventory to identify gaps
   - Check for new Dataverse tables (e.g., `conversationalai`, `copilot_*`)

3. **Report findings**
   - If new agent types are NOT being inventoried, file a GitHub issue
   - Include: agent type, Dataverse table structure, SDK/API used

**Workaround for missing agents:**
- Use the **FullInventory** environment variable (`admin_FullInventory = Yes`)
- This ensures ALL bots in `bots` table are synced
- See TROUBLESHOOTING-PVA-SYNC.md for details

#### For CoE Starter Kit Maintainers

**Short-term (Next Release):**
1. **Documentation Update**
   - Clarify which Copilot Studio agent types are supported
   - Add note about declarative/autonomous agents
   - Update terminology from "PVA" to "Copilot Studio Agents" throughout

2. **Investigation Required**
   - Test new Copilot Agent types (declarative, autonomous)
   - Identify Dataverse tables and fields used
   - Determine if current flow captures them

3. **Issue Template**
   - Create specific template for Copilot Agent inventory issues
   - Include questions about agent type, environment, table structure

**Medium-term (Future Releases):**
1. **Data Model Enhancement**
   - Add `admin_agenttype` field to `admin_pva` table
   - Possible values: Conversational, Declarative, Autonomous
   - Add `admin_iscopilot365extension` boolean field

2. **Flow Updates**
   - Query additional tables if new agent types use different storage
   - Capture agent type from Dataverse metadata
   - Handle tenant-wide agents if applicable

3. **Reporting Enhancements**
   - Power BI report filters by agent type
   - Separate inventory counts for each type
   - Usage analytics per agent type

**Long-term (Major Version):**
1. **Microsoft Copilot Studio Connector**
   - Investigate using dedicated Copilot Studio connector instead of raw Dataverse
   - May provide better abstraction over underlying data model

2. **Unified Agent Inventory**
   - Support all Copilot agent types
   - Support M365 Copilot extensions
   - Support custom agents/plugins

---

## 8. Next Steps

### For This Analysis

1. ✅ Document current PVA/Copilot Studio bot support
2. ✅ Identify data model limitations
3. ✅ Highlight unknown areas requiring investigation
4. ⏭️ Share findings with community
5. ⏭️ Recommend testing approach

### For Community Validation

**If you're using new Copilot Agent types, please help by:**

1. **Testing the inventory**
   ```
   1. Create a new Copilot agent (declarative or autonomous)
   2. Run Admin | Sync Template v4 (PVA) flow
   3. Check admin_pva table for the agent
   4. Report findings on GitHub
   ```

2. **Investigating Dataverse structure**
   ```
   1. Open environment with Copilot agents
   2. Use Advanced Find or Dataverse API
   3. List all tables starting with "bot", "copilot", or "conversational"
   4. Identify which table stores your agent
   5. Share table schema in GitHub issue
   ```

3. **Reporting results**
   - Create issue: "Copilot Agent Inventory Support - [Agent Type]"
   - Include: Agent type, Dataverse table used, fields populated
   - Attach screenshots of agent in Copilot Studio vs. CoE inventory

### For Microsoft Documentation Team

**Clarifications Needed:**
1. Do all Copilot Studio agent types (conversational, declarative, autonomous) use the same `bots` Dataverse table?
2. Are there new Dataverse entities for newer agent types?
3. Are declarative agents extending M365 Copilot environment-scoped or tenant-scoped?
4. What's the recommended approach for inventorying all Copilot agent types programmatically?

---

## 9. Related Resources

### Documentation
- **CoE Starter Kit Setup**: https://learn.microsoft.com/power-platform/guidance/coe/starter-kit
- **Inventory & Telemetry Setup**: https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components
- **PVA Sync Troubleshooting**: [CenterofExcellenceCoreComponents/TROUBLESHOOTING-PVA-SYNC.md](./CenterofExcellenceCoreComponents/TROUBLESHOOTING-PVA-SYNC.md)
- **Microsoft Copilot Studio Docs**: https://learn.microsoft.com/microsoft-copilot-studio/

### Key Files in Repository
- **PVA Flow (v4)**: `CenterofExcellenceCoreComponents/SolutionPackage/src/Workflows/AdminSyncTemplatev4PVA-*.json`
- **PVA Entity**: `CenterofExcellenceCoreComponents/SolutionPackage/src/Entities/admin_PVA/Entity.xml`
- **PVA Component Entity**: `CenterofExcellenceCoreComponents/SolutionPackage/src/Entities/admin_PVAComponent/`
- **Troubleshooting Guide**: `CenterofExcellenceCoreComponents/TROUBLESHOOTING-PVA-SYNC.md`

### GitHub Issues
- Search: https://github.com/microsoft/coe-starter-kit/issues
- File new issue: https://github.com/microsoft/coe-starter-kit/issues/new/choose
- Use template: "CoE Starter Kit - Bug" or "CoE Starter Kit - Question"

---

## 10. Summary Table

| Feature | v4.45/v4.50 Support | Notes |
|---------|---------------------|-------|
| **Classic PVA Conversational Bots** | ✅ **Fully Supported** | Via Admin Sync v4 (PVA) flow |
| **Copilot Studio Conversational Bots** | ✅ **Likely Supported** | Same as classic PVA, uses `bots` table |
| **Declarative Copilot Agents** | ❓ **Unknown** | Needs testing - may use different tables |
| **Autonomous Copilot Agents** | ❓ **Unknown** | Needs testing - may use different tables |
| **M365 Copilot Extensions** | ❓ **Unknown** | May be tenant-scoped, not environment-scoped |
| **Agent Type Differentiation** | ❌ **Not Supported** | No field to distinguish agent types |
| **Bot Components/Topics** | ✅ **Supported** | Via `admin_pvacomponent` table |
| **Bot-to-Flow Mapping** | ✅ **Supported** | Via `admin_pvacomponentflowlookup` table |
| **Bot Usage Metrics** | ✅ **Supported** | Via `admin_pvabotusage` table |
| **Governance Workflows** | ✅ **Supported** | Compliance, business justification, etc. |
| **Power BI Dashboard** | ✅ **Supported** | For classic bots only |

---

**Analysis Version**: 1.0  
**Last Updated**: February 13, 2025  
**Status**: Ready for Community Review & Testing  
**Next Review**: After community feedback or new CoE version release
