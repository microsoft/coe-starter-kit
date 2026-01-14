# Quick Start: Finding Flows/Apps Affected by Account Disabling

## Goal
Identify which flows and apps will be impacted when you disable a user account.

## Prerequisites
- CoE Starter Kit version 4.28.0 or later installed
- Admin access to the CoE environment
- The `AdminSyncTemplatev4ConnectionIdentities` flow has run at least once after upgrading

## Step-by-Step Guide

### Option 1: Using Power Apps (Dataverse)

1. **Open your CoE environment** in Power Apps (make.powerapps.com)

2. **Navigate to Tables** (or Dataverse)

3. **Find Connection Reference Identities**:
   - Search for "Connection Reference Identities" table
   - Open the table
   - Click "Data" to view records

4. **Filter by account name**:
   - Add a filter: `Account Name` contains `user@domain.com`
   - You'll see all connection identities for that user

5. **Check the Connection Reference link**:
   - Each record has a "Connection Reference" lookup field
   - Click on the lookup to see the connection reference details
   - From there, you can see the linked Flow or App

6. **Find all affected resources**:
   - Note the "Connector" value from the identity
   - Go to "Connection References" table
   - Filter by the same Connector and Environment
   - This shows all connection references (and their flows/apps) that use that connector

### Option 2: Using Power Automate (Flow)

Create a simple flow to query and generate a report:

```
Trigger: Manual button
Action 1: Initialize variable - varAccountName (String)
Action 2: List rows - admin_connectionreferenceidentities
  - Filter: admin_accountname eq '[varAccountName]'
  - Select: admin_name, admin_accountname, _admin_connectionreference_value, _admin_connector_value

Action 3: Apply to each (from Action 2)
  - Get row: admin_connectionreferences
    - Row ID: items('Apply_to_each')?['_admin_connectionreference_value']
  - Get row: admin_flows (if _admin_flow_value is not null)
    - Row ID: outputs('Get_row_-_Connection_Reference')?['_admin_flow_value']
  - Compose: Flow Name and ID
    
Action 4: Create HTML table (from all Compose outputs)
Action 5: Send email with the table
```

### Option 3: Using Power BI

If you have the CoE Power BI dashboard:

1. Open the Power BI report
2. Go to the "Connections" or "Inventory" page
3. Use filters to find:
   - Connection Identity: filter by Account Name
   - Follow to Connection References: use related table filtering
   - See Flows/Apps: view the linked resources

### Option 4: Using Advanced Find

1. **In Dynamics 365/Power Apps**:
   - Open Advanced Find
   
2. **Create Query**:
   ```
   Look for: Connection Reference Identities
   Use Saved View: (create new)
   Add Filter: Account Name equals [user email]
   Add Related Entity: Connection Reference
   Add Columns from Connection Reference: Display Name, Flow, App
   ```

3. **Results**:
   - Shows identities with their linked connection references
   - Export to Excel for further analysis

## Example Scenario

**Scenario:** You need to disable `john.doe@contoso.com` and want to know which flows will stop working.

**Steps:**
1. Search Connection Reference Identities for `john.doe@contoso.com`
2. Results show:
   - SQL connector identity → links to Connection Reference "SQL Production DB"
   - SharePoint connector identity → links to Connection Reference "SharePoint HR Site"

3. Click on "SQL Production DB" connection reference:
   - Shows it's used by Flow: "Daily Sales Report"
   - Shows it's used by App: "Sales Dashboard"

4. Click on "SharePoint HR Site" connection reference:
   - Shows it's used by Flow: "New Employee Onboarding"

5. **Action Items**:
   - Before disabling John's account, reassign these 2 flows and 1 app to another user
   - Update connection references to use a service account instead of personal accounts

## Best Practices

1. **Use Service Accounts**: For production flows/apps, use service accounts instead of personal accounts to avoid disruptions

2. **Document Connection Ownership**: Keep track of which connections are used where

3. **Regular Audits**: Periodically review connection identities to identify personal accounts in critical flows

4. **Proactive Replacement**: When employees change roles or leave:
   - Run this query before their last day
   - Reassign or update connections ahead of time
   - Test the flows/apps after updating connections

5. **Connection Reference Naming**: Use clear, descriptive names for connection references to make identification easier

## Troubleshooting

### Problem: Connection Reference field is empty

**Cause:** The field is only populated for identities discovered after the upgrade.

**Solution:** 
- Trigger a re-sync by editing and saving the Environment record
- Or wait for the scheduled sync to run

### Problem: Can't find specific flow/app

**Cause:** The link is approximate - one identity may link to ONE connection reference, but the same connector might be used in multiple references.

**Solution:**
- From the identity, note the Connector and Environment
- Query Connection References table for all references with that connector
- Check each one for flows/apps

### Problem: Multiple users share the same connection

**Cause:** Some connectors allow shared connections.

**Solution:**
- This is expected behavior
- When updating, coordinate with all affected users
- Consider migrating to connection references that use service accounts

## Further Reading

- See `CONNECTIONREFERENCE_FEATURE.md` for detailed technical documentation
- See `CHANGES_SUMMARY.md` for implementation details
- CoE Starter Kit Documentation: https://docs.microsoft.com/power-platform/guidance/coe/starter-kit
