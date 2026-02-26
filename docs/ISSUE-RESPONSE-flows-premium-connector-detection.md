# Issue Response: Flows with Standard Connectors Shown as Premium

## Issue Description
Flows that only use standard connectors (such as SharePoint, Excel Online, Office 365) are being incorrectly flagged as having premium connectors in the CoE Starter Kit inventory (version 4.50.8 and potentially other versions).

## Root Cause Analysis

### Technical Details
The `SYNC HELPER - Cloud Flows` workflow is responsible for inventorying cloud flows and determining whether they use premium connectors. The detection logic works as follows:

1. **Connector Tier Extraction**: The flow retrieves connector information from the Power Platform Admin API via the `Get Flow as Admin` action
2. **Tier Selection**: Uses a `Select` action to extract the tier from each connector reference
3. **Premium Filtering**: Filters the list to find any connectors with tier = "Premium"
4. **Final Determination**: Sets `hasPremiumConnectors` to `true` if:
   - Any connector has tier = "Premium", OR
   - The flow contains HTTP, HttpWebhook, or Request triggers/actions

### The Bug
The bug was in step 2 (Tier Selection). The `Select_tier` action was using an incorrect path to access the connector tier:

**Incorrect Path (Bug):**
```
@item()?['apiDefinition/properties/tier']
```

**Correct Path (Fix):**
```
@item()?['apiDefinition/properties/properties/Tier']
```

### Why This Caused the Issue
According to the Power Platform API response structure, the tier information is nested under `apiDefinition/properties/properties/Tier`, not `apiDefinition/properties/tier`. This is confirmed by the Parse JSON schema defined in the flow itself.

When the incorrect path was used:
- The tier value could not be retrieved (returned null/empty)
- The `Filter_to_premium` action would not work correctly
- The logic may have defaulted to marking flows as premium or relied solely on the HTTP/Webhook checks
- Standard connectors appeared to be premium

## Solution

### Code Fix
The fix updates the path in the `SYNCHELPER-CloudFlows` flow:

**File:** `CenterofExcellenceCoreComponents/SolutionPackage/src/Workflows/SYNCHELPER-CloudFlows-A44274DF-02DA-ED11-A7C7-0022480813FF.json`

**Change in the `Select_tier` action:**
```json
{
  "select": "@item()?['apiDefinition/properties/properties/Tier']"
}
```

### Deployment Steps

1. **Apply the Fix:**
   - Import the updated CoE Core Components solution that includes this fix
   - Or manually update the flow if you're on a version that supports flow editing

2. **Run Full Inventory:**
   After applying the fix, you must run a full inventory to refresh all flow data:
   
   a. Open the CoE Setup Wizard or Admin Command Center
   
   b. Set the environment variable `admin_FullInventory` to `Yes`
   
   c. Trigger the inventory flows (they will run on their schedule or can be run manually)
   
   d. Wait for the inventory to complete (may take several hours depending on tenant size)
   
   e. Set `admin_FullInventory` back to `No`

3. **Verify the Fix:**
   - Open the Power Platform Admin View or Admin Command Center
   - Navigate to the Flows page
   - Check flows that were previously incorrectly flagged:
     - Standard connector flows should now show "No" for hasPremiumConnectors
     - Premium connector flows should still show "Yes"
   - Compare with actual connector usage in the Power Automate maker portal

## Validation

To validate the fix is working:

1. **Check a Known Standard Flow:**
   - Find a flow that only uses standard connectors (SharePoint, Office 365, etc.)
   - Verify it shows "No" for hasPremiumConnectors

2. **Check a Known Premium Flow:**
   - Find a flow that uses premium connectors or HTTP actions
   - Verify it shows "Yes" for hasPremiumConnectors

3. **Check the Connector Entity:**
   - Navigate to the Connectors table in the Admin View
   - Verify that standard connectors show Tier = "Standard"
   - Verify that premium connectors show Tier = "Premium"

## Additional Notes

### Why Some Flows May Still Show as Premium
Even after the fix, some flows may legitimately be flagged as premium if they:
- Use actual premium connectors
- Use HTTP actions (`"type":"Http"`)
- Use HTTP Webhook triggers (`"type":"HttpWebhook"` or `"kind":"HttpWebhook"`)
- Use Request triggers (`"type":"Request"`)
- Use Teams Webhook triggers

These are considered premium features by the CoE Starter Kit logic.

### Impact on Licensing Analysis
This bug may have caused:
- Overestimation of premium connector usage
- Incorrect license requirement calculations
- False positives in compliance and governance reports

After applying the fix and running a full inventory, review your licensing analysis to get accurate data.

## Related Documentation
- [CoE Starter Kit Setup](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components)
- [Power Platform Licensing FAQ](https://learn.microsoft.com/power-platform/admin/powerapps-flow-licensing-faq)
- [Premium Connector List](https://learn.microsoft.com/power-platform/admin/powerapps-flow-licensing-faq#what-connectors-are-premium)

## Version Information
- **Issue First Identified:** Version 4.50.8
- **Fix Applied:** [This PR/Version]
- **Affected Versions:** Potentially all versions prior to this fix
