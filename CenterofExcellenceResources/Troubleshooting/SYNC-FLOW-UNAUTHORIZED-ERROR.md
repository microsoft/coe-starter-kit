# Troubleshooting: Admin | Sync Template v4 (Driver) - Unauthorized Error

## Issue Summary

The flow **"Admin | Sync Template v4 (Driver)"** fails with an **"Unauthorized"** error, typically occurring in the "Get with Name" action within the "For Type Legacy" scope when querying the Dataverse `admin_environments` table.

## Error Details

- **Flow Name:** Admin | Sync Template v4 (Driver)
- **Failing Action:** Get with Name (inside "For Type Legacy" scope)
- **Table Name:** admin_environments (Environments)
- **Error Message:** Unauthorized

## Root Cause

The "Unauthorized" error occurs when the Dataverse connection reference used by the flow does not have sufficient permissions to query the CoE tables. This is typically caused by one of the following:

1. **Connection reference not configured** - The connection reference is missing a valid connection
2. **Insufficient permissions** - The user account associated with the connection lacks the required security role
3. **Connection expired/revoked** - The connection has expired or been revoked
4. **Service principal misconfiguration** - If using a service principal, it may not have the required permissions

## Resolution Steps

### Step 1: Verify Connection References

1. Navigate to your CoE environment in **Power Apps** (make.powerapps.com)
2. Go to **Solutions** → **Center of Excellence - Core Components**
3. Select **Connection References** from the left navigation
4. Verify that the following connection references have valid connections:
   - **CoE Core - Dataverse** (`admin_CoECoreDataverse`)
   - **CoE Core - Dataverse (Env Request)** (`admin_CoECoreDataverseEnvRequest`)
   - **CoE Core - Dataverse for Environment Request** (`admin_sharedcommondataserviceforapps_98924`)

### Step 2: Update Connection References

If any connection reference is missing a connection:

1. Click on the connection reference
2. Select **+ New connection** or choose an existing valid connection
3. Ensure the connection uses a user account with appropriate permissions (see Step 3)

### Step 3: Verify User Permissions

The user account associated with the Dataverse connection must have one of the following security roles:

- **System Administrator** (recommended for initial setup)
- **Power Platform Admin** + **CoE Admin** (custom role from the CoE Starter Kit)

To verify and assign security roles:

1. Navigate to **Power Platform Admin Center** (admin.powerplatform.microsoft.com)
2. Select your CoE environment
3. Go to **Settings** → **Users + permissions** → **Users**
4. Find the user associated with the connection
5. Verify they have the **System Administrator** or **CoE Admin** role

### Step 4: Refresh Connections

If connections exist but are stale:

1. In Power Automate, go to **Data** → **Connections**
2. Find the Dataverse connection used by the flow
3. Click on the connection and verify its status
4. If the connection shows an error, click **Fix connection** or delete and recreate it

### Step 5: Re-run the Flow

After verifying and updating the connections:

1. Navigate to **My flows** in Power Automate
2. Find **Admin | Sync Template v4 (Driver)**
3. Click on the flow to open it
4. Select **Run** to trigger a new run
5. Monitor the run to ensure it completes successfully

## Prevention

To prevent this issue from recurring:

1. **Use a dedicated service account** - Create a dedicated service account for CoE flows with non-expiring credentials
2. **Monitor connection health** - Regularly check the Command Center for flow errors
3. **Set up alerts** - Configure the CoE Add-Ons Alerts flow to notify when flows fail
4. **Document connection owners** - Keep track of which accounts own which connections

## Related Documentation

- [CoE Starter Kit Setup Documentation](https://docs.microsoft.com/power-platform/guidance/coe/setup)
- [Setting up Connection References](https://docs.microsoft.com/power-platform/guidance/coe/setup-core-components#update-connection-references)
- [CoE Starter Kit FAQ](https://docs.microsoft.com/power-platform/guidance/coe/faq)

## Additional Notes

- The CoE Starter Kit is provided as a **best-effort, unsupported** solution
- For complex issues, please raise an issue at [CoE Starter Kit GitHub](https://github.com/microsoft/coe-starter-kit/issues)
- Consider attending the [CoE Starter Kit Office Hours](https://github.com/microsoft/coe-starter-kit/blob/main/CenterofExcellenceResources/OfficeHours/OFFICEHOURS.md) for community support
