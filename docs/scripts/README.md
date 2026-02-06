# CoE Starter Kit Scripts

This directory contains PowerShell and other scripts to help with common CoE Starter Kit administration and maintenance tasks.

## Available Scripts

### Export-DLPImpactAnalysis.ps1

**Purpose**: Export DLP Impact Analysis data from Dataverse to CSV file when the Canvas app or model-driven app export times out.

**Use Case**: When you have a large number of impacted apps/flows from DLP policy analysis (e.g., > 2,000 records), this script retrieves and exports all data using pagination.

**Prerequisites**:
- PowerShell 5.1 or higher
- Microsoft.Xrm.Data.PowerShell module: `Install-Module Microsoft.Xrm.Data.PowerShell`
- System Administrator or equivalent role in the CoE environment

**Usage Examples**:

```powershell
# Export all DLP Impact Analysis records
.\Export-DLPImpactAnalysis.ps1 -EnvironmentUrl "https://contoso.crm.dynamics.com"

# Export records for a specific DLP policy
.\Export-DLPImpactAnalysis.ps1 -EnvironmentUrl "https://contoso.crm.dynamics.com" -DLPPolicyName "Strict Policy"

# Export records from the last 30 days only
.\Export-DLPImpactAnalysis.ps1 -EnvironmentUrl "https://contoso.crm.dynamics.com" -DaysBack 30

# Export to a specific file location
.\Export-DLPImpactAnalysis.ps1 -EnvironmentUrl "https://contoso.crm.dynamics.com" -OutputPath "C:\Exports\DLPImpact.csv"
```

**Related Documentation**: See [DLP Impact Analysis Export Timeout Troubleshooting](../troubleshooting/dlp-impact-analysis-export-timeout.md) for complete guidance on handling large exports.

## Installation

### Installing Microsoft.Xrm.Data.PowerShell

Most scripts in this directory require the Microsoft.Xrm.Data.PowerShell module. Install it using:

```powershell
Install-Module Microsoft.Xrm.Data.PowerShell -Scope CurrentUser
```

If you encounter issues, you may need to update PowerShellGet first:

```powershell
Install-Module PowerShellGet -Force -Scope CurrentUser
```

### Execution Policy

If you receive an execution policy error, you may need to adjust your PowerShell execution policy:

```powershell
# View current policy
Get-ExecutionPolicy

# Set to RemoteSigned (recommended for scripts)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## Security Considerations

- **Credentials**: Scripts use interactive authentication. Never hardcode credentials in scripts.
- **Data Export**: Exported CSV files may contain sensitive information. Store them securely and delete when no longer needed.
- **Execution**: Only run scripts from trusted sources. Review script contents before execution.
- **Permissions**: Scripts require appropriate permissions in your environment. Use least-privilege access where possible.

## Contributing

If you've created a useful script for CoE Starter Kit administration:

1. Ensure it follows PowerShell best practices
2. Add comprehensive comment-based help
3. Test thoroughly in a non-production environment
4. Add an entry to this README
5. Submit a pull request

See [HOW_TO_CONTRIBUTE.md](../../HOW_TO_CONTRIBUTE.md) for more information.

## Getting Help

- **Script Issues**: Report issues on [GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues)
- **General Questions**: Ask in the [Power Apps Community Forum](https://powerusers.microsoft.com/t5/Power-Apps-Governance-and/bd-p/Admin_PowerApps)
- **Documentation**: See [CoE Starter Kit Documentation](https://learn.microsoft.com/en-us/power-platform/guidance/coe/starter-kit)

## Disclaimer

These scripts are provided as-is without warranty. Always test scripts in a development or test environment before running in production. Review and understand what each script does before execution.
