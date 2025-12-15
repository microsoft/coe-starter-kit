# Filtering Maker Notifications by Environment

## Overview

This guide explains how to restrict maker notification emails to specific environments or specific sets of users in the CoE Starter Kit Governance solution. This is useful when you want to:

- Run a pilot test with a subset of users
- Exclude certain environments from notifications
- Target notifications to specific environments only

## Maker Notification Flows

The CoE Starter Kit includes several flows that send notifications to makers:

1. **Admin | Welcome Email v3** - Sends a welcome email when a user creates their first app, flow, custom connector, or environment
2. **Admin | Compliance Details Request eMail (Apps)** - Requests compliance information from app owners
3. **Admin | Compliance Details Request eMail (Flows)** - Requests compliance information from flow owners
4. **Admin | Compliance Details Request eMail (Custom Connectors)** - Requests compliance information from custom connector owners
5. **Admin | Compliance Details Request eMail (Chatbots)** - Requests compliance information from chatbot owners
6. **Admin | Compliance Details Request eMail (Desktop Flows)** - Requests compliance information from desktop flow owners

## Option 1: Filter by Environment

To restrict notifications to specific environments, you can modify the flows to add environment filtering logic:

### Steps:

1. **Open the flow** you want to modify in Power Automate
2. **Add a condition** after the trigger that checks the environment:
   - Get the environment information from the maker or resource record
   - Compare the environment ID or name against your allowed list
3. **Add a Filter step** using one of these approaches:

   #### Approach A: Using Environment Variable
   
   Create a new environment variable to store allowed environment IDs:
   ```
   Name: admin_NotificationAllowedEnvironments
   Type: String
   Value: env1-guid,env2-guid,env3-guid
   ```
   
   Then in your flow, add a condition:
   ```
   If environment ID is in admin_NotificationAllowedEnvironments
       Then: Continue with notification
       Else: Terminate
   ```

   #### Approach B: Using Dataverse Table
   
   Create a custom table to manage allowed environments:
   - Table: "Notification Environment Allowlist"
   - Columns: Environment ID, Environment Name, Allow Notifications (Yes/No)
   
   In your flow, add a "List rows" action to check if the environment is in the allowlist.

### Example Flow Modification:

```
Trigger: When a record is created/updated
↓
Get Environment Details (if not already in trigger data)
↓
[Condition] Is environment in allowed list?
├─ Yes → Continue with existing notification logic
└─ No  → Terminate
```

## Option 2: Filter by User/Maker

To run a pilot test with specific users, you can filter notifications based on the maker's email or user ID:

### Steps:

1. **Create a Dataverse table** for pilot users:
   - Table Name: "Notification Pilot Users"
   - Columns: User Email, User ID, Include in Pilot (Yes/No)

2. **Modify the flow** to check if the maker is in the pilot list:
   ```
   Trigger
   ↓
   Get Maker Information
   ↓
   List rows from "Notification Pilot Users" where Email = Maker Email
   ↓
   [Condition] Is maker in pilot list?
   ├─ Yes → Send notification
   └─ No  → Terminate
   ```

### Example Using Environment Variable:

Create an environment variable with pilot user emails:
```
Name: admin_NotificationPilotUsers
Type: String
Value: user1@contoso.com,user2@contoso.com,user3@contoso.com
```

Add a condition in the flow:
```
If maker email contains in admin_NotificationPilotUsers
    Then: Send notification
    Else: Terminate
```

## Option 3: Disable Flows for Non-Pilot Environments

The simplest approach during a pilot:

1. **Turn off** the notification flows in all environments except your pilot environment
2. **Import** the Governance solution only into the pilot environment
3. **Use environment-specific configuration** by setting different values for environment variables

## Option 4: Filter Using Dataverse Views

For compliance detail request emails that are triggered by record updates:

1. **Modify the trigger** to use a filtered view
2. **Create a custom view** in Dataverse that filters records based on environment
3. **Update the flow trigger** to use this filtered view instead of the default view

## Best Practices

1. **Document Your Changes**: Keep track of all flow modifications for future upgrades
2. **Use Environment Variables**: Makes it easier to manage configurations across environments
3. **Test Thoroughly**: Always test in a non-production environment first
4. **Consider Upgrade Impact**: Custom modifications may need to be reapplied after CoE Starter Kit upgrades
5. **Use Separate Solutions**: Consider exporting modified flows to a separate solution layer to preserve changes during upgrades

## Important Considerations

### Upgrade Impact
- **Managed Solution Updates**: If you modify flows directly, your changes may be overwritten during CoE Starter Kit upgrades
- **Recommendation**: Create unmanaged customizations or use a separate solution layer
- **Alternative**: Fork the flows into a separate solution and turn off the original flows

### Licensing
- Ensure makers in pilot environments have appropriate licenses for the CoE Starter Kit features
- Environment filtering doesn't affect licensing requirements

### Audit and Compliance
- If filtering by environment, ensure you're still meeting compliance requirements for all environments
- Consider documenting why certain environments are excluded from notifications

## Related Resources

- [CoE Starter Kit Documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- [Governance Solution Documentation](https://learn.microsoft.com/power-platform/guidance/coe/governance-components)
- [Environment Management](https://learn.microsoft.com/power-platform/admin/environments-overview)

## Support

For questions or issues:
- Check the [GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues)
- Refer to the [CoE Starter Kit Wiki](https://github.com/microsoft/coe-starter-kit/wiki)
- Join the [Power Platform Community](https://powerusers.microsoft.com/)

---

**Note**: The CoE Starter Kit is provided as-is and customizations are your responsibility to maintain. Always test changes in a non-production environment first.
