# CoE Dataflow Chain Visualization

This document provides a visual representation of how CoE dataflows trigger sequentially.

## Standard Flow Chain

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         CoE BYODL Dataflow Chain                        │
└─────────────────────────────────────────────────────────────────────────┘

Step 1: SCHEDULED TRIGGER
┌──────────────────────┐
│  Maker Dataflow      │ ← Scheduled refresh (or manual trigger)
│  (admin_makers)      │
└──────────┬───────────┘
           │ Completes
           ▼
┌────────────────────────────────────────┐
│ CoE BYODL - When Maker dataflow        │ ← Cloud Flow (must be ON)
│ refresh is complete                    │
└──────────┬─────────────────────────────┘
           │ Updates makers data
           │ Then triggers
           ▼

Step 2: ENVIRONMENT DATAFLOW
┌──────────────────────┐
│ Environment Dataflow │
│ (admin_environments) │
└──────────┬───────────┘
           │ Completes
           ▼
┌────────────────────────────────────────┐
│ CoE BYODL - When Environment dataflow  │ ← Cloud Flow (must be ON)
│ refresh is complete                    │
└──────────┬─────────────────────────────┘
           │ Updates environment data
           │ Then triggers ALL THREE in parallel
           │
           ├───────────────┬───────────────┐
           ▼               ▼               ▼

Step 3: RESOURCE DATAFLOWS (Parallel)
┌─────────────┐   ┌─────────────┐   ┌──────────────┐
│Flow Dataflow│   │App Dataflow │   │Model App     │
│(cloud flows)│   │(canvas apps)│   │Dataflow      │
└──────┬──────┘   └──────┬──────┘   └──────┬───────┘
       │                 │                  │
       │ Completes       │ Completes        │ Completes
       ▼                 ▼                  ▼
┌─────────────┐   ┌─────────────┐   ┌──────────────┐
│When Flow    │   │When App     │   │When Model App│
│dataflow     │   │dataflow     │   │dataflow      │
│complete     │   │complete     │   │complete      │
└─────────────┘   └─────────────┘   └──────────────┘
       │                 │                  │
       └─────────────────┴──────────────────┘
                         │
                         ▼
                  ┌─────────────┐
                  │   DONE!     │
                  │ All data    │
                  │  refreshed  │
                  └─────────────┘
