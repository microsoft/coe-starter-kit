# Troubleshooting the CoE Starter Kit

This document provides quick links to troubleshooting resources for the Microsoft Power Platform Center of Excellence (CoE) Starter Kit.

## Common Issues

### Audit Logs Issues
- **[Office 365 Management API Subscription Flow Fails](docs/coe-knowledge/TROUBLESHOOT-AuditLogs-Office365ManagementAPI.md)**
  - Error: "Get_Azure_Secret - Value cannot be null"
  - Environment variable configuration issues
  - Managed solution limitations

### Environment Variables
See the [Common GitHub Responses Guide](docs/coe-knowledge/COE-Kit-Common-GitHub-Responses.md#environment-variables-and-managed-solutions) for:
- Why environment variables are read-only in managed solutions
- How to configure environment variables using the Setup Wizard
- How to re-import solutions to set environment variables

### Inventory and Data Collection
See the [Common GitHub Responses Guide](docs/coe-knowledge/COE-Kit-Common-GitHub-Responses.md#inventory-and-cleanup-flows) for:
- Running full inventory
- Pagination and licensing issues
- Flow failures and timeouts

### Setup and Configuration
See the [Common GitHub Responses Guide](docs/coe-knowledge/COE-Kit-Common-GitHub-Responses.md#setup-wizard-guidance) for:
- Using the CoE Setup & Upgrade Wizard
- Upgrading to new versions
- Configuration best practices

## Knowledge Base

For comprehensive troubleshooting guides and common responses, visit:
- **[CoE Knowledge Base](docs/coe-knowledge/README.md)** - Central hub for troubleshooting documentation
- **[Common GitHub Responses](docs/coe-knowledge/COE-Kit-Common-GitHub-Responses.md)** - Ready-to-use response templates
- **[Audit Logs Troubleshooting](docs/coe-knowledge/TROUBLESHOOT-AuditLogs-Office365ManagementAPI.md)** - Office 365 Management API issues

## Official Documentation

The official documentation is the primary source for setup, configuration, and usage information:
- **[CoE Starter Kit Overview](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)**
- **[Setup Instructions](https://learn.microsoft.com/power-platform/guidance/coe/setup)**
- **[Core Components Setup](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components)**
- **[Audit Logs Setup](https://learn.microsoft.com/power-platform/guidance/coe/setup-auditlog)**

## Getting Help

### Before Creating an Issue
1. **Search existing issues**: Check if your problem has already been reported in [GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues)
2. **Review the knowledge base**: Check the [CoE Knowledge Base](docs/coe-knowledge/README.md) for known issues and solutions
3. **Check official documentation**: Review the [official documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit) for setup guidance

### Creating a New Issue
When creating a new issue, please provide:
- CoE Starter Kit version
- Which component/solution (Core, Governance, Nurture, etc.)
- Specific app or flow name
- Complete error message
- Steps to reproduce
- Screenshots (if applicable)

Use the appropriate [issue template](https://github.com/microsoft/coe-starter-kit/issues/new/choose) for your situation.

### Support Channels
- **GitHub Issues**: For bugs and feature requests specific to the CoE Starter Kit
- **Power Apps Community**: For general Power Platform governance questions - [Power Apps Governance Forum](https://powerusers.microsoft.com/t5/Power-Apps-Governance-and/bd-p/Admin_PowerApps)

**Note**: The CoE Starter Kit is a best-effort, community-supported solution and is not officially supported by Microsoft Product Support.

## Quick Reference

### Common Commands
- **View environment variables**: Solutions → Core Components → Environment variables
- **Run inventory**: Turn on "Admin | Sync Template v4 (Driver)" flow
- **Check flow history**: Power Automate → Cloud flows → Select flow → Run history

### Common Configurations
| Task | Location | Reference |
|------|----------|-----------|
| Configure audit logs | CoE Setup & Upgrade Wizard → Inventory / Audit Logs | [Guide](docs/coe-knowledge/TROUBLESHOOT-AuditLogs-Office365ManagementAPI.md) |
| Set environment variables | CoE Setup & Upgrade Wizard | [Common Responses](docs/coe-knowledge/COE-Kit-Common-GitHub-Responses.md#environment-variables-and-managed-solutions) |
| Run full inventory | Admin \| Sync Template v4 (Driver) flow | [Common Responses](docs/coe-knowledge/COE-Kit-Common-GitHub-Responses.md#running-full-inventory) |
| Upgrade CoE Kit | Import solution with "Upgrade" option | [Common Responses](docs/coe-knowledge/COE-Kit-Common-GitHub-Responses.md#upgrading-coe-starter-kit) |

## Contributing

Found a solution to a problem not documented here? Please contribute!
1. Create a new troubleshooting guide in `docs/coe-knowledge/`
2. Update the [knowledge base README](docs/coe-knowledge/README.md)
3. Submit a pull request

See [HOW_TO_CONTRIBUTE.md](HOW_TO_CONTRIBUTE.md) for contribution guidelines.

---

**Last Updated**: 2026-01-07
