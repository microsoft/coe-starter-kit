# CoE Kit Common GitHub Responses

This document provides standardized responses and guidance for common CoE Starter Kit questions and issues raised on GitHub.

## Table of Contents

- [General Information](#general-information)
- [Setup and Upgrade](#setup-and-upgrade)
- [Known Limitations](#known-limitations)
- [Licensing and Pagination](#licensing-and-pagination)
- [Data Export and BYODL](#data-export-and-byodl)
- [Localization](#localization)

---

## General Information

### CoE Starter Kit Support Policy

The CoE Starter Kit is provided as a **sample implementation** and is **not officially supported** through standard Microsoft Support channels. While the underlying Power Platform features and APIs are fully supported, the kit itself represents reference implementations.

**For issues with:**
- **The CoE Starter Kit itself**: Report on [GitHub Issues](https://aka.ms/coe-starter-kit-issues)
- **Core Power Platform features**: Contact Microsoft Support through your standard channel

---

## Setup and Upgrade

### Removing Unmanaged Layers

**Question**: "I don't see a 'Remove unmanaged layer' option when upgrading the CoE Starter Kit."

**Response**:
The option has been renamed to **"Remove active customizations"** in the Power Platform interface. This button performs the same function as the previously named "Remove unmanaged layer" option.

**Steps to remove active customizations:**
1. Navigate to **Solutions** in Power Apps or Power Platform admin center
2. Open the CoE Starter Kit solution
3. Navigate to the component with the unmanaged layer
4. Click on **Solution Layers**
5. Select the unmanaged layer row
6. Click **"Remove active customizations"**

Removing unmanaged customizations is necessary to ensure the managed solution can update properly and you receive all updates from new releases.

**References:**
- [Solution layers documentation](https://learn.microsoft.com/en-us/power-platform/alm/solution-layers-alm)
- [CoE Starter Kit upgrade guide](https://learn.microsoft.com/en-us/power-platform/guidance/coe/after-setup)

### Full Inventory Requirements

**Question**: "Why isn't my inventory completing or showing all resources?"

**Response**:
The CoE Starter Kit requires running a **full inventory** to discover all resources in your tenant. This can take several hours or even days for large tenants.

**Key points:**
- Initial inventory runs can take 24-48 hours or longer
- The inventory flows must complete successfully to populate data
- Check flow run history for errors
- Ensure all required connectors are configured with appropriate permissions

**References:**
- [Setup Core Components](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup-core-components)

---

## Known Limitations

### Unmanaged Layers Blocking Updates

**Issue**: Unmanaged customizations prevent managed solution updates from applying properly.

**Resolution**: Remove all unmanaged layers before upgrading. Use the "Remove active customizations" option in solution layers.

**Prevention**: 
- Always make customizations in a separate unmanaged solution
- Do not directly edit components in managed solutions
- Follow the [solution layering best practices](https://learn.microsoft.com/en-us/power-platform/alm/solution-layers-alm)

---

## Licensing and Pagination

### Pagination Limits and License Requirements

**Question**: "Why am I hitting pagination limits or seeing incomplete data?"

**Response**:
Trial licenses and certain license profiles have pagination limits that can prevent the CoE Starter Kit from retrieving complete data.

**Requirements:**
- Production environments require appropriate Power Apps/Power Automate licenses
- Admin accounts running inventory flows need sufficient API call limits
- For large tenants, consider dedicated service accounts with Premium licenses

**Test to validate license adequacy:**
- Monitor flow run history for throttling or pagination errors
- Check API call limits in Power Platform admin center
- Review [license requirements documentation](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup#licensing-and-permissions)

---

## Data Export and BYODL

### BYODL (Bring Your Own Data Lake) Status

**Important**: BYODL (Bring Your Own Data Lake) is **no longer recommended** for new implementations.

**Current Recommendation:**
- Microsoft is shifting toward **Microsoft Fabric** for data lake scenarios
- Existing BYODL implementations can continue but should plan migration
- New implementations should avoid BYODL and wait for Fabric integration guidance

**For existing BYODL users:**
- Continue current setup until migration path is published
- Monitor [CoE Starter Kit documentation](https://learn.microsoft.com/en-us/power-platform/guidance/coe/starter-kit) for Fabric integration announcements

---

## Localization

### Language Requirements

**Question**: "The CoE Starter Kit isn't working properly in my non-English environment."

**Response**:
The CoE Starter Kit currently supports **English only**. Environments must have the English language pack enabled.

**Resolution:**
1. Ensure your environment has the English language pack installed
2. Set English as the base language for the environment where CoE Starter Kit is installed
3. User interface may still display in other languages, but environment language must include English

**Technical Reason**: 
Many components rely on English schema names, labels, and API responses. Multi-language support is not currently planned.

---

## Cleanup and Maintenance

### Cleanup Flows and Archival

**Question**: "How do I clean up old or deleted resources from the CoE Starter Kit?"

**Response**:
The CoE Starter Kit includes cleanup flows that handle archival of deleted resources.

**Key Points:**
- Cleanup flows run on a schedule (typically weekly)
- Resources are marked as deleted, not immediately removed from Dataverse
- This preserves historical data and audit trails
- Manual cleanup may be needed for specific scenarios

**References:**
- [CoE Governance Components](https://learn.microsoft.com/en-us/power-platform/guidance/coe/governance-components)

---

## Additional Resources

### Setup Wizard

The CoE Starter Kit now includes a setup wizard to help with initial configuration. Use the wizard for:
- First-time setup
- Environment variable configuration
- Connection references setup
- Initial flow activation

**Note**: Even when using the wizard, carefully review the [setup documentation](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup) to understand requirements and best practices.

### Related Documentation

- [CoE Starter Kit Overview](https://learn.microsoft.com/en-us/power-platform/guidance/coe/starter-kit)
- [Setup Guide](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup)
- [Upgrade Guide](https://learn.microsoft.com/en-us/power-platform/guidance/coe/after-setup)
- [Troubleshooting Guide](../TROUBLESHOOTING.md)
- [GitHub Repository](https://github.com/microsoft/coe-starter-kit)

---

## Standard Issue Response Template

When responding to GitHub issues, consider including:

1. **Acknowledgment**: Thank the user for reporting
2. **Clarification**: Ask for any missing details (version, environment type, steps to reproduce)
3. **Context**: Reference similar issues or known limitations
4. **Resolution**: Provide step-by-step guidance
5. **References**: Link to relevant documentation
6. **Follow-up**: Ask user to confirm resolution or provide additional details

**Example:**
```
Thank you for reporting this issue. To help us investigate, could you provide:
- CoE Starter Kit version
- Environment type (Production/Trial/Dataverse for Teams)
- Steps to reproduce
- Any error messages or screenshots

Based on your description, this might be related to [link to similar issue or documentation]. 
[Provide potential resolution steps]

Please let us know if this resolves your issue or if you need additional assistance.
```
