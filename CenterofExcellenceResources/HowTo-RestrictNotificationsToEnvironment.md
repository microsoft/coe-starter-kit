# How-To: Restrict Maker Notifications to Specific Environments

## Scenario

You want to enable maker notifications only for specific environments while excluding others. This is useful for:
- Pilot testing the Governance solution
- Excluding production environments from notifications
- Targeting only development or sandbox environments

## Prerequisites

- CoE Starter Kit Governance solution installed
- System Administrator or System Customizer role in the CoE environment
- Access to modify flows in Power Automate

## Solution Overview

We'll create an environment variable to store allowed environment GUIDs and modify the notification flows to check against this list before sending emails.

## Step-by-Step Implementation

### Step 1: Create Environment Variable for Allowed Environments

1. Navigate to **Power Apps** (make.powerapps.com)
2. Select your **CoE environment**
3. Go to **Solutions** → **Center of Excellence - Core Components**
4. Click **+ New** → **More** → **Environment variable**
5. Configure the new environment variable:
   - **Display name**: `Notification Allowed Environments`
   - **Name**: `admin_NotificationAllowedEnvironments`
   - **Data Type**: Text
   - **Default Value**: Leave blank for now
   - **Description**: `Comma-separated list of environment IDs where maker notifications should be sent. Leave empty to send to all environments.`
6. Click **Save**

### Step 2: Populate Allowed Environment IDs

1. Get the environment IDs you want to allow:
   - Option A: From the **Power Platform Admin Center** → **Environments** → Click on environment → Copy the **Environment ID** from the URL
   - Option B: From the **CoE Admin Command Center** app → **Environments** view
   - Option C: Run this PowerShell to list environments:
   
   ```powershell
   # Install module if needed
   Install-Module -Name Microsoft.PowerApps.Administration.PowerShell
   
   # Connect
   Add-PowerAppsAccount
   
   # List environments
   Get-AdminPowerAppEnvironment | Select-Object DisplayName, EnvironmentName | Format-Table
   ```

2. Set the environment variable value:
   - Go back to your environment variable
   - Click **+ New environment variable value**
   - In the **Value** field, enter environment IDs separated by commas (no spaces):
     ```
     env-guid-1,env-guid-2,env-guid-3
     ```
   - Click **Save**

### Step 3: Modify the Welcome Email Flow

1. In **Solutions**, open **Center of Excellence - Core Components**
2. Find the flow **Admin | Welcome Email v3**
3. Click **Edit**
4. After the trigger step **When a new Maker is added**, add a new action:
   - Click **+ New step**
   - Search for **Compose**
   - **Action**: Compose
   - **Name**: `Get Allowed Environments`
   - **Inputs**: 
     ```
     @parameters('Notification Allowed Environments (admin_NotificationAllowedEnvironments)')
     ```

5. Add another **Compose** action to get the maker's environment:
   - **Action**: Compose
   - **Name**: `Get Maker Environment`
   - **Inputs**: Click the lightning bolt to see dynamic content, then select the environment field from the trigger (typically `EnvironmentId` or similar field from the Maker record)

6. Add a **Condition** action:
   - **Action**: Condition
   - **Name**: `Check if Environment is Allowed`
   - **Condition**:
     - If `outputs('Get Allowed Environments')` is equal to empty string
       - OR
     - If `outputs('Get Allowed Environments')` contains `outputs('Get Maker Environment')`
   
   To create this compound condition:
   - Click **Add** → **Add row**
   - First condition: `Get Allowed Environments` **is equal to** (leave blank)
   - Click **Add** → **Add row** with **Or** logic
   - Second condition: `Get Allowed Environments` **contains** `Get Maker Environment`

7. Move all existing email actions into the **If yes** branch
8. In the **If no** branch, add a **Terminate** action:
   - **Status**: Cancelled
   - **Message**: `Environment not in allowed list - skipping notification`

9. **Save** the flow

### Step 4: Test the Configuration

1. Create a test app or flow in one of the allowed environments
2. Verify the maker receives the welcome email
3. Create a test app or flow in a non-allowed environment
4. Verify no email is sent (check flow run history - should show "Cancelled")

### Step 5: Apply to Other Notification Flows

