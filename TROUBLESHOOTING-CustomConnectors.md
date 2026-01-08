# Troubleshooting: Custom Connectors Inventory Sync Issues

## Issue: "PermissionBlockedByOfficeAI" Error

### Symptoms
The "Admin | Sync Template v4 (Custom Connectors)" flow fails with the error:
```
The user with object id '....' in tenant '...' does not have access to permission 'ManageAnyCustomApi' in environment '....'. Error Code: 'PermissionBlockedByOfficeAI'.
```

### Root Cause
This error occurs when Microsoft's AI governance controls block the `ManageAnyCustomApi` permission in specific environments. This is a security feature introduced to protect environments that contain Copilot Studio bots, custom connectors used by AI features, or other AI-related resources.

The `PermissionBlockedByOfficeAI` error code indicates that even though the user has the Power Platform Admin role, the specific environment has additional AI governance restrictions that prevent administrative access to custom connector management operations.

### Who is Affected
- Users with Power Platform Admin role attempting to inventory custom connectors
- Environments with Copilot Studio (formerly Power Virtual Agents) enabled
- Environments with AI Builder or Copilot features that use custom connectors
- Environments where Microsoft has enabled enhanced AI governance controls

### Required Permissions
To successfully run the Custom Connectors sync flow, the user account needs:

1. **Power Platform Administrator** role in Entra ID (Azure AD)
2. **System Administrator** role in the target environments (for Dataverse-enabled environments)
3. **No AI governance restrictions** on the `ManageAnyCustomApi` permission

### Resolution Steps

#### Option 1: Request AI Governance Exception (Recommended)
1. Contact your Microsoft tenant administrator or Global Administrator
2. Request an exception for the CoE service account to access custom connectors in AI-governed environments
3. Document the business justification (CoE inventory and governance purposes)
4. The admin can grant exceptions through the Power Platform Admin Center under environment security settings

#### Option 2: Use Alternative Service Account
1. Create a dedicated service account specifically for CoE Starter Kit
2. Ensure this account is not subject to AI governance restrictions
3. Grant this account:
   - Power Platform Administrator role in Entra ID
   - System Administrator role in all target environments
4. Update the CoE flow connections to use this service account

#### Option 3: Exclude AI-Governed Environments (Workaround)
If the above options are not feasible, you can exclude specific environments from custom connector inventory:

1. Navigate to the **admin_environment** table in your CoE Dataverse environment
2. For environments that fail with this error, set the **admin_excusefrominventory** field to **Yes**
3. The sync flow will skip these environments for custom connector inventory
4. Document which environments are excluded and review periodically

#### Option 4: Use PowerShell for Manual Inventory (Advanced)
For environments that cannot be accessed via the flow, you can manually inventory custom connectors using PowerShell:

```powershell
# Install the Power Platform Admin PowerShell module if not already installed
Install-Module -Name Microsoft.PowerApps.Administration.PowerShell

# Connect to Power Platform
Add-PowerAppsAccount

# Get custom connectors for a specific environment
$envId = "your-environment-id"
$connectors = Get-AdminPowerAppConnector -EnvironmentName $envId -ConnectorName * | Where-Object {$_.Internal -eq $false}

# Export to CSV for manual import to CoE
$connectors | Export-Csv -Path "CustomConnectors-$envId.csv" -NoTypeInformation
```

### Prevention
To prevent this issue in future deployments:

1. **Plan your CoE service account**: Create a dedicated service account before implementing CoE Starter Kit
2. **Review AI governance policies**: Understand your organization's AI governance controls and exceptions
3. **Document exceptions**: Maintain documentation of which environments require special handling
4. **Regular reviews**: Periodically review and update AI governance exceptions as your environment evolves

### Additional Resources
- [Power Platform for Admins connector documentation](https://learn.microsoft.com/connectors/powerplatformforadmins/)
- [CoE Starter Kit Setup Instructions](https://learn.microsoft.com/power-platform/guidance/coe/setup)
- [Power Platform Admin PowerShell](https://learn.microsoft.com/power-platform/admin/powershell-getting-started)
- [Copilot Studio Security and Governance](https://learn.microsoft.com/microsoft-copilot-studio/admin-share-bots)

### Related Issues
- Environment-level security policies blocking admin operations
- AI Builder capacity and licensing restrictions
- Dataverse for Teams environments with limited admin access

### Notes
- This is not a bug in the CoE Starter Kit, but a platform-level security control
- The restriction is environment-specific and may not affect all environments in your tenant
- Microsoft may update or change AI governance policies; this troubleshooting guide reflects current behavior as of December 2025

---

## Need More Help?
If none of these solutions work for your scenario:
1. Check the [CoE Starter Kit GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues) for similar problems
2. Create a new issue with detailed error information, including:
   - Full error message and stack trace
   - Environment type (Production, Sandbox, Developer, Teams)
   - Copilot Studio or AI Builder usage in the environment
   - Service account roles and permissions
3. Engage with the Power Platform community on the [Power Apps Community Forums](https://powerusers.microsoft.com/t5/Power-Apps-Community/ct-p/PowerApps1)
