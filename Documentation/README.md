# CoE Starter Kit Documentation

This directory contains additional documentation, guidance, and best practices for the Center of Excellence (CoE) Starter Kit.

## Available Documentation

### [Inactivity Notification Flows - Complete Guide](./InactivityNotificationFlowsGuide.md)

Comprehensive guide for understanding and managing the Governance Solution's inactivity notification flows. This document covers:

- How inactivity notifications work (weekly scans, approval requests, daily checks)
- Complete lifecycle of the Archive Approval table
- Detailed explanation of all five flows involved in the process
- Common scenarios (first run, user approves/rejects, ignored requests, manager notifications)
- Troubleshooting repeated emails and timing issues
- Best practices for configuration and rollout
- FAQ addressing common questions

**Relevant for**: CoE administrators implementing or troubleshooting the Governance Solution, particularly when users report receiving repeated inactivity emails after responding to approval requests

### [Troubleshooting: Unexpected Azure DevOps Email Notifications](../docs/TROUBLESHOOTING-AZURE-DEVOPS-EMAILS.md)

Complete troubleshooting guide for unexpected email notifications about "Sync Issues to Azure DevOps" after upgrading Core Components. This document covers:

- Why these notifications occur after Core Components upgrades
- Root causes (Innovation Backlog, ALM Accelerator, Pipeline Accelerator dependencies)
- Five resolution options (turn off flows, remove unused solutions, complete setup, etc.)
- Prevention strategies for future upgrades
- When to seek additional help

**Relevant for**: CoE administrators experiencing unexpected flow failure emails after upgrades, especially for features not being used

### [Troubleshooting: Duplicate Flows in Setup Wizard](./TROUBLESHOOTING-DUPLICATE-FLOWS-SETUP-WIZARD.md)

Complete troubleshooting guide for when duplicate flow entries appear in the CoE Setup and Upgrade Wizard. This document covers:

- Root cause of duplicate entries (duplicate metadata records)
- Step-by-step cleanup instructions
- Multiple resolution options (manual cleanup, re-run metadata sync)
- Prevention strategies
- Technical details about how the wizard populates flow lists

**Relevant for**: CoE administrators setting up or upgrading the kit who see duplicate flows in the "Run setup flows" step

### [Reducing Azure Log Analytics Costs](./ReducingAzureLogAnalyticsCosts.md)

Comprehensive guide addressing high Azure Log Analytics costs caused by non-interactive sign-in logs from CoE Starter Kit service accounts. This document covers:

- Understanding why CoE service accounts generate sign-in logs
- Current architecture and Service Principal support limitations
- Five options for reducing log-related costs
- Recommended approaches based on organizational requirements
- Step-by-step implementation guides
- Cost estimation and FAQ

**Relevant for**: Organizations experiencing high Azure monitoring costs, Azure administrators, CoE Kit administrators

## Official Documentation

For complete CoE Starter Kit documentation, setup guides, and component details, please visit:

**[Microsoft Power Platform CoE Starter Kit Documentation](https://learn.microsoft.com/en-us/power-platform/guidance/coe/starter-kit)**

## Contributing

If you have suggestions for additional documentation topics or improvements to existing content, please:

1. Check existing [issues](https://github.com/microsoft/coe-starter-kit/issues) to see if your topic is already being discussed
2. Open a new issue using the appropriate template
3. Submit a pull request with your proposed documentation changes

Please follow the [contribution guidelines](../HOW_TO_CONTRIBUTE.md) when submitting documentation.

## Support

The CoE Starter Kit is provided as sample implementations and is not officially supported by Microsoft Support. For issues and questions:

- **Issues with the kit**: Report at [github.com/microsoft/coe-starter-kit/issues](https://github.com/microsoft/coe-starter-kit/issues)
- **Core platform features**: Use your standard Microsoft Support channel
- **Community support**: Visit the [Power Apps Community forum](https://powerusers.microsoft.com/t5/Power-Apps-Governance-and/bd-p/Admin_PowerApps)

---

*Last updated: January 2026*
