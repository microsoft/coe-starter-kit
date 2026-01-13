# Developer Compliance Center App Module

## Overview
The Developer Compliance Center is a model-driven app that allows makers to view and manage compliance for their Power Platform resources (apps, flows, bots, custom connectors, etc.).

## Security Roles

This app is configured with the following security role mappings to control access:

### Power Platform Maker SR
- **Role ID**: `{3e6126b5-2589-e911-a856-000d3a372932}`
- **Purpose**: Grants makers access to view and manage their own resources
- **Source**: Defined in the **CenterofExcellenceCoreComponents** solution
- **Note**: This is the primary role that should be assigned to makers who need access to the Developer Compliance Center

### System Administrator Role
- **Role ID**: `{627090ff-40a3-4053-8790-584edc5be201}`
- **Purpose**: Default system administrator role for full administrative access

### System Customizer Role  
- **Role ID**: `{119f245c-3cc8-4b62-b31c-d1a046ced15d}`
- **Purpose**: Default system customizer role for customization access

## Sharing the App

When sharing the Developer Compliance Center app with makers:

1. Navigate to the app in the Power Platform Maker Portal
2. Click **Share** 
3. Add the users or security groups
4. Select the **Power Platform Maker SR** security role
5. Click **Share**

The **Power Platform Maker SR** role will now appear in the security role dropdown when sharing the app, provided that the **CenterofExcellenceCoreComponents** solution has been installed in the environment.

## Prerequisites

- The **CenterofExcellenceCoreComponents** solution must be installed first, as it contains the **Power Platform Maker SR** security role definition
- The **CenterofExcellenceAuditComponents** solution depends on the Core Components solution

## Troubleshooting

### "Power Platform Maker SR" role not appearing in share dialog

**Cause**: The security role is defined in the Core Components solution but wasn't originally referenced in the Developer Compliance Center app module configuration.

**Solution**: This has been fixed in recent versions by adding the role reference to the app module. If you're using an older version:
1. Ensure the CenterofExcellenceCoreComponents solution is installed
2. Upgrade to the latest version of CenterofExcellenceAuditComponents solution
3. The Power Platform Maker SR role should now appear in the share dialog

## Related Documentation

- [CoE Starter Kit Setup - Governance Components](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup-governance-components)
- [Power Platform Security Roles](https://learn.microsoft.com/en-us/power-platform/admin/database-security)
