# Troubleshooting: Power BI Connection Timeout Error with Admin Planning Component

## Issue Description

When setting up the Admin Planning Component Power BI dashboard using the 'Power Platform Administration Planning.pbit' template, users may encounter a connection timeout error.

### Error Message
```
DataSource.Error: Microsoft SQL: A connection was successfully established with the server, 
but then an error occurred during the pre-login handshake. 
(provider: TCP Provider, error: 0 - The semaphore timeout period has expired.)

Details:
    DataSourceKind=CommonDataService
    DataSourcePath=org**.crm.dynamics.com
    Message=A connection was successfully established with the server, but then an error 
             occurred during the pre-login handshake. 
             (provider: TCP Provider, error: 0 - The semaphore timeout period has expired.)
    ErrorCode=-2146232060
    Number=121
    Class=20
    State=0
```

## Root Causes

This timeout error typically occurs due to one or more of the following reasons:

1. **Network or Firewall Issues**: Corporate firewalls or network policies blocking the connection
2. **TDS (Tabular Data Stream) Protocol Restrictions**: Network equipment blocking TDS protocol used by Power BI to connect to Dataverse
3. **Power BI Desktop Privacy/Security Settings**: Incorrect privacy level settings preventing connection
4. **Dataverse Throttling or Performance**: High load on the Dataverse environment
5. **Authentication Issues**: Token expiration or authentication problems
6. **Large Dataset**: The Admin tasks table contains too much data causing timeout during initial load
7. **Power BI Desktop Version**: Outdated version of Power BI Desktop

## Troubleshooting Steps

### Step 1: Verify Prerequisites

Ensure the following prerequisites are met:

1. **Admin Planning Solution Installed**
   - Verify `admintaskanalysis_core` solution is installed in your environment
   - Check that there are no unmanaged layers on solution components
   - Confirm the `Admin tasks` Dataverse table exists and contains data

