# Connection Reference Link in Connection Reference Identities

## Overview

This feature adds a new lookup field `admin_ConnectionReference` to the `admin_ConnectionReferenceIdentity` table, enabling users to link connection identities to connection references and thereby identify which flows/apps use specific accounts.

## Use Case

When you need to disable a user account, this feature helps you proactively identify which specific flows and apps will be impacted. You can:

1. Query `admin_connectionreferenceidentities` by account name to find all connection identities for that account
2. Follow the `admin_ConnectionReference` lookup to see a representative connection reference
3. From the connection reference, identify the associated flow or app
4. Use the connector and environment to find other related connection references

## Implementation Details

### Entity Changes

- **Table**: `admin_ConnectionReferenceIdentity` (`admin_connectionreferenceidentities`)
- **New Field**: `admin_ConnectionReference` (lookup to `admin_ConnectionReference`)
- **Field Type**: Lookup (optional)
- **Description**: Links to a connection reference that uses this identity

### Flow Changes

The `AdminSyncTemplatev4ConnectionIdentities` flow has been updated to:

1. After determining the connector GUID and user information
2. Query the `admin_connectionreferences` table for connection references that match:
   - The same connector (`_admin_connector_value`)
   - In the same environment (implicitly, as the flow processes one environment at a time)
3. If a matching connection reference is found, link the first one to the identity record
4. If no matching connection reference is found, the field remains empty (null)

This logic is applied in both the regular user case and the orphaned user case.

## Important Notes

### Approximate Matching

The link between connection identities and connection references is **approximate** because:

- **Connection Identities** come from the Power Platform Admin API (`Get-AdminConnections`), which returns actual connection instances with account information
- **Connection References** come from app/flow definitions, which reference logical connection references

The matching is based on connector type only, not on the specific connection instance. This means:

- A connection identity with SQL connector and account `user@domain.com` will link to **one** of the SQL connection references in that environment
- There may be multiple SQL connection references in the environment, but only one is linked
- All connection references using the same connector type are potentially relevant

### Usage Recommendations

1. **Finding Affected Resources**: When you find a connection identity by account name, follow the connection reference link, then:
   - Check if it's linked to a flow (`admin_Flow`) or app (`admin_App`)
   - Use the connector information to query for other connection references with the same connector in the same environment
   
2. **Query Pattern**: To find all potentially affected flows/apps for an account:
   ```
   1. Query admin_connectionreferenceidentities WHERE accountname = 'user@domain.com'
   2. For each identity, note the connector
   3. Query admin_connectionreferences WHERE connector = [that connector] AND environment = [that environment]
   4. Check the flow/app links in those connection references
   ```

3. **Limitations**:
   - The link is to ONE representative connection reference, not all possible ones
   - The actual connection might not be the one linked (since matching is by connector type)
   - Some identities may have no linked connection reference if no connection references exist for that connector in the environment yet

## Future Enhancements

Potential improvements to this feature could include:

1. **Many-to-Many Relationship**: Create a junction table to link identities to ALL relevant connection references, not just one
2. **Exact Matching**: Capture connection IDs from the API to enable exact matching between connections and connection references
3. **Connection ID Field**: Store the actual connection ID from the API in the identity record for better traceability

## Migration Notes

After upgrading to this version:

1. Existing connection identity records will have the `admin_ConnectionReference` field as null
2. The field will be populated for new identities as they are discovered
3. To populate existing records, you can trigger a full sync by updating the environment records to re-run the flow

## Questions or Issues

If you encounter issues or have suggestions for this feature, please file an issue on the GitHub repository with:
- Solution version
- Steps to reproduce
- Expected vs actual behavior
- Any relevant screenshots or error messages
