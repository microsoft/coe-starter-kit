# Flow Dependencies Quick Reference

This quick reference guide helps you understand and troubleshoot flow dependencies in the CoE Starter Kit inventory system.

## Core Flow Dependency Chain

```
┌─────────────────────────────────────────────────────────────┐
│  Admin - Sync Template v4 (Driver)                          │
│  • Runs: Every 24 hours (scheduled)                         │
│  • Purpose: Orchestrates entire inventory process           │
│  • Critical: Must complete before child flows run           │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ├─ Populates: Environments table
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│  Child Flows (Triggered per environment)                    │
├─────────────────────────────────────────────────────────────┤
│  • Admin - Sync Template v4 (Apps)                          │
│  • Admin - Sync Template v4 (Flows)                         │
│  • Admin - Sync Template v4 (Desktop flows)                 │
│  • Admin - Sync Template v4 (Model Driven Apps)             │
│  • Admin - Sync Template v4 (Custom Connectors)             │
│  • Admin - Sync Template v4 (Portals)                       │
│  • Admin - Sync Template v4 (PVA)                           │
│  • Admin - Sync Template v4 (Business Process Flows)        │
│  • Admin - Sync Template v4 (Security Roles)                │
│  • Admin - Sync Template v4 (Solutions)                     │
└─────────────────────────────────────────────────────────────┘
```

## What Each Flow Does

| Flow Name | Populates Table | Depends On | Trigger Type |
|-----------|----------------|------------|--------------|
| **Admin - Sync Template v4 (Driver)** | Environments | None | Scheduled (24h) |
| **Admin - Sync Template v4 (Apps)** | PowerApps App | Environments | Child flow call |
| **Admin - Sync Template v4 (Flows)** | Flow | Environments | Child flow call |
| **Admin - Sync Template v4 (Desktop flows)** | Flow (Desktop) | Environments | Child flow call |
| **Admin - Sync Template v4 (Model Driven Apps)** | PowerApps Model App | Environments | Child flow call |
| **Admin - Sync Template v4 (Custom Connectors)** | Custom Connector | Environments | Child flow call |

## Critical Dependencies

### ⚠️ If Environments Table is Empty
**Impact**: NO child flows will populate data
**Reason**: Child flows query the Environments table to know which environments to scan
**Fix**: Ensure Driver flow completes successfully

### ⚠️ If Driver Flow Fails
**Impact**: No inventory data updates
**Reason**: Driver flow is the only entry point to the inventory system  
**Fix**: Review Driver flow errors, check connections, verify admin permissions

### ⚠️ If Child Flow is Turned Off
**Impact**: That specific resource type won't update (e.g., Apps or Flows)
**Reason**: Turned off flows don't respond to triggers
**Fix**: Turn on the specific child flow

## Quick Diagnostic Checklist

Use this checklist when flows/apps tables are not populating:

- [ ] **Driver flow status**: Check run history for successful completion
  - Location: Power Automate > Cloud flows > "Admin - Sync Template v4 (Driver)"
  - Look for: Green checkmark, completion time
  
- [ ] **Environments table**: Verify data exists
  - Location: Power Platform Admin View app > Environments
  - Look for: Records with recent "Modified On" timestamps
  
- [ ] **Child flows ON status**: Confirm all flows are enabled
  - Location: Power Automate > Cloud flows > Search "Admin - Sync Template v4"
  - Look for: All flows show "On" status
  
- [ ] **Child flow run history**: Check for recent executions
  - Location: Each child flow > Run history  
  - Look for: Multiple runs after Driver completion
  
- [ ] **Connection references**: Validate all connections
  - Location: Solutions > Center of Excellence Core Components > Connection References
  - Look for: All connections show valid status
  
- [ ] **Time since last run**: Allow sufficient time
  - Expectation: 24-48 hours after upgrade or first run
  - Large tenants: Up to 4-8 hours for single run

## Common Scenarios

### Scenario 1: After Fresh Install
**Timeline**:
- Hour 0: Install solution, configure connections
- Hour 1-2: Driver flow runs (manual or scheduled)
- Hour 2-4: Child flows trigger and complete
- Hour 24: Second automated run begins

