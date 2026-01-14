# Issue Response: Licensing Display in CoE Starter Kit

## Summary

Thank you for your question about licensing display features in the CoE Starter Kit!

**Short Answer**: The CoE Starter Kit currently **does NOT** track Power Platform user licenses (such as Power Apps per user, Power Automate licenses, etc.). It **does** track **Dataverse storage capacity** as you mentioned.

## What the CoE Starter Kit Currently Tracks

✅ **Capacity Information**:
- **Dataverse Storage Capacity** (Database, File, Log storage)
- **AI Builder Credits Usage**
- **Environment Add-ons**

These are displayed in:
- CoE Dashboard Power BI reports
- Power Platform Admin View app
- Environment capacity views

## What Is NOT Tracked

❌ The following license information is **not included**:
- User license assignments (E3, E5, Power Apps per user, etc.)
- License SKU details
- License consumption by user
- Available vs. assigned license counts
- License cost analysis

## Why License Tracking Is Not Included

1. **Different APIs**: License data comes from Microsoft Graph API, while CoE uses Power Platform Admin APIs
2. **Scope**: CoE focuses on Power Platform resource governance (apps, flows, environments) rather than license management
3. **Complexity**: License reporting involves complex scenarios with bundles, nested licenses, and multiple SKU types

## Alternative Solutions

You have several options to track Power Platform licensing:

### 1. Microsoft 365 Admin Center (Easiest)
- Navigate to **Microsoft 365 Admin Center** > **Billing** > **Licenses**
- View and export license assignments

### 2. Custom Integration with Microsoft Graph API
You can extend the CoE Starter Kit by:
1. Creating a custom Dataverse table for licenses
2. Building a Power Automate flow that calls Microsoft Graph API
3. Extending Power BI reports with license data

**Example API calls**:
```
GET https://graph.microsoft.com/v1.0/users/{userId}/licenseDetails
GET https://graph.microsoft.com/v1.0/subscribedSkus
```

### 3. PowerShell Scripts
Use Microsoft Graph PowerShell to query license data:
```powershell
Connect-MgGraph -Scopes "User.Read.All"
Get-MgUser -All -Property AssignedLicenses
Get-MgSubscribedSku
```

### 4. Power Platform Admin Center
- **Power Platform Admin Center** > **Analytics** > **Capacity**
- Shows capacity consumption (similar to CoE reports)

## Detailed Documentation

I've created comprehensive documentation that covers:
- Current capabilities and limitations
- Step-by-step guidance for custom license tracking
- Code examples and API references
- Important considerations for privacy and compliance

📄 **See**: [FAQ: Licensing Display in CoE](../docs/FAQ-Licensing-Display.md)

## Recommendation

For a complete Power Platform governance solution that includes license tracking:

1. **Use CoE Starter Kit** for:
   - Resource inventory (apps, flows, connectors)
   - Storage capacity monitoring
   - Compliance and governance workflows

2. **Use Microsoft 365 Admin Center or Microsoft Graph API** for:
   - User license assignments
   - License consumption tracking
   - Cost analysis

3. **Consider building a custom integration** if you need unified reporting combining resource usage and license data.

## Related Resources

- [CoE Starter Kit Documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- [Core Components Overview](https://learn.microsoft.com/power-platform/guidance/coe/core-components)
- [Power BI Dashboard](https://learn.microsoft.com/power-platform/guidance/coe/power-bi)
- [Microsoft Graph Licensing APIs](https://learn.microsoft.com/graph/api/resources/licensedetails)

---

**Note**: Custom extensions to add license tracking are outside the scope of the official CoE Starter Kit and would need to be maintained by your organization.

If you need further assistance with implementing custom license tracking, feel free to ask follow-up questions or check out the detailed FAQ document linked above.