```

## What Happens at Each Step

### Step 1: Maker Dataflow
- **Trigger:** Scheduled refresh (configured in dataflow settings) OR manual trigger
- **Data Source:** Microsoft Dataverse (admin_makers table via BYODL)
- **Processing:** Syncs maker information from various sources
- **Cloud Flow Action:** When complete, triggers "CoE BYODL - When Maker dataflow refresh is complete"
- **Next Step:** Cloud flow updates maker records and triggers Environment dataflow

### Step 2: Environment Dataflow
- **Trigger:** Programmatically triggered by the Maker dataflow completion flow
- **Data Source:** Microsoft Dataverse (admin_environments table via BYODL)
- **Processing:** Syncs environment information and metadata
- **Cloud Flow Action:** When complete, triggers "CoE BYODL - When Environment dataflow refresh is complete"
- **Next Step:** Cloud flow processes environment data and triggers THREE dataflows in parallel

### Step 3: Resource Dataflows (Parallel)
Three dataflows run simultaneously:

#### Flow Dataflow
- **Trigger:** Programmatically triggered by Environment dataflow completion flow
- **Data Source:** Cloud flows data
- **Processing:** Syncs flow information and properties
- **Cloud Flow Action:** "CoE BYODL - When Flow dataflow refresh is complete"

#### App Dataflow
- **Trigger:** Programmatically triggered by Environment dataflow completion flow
- **Data Source:** Canvas apps data
- **Processing:** Syncs canvas app information and properties
- **Cloud Flow Action:** "CoE BYODL - When App dataflow refresh is complete"

#### Model App Dataflow
- **Trigger:** Programmatically triggered by Environment dataflow completion flow
- **Data Source:** Model-driven apps data
- **Processing:** Syncs model-driven app information
- **Cloud Flow Action:** "CoE BYODL - When Model App dataflow refresh is complete"

## Dependencies Required for Chain to Work

### 1. Environment Variables (Must be populated)
```
admin_CurrentEnvironment        → Your environment ID with region suffix
admin_MakerDataflowID          → GUID of Maker dataflow
admin_EnvironmentDataflowID    → GUID of Environment dataflow
admin_FlowDataflowID           → GUID of Flow dataflow
admin_AppDataflowID            → GUID of App dataflow
admin_ModelAppDataflowID       → GUID of Model App dataflow
```

### 2. Cloud Flows (Must be turned ON)
```
✓ CoE BYODL - When Maker dataflow refresh is complete
✓ CoE BYODL - When Environment dataflow refresh is complete
✓ CoE BYODL - When Flow dataflow refresh is complete
✓ CoE BYODL - When App dataflow refresh is complete
✓ CoE BYODL - When Model App dataflow refresh is complete
```

### 3. Connection References (Must be valid)
```
admin_CoECoreDataverse2       → Dataverse connection
admin_CoEBYODLDataverse       → Dataverse connection for BYODL
admin_CoEBYODLPowerQuery      → Power Query/Dataflow connector
```

## Break Points in the Chain

If any dataflow doesn't refresh, check the previous step:

### Symptom: Environment dataflow not refreshing
→ Check: "When Maker dataflow refresh is complete" flow
→ Verify: Maker dataflow actually completed successfully
→ Verify: Environment Dataflow ID environment variable is populated

### Symptom: Flow/App/Model App dataflows not refreshing
→ Check: "When Environment dataflow refresh is complete" flow
→ Verify: Environment dataflow actually completed successfully
→ Verify: Flow/App/Model App Dataflow ID environment variables are populated

### Symptom: Nothing refreshes after Maker
→ Check: "When Maker dataflow refresh is complete" flow is turned ON
→ Verify: All connection references are valid
→ Check: Flow run history for errors

## Expected Timeline

For a typical tenant with moderate data:

```
Maker Dataflow:        30-60 minutes
  ↓ (trigger + processing: ~5 minutes)
Environment Dataflow:  30-60 minutes
  ↓ (trigger + processing: ~5 minutes)
Flow Dataflow:         45-90 minutes
App Dataflow:          45-90 minutes     } In Parallel
Model App Dataflow:    30-60 minutes

Total Time: 2.5 - 4.5 hours
```

For large tenants (1000+ environments, 10000+ apps/flows):
```
Total Time: 6-12 hours
```

## Troubleshooting Tips

1. **Check one step at a time:** Start with Maker → Environment, then Environment → Resources
2. **Monitor flow runs:** Each cloud flow should show a run when its dataflow completes
3. **Check timestamps:** Dataflow "Last Refresh" should update after each successful refresh
4. **Review flow errors:** Failed flows will show in run history with error details
5. **Verify IDs match:** Environment variable values should match actual dataflow GUIDs

## Additional Notes

⚠️ **BYODL is deprecated:** This architecture is being phased out in favor of Fabric integration and cloud flow-based inventory collection.

📊 **License matters:** Trial or insufficient licenses can cause dataflows to fail or timeout.

⏱️ **Be patient:** The full chain takes hours, not minutes. Don't manually trigger if one is already running.

## Related Documentation

- [TROUBLESHOOTING-DATAFLOWS.md](../../TROUBLESHOOTING-DATAFLOWS.md) - Complete troubleshooting guide
- [dataflow-refresh-not-working.md](./dataflow-refresh-not-working.md) - Issue response template
- [CoE Setup Documentation](https://learn.microsoft.com/power-platform/guidance/coe/setup)
