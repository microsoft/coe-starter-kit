# CoE Starter Kit - Licensing FAQ

This document addresses frequently asked questions about licensing requirements for the Power Platform Center of Excellence (CoE) Starter Kit.

## Table of Contents
- [Can I remove Power Apps Premium license from the service account after installation?](#can-i-remove-power-apps-premium-license-from-the-service-account-after-installation)
- [What licenses are required for the service account?](#what-licenses-are-required-for-the-service-account)
- [Can I use Per Flow licenses instead of Per User licenses?](#can-i-use-per-flow-licenses-instead-of-per-user-licenses)
- [Do end users need Premium licenses?](#do-end-users-need-premium-licenses)

## Can I remove Power Apps Premium license from the service account after installation?

**Short Answer: No**

You **cannot** remove the Power Apps Premium license from the service account after CoE Starter Kit installation, even if you're only using flows and not the Power Apps components.

### Why Both Licenses Are Required

The CoE Starter Kit service account requires **both** Power Apps Premium and Power Automate Premium licenses for the following reasons:

1. **Installation Requirements**: The initial installation process requires Power Apps Premium to deploy and configure the solution components properly.

2. **Ongoing Operations**: Even if you're primarily using flows, many CoE components have interdependencies between Power Apps and Power Automate:
   - Some flows are triggered from or interact with Power Apps
   - Administrative functions may require app access
   - Data models and Dataverse interactions are used by both apps and flows

3. **Future Updates**: Microsoft releases regular updates to the CoE Starter Kit. These updates may introduce new features or dependencies that require Power Apps Premium. Removing this license could break functionality during upgrades.

4. **Microsoft Support**: Running the CoE Starter Kit with only Power Automate Premium is **not officially supported by Microsoft**. If you encounter issues, you may not receive support without the recommended license configuration.

### Official License Requirements

According to [Microsoft's official documentation](https://learn.microsoft.com/power-platform/guidance/coe/setup), the service account must have:

| License Type | Required | Purpose |
|--------------|----------|---------|
| **Power Apps Premium (Per User)** | ✅ Yes | Required for app deployment, administration, and ongoing operations |
| **Power Automate Premium (Per User or Per Flow)** | ✅ Yes | Required for cloud flows, premium connectors, and automation |
| **Microsoft 365** | ✅ Yes | Required for Outlook connector and email-enabled mailbox |
| **Power BI Premium** | ⚠️ Conditional | Required if using Power BI dashboards and data export features |

**Important Notes:**
- All licenses must be **non-trial** licenses
- Licenses must be **permanently assigned** to the service account (not via delegation or temporary elevation)
- The service account must be a regular user account with these licenses; **service principals are not supported**

## What licenses are required for the service account?

The service account used to install and run the CoE Starter Kit must have:

### Required Licenses
1. **Power Apps Premium (Per User, non-trial)**
   - Enables app creation, management, and access to premium connectors
   - Required for Dataverse access and administrative scenarios
   - Must remain assigned throughout the lifecycle of the CoE Starter Kit

2. **Power Automate Premium (Per User or Per Flow, non-trial)**
   - Enables automation of governance tasks, inventory collection, and monitoring
   - Required for flows that use premium connectors
   - Can be assigned as Per User to the account or as Per Flow to individual flows

3. **Microsoft 365 License**
   - Enables Office 365 Outlook connector for notifications
   - Provides email-enabled mailbox access
   - Required for communication features

4. **Power BI Premium (Per User or Capacity)**
   - Required if using Power BI dashboards
   - Needed for data export and reporting features
   - Only required if you're using the CoE Dashboard components

### Required Permissions
In addition to licenses, the service account must have:

- **Power Platform Service Admin** or **Global Admin** role
- Sufficient permissions to access all environments being monitored
- Permissions to create and manage Dataverse tables
- Azure AD permissions for app registrations (if collecting telemetry)

## Can I use Per Flow licenses instead of Per User licenses?

**Partial Yes - for Power Automate only**

You can use **Power Automate Per Flow** licenses for specific flows instead of assigning a Per User license to the service account. However:

### Considerations:

1. **Power Apps Premium Still Required**: You still need to assign Power Apps Premium (Per User) to the service account for installation and app components.

2. **Per Flow License Assignment**: 
   - Per Flow licenses are assigned to individual flows, not to the service account
   - Each flow that uses premium connectors needs its own Per Flow license
   - This can become expensive if you have many flows

3. **Cost Comparison**:
   - Power Automate Per User: One license covers unlimited flows for that user
   - Power Automate Per Flow: Each flow requires a separate license
   - Evaluate your total number of flows to determine the most cost-effective option

4. **Best Practice**: For CoE Starter Kit deployments, a **Power Automate Per User** license on the service account is typically more cost-effective and simpler to manage.

## Do end users need Premium licenses?

**No - with proper configuration**

End users who access the CoE Starter Kit apps do **not** need Power Apps Premium licenses if:

1. **Apps are shared properly**: The apps are shared with users in your organization
2. **Service account owns the apps**: The apps run in the context of the service account's license
3. **Users have appropriate base licenses**: Users have Power Apps for Microsoft 365 or similar licenses included with Microsoft 365

### User License Requirements by Component:

| Component | User License Required |
|-----------|----------------------|
| Viewing CoE Dashboards (Power BI) | Power BI Free or Pro (depending on how dashboards are shared) |
| Using CoE Apps (if shared by service account) | Power Apps for Microsoft 365 (included with Microsoft 365) |
| Creating/editing apps via CoE | Power Apps Premium (Per User) |
| Running automated flows | No license (flows run under service account) |

### Important Notes:
- Users who **only consume** apps and reports don't need Premium licenses
- Users who want to **create or modify** apps need their own Power Apps Premium licenses
- The CoE Starter Kit enables governance; it doesn't replace individual licensing for makers

## Additional Resources

For more detailed information about CoE Starter Kit setup and licensing:

- [Official CoE Starter Kit Setup Documentation](https://learn.microsoft.com/power-platform/guidance/coe/setup)
- [CoE Starter Kit FAQ](https://learn.microsoft.com/power-platform/guidance/coe/faq)
- [Power Platform Licensing Overview](https://learn.microsoft.com/power-platform/admin/pricing-billing-skus)
- [GitHub Issues - CoE Starter Kit](https://github.com/microsoft/coe-starter-kit/issues)

---

**Disclaimer**: This FAQ is based on official Microsoft documentation and community best practices as of the last update. Always refer to the [official Microsoft documentation](https://learn.microsoft.com/power-platform/guidance/coe/setup) for the most current requirements and recommendations.

If you have additional questions not covered here, please [open an issue](https://github.com/microsoft/coe-starter-kit/issues/new/choose) using the Question template.
