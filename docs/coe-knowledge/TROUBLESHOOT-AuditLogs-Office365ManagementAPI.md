# Troubleshooting: Admin | Audit Logs | Office 365 Management API Subscription Flow

## Issue: Flow Fails with "Get_Azure_Secret - Value cannot be null" Error

### Symptoms
The `Admin | Audit Logs | Office 365 Management API Subscription` flow fails with the following error:
```
Action 'Get_Azure_Secret' failed. Error occurred while reading secret: Value cannot be null. Parameter name: input
```

### Root Cause
This error occurs when the Office 365 Management API client secret environment variable is not properly configured in the CoE Core Components solution. The flow attempts to retrieve the Azure Key Vault secret reference but finds a null value because:

1. The required environment variables were not provided during the initial solution import
2. In a **managed solution**, environment variable values cannot be edited after installation if they were not initialized during import
3. The environment variable `admin_auditlogsclientazuresecret` or `admin_auditlogsclientsecret` is missing or empty

### Required Environment Variables
The flow requires the following environment variables to be configured:

| Environment Variable | Description | Required |
|---------------------|-------------|----------|
| `admin_auditlogsclientid` | Azure AD Application (Client) ID | Yes |
| `admin_auditlogsclientsecret` | Client Secret VALUE (plain text) | Yes* |
| `admin_auditlogsclientazuresecret` | Azure Key Vault secret reference | Yes* |
| `admin_TenantID` | Azure Directory (Tenant) ID | Yes |

*Note: You must configure **either** `admin_auditlogsclientsecret` OR `admin_auditlogsclientazuresecret`, not both.

### Prerequisites
Before configuring the flow, you need to have:
1. An Azure AD App Registration with appropriate permissions for Office 365 Management API
   - **Required API Permissions**: Office 365 Management APIs → ActivityFeed.Read
2. A Client Secret created for the app registration
3. The following values ready:
   - Application (Client) ID
   - Client Secret VALUE (not the secret ID or name)
   - Azure Directory (Tenant) ID

### Resolution Steps

#### Option 1: Configure Using CoE Setup & Upgrade Wizard (Recommended)

If you have a managed solution installation, the recommended approach is to use the CoE Setup & Upgrade Wizard:

