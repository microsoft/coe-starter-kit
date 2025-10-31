# Per-App Licenses in PowerApps Apps Table

## Question

Is there a field in the PowerApps Apps table (admin_app) to see if an application has the option enabled: Per-app licenses?

We have more than 4,000 applications and have detected that this type of license has been assigned to more than 2,000 applications, and we need to locate them.

## Answer

### Overview

Currently, there is **no direct field** in the PowerApps for Admins connector (`admin_app` table) that explicitly shows whether an application has "per-app licenses" enabled or assigned. The per-app licensing model in Power Platform works differently than a simple app-level property.

### How Per-App Licensing Works

Per-app licenses in Power Platform are managed at the **environment and user level**, not as an app property:

1. **License Allocation**: Per-app licenses are allocated to environments through the Power Platform Admin Center (Capacity > Add-ons)
2. **License Assignment**: When you share an app with a user, the per-app license is automatically consumed/assigned to that user
3. **Not an App Property**: The "per-app license" is not a toggle or field that exists on the app itself

### Alternative Approaches to Identify Apps

While there's no direct field, you can use the following approaches to identify which apps are using per-app licenses:

#### 1. Check License Consumption via Power Platform Admin Center
- Navigate to **Power Platform Admin Center** > **Resources** > **Capacity**
- Review the **Add-ons** tab to see per-app license allocations by environment
- Check **Licensing** reports to see which users have per-app licenses assigned

#### 2. Use PowerApps for Admins Connector
While the connector doesn't have a "per-app license enabled" field, you can:
- Use `Get-AdminPowerApp` or the connector to retrieve app metadata
- Cross-reference apps with environment capacity data
- Track which apps use premium connectors (indicator of premium licensing needs)

#### 3. Custom Solution with CoE Starter Kit
Extend the CoE Starter Kit to track licensing:

```powershell
# Example PowerShell to check app details
Get-AdminPowerApp -EnvironmentName <env-id> -AppName <app-id>
```

Then cross-reference with license assignment data from:
- Microsoft Graph API for user license assignments
- Power Platform Admin APIs for environment capacity

#### 4. Audit App Sharing and Premium Connector Usage

Apps that likely use per-app licenses typically:
- Use premium connectors (Dataverse, SQL, etc.)
- Are shared with users who don't have per-user licenses
- Reside in environments with per-app license capacity allocated

### Recommended Workflow

To identify your 2,000+ apps with per-app licenses:

1. **Export Environment Capacity Data**
   - Use Power Platform Admin Center to export capacity/license data per environment
   - Identify environments with per-app license pools

2. **Cross-Reference with App Inventory**
   - Use CoE Starter Kit or PowerApps for Admins connector to list all apps
   - Filter apps by environment where per-app licenses are allocated

3. **Check Premium Connector Usage**
   - Apps using premium connectors (like Dataverse) require premium licensing
   - Use the CoE Starter Kit's connector inventory to identify these apps

4. **Create Custom Tracking**
   - Add a custom field to your `admin_app` table in the CoE Starter Kit
   - Use Power Automate to populate this field based on:
     - Environment has per-app capacity allocated
     - App uses premium connectors
     - Users sharing data indicates per-app consumption

### Code Example: Identifying Apps in Environments

```powershell
# This example shows how to list apps by environment
# Capacity and license data should be retrieved from Power Platform Admin Center

# Connect to Power Platform
Add-PowerAppsAccount

# List all environments
$environments = Get-AdminPowerAppEnvironment

foreach ($env in $environments) {
    Write-Host "Environment: $($env.DisplayName) ($($env.EnvironmentName))"
    
    # List all apps in this environment
    $apps = Get-AdminPowerApp -EnvironmentName $env.EnvironmentName
    
    Write-Host "  Total Apps: $($apps.Count)"
    
    foreach ($app in $apps) {
        Write-Host "  - App: $($app.DisplayName)"
        Write-Host "    Owner: $($app.Owner.displayName)"
        Write-Host "    Created: $($app.CreatedTime)"
    }
    Write-Host ""
}
```

**To identify apps with per-app licenses:**

1. **Check Environment Capacity** in Power Platform Admin Center:
   - Navigate to: `Resources > Capacity > Add-ons`
   - Identify environments with per-app license allocations
   - Note the environment IDs

2. **Filter apps** from step 1 to only those in environments with per-app licenses

3. **Use CoE Starter Kit** for advanced tracking:
   - The CoE Starter Kit inventories all apps and their connectors
   - Apps using Dataverse or premium connectors require premium licenses
   - Cross-reference this data with your license allocations

### Important Notes

1. **Default Behavior**: The behavior you mentioned about per-app licenses being "enabled by default" when creating apps is likely related to how Power Platform applies licensing when apps are created in environments that have per-app capacity allocated.

2. **No Direct Field**: Microsoft does not expose a direct API field or app property for "per-app license enabled" because the licensing is managed at the sharing/assignment level, not at the app configuration level.

3. **Environment-Based**: Focus your search on environments with per-app capacity allocated, then inventory apps within those environments.

### Additional Resources

- [Power Platform Admin Center Documentation](https://learn.microsoft.com/en-us/power-platform/admin/)
- [About Power Apps Per-App Plans](https://learn.microsoft.com/en-us/power-platform/admin/about-powerapps-perapp)
- [PowerApps for Admins Connector Reference](https://learn.microsoft.com/en-us/connectors/powerappsforadmins/)
- [CoE Starter Kit - Extend and Customize](https://learn.microsoft.com/en-us/power-platform/guidance/coe/modify-components)

### Summary

To locate your 2,000+ applications with per-app licenses:
1. Identify environments with per-app license capacity
2. Export all apps from those environments
3. Consider creating a custom field in your CoE Starter Kit to track this information
4. Use premium connector usage as an indicator of licensing requirements

If you need help implementing a custom tracking solution, please refer to the CoE Starter Kit documentation on extending components or reach out to the community with specific technical questions.
