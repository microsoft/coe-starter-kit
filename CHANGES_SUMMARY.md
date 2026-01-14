# Summary of Changes for Connection Reference Identity Feature

## Issue
GitHub Issue: [CoE Starter Kit - Feature]: Please add [connectionreferenceid] to 'admin_connectionreferenceidentities' table

**Problem Statement:**
Users need to identify which flows and apps will be impacted when disabling a user account. The `admin_connectionreferenceidentities` table stores information about which accounts are using connectors, but there was no way to link this to specific flows or apps.

**Requested Solution:**
Add a `connectionreferenceid` column to the `admin_connectionreferenceidentities` table to enable joining with the `admin_connectionreferences` table, which contains information about which flows and apps use specific connectors.

## Changes Made

### 1. Entity Definition Changes

**File:** `CenterofExcellenceCoreComponents/SolutionPackage/src/Entities/admin_ConnectionReferenceIdentity/Entity.xml`

**Change:** Added a new lookup attribute `admin_ConnectionReference` to the `admin_ConnectionReferenceIdentity` entity.

**Details:**
- **Attribute Name:** `admin_ConnectionReference`
- **Logical Name:** `admin_connectionreference`
- **Type:** Lookup (single)
- **Required Level:** None (optional field)
- **Description:** "Link to a connection reference that uses this identity"
- **Introduced Version:** 4.28.0

This lookup field enables users to navigate from a connection identity record to a related connection reference record, and from there to the associated flow or app.

### 2. Flow Changes

**File:** `CenterofExcellenceCoreComponents/SolutionPackage/src/Workflows/AdminSyncTemplatev4ConnectionIdentities-919D34D1-A8AC-EE11-A569-000D3A3411D9.json`

**Changes:** Added logic to query and populate the new `admin_ConnectionReference` field in two places where connection identity records are created.

#### Change 1: Regular User Identity Creation (Line ~545)

**Added Action:** `Find_matching_connection_reference`
- **Type:** OpenApiConnection (ListRecords)
- **Purpose:** Query the `admin_connectionreferences` table to find a connection reference that uses the same connector
- **Filter:** `_admin_connector_value eq @{outputs('ConnectorGUID')}`
- **Top:** 1 (returns first match)

**Updated Action:** `Add_Connection_Identities`
- **RunAfter:** Changed to run after `Find_matching_connection_reference` (with Succeeded or Failed status)
- **New Parameter:** `item/admin_ConnectionReference@odata.bind`
  - **Value:** Conditional expression that sets the OData bind string if a match is found, otherwise null
  - **Expression:** `@if(greater(length(coalesce(outputs('Find_matching_connection_reference')?['body/value'], createArray())), 0), concat('admin_connectionreferences(', first(outputs('Find_matching_connection_reference')?['body/value'])?['admin_connectionreferenceid'], ')'), null)`

#### Change 2: Orphaned User Identity Creation (Line ~734)

**Added Action:** `Find_matching_connection_reference_for_orphan`
- Same structure as the regular user case, but uses `shared_commondataserviceforapps_3` connection

**Updated Action:** `Add_Connection_Identities_for_Orphan`
- **RunAfter:** Changed to run after `Find_matching_connection_reference_for_orphan` (with Succeeded or Failed status)
- **New Parameter:** `item/admin_ConnectionReference@odata.bind`
  - Same conditional expression using `outputs('Find_matching_connection_reference_for_orphan')`

### 3. Documentation

**File:** `CONNECTIONREFERENCE_FEATURE.md` (new file)

Created comprehensive documentation covering:
- Overview of the feature and use case
- Implementation details
- Important notes about approximate matching
- Usage recommendations and query patterns
- Known limitations
- Future enhancement possibilities
- Migration notes

## How It Works

1. When the `AdminSyncTemplatev4ConnectionIdentities` flow processes connections for an environment:
   - For each unique connection identity (connector + account + creator)
   - The flow queries `admin_connectionreferences` for any connection reference using the same connector
   - If found, it links the first matching connection reference to the identity record
   - If not found, the field remains null

2. Users can now:
   - Query `admin_connectionreferenceidentities` by account name to find identities
   - Follow the `admin_ConnectionReference` lookup to see a connection reference
   - From the connection reference, identify the linked flow (via `admin_Flow`) or app (via `admin_App`)
   - Query for other connection references with the same connector to find all potentially affected resources

## Important Limitations

1. **Approximate Matching:** The link is based on connector type only, not on specific connection instances. This means:
   - A connection identity is linked to ONE representative connection reference
   - Other connection references using the same connector may also be affected
   - The actual connection instance may be different from the one implied by the link

2. **No Historical Data:** Existing connection identity records will have null values for the new field until the environment is reprocessed

3. **One-to-Many Relationship:** One identity can be used in multiple connection references, but only one link is stored

## Testing Recommendations

1. After upgrading:
   - Trigger a full environment sync by updating environment records
   - Verify that new connection identity records have the `admin_ConnectionReference` field populated
   - Check that the linked connection references have valid flows or apps

2. Query patterns to validate:
   ```
   # Find identities for a specific account
   SELECT * FROM admin_connectionreferenceidentities WHERE admin_accountname = 'user@domain.com'
   
   # Follow the link to connection references
   SELECT cr.* 
   FROM admin_connectionreferences cr
   INNER JOIN admin_connectionreferenceidentities cri ON cr.admin_connectionreferenceid = cri._admin_connectionreference_value
   WHERE cri.admin_accountname = 'user@domain.com'
   
   # Find associated flows/apps
   SELECT f.admin_displayname, f.admin_flowid
   FROM admin_flows f
   INNER JOIN admin_connectionreferences cr ON f.admin_flowid = cr._admin_flow_value
   INNER JOIN admin_connectionreferenceidentities cri ON cr.admin_connectionreferenceid = cri._admin_connectionreference_value
   WHERE cri.admin_accountname = 'user@domain.com'
   ```

## Rollback Considerations

If this change needs to be rolled back:
1. The new field in the entity is optional, so existing code will continue to work
2. The flow changes handle the case where no connection reference is found (sets null)
3. Remove the two new query actions from the flow and the new parameter from the create actions
4. The entity field can be left in place (harmless) or removed in a future version

## Future Enhancements

Potential improvements that could be made:
1. Create a many-to-many junction table to link identities to ALL matching connection references
2. Store the actual connection ID from the API to enable exact matching
3. Add a periodic sync job to backfill the field for existing records
4. Enhance matching logic to consider account/creator information in addition to connector type
