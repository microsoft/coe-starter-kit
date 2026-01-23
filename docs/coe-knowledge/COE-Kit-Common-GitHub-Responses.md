# CoE Kit Common GitHub Responses

This document contains ready-to-use explanations, clarifications, and workarounds for common questions and issues raised about the CoE Starter Kit.

## Table of Contents
- [CoE Starter Kit Status and Support](#coe-starter-kit-status-and-support)
- [Known Limitations](#known-limitations)
- [Setup and Configuration](#setup-and-configuration)

---

## CoE Starter Kit Status and Support

### Is the CoE Starter Kit being retired?

**No, the CoE Starter Kit is NOT being retired.** The CoE Starter Kit continues to be actively developed and supported by Microsoft.

**Evidence of ongoing development:**
- Active releases: The most recent release is available at [GitHub Releases](https://github.com/microsoft/coe-starter-kit/releases)
- Continuous updates: Regular bug fixes and feature enhancements are published
- Active community: GitHub issues and pull requests are actively managed
- Official documentation: Maintained at [Microsoft Learn - CoE Starter Kit](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)

**Important clarifications:**
- **Office Hours status**: CoE Starter Kit Office Hours are currently paused (not retired). This is a temporary pause of the monthly office hours sessions, not an indication of project retirement.
- **Support model**: The CoE Starter Kit is provided as a **best-effort, community-supported** toolkit. While it is not covered by Microsoft's standard product support SLAs, the team actively maintains the repository and responds to issues on GitHub.
- **Long-term commitment**: Microsoft remains committed to helping customers develop Power Platform governance strategies, and the CoE Starter Kit continues to be a key resource for this purpose.

**How to stay informed:**
- Subscribe to [GitHub Releases](https://github.com/microsoft/coe-starter-kit/releases) to receive notifications about new versions
- Monitor [open milestones](https://github.com/microsoft/coe-starter-kit/milestones?state=open) to see planned features and releases
- Review [closed milestones](https://github.com/microsoft/coe-starter-kit/milestones?state=closed) to see what's been delivered
- Raise questions via [GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues/new/choose)

**References:**
- Official CoE Starter Kit documentation: https://learn.microsoft.com/power-platform/guidance/coe/starter-kit
- GitHub repository: https://github.com/microsoft/coe-starter-kit
- Latest releases: https://github.com/microsoft/coe-starter-kit/releases

---

## Known Limitations

### BYODL (Bring Your Own Data Lake)

**Status**: BYODL is no longer recommended for new implementations.

**Recommendation**: Microsoft is moving toward Fabric-based data lake solutions for Power Platform telemetry and inventory data. Customers should avoid setting up new BYODL implementations and should consider planning migration to Fabric when it becomes generally available for this scenario.

**For existing BYODL users**: Continue to use your existing setup, but be aware that future enhancements may focus on Fabric integration rather than BYODL.

---

### Language Support

**English only**: The CoE Starter Kit is localized for English only. 

**Requirement**: Ensure that your Power Platform environment has the English language pack enabled to avoid errors and display issues.

---

### Pagination and License Requirements

**Issue**: Trial licenses or insufficient license profiles may encounter pagination limits when querying Power Platform APIs.

**Impact**: This can result in incomplete inventory data or failed synchronization flows.

**Validation**: Use the license validation tests provided in the setup documentation to ensure your service account has adequate licensing.

**Minimum requirement**: A Power Apps Per User or Power Apps Per App license is recommended for the service account running inventory and sync flows.

---

## Setup and Configuration

### Inventory and Cleanup Flows

**Expected behavior:**
- Inventory flows may take several hours to complete initial runs, depending on tenant size
- Cleanup flows should be run carefully and tested in non-production environments first
- A full inventory run is required after initial setup or after major environment changes

**Best practices:**
- Remove unmanaged layers from CoE Starter Kit solutions to receive automatic updates
- Review and customize cleanup flows to match your organization's retention policies
- Monitor flow run history for errors and failed synchronizations

**References:**
- Setup instructions: https://learn.microsoft.com/power-platform/guidance/coe/setup
- After setup guidance: https://learn.microsoft.com/power-platform/guidance/coe/after-setup

---

## Additional Resources

- **Setup wizard**: Use the CoE CLI or Setup Wizard for guided installation: https://learn.microsoft.com/power-platform/guidance/coe/setup
- **Upgrade instructions**: https://learn.microsoft.com/power-platform/guidance/coe/after-setup
- **Customization guidance**: https://learn.microsoft.com/power-platform/guidance/coe/modify-components
- **ALM Accelerator**: https://learn.microsoft.com/power-platform/guidance/coe/setup-almacceleratorpowerplatform-cli

---

*Last updated: January 2026*
