# CoE Starter Kit Core Components - PowerShell Scripts

This folder contains PowerShell scripts to help manage and troubleshoot the CoE Starter Kit Core Components.

## Available Scripts

### Update-FullInventoryEnvVar.ps1

Updates the `admin_FullInventory` environment variable value when it appears locked or read-only in the Power Platform admin center.

**Usage:**
```powershell
.\Update-FullInventoryEnvVar.ps1 -EnvironmentId "YOUR_ENVIRONMENT_GUID" -Value "no"
```

**Parameters:**
- `EnvironmentId` (required): The GUID of your CoE environment
- `Value` (required): "yes" for full inventory, "no" for incremental inventory
- `TenantId` (optional): Azure AD tenant ID if you need to specify a different tenant

**Prerequisites:**
- PowerShell 5.1 or later
- `Microsoft.PowerApps.Administration.PowerShell` module
- Power Platform Administrator or System Administrator permissions

**When to use this script:**
- The FullInventory environment variable appears read-only/locked in the UI
- You have a large tenant (10,000+ resources) and need to switch to incremental inventory
- You're experiencing inventory timeouts or incomplete updates

For more information, see [TROUBLESHOOTING-INVENTORY.md](../../TROUBLESHOOTING-INVENTORY.md)

## Installation

### Install Required PowerShell Module

Before running any scripts, install the required PowerShell module:

```powershell
Install-Module -Name Microsoft.PowerApps.Administration.PowerShell -Scope CurrentUser
```

### Running Scripts

1. Open PowerShell (or PowerShell ISE)
2. Navigate to the Scripts folder
3. Run the desired script with appropriate parameters

**Example:**
```powershell
cd "C:\path\to\coe-starter-kit\CenterofExcellenceCoreComponents\Scripts"
.\Update-FullInventoryEnvVar.ps1 -EnvironmentId "12345678-1234-1234-1234-123456789012" -Value "no"
```

## Troubleshooting

If you encounter errors when running scripts:

1. **Module not found**: Install the Microsoft.PowerApps.Administration.PowerShell module
2. **Access denied**: Ensure you have Power Platform Administrator or System Administrator permissions
3. **Environment not found**: Verify the Environment ID is correct
4. **Authentication failed**: Run `Add-PowerAppsAccount` to re-authenticate

For more help, see:
- [CoE Starter Kit Documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- [Inventory Troubleshooting Guide](../../TROUBLESHOOTING-INVENTORY.md)
- [GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues)

## Contributing

If you create useful scripts for managing the CoE Starter Kit, please consider contributing them back to the repository. See [HOW_TO_CONTRIBUTE.md](../../HOW_TO_CONTRIBUTE.md) for guidelines.
