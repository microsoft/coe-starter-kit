# Implementation Guide: Solution Membership for Desktop Flows and PVA

## Current Status

✅ **COMPLETED:**
- Many-to-many relationship schemas added to Dataverse:
  - `admin_PPSolution_DesktopFlow` (Desktop Flows ↔ Solutions)
  - `admin_PPSolution_PVA` (PVA Bots ↔ Solutions)
- Intersection tables will be created automatically:
  - `admin_PPSolution_DesktopFlow_Table`
  - `admin_PPSolution_PVA_Table`

⏳ **PENDING:**
- Flow logic to populate the solution membership relationships

## Next Steps

The **CLEANUPHELPER-SolutionObjects** flow needs to be updated to query and populate solution membership for Desktop Flows and PVA bots.

### Flow Modification Overview

File: `CLEANUPHELPER-SolutionObjects-8A51E503-8EB5-EE11-A569-000D3A3411D9.json`

#### Current Flow Structure

The flow currently handles Apps and Cloud Flows:

```
1. Get solution list
2. For each solution:
   a. List solution components (Apps: componenttype 300/80)
   b. List solution components (Flows: componenttype 29)
   c. Compare with current inventory
   d. Associate new items
   e. Disassociate removed items
```

#### Required Changes

Add parallel processing for Desktop Flows and PVA:

```
2. For each solution:
   a. List solution components (Apps: componenttype 300/80)
   b. List solution components (Flows: componenttype 29, category ne 6)
   c. List solution components (Desktop Flows: componenttype 29, category eq 6)  ← NEW
   d. List solution components (PVA: componenttype 380)                          ← NEW
   e. Compare with current inventory
   f. Associate new items (Apps, Flows, Desktop Flows, PVA)                     ← UPDATED
   g. Disassociate removed items (Apps, Flows, Desktop Flows, PVA)              ← UPDATED
```

### Detailed Implementation Steps

#### Step 1: Add Desktop Flow Solution Component Query

In the "Get solution components from this environment" scope, add a new action after "List_Solutions_Workflows":

**Action Name:** `List_Solutions_DesktopFlows`
**Type:** OpenApiConnection - ListRecordsWithOrganization
**Parameters:**
```json
{
  "organization": "@triggerBody()['text_1']",
  "entityName": "solutioncomponents",
  "$filter": "componenttype eq 29 and _solutionid_value eq @{items('Apply_to_each_Soln')?['admin_solutionenvtguid']}"
}
```
**Runtime Configuration:**
```json
{
  "paginationPolicy": {
    "minimumItemCount": 100000
  }
}
```

**Note:** This query returns both Cloud Flows and Desktop Flows (both are componenttype 29). We need to filter Desktop Flows by joining with the workflows table where `category eq 6`.

#### Step 2: Filter Desktop Flows from Workflows

**Action Name:** `Filter_DesktopFlows_Only`
**Type:** Filter Array
**From:** `@outputs('List_Solutions_DesktopFlows')?['body/value']`
**Condition:** Use a nested HTTP call or Dataverse query to check if workflow has `category eq 6`

**Alternative Approach:** Since filtering requires additional API calls, consider combining Desktop Flows with Cloud Flows initially and filtering during the association phase by querying the workflow record's category.

#### Step 3: Add PVA Solution Component Query

**Action Name:** `List_Solutions_PVA`
**Type:** OpenApiConnection - ListRecordsWithOrganization
**Parameters:**
```json
{
  "organization": "@triggerBody()['text_1']",
  "entityName": "solutioncomponents",
  "$filter": "componenttype eq 380 and _solutionid_value eq @{items('Apply_to_each_Soln')?['admin_solutionenvtguid']}"
}
```
**Runtime Configuration:**
```json
{
  "paginationPolicy": {
    "minimumItemCount": 100000
  }
}
```

#### Step 4: Select Actual Desktop Flows

**Action Name:** `Select_Actual_DesktopFlows`
**Type:** Select
**From:** `@outputs('List_Solutions_DesktopFlows')?['body/value']`
**Map:**
```json
{
  "ObjectID": "@item()['objectid']"
}
```

#### Step 5: Select Actual PVA Bots

**Action Name:** `Select_Actual_PVA`
**Type:** Select
**From:** `@outputs('List_Solutions_PVA')?['body/value']`
**Map:**
```json
{
  "ObjectID": "@item()['objectid']"
}
```

#### Step 6: Get Current Desktop Flow Inventory

In the "Get_Current_Inventory_of_Solution_Objects" scope, add:

**Action Name:** `Get_Inventory_DesktopFlows_for_Soln`
**Type:** OpenApiConnection - ListRecords
**Parameters:**
```json
{
  "entityName": "admin_solutions",
  "recordId": "@items('Apply_to_each_Soln')?['admin_solutionid']",
  "$expand": "admin_PPSolution_DesktopFlow($select=admin_rpaid)"
}
```

#### Step 7: Get Current PVA Inventory

**Action Name:** `Get_Inventory_PVA_for_Soln`
**Type:** OpenApiConnection - ListRecords
**Parameters:**
```json
{
  "entityName": "admin_solutions",
  "recordId": "@items('Apply_to_each_Soln')?['admin_solutionid']",
  "$expand": "admin_PPSolution_PVA($select=admin_pvaid)"
}
```

#### Step 8: Add Desktop Flow Association Logic

In the "Add items to inventory if not already present" section, add a parallel scope:

**Scope Name:** `AddToInventory - DesktopFlows`

**Apply to each:** `@body('Select_Actual_DesktopFlows')`

