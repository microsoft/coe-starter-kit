# CoE Audit Components

The CoE Audit Components (also known as Governance Components) provide additional governance and compliance capabilities to help administrators manage and monitor Power Platform usage.

## Overview

This solution extends the Core Components with governance-focused features:
- Compliance processes and automation
- App and flow archival workflows
- Risk assessments
- Developer compliance tracking
- Quarantine and exception management

## Documentation

### Related Documentation

- **[Audit Log Components Setup](../CenterofExcellenceAuditLogs/README.md)** - For Office 365 audit log collection
- **[Azure Key Vault Setup](../CenterofExcellenceAuditLogs/AZURE-KEYVAULT-SETUP.md)** - If using Key Vault for secure credential storage
- **[Troubleshooting Guide](../CenterofExcellenceAuditLogs/TROUBLESHOOTING.md)** - Solutions for common configuration issues
- **Official Setup Documentation** - https://docs.microsoft.com/power-platform/guidance/coe/before-setup-gov

## Prerequisites

Before setting up the Audit Components, ensure you have:

1. **CoE Core Components** installed and running
2. **Inventory Data** collected from Core Components
3. **Power Platform Administrator** access
4. **Appropriate Licenses**:
   - Power Apps/Power Automate licenses
   - Office 365 licenses for users

## Key Components

### Canvas Apps
- **Compliance Hub** - Central governance dashboard
- **Developer Compliance Center** - Self-service compliance tracking
- **App Quarantine** - Manage quarantined apps

### Flows
- **Archive and Clean Up Flows** - Automated resource management
- **Compliance Process Flows** - Governance workflow automation
- **Risk Assessment Flows** - Automated risk scoring

### Tables
- Compliance tracking tables
- Archival history tables
- Exception management tables

## Setup Instructions

1. **Import the Solution**
   - Download from [CoE Starter Kit Releases](https://github.com/microsoft/coe-starter-kit/releases)
   - Import `CenterofExcellenceAuditComponents_x.xx_managed.zip`

2. **Configure Environment Variables**
   - Set organization-specific settings
   - Configure thresholds and policies

3. **Turn On Flows**
   - Enable flows based on your governance requirements
   - Set appropriate schedules

4. **Share Apps**
   - Share governance apps with administrators
   - Configure security roles

## Integration with Audit Logs

The Audit Components work best when combined with Audit Log Components:

- **Audit Log Components** collect raw Office 365 audit data
- **Audit Components (Governance)** provide workflows and apps to act on that data

For issues related to audit log collection (Office 365 Management API), see:
- [Audit Log Troubleshooting](../CenterofExcellenceAuditLogs/TROUBLESHOOTING.md)
- [Azure Key Vault Setup](../CenterofExcellenceAuditLogs/AZURE-KEYVAULT-SETUP.md)

## Common Setup Scenarios

### Scenario 1: Using Azure Key Vault for Secrets

If your governance workflows require Azure AD authentication or API access:

1. Follow the [Azure Key Vault Setup Guide](../CenterofExcellenceAuditLogs/AZURE-KEYVAULT-SETUP.md)
2. Register Microsoft.PowerPlatform provider in your Azure subscription
3. Configure environment variables with Key Vault references

### Scenario 2: Governance Without Audit Logs

You can use Audit Components for governance without collecting Office 365 audit logs:

1. Ensure Core Components are collecting inventory data
2. Install Audit Components
3. Configure governance policies based on inventory data
4. Skip Audit Log components if not needed

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│  CoE Core Components                                         │
│  (Inventory Data Collection)                                 │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           │ Provides Data
                           ▼
┌─────────────────────────────────────────────────────────────┐
│  Dataverse (CoE Tables)                                     │
│  ├─ Environments                                             │
│  ├─ Apps                                                     │
│  ├─ Flows                                                    │
│  └─ Connectors                                              │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           │ Reads/Updates
                           ▼
┌─────────────────────────────────────────────────────────────┐
│  Audit Components (Governance)                               │
│  ├─ Compliance Hub App                                       │
│  ├─ Risk Assessment Flows                                    │
│  ├─ Archive Flows                                           │
│  └─ Developer Compliance Center                             │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           │ Optionally Integrates With
                           ▼
┌─────────────────────────────────────────────────────────────┐
│  Audit Log Components (Optional)                             │
│  └─ Office 365 Audit Data                                   │
└─────────────────────────────────────────────────────────────┘
```

## Getting Help

### Common Issues

For Azure Key Vault and authentication issues, see:
- [Troubleshooting Guide](../CenterofExcellenceAuditLogs/TROUBLESHOOTING.md)

### Support Channels

1. **Documentation**: https://docs.microsoft.com/power-platform/guidance/coe/governance-components
2. **GitHub Issues**: https://github.com/microsoft/coe-starter-kit/issues
3. **Community Forums**: https://powerusers.microsoft.com/t5/Power-Apps-Governance-and/bd-p/Admin_PowerApps

## Contributing

We welcome contributions! Please see:
- [Contributing Guidelines](../CONTRIBUTING.md)
- [How to Contribute](../HOW_TO_CONTRIBUTE.md)

## License

This project is licensed under the MIT License - see the [LICENSE](../LICENSE) file for details.

---

**Last Updated**: 2025-11-03  
**Version**: 1.0  
**Maintained By**: CoE Starter Kit Team  
**Repository**: https://github.com/microsoft/coe-starter-kit
