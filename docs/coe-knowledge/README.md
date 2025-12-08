# CoE Starter Kit Knowledge Base

This directory contains troubleshooting guides, common responses, and quick reference materials for the Center of Excellence (CoE) Starter Kit.

## Purpose

The CoE Knowledge Base provides:
- Ready-to-use responses for common GitHub issues
- Detailed troubleshooting guides for inventory flows
- Quick reference materials for understanding flow dependencies
- Best practices and known limitations

## Documents in This Directory

### 1. [COE-Kit-Common-GitHub-Responses.md](COE-Kit-Common-GitHub-Responses.md)
**Purpose**: Repository of common responses for GitHub issue triage

**Use this when**:
- Responding to frequently asked questions
- Providing consistent answers across issues
- Explaining known limitations
- Sharing workarounds and best practices

**Topics covered**:
- Support and SLA expectations
- Inventory and data collection
- BYODL (Bring Your Own Data Lake) status
- Licensing and pagination limits
- Language and localization requirements
- Cleanup flows usage
- Upgrade issues and troubleshooting
- Setup wizard guidance
- DLP policy considerations

### 2. [Troubleshooting-Inventory-Flows.md](Troubleshooting-Inventory-Flows.md)
**Purpose**: Comprehensive guide for diagnosing inventory flow issues

**Use this when**:
- Flows or Apps tables are not populating
- Inventory data is stale or incomplete
- Flows are running but not producing results
- After upgrades when inventory stops working

**Topics covered**:
- Inventory flow architecture overview
- Driver flow and child flow dependencies
- Step-by-step troubleshooting process
- Common root causes and solutions
- Performance expectations by tenant size
- Monitoring tips and best practices

### 3. [Flow-Dependencies-Quick-Reference.md](Flow-Dependencies-Quick-Reference.md)
**Purpose**: Quick reference for understanding flow dependencies

**Use this when**:
- You need to quickly understand flow relationships
- Diagnosing which flow is causing issues
- Explaining the inventory system to users
- Creating issue responses about dependencies

**Topics covered**:
- Visual flow dependency chain
- Quick diagnostic checklist
- Common scenarios (fresh install, after upgrade, daily operations)
- Troubleshooting by symptom
- Manual trigger instructions
- Connection requirements

## Quick Navigation

### I need to troubleshoot why inventory isn't working
→ Start with [Flow-Dependencies-Quick-Reference.md](Flow-Dependencies-Quick-Reference.md) for quick diagnostics
→ Then use [Troubleshooting-Inventory-Flows.md](Troubleshooting-Inventory-Flows.md) for detailed steps

### I need to respond to a GitHub issue
→ Check [COE-Kit-Common-GitHub-Responses.md](COE-Kit-Common-GitHub-Responses.md) for pre-written responses
→ Reference specific sections based on the issue topic

### I need to understand flow dependencies
→ See [Flow-Dependencies-Quick-Reference.md](Flow-Dependencies-Quick-Reference.md) for visual diagrams and tables

### I need to help someone after an upgrade
→ Check "Upgrade Issues" in [COE-Kit-Common-GitHub-Responses.md](COE-Kit-Common-GitHub-Responses.md)
→ Follow diagnostic steps in [Troubleshooting-Inventory-Flows.md](Troubleshooting-Inventory-Flows.md)

## Common Issue Patterns

Based on GitHub issues and community feedback, here are the most common problems and where to find solutions:

| Issue Description | Primary Resource | Section |
|-------------------|-----------------|---------|
| Apps/Flows tables empty after upgrade | [Troubleshooting-Inventory-Flows.md](Troubleshooting-Inventory-Flows.md) | Common Issues After Upgrades |
| Don't know which flows to check | [Flow-Dependencies-Quick-Reference.md](Flow-Dependencies-Quick-Reference.md) | Quick Diagnostic Checklist |
| Flows running for hours | [COE-Kit-Common-GitHub-Responses.md](COE-Kit-Common-GitHub-Responses.md) | Long-Running Flows |
| Missing data for some environments | [Troubleshooting-Inventory-Flows.md](Troubleshooting-Inventory-Flows.md) | Step 6: Monitor Flow Execution |
| DLP blocking inventory | [COE-Kit-Common-GitHub-Responses.md](COE-Kit-Common-GitHub-Responses.md) | DLP Policy Considerations |
| Need to run full inventory | [COE-Kit-Common-GitHub-Responses.md](COE-Kit-Common-GitHub-Responses.md) | Full Inventory Required |
| Pagination errors | [COE-Kit-Common-GitHub-Responses.md](COE-Kit-Common-GitHub-Responses.md) | Pagination Limits |
| BYODL questions | [COE-Kit-Common-GitHub-Responses.md](COE-Kit-Common-GitHub-Responses.md) | BYODL No Longer Recommended |

## Contributing

These documents are maintained by the CoE Starter Kit team. If you identify:
- Missing common scenarios
- Outdated information  
- New troubleshooting steps
- Additional workarounds

Please submit a pull request or create an issue with the suggested updates.

## Related Resources

### Official Documentation
- [CoE Starter Kit Overview](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- [Core Components Setup](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components)
- [Inventory Flows](https://learn.microsoft.com/power-platform/guidance/coe/core-components#inventory-flows)
- [Troubleshooting Guide](https://learn.microsoft.com/power-platform/guidance/coe/troubleshoot)

### Community Resources
- [GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues)
- [GitHub Releases](https://github.com/microsoft/coe-starter-kit/releases)
- [Power Apps Community Forum](https://powerusers.microsoft.com/t5/Power-Apps-Community/ct-p/PowerApps1)

### Support
- For CoE Starter Kit issues: [Create an issue on GitHub](https://github.com/microsoft/coe-starter-kit/issues/new/choose)
- For Power Platform issues: Use your standard Microsoft Support channels

---

## Document History

| Date | Change | Author |
|------|--------|--------|
| 2024-12 | Initial knowledge base creation | CoE Team |
| | Added common responses for inventory issues | |
| | Created troubleshooting guides | |
| | Added flow dependency reference | |

---

*Last updated: December 2024*