1. **Open the CoE Setup & Upgrade Wizard**
   - Navigate to [Power Apps](https://make.powerapps.com)
   - Select your CoE environment (e.g., "CoE - Governance")
   - Go to **Solutions**
   - Open **Center of Excellence – Core Components**
   - Launch the **CoE Setup & Upgrade Wizard** (model-driven app)

2. **Navigate to Audit Logs Configuration**
   - In the wizard, go to the **Inventory / Audit Logs** configuration section
   - You will be prompted to provide the following values:

3. **Provide Required Values**
   - **Audit Logs – Client ID**: Enter your Application (Client) ID
   - **Audit Logs – Client Secret**: Enter the Client Secret VALUE
     - ⚠️ **Important**: Enter the actual secret value, NOT the secret name or ID
     - This should be the string value generated when you created the client secret in Azure AD
   - **Tenant ID**: Enter your Azure Directory (Tenant) ID

4. **Save and Complete**
   - Click **Save** or **Next** to persist the values
   - Complete the wizard steps
   - The wizard will configure the environment variables: `admin_auditlogsclientid`, `admin_auditlogsclientsecret`, and `admin_TenantID`

5. **Verify and Test**
   - Go to **Power Automate** → **Cloud flows**
   - Find `Admin | Audit Logs | Office 365 Management API Subscription`
   - Turn the flow **On** (if not already enabled)
   - Click **Run** to test the flow
   - The flow should complete successfully

#### Option 2: Configure During Solution Import (Fresh Installation)

If the environment variables were not provided during the original installation, you may need to re-import the solution:

⚠️ **Warning**: This approach requires removing and re-installing the Core Components solution, which may impact dependent solutions and data.

1. **Check for Dependencies**
   - Go to [Power Platform Admin Center](https://admin.powerplatform.microsoft.com)
   - Select your CoE environment
   - Go to **Solutions**
   - Check if other solutions depend on **Center of Excellence – Core Components**
   - If dependencies exist, you cannot remove the solution and should use Option 3 instead

2. **Remove the Core Components Solution** (if no dependencies)
   - In **Solutions**, locate **Center of Excellence – Core Components**
   - Click **Delete**
   - Confirm the deletion

3. **Download Latest Version**
   - Download the latest CoE Starter Kit from [GitHub Releases](https://github.com/microsoft/coe-starter-kit/releases)
   - Extract the ZIP file
   - Locate the **Core Components** managed solution file

4. **Import with Environment Variables**
   - Go to [Power Apps](https://make.powerapps.com)
   - Select your CoE environment
   - Go to **Solutions** → **Import**
   - Upload the Core Components solution ZIP file
   - Proceed through the import wizard

5. **Configure Environment Variables During Import**
   - After the **Connections** screen, you will see **Connection references and environment variables**
   - **This is critical**: Provide the following values:
     - **Audit Logs – Client ID**: Your Application (Client) ID
     - **Audit Logs – Client Secret**: The actual Client Secret VALUE
     - **Tenant ID**: Your Azure Directory (Tenant) ID
   - Click **Next** and complete the import

6. **Run the Flow**
   - After import completes, run the CoE Setup & Upgrade Wizard
   - Turn on the `Admin | Audit Logs | Office 365 Management API Subscription` flow
   - Test the flow by clicking **Run**

#### Option 3: Manual Environment Variable Configuration (For Unmanaged Solutions Only)

If you have an **unmanaged** solution (not recommended for production), you can manually configure environment variables:

1. **Navigate to Environment Variables**
   - Go to [Power Apps](https://make.powerapps.com)
   - Select your CoE environment
   - Go to **Solutions** → **Center of Excellence – Core Components**
   - Click on **Environment variables** in the left navigation

2. **Configure Each Variable**
   - Open `admin_auditlogsclientid`
     - Set **Current Value** to your Application (Client) ID
     - Click **Save**
   - Open `admin_auditlogsclientsecret`
     - Set **Current Value** to your Client Secret VALUE
     - Click **Save**
   - Open `admin_TenantID`
     - Set **Current Value** to your Azure Directory (Tenant) ID
     - Click **Save**

3. **Test the Flow**
   - Turn on the flow and run it

⚠️ **Note**: This option only works for **unmanaged solutions**. Managed solutions have read-only environment variables after installation.

### Common Errors and Solutions

#### Error: "Value cannot be null"
- **Cause**: Environment variable is not configured
- **Solution**: Follow Resolution Steps to configure the required variables

#### Error: "Unauthorized" or "401"
- **Cause**: Invalid Client ID or Client Secret, or insufficient API permissions
- **Solution**: 
  - Verify the Client ID and Secret are correct
  - Ensure the Azure AD app has `ActivityFeed.Read` permission for Office 365 Management APIs
  - Grant admin consent for the permissions

#### Error: "Invalid audience"
- **Cause**: Incorrect tenant configuration
- **Solution**: Verify `admin_TenantID` matches your Azure AD tenant

#### Environment Variables Are Read-Only / Locked
- **Cause**: This is expected behavior for managed solutions where values were not provided during import
- **Solution**: Use Option 1 (CoE Setup & Upgrade Wizard) or Option 2 (Re-import solution)

### Verification Steps

After configuring the environment variables, verify the setup:

1. **Test the Flow**
   - Run the `Admin | Audit Logs | Office 365 Management API Subscription` flow
   - Use operation: `list` to check existing subscriptions
   - If successful, the flow will return subscription status

2. **Check Flow Run History**
   - Open the flow
   - Click **Run history**
   - Verify the most recent run shows "Succeeded"
   - If it fails, check the error details for specific guidance

3. **Verify Subscription**
   - After a successful run with operation `start`, verify the subscription is active
   - You can run with operation `list` to see active subscriptions
   - Expected output: Status should be "enabled" for "Audit.General" content type

### Additional Resources

- [CoE Starter Kit Documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- [CoE Core Components Setup](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components)
- [Configure Audit Logs](https://learn.microsoft.com/power-platform/guidance/coe/setup-auditlog)
- [Office 365 Management API Reference](https://learn.microsoft.com/office/office-365-management-api/office-365-management-activity-api-reference)

### When to Seek Additional Help

If you've followed all resolution steps and the flow still fails:

1. Check the [GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues) for similar problems
2. Verify your Azure AD app registration permissions
3. Check that your user account has appropriate permissions in the CoE environment
4. Review the full flow run history for additional error details
5. Create a new issue with:
   - Solution version
   - Complete error message
   - Steps you've already tried
   - Screenshot of flow run failure
