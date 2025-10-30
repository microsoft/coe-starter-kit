# Power BI Embedded Apps - Design Considerations

## Current Implementation

The Power BI dashboard templates (Production_CoEDashboard_*.pbit) contain embedded Power Apps visuals that use hardcoded App IDs. These IDs are environment-specific and change when:
- Upgrading the CoE Starter Kit
- Importing the solution into a new environment
- Reinstalling the solution

### Current App IDs in Template (July 2024)
- **Manage Flow** visual: `207e575c-6cf0-4d79-96f9-ffed8310be43`
- **Manage App** visual: `2fd6105d-fd1e-4367-8d35-23fce69f33f4`

These are placeholder IDs from the development/template environment and will not work in user environments.

## Problem

When users upgrade or deploy the CoE Starter Kit:
1. The solution creates new instances of the embedded apps with new GUIDs
2. The Power BI template still references the old/placeholder GUIDs
3. Users experience errors when trying to use drill-through features
4. Manual update of the template is required

## Proposed Solutions

### Solution 1: Power BI Parameters (Recommended)

Update the Power BI template to use parameters for App IDs:

**Advantages:**
- Users can update App IDs in Power BI Service without needing Power BI Desktop
- Parameters can be set during report configuration
- More maintainable and user-friendly

**Implementation:**
1. Create Power BI parameters: `AdminAccessFlowAppID` and `AdminAccessAppAppID`
2. Use these parameters in the embedded visual configurations instead of hardcoded values
3. Document the parameter values in setup guide

**Power BI Parameter Configuration:**
```
Name: AdminAccessFlowAppID
Type: Text
Current Value: <to be set by user>
Description: App ID for "Admin - Access this Flow" app from your CoE environment
```

### Solution 2: Dynamic App ID Lookup

Create a lookup table in Dataverse that stores the embedded app IDs:

**Advantages:**
- Fully automated - no manual configuration needed
- App IDs automatically updated when solution is imported

**Implementation:**
1. Add a new table/entity: `CoE Configuration` or extend existing settings
2. During solution import, use a flow to populate app IDs
3. Power BI queries this table to get current app IDs
4. Use M query to dynamically set the `appId` property

**Challenges:**
- Power BI embedded visual App ID property may not support dynamic expressions
- Would require testing to validate feasibility

### Solution 3: Setup Script/Tool

Create an automated tool that:
1. Connects to user's environment
2. Gets the correct App IDs
3. Modifies the .pbit file automatically
4. Provides user with customized .pbix file

**Advantages:**
- One-time automated process
- No manual Power BI editing needed

**Challenges:**
- Requires additional tooling
- .pbit files are ZIP archives with binary content that needs careful handling

### Solution 4: Documentation + Helper Script (Current Implementation)

**Current approach:**
- Provide clear documentation
- Provide PowerShell script to get App IDs
- Guide users through manual update process

**Advantages:**
- Simple to implement and maintain
- No risk of breaking existing functionality
- Works with current Power BI limitations

**Disadvantages:**
- Requires manual steps
- User must have Power BI Desktop

## Recommendation

**Short-term:** Continue with Solution 4 (Documentation + Helper Script) - already implemented

**Medium-term:** Implement Solution 1 (Power BI Parameters)
- Modify the .pbit templates to use parameters
- Update setup documentation to include parameter configuration
- Reduces friction for users
- Still requires one-time manual configuration but easier than current approach

**Long-term:** Investigate Solution 2 (Dynamic Lookup)
- If Power BI supports dynamic app IDs through expressions
- Would provide the best user experience
- Requires validation and testing

## Implementation Notes for Solution 1

To implement Power BI parameters, the following changes would be needed in the .pbit files:

1. Add parameters to DataModelSchema:
```json
{
  "name": "AdminAccessFlowAppID",
  "description": "App ID for Admin - Access this Flow app",
  "type": "text",
  "isRequired": true,
  "defaultValue": ""
}
```

2. Update Report/Layout to reference parameters:
```json
"appId": {
  "expr": {
    "Parameter": {
      "Name": "AdminAccessFlowAppID"
    }
  }
}
```

3. Document the parameters in setup guide with instructions to get values using the PowerShell script.

## Next Steps

1. Test if Power BI embedded visual supports parameter references for App IDs
2. If supported, create updated .pbit templates with parameters
3. Update documentation accordingly
4. Release as part of next version
