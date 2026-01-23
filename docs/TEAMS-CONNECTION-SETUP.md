# CoE Starter Kit - Teams Connection Setup Guide

## Overview

Starting with recent versions of the CoE Starter Kit, a **Microsoft Teams connection** (`CoE Core - Teams` / `admin_CoECoreTeams`) is required for the Core Components solution. This connection enables Teams-based notifications and approvals for various CoE Kit features.

## What is the Teams Connection Used For?

The Teams connection is used by the following flows in the Core Components solution:

1. **Admin | Sync Template v4 (Driver)** - Uses Teams connector for escalation notifications when the inventory sync encounters critical errors
2. **App Catalog - Request Access** - Sends approval requests via Teams when makers request access to apps in the App Catalog
3. **DLP Impact Analysis - Send Notification** - Sends Teams notifications about DLP policy impact on resources

## Why is This Connection Now Required?

The Teams connection was added to improve admin experience by:
- Providing real-time notifications for critical sync errors
- Enabling faster approval workflows through Teams
- Improving visibility of DLP policy changes

While these features enhance the CoE Kit experience, **the Teams connection is required during solution import** even if you don't plan to use Teams-based notifications. The connection can remain disconnected if you don't want to use these features.

## Permissions Required

The Teams connection requires **standard user permissions** - no special admin or elevated permissions are needed:

### ✅ Required Permissions
- **Microsoft Teams** - Standard user access
- Ability to send and receive Teams messages in your organization
- Access to Teams as a licensed M365 user

### ❌ NOT Required
- Teams admin permissions
- Elevated API permissions
- Azure AD admin consent

## How to Set Up the Teams Connection

### During Solution Import/Upgrade

When importing or upgrading the CoE Core Components solution, you'll see the connection requirement screen:

1. **During Import**:
   - You'll see "CoE Core - Teams" in the connections list
   - The connection will show a red warning icon if not yet created
   - Connection reference name: `admin_CoECoreTeams`

2. **Create the Connection**:
   - Click on the "CoE Core - Teams" connection row
   - Click the "+" or "New connection" button
   - Sign in with your account (the one that will run the flows)
   - Click **Allow** when prompted for Teams permissions
   - Wait for the green checkmark to appear

3. **Select the Connection**:
   - After creating, select the connection from the dropdown
   - Ensure all connections show green checkmarks
   - Click **Next** to continue the import

### After Import (If Connection Wasn't Set Up)

If you skipped the Teams connection during import, you can add it later:

