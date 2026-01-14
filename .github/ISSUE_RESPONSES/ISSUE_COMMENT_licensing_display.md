# Response to Issue: Licensing Display in CoE

Thank you for your question! This is a great inquiry about the CoE Starter Kit's capabilities.

## Current Capabilities ✅

You are **absolutely correct** in your understanding! The CoE Starter Kit currently **only tracks Dataverse storage capacity**, not Power Platform product licenses.

### What IS Available in the CoE Starter Kit:

The kit includes the **`admin_EnvironmentCapacity`** entity that tracks:
- **Capacity Type**: Database, File, and Log storage
- **Approved Capacity**: The allocated capacity for each environment
- **Actual Consumption**: Current usage levels
- **Capacity Units**: MB or GB measurements

This capacity information is:
- Collected automatically by the Core Components inventory flows
- Visible in the **Power Platform Admin View** model-driven app
- Displayed in the **CoE Dashboard Power BI reports**
- Monitored by the **Admin - Capacity Alerts** flow (sends notifications when capacity exceeds thresholds)

### What is NOT Available ❌

The CoE Starter Kit does **NOT** currently track:
- ❌ Power Platform user licenses (Premium, Per User, Per App, etc.)
- ❌ Microsoft 365 licenses
- ❌ Dynamics 365 licenses
- ❌ License assignments per user
- ❌ Available vs. consumed license counts
- ❌ License expiration dates or renewal information

**Note**: The Setup Wizard flows do check license details via Microsoft Graph API for validation during installation, but this data is not stored in Dataverse tables or made available for reporting/visualization purposes.

## Why License Tracking is Not Included

The CoE Starter Kit's primary focus is on **Power Platform governance and adoption** (managing apps, flows, connectors, environments, etc.) rather than license procurement and management.

License tracking would require:
1. **Different APIs**: Microsoft Graph API (`/subscribedSkus`, `/users/{id}/licenseDetails`)
2. **Different Permissions**: Directory.Read.All or Organization.Read.All
3. **Different Domain**: License management is typically owned by IT procurement/finance teams

## Alternative Solutions 💡

If you need to track Power Platform licenses, here are proven approaches:

### 🎯 Option 1: Microsoft 365 Admin Center (Recommended)
The simplest approach for most organizations:
1. Navigate to [https://admin.microsoft.com](https://admin.microsoft.com)
2. Go to **Billing > Licenses** for all available licenses
3. Go to **Users > Active users** for per-user assignments
4. Use built-in reports for utilization tracking

### 🔧 Option 2: Custom Power Automate Flows with Microsoft Graph
Build custom flows to retrieve and store license data:

**Get tenant-level license information:**
```
GET https://graph.microsoft.com/v1.0/subscribedSkus
```
Returns: SKU ID, Part Number, Consumed Units, Enabled Units, Suspended Units, etc.

**Get per-user license details:**
```
GET https://graph.microsoft.com/v1.0/users/{user-id}/licenseDetails
```
Returns: All license assignments for a specific user

**Implementation approach:**
1. Create HTTP calls using Microsoft Graph connector or HTTP with Azure AD
2. Parse the JSON responses
3. Store in custom Dataverse tables in your CoE environment
4. Create Power BI reports or canvas apps to visualize the data

**Required Permissions**: `Directory.Read.All` (Application or Delegated)

### 📊 Option 3: Power BI with Microsoft Graph Connector
Create a dedicated license dashboard:
1. Open Power BI Desktop
2. Use the **Microsoft Graph** connector
3. Connect to `/subscribedSkus` and `/users` endpoints
4. Build visualizations for license consumption, trends, and allocation
5. Publish to your workspace alongside the existing CoE Dashboard

### 💻 Option 4: PowerShell Automation
For scripted reporting and automation:

```powershell
# Using Microsoft Graph PowerShell SDK
Connect-MgGraph -Scopes "Directory.Read.All"

# Get all subscribed SKUs
Get-MgSubscribedSku | Select-Object SkuPartNumber, ConsumedUnits, @{
    Name='EnabledUnits'; Expression={$_.PrepaidUnits.Enabled}
}

# Get licenses for a specific user
Get-MgUser -UserId "user@domain.com" | 
    Select-Object -ExpandProperty AssignedLicenses
```

## Next Steps

### If You Want This Feature in CoE Starter Kit:
1. **👍 Upvote this issue** to show community interest
2. **📝 Convert to Feature Request**: The maintainers can reclassify this as a feature request
3. **🤝 Contribute**: The CoE Starter Kit is open source! Consider contributing:
   - Data model extensions (custom tables for licenses)
   - Flows to sync license data from Graph API
   - Power BI visuals for license tracking
4. **💬 Share Your Solution**: If you implement custom license tracking, share it with the community!

## Additional Resources 📚

- [Microsoft Graph API - List Subscribed SKUs](https://learn.microsoft.com/en-us/graph/api/subscribedsku-list)
- [Microsoft Graph API - List User License Details](https://learn.microsoft.com/en-us/graph/api/user-list-licensedetails)
- [CoE Starter Kit Documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- [Power Platform for Admins Connector](https://learn.microsoft.com/connectors/powerplatformforadmins/)
- [Microsoft Graph PowerShell SDK](https://learn.microsoft.com/powershell/microsoftgraph/overview)

## Summary

| Feature | Available in CoE? | Alternative |
|---------|------------------|-------------|
| Dataverse Storage Capacity | ✅ Yes | N/A - included |
| Power Platform Licenses | ❌ No | Microsoft 365 Admin Center or Microsoft Graph API |
| License Assignments | ❌ No | Microsoft Graph API |
| License Utilization Trends | ❌ No | Custom Power BI with Graph |

**Bottom line**: For now, use the Microsoft 365 Admin Center for license visibility, or build a custom integration using Microsoft Graph API if you need license data integrated with your CoE governance data.

Does this answer your question? Let me know if you'd like more details on any of these alternatives!
