# CoE Starter Kit - Licensing Display Capabilities

## Question
Are there any features from CoE that provide licenses for the Power Platform product to be shown in the CoE app or Power BI reporting? Currently, what I know is that the CoE only displays the Dataverse storage capacity in the CoE app and Power BI.

## Answer

### Current Capabilities

You are correct! The CoE Starter Kit **currently only tracks Dataverse storage capacity**, not Power Platform product licenses. Specifically:

#### What IS Available:
- **Dataverse Storage Capacity**: The CoE Starter Kit includes the `admin_EnvironmentCapacity` entity that tracks:
  - Capacity Type (Database, File, Log)
  - Approved Capacity
  - Actual Consumption
  - Capacity Units
  
This information is collected by the Core Components inventory flows and can be viewed in:
- The Power Platform Admin View model-driven app
- The CoE Dashboard Power BI reports
- Through the **Admin - Capacity Alerts** flow, which sends notifications when capacity thresholds are exceeded

#### What is NOT Available:
The CoE Starter Kit does **NOT** currently track or display:
- Power Platform user licenses (e.g., Premium, Per User, Per App)
- Microsoft 365 licenses
- Dynamics 365 licenses
- License assignments per user
- Available vs. consumed license counts
- License expiration dates

### Why Licensing Information is Not Included

The CoE Starter Kit focuses on **governance and adoption** of Power Platform resources (apps, flows, connectors, etc.) rather than license management. License information requires:

1. **Different APIs**: License data is available through Microsoft Graph API (`/subscribedSkus` and `/users/{id}/licenseDetails` endpoints)
2. **Different Permissions**: Requires Directory.Read.All or other Graph API permissions
3. **Different Scope**: License management is typically handled by IT/procurement teams separately from Power Platform governance

### Alternative Approaches to Get License Information

If you need to track and report on Power Platform licenses, consider these alternatives:

#### Option 1: Microsoft 365 Admin Center
The easiest approach for viewing license information:
- Navigate to https://admin.microsoft.com
- Go to **Billing > Licenses** to see all available licenses
- Go to **Users > Active users** to see license assignments per user
- Use built-in reports for license utilization

#### Option 2: Microsoft Graph API with Power Automate
Create custom flows to retrieve license data:

1. **Get Subscribed SKUs** (tenant-level license information):
   ```
   GET https://graph.microsoft.com/v1.0/subscribedSkus
   ```
   Returns: SKU ID, SKU Part Number, Consumed Units, Enabled Units, etc.

2. **Get User License Details**:
   ```
   GET https://graph.microsoft.com/v1.0/users/{user-id}/licenseDetails
   ```
   Returns: License assignments per user

3. **Store in Custom Dataverse Tables**: You could create custom tables in your CoE environment to store this data and display it alongside your existing CoE data.

**Required Permissions**: Directory.Read.All (application or delegated)

#### Option 3: PowerShell Scripts
Use the Microsoft Graph PowerShell SDK or Azure AD PowerShell module:

```powershell
# Using Microsoft Graph PowerShell
Connect-MgGraph -Scopes "Directory.Read.All"
Get-MgSubscribedSku | Select-Object SkuPartNumber, ConsumedUnits, PrepaidUnits
Get-MgUser -UserId "user@domain.com" | Select-Object -ExpandProperty AssignedLicenses
```

#### Option 4: Power BI with Microsoft Graph Data Connector
Create a custom Power BI report:
1. Use the **Microsoft Graph** connector in Power BI Desktop
2. Connect to the `/subscribedSkus` and `/users` endpoints
3. Create visualizations for license consumption
4. Publish to your Power BI workspace alongside the CoE Dashboard

### Feature Request

If you would like to see license tracking added to the CoE Starter Kit, you can:
1. **Upvote or create a feature request** on this GitHub repository
2. **Contribute**: The CoE Starter Kit is open source - you could contribute flows and data model extensions to add this capability
3. **Share your implementation**: If you build a custom solution, consider sharing it with the community

### Additional Resources

- **Microsoft Graph API - Subscribed SKUs**: https://learn.microsoft.com/en-us/graph/api/subscribedsku-list
- **Microsoft Graph API - License Details**: https://learn.microsoft.com/en-us/graph/api/user-list-licensedetails
- **CoE Starter Kit Documentation**: https://learn.microsoft.com/power-platform/guidance/coe/starter-kit
- **Power Platform Admin Connectors**: https://learn.microsoft.com/connectors/powerplatformforadmins/

### Summary

**Current State**: The CoE Starter Kit tracks Dataverse storage capacity but not Power Platform licenses.

**Recommendation**: Use Microsoft 365 Admin Center for license management, or build a custom solution using Microsoft Graph API to integrate license data into your CoE environment if needed.

**Future**: Consider submitting a feature request if this capability would be valuable for your organization.
