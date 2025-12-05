# Center of Excellence - Core Components

The CoE Core Components solution contains the core data model, apps, and flows that form the foundation of the Center of Excellence (CoE) Starter Kit.

## Overview

The Core Components solution provides:
- **Data Model**: Dataverse tables to store inventory data about apps, flows, connectors, makers, and environments
- **Canvas Apps**: User-facing applications for app catalog, admin tools, and reporting
- **Cloud Flows**: Automation for data collection, compliance, and governance
- **Model-Driven Apps**: Admin interfaces for managing CoE data
- **Environment Variables**: Configuration settings for customization

## Prerequisites

Before installing the Core Components solution, ensure the following dependencies are installed:

### Required Solutions
1. **Power Platform Creator Kit** (Minimum version: 1.0.20241119.01)
   - Download from: [Microsoft Creator Kit on AppSource](https://aka.ms/creatorkitdownload)
   - The Creator Kit provides modern UI components used by several CoE apps
   - **Critical**: Many apps (App Catalog, Command Center, etc.) will not display correctly without the Creator Kit

2. **PowerCAT Toolkit** (Minimum version: 1.0.20250205.2)
   - Typically installed automatically with Creator Kit
   - Provides component library for PCF controls

### Environment Settings
- **PCF Controls Enabled**: Power Apps Component Framework for canvas apps must be enabled in your environment
  - Enable in Power Platform Admin Center > Environment > Settings > Product > Features
  - Turn on "Power Apps component framework for canvas apps"

## Installation

### New Installation
1. Install the **Creator Kit** from AppSource (see Prerequisites above)
2. Download the latest CoE Starter Kit release from [GitHub Releases](https://github.com/microsoft/coe-starter-kit/releases)
3. Import the **CenterofExcellenceCoreComponents** managed solution to your environment
4. Select **"Install dependent solutions"** when prompted to ensure Creator Kit is included
5. Configure environment variables and connection references
6. Follow the setup guide: [CoE Starter Kit Setup](https://learn.microsoft.com/power-platform/guidance/coe/setup)

### Upgrade from Previous Version
1. Ensure Creator Kit is installed (see Prerequisites)
2. Download the latest CoE Starter Kit release
3. Import the new version of **CenterofExcellenceCoreComponents** as an upgrade
4. Update any environment variables as needed
5. Follow the upgrade guide: [CoE Starter Kit Upgrade](https://learn.microsoft.com/power-platform/guidance/coe/after-setup)

## Key Applications

### App Catalog
A user-friendly catalog of apps available in your organization, allowing users to:
- Browse and search for apps
- Request access to apps
- Provide feedback to app makers

**Note**: Requires Creator Kit to display properly. See [Troubleshooting Guide](./TROUBLESHOOTING.md) if UI is not displaying.

### Admin - Command Center  
Central hub for CoE administrators to:
- View environment and tenant overview
- Monitor compliance and governance
- Access admin tools and reports

### DLP Editor
Tool for managing Data Loss Prevention (DLP) policies.

### Power BI Dashboard Manager
Manage Power BI dashboard inventory and governance.

## Troubleshooting

If you experience issues with apps not displaying correctly (blank screens, missing controls), see the [Troubleshooting Guide](./TROUBLESHOOTING.md).

Common issues:
- **Blank or incomplete UI in App Catalog**: Creator Kit not installed → [Solution](./TROUBLESHOOTING.md#app-catalog-ui-not-displaying-correctly)
- **PCF controls not rendering**: PCF not enabled in environment → [Solution](./TROUBLESHOOTING.md#verify-pcf-controls-are-enabled-in-your-environment)
- **Connection errors**: Connection references not configured → [Configure connections](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components)

## Documentation

- **Official Documentation**: [CoE Starter Kit Documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- **Setup Guide**: [Setup Core Components](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components)
- **Troubleshooting**: [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)
- **GitHub Issues**: [Report bugs or request features](https://github.com/microsoft/coe-starter-kit/issues)

## Solution Components

### Canvas Apps
- Admin - Command Center
- App Catalog
- DLP Editor v2
- Power BI Dashboard Manager
- Set App Permissions
- Template Catalog Wizard

### Model-Driven Apps
- Power Platform Admin View

### Cloud Flows
- Admin | Sync Template v4 (Apps)
- Admin | Sync Template v4 (Flows)
- Admin | Sync Template v4 (Connectors)
- Admin | Sync Template v4 (Custom Connectors)
- And many more...

### Dataverse Tables
- Power Apps App
- Cloud Flow
- Connection
- Connector
- Environment
- Maker
- And many more...

## Support

The CoE Starter Kit is provided as-is without official Microsoft support. For assistance:

1. **Check Documentation**: [Microsoft Learn - CoE Starter Kit](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
2. **Review Troubleshooting**: [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)
3. **Search Issues**: [GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues)
4. **Ask Community**: [Power Platform Community](https://powerusers.microsoft.com/)
5. **Report Bug**: [Create New Issue](https://github.com/microsoft/coe-starter-kit/issues/new/choose)

## Version Information

Current solution source version aligns with the latest release. Check [Releases](https://github.com/microsoft/coe-starter-kit/releases) for version history and changelogs.

## License

This project is licensed under the MIT License - see the [LICENSE](../LICENSE) file for details.
