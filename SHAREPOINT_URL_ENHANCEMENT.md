# SharePoint Site URL Enhancement

## Overview
This enhancement addresses the issue where SharePoint site URLs were not being captured in the COE Power BI report when Canvas Apps use SharePoint as a data source.

## Problem Statement
Previously, when Canvas Apps used SharePoint lists or libraries as data sources, the COE Power BI report's "SharePoint Form URL" column appeared blank. This was because the sync flow only captured the `accountName` property from connections, which works for user-authenticated connections but doesn't capture SharePoint site URLs.

## Solution
The enhancement adds a new field `admin_DatasetUrl` to the `admin_ConnectionReferenceIdentity` entity and updates the connection sync flow to extract dataset URLs from connection properties.

## Changes Made

### 1. Data Model Changes
**File**: `CenterofExcellenceCoreComponents/SolutionPackage/src/Entities/admin_ConnectionReferenceIdentity/Entity.xml`

Added new field:
- **Field Name**: `admin_DatasetUrl`
- **Type**: Text (URL format)
- **Max Length**: 2000 characters
- **Description**: "The URL of the dataset for connectors like SharePoint, SQL, etc. For SharePoint connections, this stores the SharePoint site URL."

### 2. Flow Changes
**File**: `CenterofExcellenceCoreComponents/SolutionPackage/src/Workflows/AdminSyncTemplatev4ConnectionIdentities-919D34D1-A8AC-EE11-A569-000D3A3411D9.json`

**Changes**:
1. **Select Action** - Updated to extract dataset URL:
   ```json
   "datasetUrl": "@coalesce(item()?['properties']?['parameterValues']?['dataset'], item()?['properties']?['connectionParameters']?['dataset'])"
   ```
   This extracts the dataset URL from either `parameterValues` or `connectionParameters` properties.

2. **ParseJson Schema** - Added `datasetUrl` property to the schema (optional field).

3. **Create Record Actions** - Added `admin_dataseturl` field to both:
   - `Add_Connection_Identities` action (for regular users)
   - `Add_Connection_Identities_for_Orphan` action (for orphaned users)

## Benefits
- **SharePoint Connections**: SharePoint site URLs are now captured and displayed in the COE dashboard
- **SQL Connections**: SQL Server names/connection strings can be captured
- **Other Data Sources**: Any connector that uses dataset parameters will have this information available
- **Improved Visibility**: Administrators can now track which SharePoint sites are being used across Canvas Apps

## Power BI Report Updates
To display the SharePoint site URLs in your Power BI report:

1. **Refresh the Data Model**: After deploying this solution, refresh your Power BI data sources to include the new `admin_dataseturl` field.

2. **Update Visuals**: Add the `Dataset URL` column to your connector-related tables:
   ```
   Table: admin_ConnectionReferenceIdentity
   Field: admin_DatasetUrl (admin_dataseturl)
   ```

3. **Create Measures** (optional): Create measures to show SharePoint-specific URLs:
   ```DAX
   SharePoint Site URL = 
   IF(
       RELATED(admin_Connector[admin_Name]) = "shared_sharepointonline",
       admin_ConnectionReferenceIdentity[admin_DatasetUrl],
       BLANK()
   )
   ```

## Data Examples
After this enhancement, the `admin_DatasetUrl` field will contain values like:

- **SharePoint**: `https://contoso.sharepoint.com/sites/HRDepartment`
- **SQL Server**: `server.database.windows.net`
- **Dataverse**: Organization URL or environment ID
- **File-based connectors**: File path or folder location

## Deployment Instructions

### Prerequisites
- COE Starter Kit installed
- Admin access to Power Platform environment
- Ability to import solutions

### Deployment Steps

1. **Import the Solution**:
   - The updated solution will include the new `admin_DatasetUrl` field on the `admin_ConnectionReferenceIdentity` entity.
   - The flow `AdminSyncTemplatev4ConnectionIdentities` will be updated automatically.

2. **Trigger Initial Sync**:
   - After deployment, trigger the connection identities sync flow for each environment to populate the new field with existing connections.
   - The flow runs automatically when environments are created/updated, but you can manually trigger it.

3. **Update Power BI Report**:
   - Open your COE Dashboard Power BI file
   - Refresh the data model to see the new field
   - Update visuals to include the `Dataset URL` column
   - Publish the updated report

4. **Verify**:
   - Check a Canvas App that uses SharePoint as a data source
   - View the app in the Power BI report
   - Verify that the SharePoint site URL now appears in the report

## Compatibility
- **Minimum COE Version**: 4.50.1
- **Backward Compatible**: Yes - existing functionality is not changed
- **Power BI Report**: Requires refresh after deployment, but existing reports will continue to work

## Limitations
- The dataset URL field is populated only for new connections or when the sync flow runs after deployment
- Not all connectors expose dataset information in the same way; some connectors may not have this information available
- For connectors that use implicit connections (like Office 365 Users), this field may remain empty

## Future Enhancements
- Add connector-specific parsing logic for different dataset formats
- Create specialized fields for common connectors (SharePoint site, SQL server, etc.)
- Add validation to detect when dataset URLs change
- Implement change tracking to notify admins of dataset URL updates

## Support
If you encounter issues with this enhancement:
1. Verify the field was added successfully to the `admin_ConnectionReferenceIdentity` entity
2. Check that the flow `AdminSyncTemplatev4ConnectionIdentities` is enabled and running
3. Review flow run history for any errors
4. Ensure connections have the required properties (parameterValues or connectionParameters)

## Related Issue
GitHub Issue: [COE - Power BI Report where Canvas App Data Source URL of the SharePoint site is blank]

## Contributors
- Microsoft CoE Starter Kit Team
- Community Contributors
