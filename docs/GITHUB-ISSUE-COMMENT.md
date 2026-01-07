# Response to Issue: Licensing Display in CoE Starter Kit

Hi @[issue-author],

Thank you for your question about licensing display features in the CoE Starter Kit!

## Short Answer

The CoE Starter Kit currently **does NOT** track Power Platform user licenses (such as Power Apps per user, Power Automate per user, E3/E5 licenses, etc.). 

You are correct that it **does track Dataverse storage capacity** - this is currently the only capacity/licensing-related information displayed in the CoE apps and Power BI reports.

## What the CoE Starter Kit Currently Tracks

✅ **Available**:
- **Dataverse Storage Capacity** (Database, File, Log storage) via the `admin_EnvironmentCapacity` entity
- **AI Builder Credits Usage** via the `admin_AICreditsUsage` entity
- **Environment Add-ons** via the `admin_EnvironmentAddons` entity

These appear in:
- CoE Dashboard Power BI reports
- Power Platform Admin View app
- Environment capacity views

## What Is NOT Tracked

❌ **Not Available**:
- User license assignments (Power Apps, Power Automate licenses)
- License SKU details
- License consumption by user
- Available vs. assigned license counts
- License cost analysis

## Why License Tracking Is Not Included

1. **Different APIs**: License data comes from Microsoft Graph API, while the CoE Starter Kit uses Power Platform Admin APIs
2. **Scope**: CoE focuses on Power Platform resource governance rather than Microsoft 365 license management
3. **Complexity**: License reporting involves complex scenarios with bundles and nested licenses

## Alternative Solutions

You have several options to track Power Platform licensing:

### 1. Microsoft 365 Admin Center (Quickest Option)
- Navigate to **Microsoft 365 Admin Center** > **Billing** > **Licenses**
- View and export license assignments

### 2. Extend CoE with Microsoft Graph API
You can build a custom integration:
1. Create a custom Dataverse table for licenses (e.g., `admin_UserLicense`)
2. Build a Power Automate flow that calls Microsoft Graph API
3. Extend Power BI reports with the license data

**Example Microsoft Graph API calls**:
```
GET https://graph.microsoft.com/v1.0/users/{userId}/licenseDetails
GET https://graph.microsoft.com/v1.0/subscribedSkus
```

### 3. PowerShell Scripts
```powershell
Connect-MgGraph -Scopes "User.Read.All", "Organization.Read.All"
Get-MgUser -All -Property AssignedLicenses
Get-MgSubscribedSku | Select-Object SkuPartNumber, ConsumedUnits
```

### 4. Power Platform Admin Center Analytics
- **Power Platform Admin Center** > **Analytics** > **Capacity**
- Similar to CoE reports but directly from the admin portal

## Detailed Documentation

I've created comprehensive documentation that includes:
- Step-by-step guidance for custom license tracking
- Code examples and API references
- Important privacy and compliance considerations

📄 **See**: [FAQ: Licensing Display in CoE Starter Kit](../docs/FAQ-Licensing-Display.md)

## Recommendation

For complete Power Platform governance with license tracking:

1. **Use CoE Starter Kit** for resource inventory, capacity monitoring, and governance workflows
2. **Use Microsoft 365 Admin Center or Microsoft Graph API** for license management and cost tracking
3. **Build a custom integration** if you need unified reporting

## Related Resources

- [CoE Starter Kit Documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- [Core Components](https://learn.microsoft.com/power-platform/guidance/coe/core-components)
- [Power BI Dashboard](https://learn.microsoft.com/power-platform/guidance/coe/power-bi)
- [Microsoft Graph Licensing APIs](https://learn.microsoft.com/graph/api/resources/licensedetails)

---

**Note**: Custom extensions to add license tracking would be outside the official CoE Starter Kit scope and maintained by your organization.

Let me know if you need any clarification or would like help with implementing a custom license tracking solution!
