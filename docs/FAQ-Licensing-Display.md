# FAQ: Licensing Display in CoE Starter Kit

## Question
Are there any features from CoE that provide licenses for the Power Platform product to be shown in the CoE app or Power BI reporting?

## Current State

The **CoE Starter Kit** currently focuses on **inventory and governance** of Power Platform resources (apps, flows, connectors, environments, etc.) rather than license assignment tracking. 

### What IS Currently Available

The CoE Starter Kit **does track** the following capacity-related information:

1. **Dataverse Storage Capacity**
   - **Entity**: `admin_EnvironmentCapacity`
   - **Fields tracked**:
     - Capacity Type (e.g., Database, File, Log)
     - Actual Consumption
     - Approved Capacity
     - Capacity Unit
   - **Display locations**:
     - CoE Dashboard Power BI reports
     - Power Platform Admin View app
     - Environment records in Dataverse

2. **AI Credits Usage**
   - **Entity**: `admin_AICreditsUsage`
   - Tracks AI Builder credit consumption

3. **Environment Add-ons**
   - **Entity**: `admin_EnvironmentAddons`
   - Tracks add-on capacity assigned to environments

### What IS NOT Currently Available

The CoE Starter Kit **does not track**:

❌ **User License Assignments** (E3, E5, Power Apps per user, Power Automate per user, etc.)  
❌ **License SKU Details**  
❌ **License Consumption by User**  
❌ **Available vs. Assigned License Counts**  
❌ **License Cost Analysis**

The `admin_PowerPlatformUser` entity tracks user information but does **not include license details** like:
- License type (Power Apps per user, per app, etc.)
- License SKU
- License assignment date
- License source (E3, E5, standalone, etc.)

## Why License Tracking Is Not Included

1. **Different API Requirements**: License information is available through Microsoft Graph API and Azure AD APIs, not the Power Platform Admin APIs that the CoE Starter Kit primarily uses.

2. **Scope Focus**: The CoE Starter Kit focuses on Power Platform resource governance (apps, flows, environments) rather than Microsoft 365 license management.

3. **Complexity**: License reporting involves complex scenarios:
   - Multiple license types and bundles
   - Nested licenses (E3/E5 that include Power Apps)
   - Service-specific license enforcement
   - Trial vs. paid licenses

## Alternative Solutions

If you need to track Power Platform licensing, consider these alternatives:

### Option 1: Microsoft 365 Admin Center
- Navigate to **Microsoft 365 Admin Center** > **Billing** > **Licenses**
- View license assignments and consumption
- Export license reports

### Option 2: Microsoft Graph API
Use Microsoft Graph API to query license information:

```
GET https://graph.microsoft.com/v1.0/users/{userId}/licenseDetails
GET https://graph.microsoft.com/v1.0/subscribedSkus
```

You can build a custom Power Automate flow to:
1. Call Microsoft Graph API to retrieve license information
2. Store results in a custom Dataverse table
3. Include in your Power BI reports

**Example License SKUs for Power Platform**:
- `POWERAPPS_PER_USER` - Power Apps per user plan
- `FLOW_PER_USER` - Power Automate per user plan
- `POWERAPPS_PER_APP` - Power Apps per app plan
- `POWER_BI_PRO` - Power BI Pro
- Licenses included in E3/E5 bundles

### Option 3: PowerShell Scripts
Use PowerShell with Microsoft Graph to export license data:

```powershell
Connect-MgGraph -Scopes "User.Read.All", "Organization.Read.All"

# Get all users with license details
Get-MgUser -All -Property DisplayName, UserPrincipalName, AssignedLicenses | 
    Select-Object DisplayName, UserPrincipalName, AssignedLicenses

# Get subscribed SKUs
Get-MgSubscribedSku | Select-Object SkuPartNumber, ConsumedUnits, PrepaidUnits
```

### Option 4: Power Platform Admin Analytics
- **Power Platform Admin Center** > **Analytics** > **Capacity**
- View storage and add-on capacity consumption
- Note: This shows capacity, not user licenses

### Option 5: Third-Party Tools
Several third-party governance tools provide license tracking alongside Power Platform governance:
- Microsoft Purview (formerly Azure Purview)
- Third-party ITSM tools with Microsoft 365 connectors

## Recommended Approach

If you want to extend the CoE Starter Kit with license tracking:

1. **Create a Custom Table** in the CoE Dataverse environment:
   - Table name: e.g., `admin_UserLicense`
   - Fields: 
     - User (lookup to `admin_PowerPlatformUser`)
     - License SKU
     - License Type
     - Assignment Date
     - License Source

2. **Create a Custom Flow** that:
   - Runs on a schedule (daily/weekly)
   - Uses HTTP connector to call Microsoft Graph API
   - Requires application registration with appropriate permissions
   - Populates the custom table

3. **Extend Power BI Reports**:
   - Add the custom table as a data source
   - Create license consumption visuals
   - Join with existing CoE data for usage vs. license analysis

4. **Required Permissions**:
   - Azure AD App Registration with `User.Read.All` and `Directory.Read.All` permissions
   - Appropriate admin consent for the application

## Important Considerations

⚠️ **Privacy and Compliance**: Ensure your organization's privacy policies allow collection and storage of user license information.

⚠️ **Data Freshness**: License data changes frequently. Plan for regular synchronization.

⚠️ **Support**: Custom extensions are outside the scope of the CoE Starter Kit and are not officially supported by Microsoft.

## Related Documentation

- [CoE Starter Kit Setup](https://learn.microsoft.com/power-platform/guidance/coe/setup)
- [CoE Core Components](https://learn.microsoft.com/power-platform/guidance/coe/core-components)
- [Power BI Dashboard](https://learn.microsoft.com/power-platform/guidance/coe/power-bi)
- [Microsoft Graph Licensing APIs](https://learn.microsoft.com/graph/api/resources/licensedetails)
- [Power Platform Admin Connectors](https://learn.microsoft.com/connectors/powerplatformforadmins/)

## Summary

✅ **Available**: Dataverse storage capacity, AI credits, environment add-ons  
❌ **Not Available**: User license assignments, SKU details, license consumption  
💡 **Solution**: Extend CoE with custom Microsoft Graph integration or use alternative tools

For capacity tracking, the CoE Starter Kit provides comprehensive reporting. For license management, you'll need to integrate with Microsoft Graph API or use the Microsoft 365 Admin Center.

---

**Last Updated**: January 2026  
**CoE Starter Kit Version**: December 2025  
**Issue Reference**: [CoE Starter Kit - QUESTION] Licensing display in CoE