**Condition:** Check if Desktop Flow is not already in inventory

**Action:** `Add_Solution_DesktopFlow`
```json
{
  "entityName": "admin_solutions",
  "recordId": "@items('Apply_to_each_Soln')?['admin_solutionid']",
  "associationEntityRelationship": "admin_PPSolution_DesktopFlow",
  "item/@odata.id": "@first(outputs('Get_DesktopFlow_To_Add')?['body/value'])?['@odata.id']"
}
```

#### Step 9: Add PVA Association Logic

**Scope Name:** `AddToInventory - PVA`

**Apply to each:** `@body('Select_Actual_PVA')`

**Condition:** Check if PVA bot is not already in inventory

**Action:** `Add_Solution_PVA`
```json
{
  "entityName": "admin_solutions",
  "recordId": "@items('Apply_to_each_Soln')?['admin_solutionid']",
  "associationEntityRelationship": "admin_PPSolution_PVA",
  "item/@odata.id": "@first(outputs('Get_PVA_To_Add')?['body/value'])?['@odata.id']"
}
```

#### Step 10: Add Desktop Flow Disassociation Logic

In the "Remove items from inventory" section, add:

**Scope Name:** `RemoveFromInventory - DesktopFlows`

**Apply to each:** Current Desktop Flows in inventory

**Condition:** Check if Desktop Flow is not in the solution components list

**Action:** `Remove_Solution_DesktopFlow`
```json
{
  "entityName": "admin_solutions",
  "recordId": "@items('Apply_to_each_Soln')?['admin_solutionid']",
  "associationEntityRelationship": "admin_PPSolution_DesktopFlow",
  "$id": "@first(outputs('Get_DesktopFlow_To_Remove')?['body/value'])?['@odata.id']"
}
```

#### Step 11: Add PVA Disassociation Logic

**Scope Name:** `RemoveFromInventory - PVA`

**Apply to each:** Current PVA bots in inventory

**Condition:** Check if PVA bot is not in the solution components list

**Action:** `Remove_Solution_PVA`
```json
{
  "entityName": "admin_solutions",
  "recordId": "@items('Apply_to_each_Soln')?['admin_solutionid']",
  "associationEntityRelationship": "admin_PPSolution_PVA",
  "$id": "@first(outputs('Get_PVA_To_Remove')?['body/value'])?['@odata.id']"
}
```

### Testing Plan

1. **Setup Test Environment:**
   - Deploy updated solution with new relationships
   - Verify intersection tables are created
   - Create test Desktop Flows and PVA bots in solutions

2. **Test Association:**
   - Create a new Desktop Flow in a solution
   - Run CLEANUPHELPER-SolutionObjects
   - Verify Desktop Flow appears in solution's related records
   - Repeat for PVA bot

3. **Test Disassociation:**
   - Remove Desktop Flow from solution
   - Run CLEANUPHELPER-SolutionObjects
   - Verify Desktop Flow relationship is removed
   - Repeat for PVA bot

4. **Test Edge Cases:**
   - Desktop Flow in multiple solutions
   - PVA bot in Default solution
   - Desktop Flow with no solution (standalone)
   - Solution with many Desktop Flows/PVA (pagination)

### Known Considerations

1. **Component Type Overlap:** Both Cloud Flows and Desktop Flows use componenttype 29. Additional filtering by the workflow's `category` field is required to distinguish them.

2. **Performance:** Each solution will require additional API calls for Desktop Flow and PVA component queries. Monitor for throttling.

3. **Pagination:** Use pagination policy with `minimumItemCount: 100000` to handle solutions with many components.

4. **Error Handling:** Add try-catch blocks for association/disassociation operations to handle cases where relationships already exist or don't exist.

5. **Default Solution:** The Default Solution (uniquename: "Default") may not return expected results for Desktop Flows/PVA. Consider excluding or handling specially.

### Alternative Simplified Approach

If the full solution component sync is too complex, consider a simpler approach:

1. **Modify Desktop Flow Sync:** In `AdminSyncTemplatev4Desktopflows`, after retrieving each Desktop Flow from the workflows table, query its solution membership via:
   ```
   GET [org]/api/data/v9.2/workflows([workflow-id])?$expand=solutionid
   ```

2. **Modify PVA Sync:** Similarly, in `AdminSyncTemplatev4PVA`, query solution membership when syncing each bot.

3. **Direct Association:** Directly associate the Desktop Flow/PVA with its solution during the sync process rather than in a separate cleanup flow.

**Pros:**
- Simpler logic
- Happens during natural sync cycle
- Less additional API calls overall

**Cons:**
- Doesn't follow the pattern of other resources
- May miss solution membership changes between full syncs
- Requires modifying multiple flows

## Rollback Plan

If issues occur after deployment:

1. The new relationships are backward compatible - existing functionality is not affected
2. Solution membership queries can be disabled by not running the updated flow
3. Remove the intersection table records if needed:
   ```
   DELETE FROM admin_PPSolution_DesktopFlow_Table WHERE ...
   DELETE FROM admin_PPSolution_PVA_Table WHERE ...
   ```

## Documentation Updates Needed

Once implemented, update:
- [ ] CoE Starter Kit official documentation
- [ ] Release notes for the version
- [ ] Power BI reports to show solution membership
- [ ] Canvas apps to display solution relationships

## Questions for Review

1. Should we use the CLEANUPHELPER approach or modify individual sync flows?
2. How should we handle the Default solution?
3. What's the expected behavior for Desktop Flows in multiple solutions?
4. Should we backfill historical data or only track going forward?
