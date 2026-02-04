# Troubleshooting: Duplicate Flows in CoE Setup Wizard

## Issue Description

When using the CoE Setup and Upgrade Wizard during the "Run setup flows" step, you may see duplicate entries for the same flow (e.g., "Admin | Sync Template v3 Configure Emails" appears twice).

![Duplicate Flow Example](https://github.com/user-attachments/assets/dedffb56-a33f-44bb-a178-df03edde9811)

## Root Cause

The CoE Setup Wizard displays flows based on records in the **CoE Solution Metadata** table. If this table contains duplicate records for the same flow (with the same `admin_objectname`), each duplicate record will cause the flow to appear multiple times in the Setup Wizard.

### How Duplicates Can Occur

Duplicate metadata records can be created in several scenarios:

1. **Multiple runs of the metadata flow**: Running "Admin | Sync Template v3 CoE Solution Metadata" multiple times in certain error conditions
2. **Failed upgrade/import**: A partially failed solution import or upgrade may leave orphaned metadata records
3. **Manual record creation**: Accidentally creating duplicate metadata records manually
4. **Corrupted state**: In rare cases, database corruption or conflicts can create duplicates

## Resolution

### Option 1: Clean Up Duplicate Metadata Records (Recommended)

The best solution is to remove duplicate records from the CoE Solution Metadata table:

1. **Open Power Apps** (https://make.powerapps.com)
2. Navigate to your **CoE environment**
3. Go to **Tables** → **CoE Solution Metadata**
4. **View the data** in the table
5. **Filter** by `Object Name` = "Admin | Sync Template v3 Configure Emails" (or the duplicate flow name)
6. **Identify duplicate records**:
   - Look for multiple records with the same `Object Name`
   - Check the `Created On` and `Modified On` dates
   - Keep the most recent record
7. **Delete the older duplicate record(s)**
8. **Refresh the Setup Wizard**

#### PowerShell Script to Find Duplicates

You can use this PowerShell script to identify all duplicate metadata records:

```powershell
# Install the module if needed
# Install-Module -Name Microsoft.PowerApps.Administration.PowerShell
# Install-Module -Name Microsoft.PowerApps.PowerShell -AllowClobber

# Connect to your environment
Add-PowerAppsAccount

# Set your environment ID
$environmentId = "YOUR-ENVIRONMENT-ID"

# Get duplicate metadata records
$duplicates = @"
<fetch>
  <entity name='admin_coesolutionmetadata'>
    <attribute name='admin_coesolutionmetadataid'/>
    <attribute name='admin_objectname'/>
    <attribute name='createdon'/>
    <attribute name='modifiedon'/>
    <order attribute='admin_objectname'/>
  </entity>
</fetch>
"@

# This would require Dataverse API access
# For manual cleanup, use the Power Apps maker portal as described above
```

### Option 2: Run the Metadata Flow Again

Sometimes, running the "Admin | Sync Template v3 CoE Solution Metadata" flow again can fix the issue, as it has upsert logic that should update existing records rather than creating new ones:

1. Open **Power Automate** in your CoE environment
2. Find **"Admin | Sync Template v3 CoE Solution Metadata"**
3. **Run** the flow manually
4. Wait for it to complete successfully
5. **Refresh** the Setup Wizard

**Note**: This may not always resolve duplicates that already exist, but it ensures no new duplicates are created.

### Option 3: Ignore the Duplicate (Not Recommended)

If you're unable to clean up the duplicates immediately, you can proceed with setup:

1. The duplicate entry in the Setup Wizard is just a display issue
2. Both entries point to the same actual flow
3. Running either one will have the same effect
4. Click "View Flow Details" to confirm they point to the same flow

However, this is not recommended as it can cause confusion and may lead to other issues.

## Prevention

To prevent duplicate metadata records in the future:

1. **Only run the metadata flow when needed**: Don't run "Admin | Sync Template v3 CoE Solution Metadata" multiple times unnecessarily
2. **Follow upgrade instructions**: When upgrading, follow the official documentation step-by-step
3. **Check for errors**: After running the metadata flow, check for errors in the flow run history
4. **Backup before upgrades**: Consider exporting your CoE Solution Metadata table before major upgrades

## Technical Details

### How the Setup Wizard Populates the Flow List

The Setup Wizard uses this logic (simplified):

```powerapps
Clear(FlowsWithMetadata);
ForAll(
    Filter(
        'CoE Solution Metadata',
        ObjectType = "CloudFlows"
    ),
    Collect(
        FlowsWithMetadata,
        {
            theName: ObjectName,
            theGUID: LookUp(Processes, 'Process Name' = ObjectName).Process,
            // ... other fields
        }
    )
);
```

This iterates through **all** metadata records where `ObjectType = "CloudFlows"`. If there are 2 metadata records for "Admin | Sync Template v3 Configure Emails", it will create 2 entries in the `FlowsWithMetadata` collection, even though they both point to the same actual flow (same GUID).

### Why the Metadata Flow Doesn't Always Prevent Duplicates

The "Admin | Sync Template v3 CoE Solution Metadata" flow has upsert logic:

```javascript
// Simplified flow logic
See_if_already_exists: Query where admin_objectname eq '<FlowName>'
If (count results < 1):
    Create new record
Else:
    Update first(results) 
```

This works correctly **if**:
- The query returns results
- The filter matches existing records properly

However, in some scenarios (database conflicts, timing issues, or manual records), duplicates can still exist.

## Related Issues

- [#10284](https://github.com/microsoft/coe-starter-kit/issues/10284) - Similar duplicate flow issue

## Need More Help?

If you continue to experience issues after trying these steps:

1. Check the [CoE Starter Kit Documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
2. Search for similar issues in the [GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues)
3. Create a new issue with:
   - Your CoE Starter Kit version
   - Screenshots of the duplicate
   - Steps you've already tried
   - Any error messages from flow runs

---

**Document Version**: 1.0  
**Last Updated**: February 2026  
**Applies To**: CoE Starter Kit v4.50.8 and later
