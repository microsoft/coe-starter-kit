# CoE Audit Log Components

The CoE Audit Log components enable you to collect and analyze audit logs from Office 365 Management APIs to gain insights into Power Platform usage and governance.

## Overview

This solution provides:
- Automated collection of Office 365 audit logs for Power Platform activities
- Integration with Azure Key Vault for secure credential storage
- Scheduled synchronization of audit data to Dataverse
- Analytics and reporting capabilities through Power BI

## Documentation

### Setup Guides

- **[Azure Key Vault Setup](./AZURE-KEYVAULT-SETUP.md)** - Step-by-step guide for configuring Azure Key Vault integration
- **Official Setup Documentation** - https://docs.microsoft.com/power-platform/guidance/coe/setup-auditlog

### Troubleshooting

- **[Troubleshooting Guide](./TROUBLESHOOTING.md)** - Solutions for common issues including:
  - Azure Key Vault access errors
  - Microsoft.PowerPlatform resource provider registration
  - Authentication and permission issues
  - Data synchronization problems

## Prerequisites

Before setting up the Audit Log components, ensure you have:

1. **CoE Core Components** installed
2. **Azure Subscription** with appropriate permissions
3. **Azure AD App Registration** configured for Office 365 Management APIs
4. **Required Licenses**:
   - Office 365 E3/E5 or Microsoft 365 E3/E5
   - Power Apps/Power Automate licenses for running the solution
5. **Permissions**:
   - Power Platform Administrator access
   - Azure Subscription Contributor or Owner
   - Azure AD Global Administrator (for API consent)

## Quick Start

### 1. Register Microsoft.PowerPlatform Provider

⚠️ **Important**: This is a critical first step that must be completed before using Key Vault with Power Platform.

```bash
# Via Azure CLI
az provider register --namespace Microsoft.PowerPlatform
```

See [Azure Key Vault Setup Guide](./AZURE-KEYVAULT-SETUP.md) for detailed instructions.

### 2. Configure Azure Key Vault

1. Create or identify your Azure Key Vault
2. Add access policy for `Microsoft.PowerPlatform` service principal
3. Store your client secret in the Key Vault
4. Configure environment variables with Key Vault references

See [Azure Key Vault Setup Guide](./AZURE-KEYVAULT-SETUP.md) for detailed instructions.

### 3. Import the Solution

1. Download the latest release: [CoE Starter Kit Releases](https://github.com/microsoft/coe-starter-kit/releases)
2. Import `CenterofExcellenceAuditLogs_x.xx_managed.zip` to your environment
3. Configure environment variables
4. Turn on the flows

### 4. Verify Setup

1. Run "Admin | Audit Logs | Start Audit Log subscription"
2. Wait 24-48 hours for initial data collection
3. Check "Admin | Audit Logs | Sync Audit Logs" for successful runs

## Components Included

### Flows

- **Admin | Audit Logs | Start Audit Log subscription** - Initializes the Office 365 Management API subscription
- **Admin | Audit Logs | Office 365 Management API | Subscription** - Manages the subscription lifecycle
- **Admin | Audit Logs | Sync Audit Logs** - Scheduled flow that retrieves and stores audit logs

### Data Tables

- **Audit Log** - Stores the collected audit log entries
- Additional supporting tables for configuration and status tracking

## Common Issues

### Issue: "Microsoft.PowerPlatform provider is not registered"

**Solution**: Register the provider in your Azure subscription. See [Troubleshooting Guide](./TROUBLESHOOTING.md#error-microsoftpowerplatform-provider-not-registered) for detailed steps.

### Issue: "Invalid client secret provided"

**Solution**: Ensure you're using the secret VALUE, not the secret ID. See [Troubleshooting Guide](./TROUBLESHOOTING.md#error-invalid-client-secret-provided) for detailed steps.

### Issue: "Access denied" to Key Vault

**Solution**: Configure access policies for Microsoft.PowerPlatform. See [Azure Key Vault Setup Guide](./AZURE-KEYVAULT-SETUP.md#3-configure-key-vault-access) for detailed steps.

### Issue: No audit logs appearing

**Solution**: Office 365 audit logs have a delay. Wait 24-48 hours and verify flow execution. See [Troubleshooting Guide](./TROUBLESHOOTING.md#issue-audit-logs-not-appearing-in-coe-dashboard) for detailed steps.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│  Office 365 Management APIs                                 │
│  (Audit Log Content)                                        │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           │ HTTPS
                           ▼
┌─────────────────────────────────────────────────────────────┐
│  Power Automate Flows                                        │
│  ├─ Start Subscription                                       │
│  ├─ Manage Subscription                                      │
│  └─ Sync Audit Logs (Scheduled)                             │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           │ Authentication
                           ▼
┌─────────────────────────────────────────────────────────────┐
│  Azure Key Vault                                             │
│  └─ Client Secret (Secure Storage)                          │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           │ Reads Secret
                           ▼
┌─────────────────────────────────────────────────────────────┐
│  Azure AD App Registration                                   │
│  └─ Office 365 Management API Permissions                   │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           │ Stores Data
                           ▼
┌─────────────────────────────────────────────────────────────┐
│  Dataverse (Audit Log Table)                                │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           │ Data Source
                           ▼
┌─────────────────────────────────────────────────────────────┐
│  Power BI Reports                                            │
│  (CoE Dashboard - Audit Logs)                               │
└─────────────────────────────────────────────────────────────┘
```

## Security Considerations

1. **Secure Credential Storage**: Use Azure Key Vault for storing client secrets
2. **Principle of Least Privilege**: Grant only necessary permissions to service principals
3. **Regular Secret Rotation**: Set calendar reminders to rotate secrets before expiration
4. **Audit Monitoring**: Review audit logs regularly for suspicious activity
5. **Network Security**: Consider using Private Link for Key Vault access in enterprise scenarios

## Data Privacy

The Audit Log components collect and store:
- User activities within Power Platform (app usage, flow runs, etc.)
- Connector usage information
- Environment and resource metadata

Ensure compliance with your organization's data retention and privacy policies.

## Limitations

- **Audit Log Delay**: Office 365 audit logs can have up to 24-hour delay
- **API Throttling**: Office 365 Management API has rate limits
- **Retention Period**: Audit logs are retained for 7 days in Office 365, then must be stored in your solution
- **Licensing Requirements**: Requires Office 365 E3/E5 or Microsoft 365 E3/E5

## Support

### Documentation
- [CoE Starter Kit Official Documentation](https://docs.microsoft.com/power-platform/guidance/coe/starter-kit)
- [Setup Guide for Audit Logs](https://docs.microsoft.com/power-platform/guidance/coe/setup-auditlog)
- [Troubleshooting Guide](./TROUBLESHOOTING.md)

### Community Support
- [GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues)
- [Power Platform Community](https://powerusers.microsoft.com/t5/Power-Apps-Governance-and/bd-p/Admin_PowerApps)

### Reporting Issues
If you encounter a bug:
1. Check the [Troubleshooting Guide](./TROUBLESHOOTING.md)
2. Search [existing issues](https://github.com/microsoft/coe-starter-kit/issues)
3. [Create a new issue](https://github.com/microsoft/coe-starter-kit/issues/new/choose) using the bug report template

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
