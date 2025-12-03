# Service Account Metrics in CoE Starter Kit

## Question
How can I retrieve metrics based on service accounts and their usage in the CoE Starter Kit? Specifically:
- Number of connections/Power Automate flows/dataflows/environments owned by service accounts
- Other metrics related to service account usage
- How to identify connections with expired tokens that require reauthentication

## Answer

### Service Account Tracking

Yes, the CoE Starter Kit provides several capabilities for tracking service account (Service Principal) usage and metrics.

#### 1. Service Principal Makers

The **admin_Maker** entity in the CoE Core Components solution includes a field called `admin_userisserviceprinciple` that identifies whether a maker is a service principal. This allows you to filter and report on service accounts specifically.

The following metrics are automatically calculated for each maker (including service principals) in the **admin_Maker** table:

- **admin_numberofapps** - Total number of apps
- **admin_numberofcanvasapps** - Number of Canvas apps
- **admin_numberofmodeldrivenapps** - Number of Model-driven apps  
- **admin_numberofsharepointapps** - Number of SharePoint apps
- **admin_numberofflows** - Number of Power Automate flows
- **admin_numberofuiflows** - Number of Desktop flows (RPA)
- **admin_numberofpvas** - Number of Power Virtual Agents bots
- **admin_numberofcustomconnectors** - Number of custom connectors
- **admin_numberofenvironments** - Number of environments (as owner/creator)

#### 2. Viewing Service Principal Metrics

There is a built-in saved query/view called **"Service Principle Makers"** that filters the Maker entity to show only service principals along with their app and flow counts. This view can be accessed in the CoE Core Components solution.

To access this data:

1. **Via the Power Platform Admin View app**: Navigate to the Makers view and filter by `admin_userisserviceprinciple = Yes`
2. **Via Power BI**: Use the Power BI dashboard included with the CoE Starter Kit to create custom reports filtering on service principals
3. **Via API/Power Automate**: Query the admin_Maker entity with a filter on `admin_userisserviceprinciple eq true`

#### 3. Connection Reference Tracking

The CoE Starter Kit tracks connections through two main entities:

- **admin_ConnectionReference** - Tracks connections used by apps and flows
  - Links to both Apps (admin_App) and Flows (admin_Flow)
  - Includes the connector type and when the connection was created
  
- **admin_ConnectionReferenceIdentity** - Tracks the identities using various connector types
  - Includes `admin_accountname` - The account name using the connection
  - Includes `admin_ConnectionReferenceCreator` - Lookup to the user/service principal who created the connection
  - Includes `admin_ConnectionReferenceCreatorDisplayName` - Display name of the connection creator
  - Includes `admin_connectionreferencecreatorisorphan` - Flag indicating if the creator account no longer exists

#### 4. Connection Expiration Tracking

**Current Limitation**: The CoE Starter Kit does **not** currently track connection token expiration status directly. The inventory flows collect metadata about connections but do not include token expiration dates or authentication status from the Power Platform APIs.

**Workarounds and Alternatives**:

1. **Manual Identification**: Orphaned connections (where the creator no longer exists) are tracked via the `admin_connectionreferencecreatorisorphan` field, which can indicate connections that may need attention

2. **Power Platform Admin Center**: Connection status and authentication issues are best monitored through the Power Platform Admin Center or via direct API calls to the Power Platform Management connectors

3. **Power Automate Flow Runs**: Failed flow runs due to connection issues will appear in the CoE telemetry data, which can serve as an indirect indicator of connection problems

4. **Custom Extension**: You could extend the CoE Starter Kit by creating a custom flow that:
   - Uses the Power Platform for Admins connector
   - Queries connection status via the `Get Connections as Admin` action
   - Stores connection health status in a custom entity
   - Note: This would require appropriate admin permissions and may be subject to API throttling limits

#### 5. Dataflows

For **dataflows** specifically, the CoE Starter Kit does not have a dedicated entity for tracking dataflows in the same way it tracks apps and flows. However:

- Dataflows can be inventoried if you're using the **Data Export** method for inventory (BYODL - Bring Your Own Data Lake)
- The CoE Starter Kit tracks when dataflow refreshes occur in the context of its own sync operations
- Creating custom tracking for dataflows would require extending the solution with additional flows and entities

### Recommended Approach for Service Account Metrics

To get comprehensive service account metrics:

1. **Install the CoE Core Components solution** (May 2025 version as specified in your question)

2. **Run the inventory flows** to populate the Dataverse tables with your tenant data

3. **Create a custom view or report** that:
   ```
   Filter: admin_userisserviceprinciple = Yes
   Display: 
   - Display Name
   - Number of Apps (admin_numberofapps)
   - Number of Flows (admin_numberofflows)  
   - Number of Custom Connectors (admin_numberofcustomconnectors)
   - Number of Environments (admin_numberofenvironments)
   ```

4. **For connection details by service account**:
   - Query the `admin_ConnectionReferenceIdentity` entity
   - Join with `admin_ConnectionReference` to get connection details
   - Filter by service principal makers

5. **For connection health monitoring**:
   - Set up monitoring of flow run failures in the CoE telemetry
   - Consider implementing a custom solution using Power Platform Admin APIs
   - Review the Power Platform Admin Center regularly for connection issues

### Related Entities You Can Query

- **admin_Maker** - Service principal information and aggregate counts
- **admin_Flow** - Individual flows (with owner/creator information)
- **admin_App** - Individual apps (with owner/creator information)
- **admin_Environment** - Environments (with owner information)
- **admin_ConnectionReference** - Connection references used by apps/flows
- **admin_ConnectionReferenceIdentity** - Identity information for connections
- **admin_Connector** - Connector information
- **admin_Solution** - Solutions (includes `admin_solutionowner` field for service account scenarios)

### Additional Resources

- [CoE Starter Kit Documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- [CoE Core Components](https://learn.microsoft.com/power-platform/guidance/coe/core-components)
- [Power Platform for Admins Connector](https://learn.microsoft.com/connectors/powerplatformforadmins/)

### Note on the "May 2025" Version

The version you mentioned ("May 2025") appears to be a future version. As of the current date, the latest releases are available at: https://github.com/microsoft/coe-starter-kit/releases

Please ensure you're using a current released version of the CoE Starter Kit. The functionality described above is available in recent releases (2024 versions).