Repeat Step 3 for other notification flows:
- **Admin | Compliance Details Request eMail (Apps)**
- **Admin | Compliance Details Request eMail (Flows)**
- **Admin | Compliance Details Request eMail (Custom Connectors)**
- **Admin | Compliance Details Request eMail (Chatbots)**
- **Admin | Compliance Details Request eMail (Desktop Flows)**

For compliance detail request flows, the environment information is typically available through the related resource (app, flow, etc.) record. You may need to add a **Get row** action to retrieve the environment ID from the related resource.

## Alternative Approach: Filter by Environment Name

If you prefer to use environment names instead of GUIDs:

1. Modify the environment variable to store environment names:
   ```
   Development,Sandbox,Test Environment
   ```

2. In the flow, get the environment name instead of ID:
   - Add a **List rows** action to query the Environment table
   - **Table**: Environments (admin_environment)
   - **Filter rows**: `admin_environmentid eq 'ENVIRONMENT_ID_FROM_MAKER'`
   - **Select columns**: `admin_displayname`

3. Update the condition to check environment name:
   ```
   outputs('Get Allowed Environments') contains outputs('Get Environment Name')
   ```

## Troubleshooting

### Emails still being sent to all environments
- Verify the environment variable has the correct value set
- Check the flow run history to ensure the condition is evaluating correctly
- Ensure the flow is using the latest version (republish after changes)

### No emails being sent at all
- Verify the environment variable value is correctly formatted (no extra spaces)
- Check if the environment IDs match exactly (including hyphens)
- Review flow run history for errors

### Environment ID not available in flow
- Some flows may need additional steps to retrieve environment information
- You may need to lookup the environment from the related resource (app/flow) record
- Use the **Get row** action to retrieve the full record with environment details

## Maintenance Considerations

### During CoE Starter Kit Upgrades
- **Export your modified flows** to a separate solution before upgrading
- After upgrade, you may need to reapply modifications
- Alternative: Create a separate flow that runs before the standard flows and sets a flag to skip/continue

### Documentation
- Document which flows have been modified
- Keep a list of allowed environment IDs
- Track reasons for including/excluding specific environments

## Advanced Options

### Using a Custom Table for Environment Management

For more flexibility, create a custom table:

1. Create table **Notification Environment Config**:
   - Columns:
     - `Environment ID` (Text)
     - `Environment Name` (Text)
     - `Send Notifications` (Yes/No)
     - `Notes` (Text)

2. Populate with your environments

3. In flows, use **List rows** to check configuration:
   ```
   List rows from Notification Environment Config
   Filter: Environment ID eq 'CURRENT_ENV_ID' and Send Notifications eq true
   ```

### Conditional Notification by Resource Type

You can also filter notifications based on resource types (apps vs flows) or other criteria:

- Add conditions to check app type, connector usage, etc.
- Create different allowed environment lists for different notification types
- Implement time-based restrictions (e.g., no notifications on weekends)

## Example Flow Structure

```
┌─────────────────────────────────┐
│  Trigger: New Maker Record      │
└────────────┬────────────────────┘
             │
             ▼
┌─────────────────────────────────┐
│  Get Allowed Environments Var   │
└────────────┬────────────────────┘
             │
             ▼
┌─────────────────────────────────┐
│  Get Maker's Environment ID     │
└────────────┬────────────────────┘
             │
             ▼
        ┌────┴────┐
        │         │
   Yes  │ Allowed? │  No
        │         │
        └────┬────┘
             │
    ┌────────┴────────┐
    ▼                 ▼
┌───────┐      ┌──────────┐
│ Send  │      │ Terminate│
│ Email │      │ (Skip)   │
└───────┘      └──────────┘
```

## Related Documentation

- [Filtering Maker Notifications](./FilteringMakerNotifications.md) - Overview and all filtering options
- [CoE Starter Kit Governance Components](https://learn.microsoft.com/power-platform/guidance/coe/governance-components)
- [Environment Variables in Power Platform](https://learn.microsoft.com/power-platform/admin/environment-variables)

## Support

If you encounter issues:
1. Check the [GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues) for similar questions
2. Review flow run history for detailed error messages
3. Verify environment variable values are correctly set
4. Ensure you have the necessary permissions to modify flows

---

**Last Updated**: December 2024  
**Applies to**: CoE Starter Kit v3.0 and later