2. **Power BI Desktop Version**
   - Install the latest version of Power BI Desktop from [Microsoft Download Center](https://powerbi.microsoft.com/desktop/)
   - Minimum recommended version: Latest monthly release

3. **User Permissions**
   - Ensure you have System Administrator or System Customizer role in the target environment
   - Verify you have appropriate Power BI license (Power BI Pro or Premium Per User)

### Step 2: Network and Firewall Configuration

1. **Check Firewall Settings**
   - Ensure outbound HTTPS (port 443) is allowed to `*.dynamics.com` and `*.crm.dynamics.com`
   - Ensure TDS protocol (port 1433) is allowed for Dataverse connections
   - Contact your IT/Network team to verify no deep packet inspection is blocking TDS protocol

2. **Whitelist Required Endpoints**
   - Add the following URLs to your firewall/proxy whitelist:
     - `*.dynamics.com`
     - `*.crm.dynamics.com`
     - `*.powerapps.com`
     - `*.powerbi.com`
     - `login.microsoftonline.com`
     - `*.windows.net`

3. **VPN/Proxy Considerations**
   - Try connecting without VPN if applicable
   - If using corporate proxy, ensure it's properly configured in Power BI Desktop

### Step 3: Power BI Desktop Configuration

1. **Set Privacy Levels**
   - Open Power BI Desktop
   - Go to **File** > **Options and Settings** > **Options**
   - Navigate to **Current File** > **Privacy**
   - Set Privacy level to **Organizational** for your Dataverse connection
   - Or disable privacy level checks: **Security** > **Privacy** > Uncheck "Combine data according to your Privacy Level settings for each source"

2. **Configure Data Source Settings**
   - Go to **File** > **Options and Settings** > **Data Source Settings**
   - Find your Dataverse connection (org**.crm.dynamics.com)
   - Click **Edit Permissions**
   - Ensure credentials are current (click **Edit** to re-authenticate if needed)
   - Clear permissions and re-add if necessary

3. **Increase Timeout Settings**
   - While Power BI Desktop doesn't have a built-in timeout setting for Dataverse connections, you can try modifying the M query:
   - In Power Query Editor, go to **Advanced Editor**
   - Add timeout parameter to connection string if available

### Step 4: Optimize the Power BI Query

1. **Reduce Initial Data Load**
   - Open the .pbit file in Power BI Desktop
   - Go to **Transform Data** > **Power Query Editor**
   - Review the queries and add filters to reduce data volume:
     ```m
     // Example: Filter to only active tasks from last 6 months
     = Table.SelectRows(Source, each [statecode] = 0 and [createdon] >= Date.AddMonths(DateTime.LocalNow(), -6))
     ```

2. **Check for Complex Transformations**
   - Review all transformation steps in Power Query
   - Simplify or remove unnecessary transformations
   - Push filtering operations to the source (Dataverse) rather than doing them in Power BI

### Step 5: Verify Dataverse Environment

1. **Check Environment Health**
   - Navigate to [Power Platform Admin Center](https://admin.powerplatform.microsoft.com/)
   - Select your environment
   - Check for any alerts or performance issues

2. **Verify Admin Tasks Table**
   - Go to [Power Apps](https://make.powerapps.com/)
   - Select your environment
   - Navigate to **Tables** > **Admin tasks** (`admin_task`)
   - Verify the table exists and contains data
   - Check if there are excessive number of records (>100,000 could cause performance issues)

3. **Check API Limits**
   - Review if your environment is hitting API throttling limits
   - Check the [Power Platform admin center](https://admin.powerplatform.microsoft.com/) for any throttling notifications

### Step 6: Alternative Connection Methods

If the above steps don't resolve the issue, try these alternatives:

1. **Use Power BI Service Instead of Desktop**
   - Create a new report directly in Power BI Service
   - Use the Dataverse connector in Power BI Service
   - Configure the connection to your environment

2. **Use OData Feed Connection**
   - In Power BI Desktop, use **Get Data** > **OData Feed**
   - Enter the OData endpoint: `https://[your-environment].crm.dynamics.com/api/data/v9.2/`
   - Authenticate using organizational account
   - Select the `admin_tasks` entity

3. **Export Data and Use Excel/CSV**
   - As a temporary workaround, export the Admin tasks data from Dataverse
   - Import the exported data into Power BI
   - Note: This won't auto-refresh from Dataverse

### Step 7: Advanced Troubleshooting

1. **Enable TLS 1.2**
   - Ensure TLS 1.2 is enabled on your machine
   - Open Registry Editor (regedit) as Administrator
   - Navigate to: `HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols`
   - Ensure TLS 1.2 is enabled for both Client and Server

2. **Check Power BI Desktop Logs**
   - Navigate to: `%LocalAppData%\Microsoft\Power BI Desktop\Traces`
   - Review recent log files for detailed error information
   - Look for any network or authentication errors

3. **Test Connection with Other Tools**
   - Use [XrmToolBox](https://www.xrmtoolbox.com/) to test Dataverse connectivity
   - Use Power Apps portal to verify you can access the environment
   - This helps isolate if the issue is specific to Power BI or broader connectivity issue

## Prevention and Best Practices

1. **Regular Updates**
   - Keep Power BI Desktop updated to the latest version
   - Update CoE Starter Kit components regularly

2. **Environment Maintenance**
   - Regularly archive or delete old admin task records
   - Monitor environment performance and capacity

3. **Network Configuration**
   - Work with IT to ensure stable connectivity to Microsoft cloud services
   - Document required firewall rules for Power Platform and Power BI

4. **Documentation**
   - Document your specific environment URL and connection settings
   - Keep track of any custom configurations or workarounds

## Related Resources

- [CoE Starter Kit Setup - Admin Tasks Component](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup-admin-tasks-component)
- [Power BI Desktop Troubleshooting](https://learn.microsoft.com/en-us/power-bi/connect-data/desktop-troubleshooting-sign-in)
- [Dataverse Connection from Power BI](https://learn.microsoft.com/en-us/power-bi/connect-data/service-connect-to-dataverse)
- [Power Platform Network Requirements](https://learn.microsoft.com/en-us/power-platform/admin/online-requirements)

## Still Having Issues?

If you've tried all the above steps and still experiencing issues:

1. **Report an Issue**
   - File an issue at: [CoE Starter Kit Issues](https://github.com/microsoft/coe-starter-kit/issues)
   - Include:
     - Power BI Desktop version
     - CoE Starter Kit version
     - Admin Planning solution version
     - Full error message
     - Steps you've already tried

2. **Community Support**
   - Post in the [Power Apps Community Forum](https://powerusers.microsoft.com/t5/Power-Apps-Governance-and/bd-p/Admin_PowerApps)
   - Join CoE Starter Kit Office Hours (check [OFFICEHOURS.md](../../CenterofExcellenceResources/OfficeHours/OFFICEHOURS.md))

3. **Microsoft Support**
   - For Power BI connectivity issues: [Power BI Support](https://powerbi.microsoft.com/support/)
   - For Power Platform issues: Contact your Microsoft Support team

## Disclaimer

The CoE Starter Kit is a community-driven project and is not officially supported by Microsoft Support. However, the underlying platform features (Power BI, Dataverse, Power Platform) are fully supported through standard Microsoft support channels.
