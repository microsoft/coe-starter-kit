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
- **Copilot Agents FAQ:** [FAQ-COPILOT-AGENTS-SUPPORT.md](./FAQ-COPILOT-AGENTS-SUPPORT.md)
- **PVA Sync Troubleshooting:** [TROUBLESHOOTING-PVA-SYNC.md](./TROUBLESHOOTING-PVA-SYNC.md)
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
This solution contains the core components for the CoE Starter Kit, including inventory flows, environment management, and telemetry collection.

## ⚠️ Critical: DLP Policy Operations Warning

**IMPORTANT**: When working with DLP (Data Loss Prevention) policies using the CoE Starter Kit tools, be aware of potential risks:

- The **DLP Impact Analysis** tool is designed for **analysis and impact assessment only**
- For **production DLP policy operations** (create, copy, modify, delete), use the **[Power Platform Admin Center](https://admin.powerplatform.microsoft.com)** directly
- Copying or rapidly modifying DLP policies through automation can cause **unintended tenant-wide enforcement**
- DLP policy evaluations are cached for 2-4 hours and may persist even after policy deletion

📖 **See**: [Troubleshooting DLP Policy Scope Issues](../Documentation/TROUBLESHOOTING-DLP-POLICY-SCOPE.md) for detailed guidance and prevention strategies.

## Troubleshooting Guides

### DLP and Policy Issues

- **[DLP Policy Scope Issues](../Documentation/TROUBLESHOOTING-DLP-POLICY-SCOPE.md)** - Critical guidance for preventing and resolving tenant-wide DLP enforcement issues

### Inventory and Sync Issues

- **[Power Platform Admin View Not Showing Updated Apps or Missing Environments](../docs/troubleshooting/admin-view-missing-data.md)** - Comprehensive guide for resolving issues where the Admin View app doesn't display all apps or environments after an upgrade
- **[PVA/Copilot Studio Sync Issues](./TROUBLESHOOTING-PVA-SYNC.md)** - Guide for resolving issues where not all bots appear in the inventory
- **[Desktop Flows Sync Issues](./TROUBLESHOOTING-DESKTOP-FLOW-SYNC.md)** - Guide for resolving issues where desktop flows are missing from the inventory

### App Issues

- **[AppForbidden Error in CoE Admin Command Center](../docs/TROUBLESHOOTING-DLP-APPFORBIDDEN.md)** - Resolve DLP policy errors when opening the Flows section in the Admin Command Center

### Security and Access

- **[Security Roles FAQ](../CenterofExcellenceResources/FAQ-SecurityRoles.md)** - Guide for understanding and assigning CoE security roles to grant users access to CoE apps

### Common Questions

**Q: Why aren't all my resources showing up in the inventory?**

A: The inventory flows run in incremental mode by default, which only syncs new or recently modified resources. To capture all resources, you need to run a full inventory by setting the `admin_FullInventory` environment variable to `Yes`. Remember to set it back to `No` after the full inventory completes.

**Q: How often do the inventory flows run?**

A: The inventory flows are triggered when environment records are created or updated in the CoE Dataverse environment. The Admin | Sync Template v4 (Driver) flow typically runs on a schedule to update environment records, which then triggers the individual sync flows.

**Q: What does "skipped" mean in the flow run history?**

A: "Skipped" branches are normal and indicate that a conditional branch was not executed because the condition was not met. For example, if you're running in incremental mode, the "full inventory" branch will be skipped. This is expected behavior.

## Environment Variables

Key environment variables that control inventory behavior:

- `admin_FullInventory` - Run full inventory (Yes/No, default: No)
- `admin_InventoryFilter_DaysToLookBack` - Days to look back for modified resources (default: 7)
- `admin_DelayObjectInventory` - Add random delay to avoid throttling (Yes/No, default: No)
- `admin_isFullTenantInventory` - Track all environments or a subset (Yes/No, default: Yes)

For detailed guidance on reducing action consumption and optimizing flow performance in large tenants, see the **[Flow Action Consumption Optimization Guide](../CenterofExcellenceResources/FlowActionConsumptionOptimization.md)**.

## Additional Documentation

- [CoE Starter Kit Documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- [Setup Core Components](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components)