1. **Navigate to Connections**:
   - Go to [Power Automate](https://flow.microsoft.com)
   - Navigate to **Data** > **Connections**
   - Click **+ New connection**

2. **Create Teams Connection**:
   - Search for "Microsoft Teams"
   - Select **Microsoft Teams** connector
   - Click **Create**
   - Sign in and authorize

3. **Update Flow Connection References**:
   - Open the CoE environment
   - Go to **Solutions** > **Center of Excellence - Core Components**
   - For each flow that uses Teams (listed above):
     - Open the flow
     - Click **Edit**
     - Update the Teams connection reference
     - Save the flow

## Troubleshooting

### "I can't create the Teams connection during import"

**Possible causes:**
1. **Teams not available in your tenant**
   - Verify Microsoft Teams is enabled for your organization
   - Check with your M365 admin if Teams is blocked

2. **No Teams license**
   - The user creating the connection needs a Teams license
   - Verify your Microsoft 365 license includes Teams

3. **Conditional access policies**
   - Your organization may have conditional access policies preventing connection creation
   - Try from a compliant device or network
   - Contact your Azure AD admin for exceptions if needed

**Solution:**
- Ensure you have Teams access and a proper license
- Try creating the connection from [Power Automate directly](https://flow.microsoft.com)
- If your organization blocks Teams, you may need an exception for the CoE admin account

### "Do I need to use Teams for CoE Kit to work?"

**Short answer:** No, but the connection must be created.

The Teams connection is required during solution import, but you can choose not to use Teams-based features:
- The flows will still run without Teams notifications
- Teams actions typically have conditional logic that checks if Teams is enabled
- You can disable Teams-based notifications through environment variables or flow modifications

### "What if Teams connector is blocked by DLP policy?"

If your Data Loss Prevention (DLP) policy blocks the Microsoft Teams connector:

1. **Option 1: Update DLP Policy (Recommended)**
   - Add Microsoft Teams connector to the **Business** data group
   - Ensure it's in the same group as Power Platform connectors
   - Contact your Power Platform admin or CoE lead

2. **Option 2: Create Exception Environment**
   - Request an exception for your CoE environment
   - DLP policies can exclude specific environments
   - This is the recommended approach for CoE environments

3. **Option 3: Modify Flows (Advanced)**
   - Remove Teams actions from the affected flows
   - This requires customization and may break during upgrades
   - Only recommended if Options 1 & 2 are not possible

### "Which account should create the Teams connection?"

**Best Practice:**
- Use the same account that runs your CoE inventory flows
- Typically a dedicated service account or CoE admin account
- Ensure this account has:
  - Teams license
  - Teams access
  - Permissions to send messages on behalf of CoE Kit

**Important:** Teams messages will be sent from this account's identity.

## Version Information

- **First introduced:** The Teams connection was added to Core Components in versions released after mid-2024
- **Affects:** All customers upgrading from versions before the Teams connection requirement
- **Solutions affected:** Center of Excellence - Core Components only

## Related Documentation

- [CoE Starter Kit Setup Guide](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components)
- [Upgrade CoE Starter Kit](https://learn.microsoft.com/power-platform/guidance/coe/after-setup)
- [Troubleshooting Upgrades](../TROUBLESHOOTING-UPGRADES.md)
- [Microsoft Teams Connector Documentation](https://learn.microsoft.com/connectors/teams/)

## Frequently Asked Questions

### Q: Can I skip this connection during import?

**A:** No, the connection is required for successful import. However, you can create it and leave it unused if you don't want Teams notifications.

### Q: Will this connection cost extra?

**A:** No, the Microsoft Teams connector is a standard connector included with your Microsoft 365 license. No additional costs are incurred.

### Q: Does this require Teams admin permissions?

**A:** No, standard Teams user permissions are sufficient. The connection only needs to send messages and receive responses, which any Teams user can do.

### Q: What happens if I don't configure this connection?

**A:** The solution import will fail or show errors. After import, flows using Teams will show connection errors and won't run properly.

### Q: Can I use a service account for this connection?

**A:** Yes, and this is recommended. Use the same service account that runs your CoE flows. Ensure it has:
- A Teams license
- Access to Teams in your organization
- Appropriate permissions to send notifications

### Q: My organization uses Sovereign Cloud (GCC High/DoD) - is Teams available?

**A:** Microsoft Teams connector availability varies by sovereign cloud:
- **GCC**: Teams connector is available
- **GCC High**: Teams connector is available (as of 2024)
- **DoD**: Check with your tenant administrator for current status

For sovereign cloud guidance, see [Sovereign Cloud Support Guide](./sovereign-cloud-support.md).

### Q: How do I know which version introduced this requirement?

**A:** The Teams connection requirement was introduced in CoE Kit versions released in mid-2024 and later. If you're upgrading from versions before June 2024, you'll encounter this new requirement.

Check your current version:
1. Open the **Center of Excellence - Core Components** solution
2. Check the **Version** field in solution properties
3. Compare with [Release History](https://github.com/microsoft/coe-starter-kit/releases)

## Need More Help?

If you continue to experience issues setting up the Teams connection:

1. **Search Existing Issues**: Check [CoE Starter Kit Issues](https://github.com/microsoft/coe-starter-kit/issues) for similar problems
2. **Review Setup Documentation**: Visit the [official setup guide](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components)
3. **Ask Questions**: Use the [question issue template](https://github.com/microsoft/coe-starter-kit/issues/new/choose)
4. **Community Support**: Post in [Power Apps Community Forum](https://powerusers.microsoft.com/t5/Power-Apps-Governance-and/bd-p/Admin_PowerApps)

---

**Document Version**: 1.0  
**Last Updated**: January 2026  
**Maintained by**: CoE Starter Kit Community
