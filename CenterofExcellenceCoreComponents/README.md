# Center of Excellence - Core Components

The Core Components solution contains the fundamental inventory, analytics, and compliance capabilities of the CoE Starter Kit.

## Prerequisites

Before installing the Core Components solution, ensure you have met all prerequisites:

### Required Solutions
1. **Creator Kit** (Required)
   - **Download:** https://aka.ms/creatorkitdownload
   - **Why:** The CoE Setup Wizard uses PowerCAT PCF controls (FluentDetailsList, Shimmer controls)
   - **Install:** Must be installed **before** the Core Components
   
2. **Power Virtual Agents** (Optional, required for Copilot features)
   - Automatically included with appropriate licenses
   - Required if using Setup Wizard Copilot features

### Service Account Setup
The service account used for CoE administration requires:
- ✅ Must be a **user account** (not service principal or app registration)
- ✅ **Power Apps Per User** or **Power Apps Premium** license
- ✅ **Power Platform Admin** role in Microsoft Entra ID
- ✅ **System Administrator** role in the CoE environment

### Environment Configuration
- ✅ Environment has a Dataverse database provisioned
- ✅ **English (1033)** language pack is enabled
- ✅ DLP policies allow required connectors (HTTP with Azure AD, Dataverse, Office 365 Outlook)

## Installation

1. **Install Creator Kit first** from [AppSource](https://aka.ms/creatorkitdownload)
2. Configure service account with appropriate licenses and roles
3. Import the **CenterofExcellenceCoreComponents** managed solution
4. Launch the **CoE Setup and Upgrade Wizard** app
5. Follow the guided setup process

## Common Issues

### Error loading control
If you see "Error loading control" in the Setup Wizard:
- Verify Creator Kit is installed
- Clear your browser cache completely
- Try opening in InPrivate/Incognito mode
- Verify English language pack is enabled

**Full troubleshooting steps:** [TROUBLESHOOTING-SETUP-WIZARD.md](../CenterofExcellenceResources/TROUBLESHOOTING-SETUP-WIZARD.md)

### Cannot add service account as System Administrator
If role assignment fails:
- Verify service account has Power Apps Per User or Premium license
- Confirm it's a user account (not service principal)
- Wait 15-30 minutes after assigning licenses
- Try assigning via PowerShell as alternative method

**Full troubleshooting steps:** [TROUBLESHOOTING-SETUP-WIZARD.md](../CenterofExcellenceResources/TROUBLESHOOTING-SETUP-WIZARD.md)

## Documentation

- **Quick Setup Checklist:** [QUICK-SETUP-CHECKLIST.md](../CenterofExcellenceResources/QUICK-SETUP-CHECKLIST.md)
- **Troubleshooting Guide:** [TROUBLESHOOTING-SETUP-WIZARD.md](../CenterofExcellenceResources/TROUBLESHOOTING-SETUP-WIZARD.md)
- **Official Documentation:** https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components
- **FAQ:** https://learn.microsoft.com/power-platform/guidance/coe/faq

## Support

- **Issues:** https://github.com/microsoft/coe-starter-kit/issues
- **Community:** https://powerusers.microsoft.com/t5/Power-Apps-Governance-and/bd-p/Admin_PowerApps
- **Microsoft Support:** Via Power Platform Admin Center

## Version

**Current Version:** See [releases](https://github.com/microsoft/coe-starter-kit/releases) for the latest version  
**Release Notes:** [View releases](https://github.com/microsoft/coe-starter-kit/releases)

---

For complete installation and configuration instructions, visit the [official documentation](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components).