**Expected**: First full inventory within 4-8 hours

### Scenario 2: After Upgrade (from 11/11)
**Timeline**:
- Day 0: Upgrade completed
- Day 0-1: Flows may need to be turned back on
- Day 1: First Driver run completes
- Day 1-2: Child flows catch up with new data

**Expected**: Full inventory refresh within 24-48 hours

### Scenario 3: Daily Operations
**Timeline**:
- Every 24 hours: Driver flow runs automatically
- Within 1-4 hours: All child flows complete
- Data freshness: Within 24 hours for most resources

**Expected**: Continuous daily updates

## Troubleshooting by Symptom

### Symptom: "Flows table is empty"
**Most likely cause**: Driver flow not completing or Flows child flow not running
**Check**:
1. Driver flow run history (last 48 hours)
2. Environments table has data
3. "Admin - Sync Template v4 (Flows)" is turned ON
4. "Admin - Sync Template v4 (Flows)" run history shows executions

### Symptom: "Apps table is empty"
**Most likely cause**: Driver flow not completing or Apps child flow not running
**Check**:
1. Driver flow run history (last 48 hours)
2. Environments table has data
3. "Admin - Sync Template v4 (Apps)" is turned ON
4. "Admin - Sync Template v4 (Apps)" run history shows executions

### Symptom: "Some environments missing apps/flows"
**Most likely cause**: Child flow failed for specific environments
**Check**:
1. Child flow run history for failed runs
2. Error messages mentioning specific environment
3. Environment permissions and access
4. API throttling errors (429)

### Symptom: "Data is 2+ days old"
**Most likely cause**: Driver flow not running on schedule
**Check**:
1. Driver flow schedule configuration
2. Flow suspension status (flows auto-suspend after errors)
3. Connection expiration
4. License issues

## Flow Run Timing

| Flow | Typical Duration | Max Expected |
|------|------------------|--------------|
| Driver (small tenant) | 15-30 min | 1 hour |
| Driver (large tenant) | 1-2 hours | 4 hours |
| Child flow per environment | 1-5 min | 15 min |
| Complete inventory cycle | 1-4 hours | 8 hours |

## Manual Trigger Instructions

### To Force Immediate Inventory Update:

1. **Navigate to Driver Flow**
   - Power Automate > Cloud flows
   - Search: "Admin - Sync Template v4 (Driver)"
   - Click the flow name

2. **Trigger Manual Run**
   - Click "Run" button (top right)
   - Click "Run flow" in the panel
   - Click "Done"

3. **Monitor Progress**
   - Stay on the flow page
   - Click "Refresh" to see latest run
   - Wait for completion (green checkmark)

4. **Verify Child Triggers**
   - Navigate to each child flow
   - Check run history within 15-30 minutes
   - Should see multiple new runs

5. **Check Data Tables**
   - Open Power Platform Admin View app
   - Navigate to Apps/Flows tables
   - Verify recent records appear

## Connection Requirements

All flows require these connections to be valid:

| Connection | Used By | Purpose |
|-----------|---------|---------|
| **Power Platform for Admins** | Driver, All child flows | Get environments, resources |
| **Dataverse** | Driver, All child flows | Store inventory data |
| **Office 365 Users** | Driver, Child flows | Get user information |
| **Office 365 Groups** | Driver (optional) | Get group ownership |

### How to Verify Connections:
1. Solutions > Center of Excellence Core Components
2. Click "Connection References"
3. Each should show: "Connection set" or similar valid status
4. If invalid: Click the reference, select/create valid connection

## Related Topics

- For detailed troubleshooting: See [Troubleshooting-Inventory-Flows.md](Troubleshooting-Inventory-Flows.md)
- For common responses: See [COE-Kit-Common-GitHub-Responses.md](COE-Kit-Common-GitHub-Responses.md)
- For official docs: [Microsoft Learn - CoE Starter Kit](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)

---

*Quick reference guide - Last updated: December 2024*
