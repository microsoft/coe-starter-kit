# Admin View Data Refresh - Troubleshooting Flowchart

```
┌─────────────────────────────────────────────────────────────────┐
│  Power Platform Admin View showing old data or missing envs?   │
└─────────────────────┬───────────────────────────────────────────┘
                      │
                      ▼
         ┌────────────────────────────┐
         │  Check Flow Status         │
         │  (Driver, Apps, Envs)      │
         └────────┬───────────────────┘
                  │
         ┌────────┴────────┐
         │                 │
    All "On"          Some "Off"/
         │            "Suspended"
         │                 │
         ▼                 ▼
┌────────────────┐  ┌──────────────────┐
│ Check Run      │  │ Turn On Flows    │
│ History        │  │ & Check          │
│                │  │ Connections      │
└────┬───────────┘  └────┬─────────────┘
     │                   │
     │ Recent success?   │ Fixed?
     │                   │
 ┌───┴────┬──────┐      │
 │        │      │      │
 Yes      No     Old    │
 │        │      │      │
 │        └──────┴──────┘
 │               │
 │               ▼
 │      ┌────────────────────┐
 │      │ Check Connections  │
 │      │ (Re-authenticate)  │
 │      └─────┬──────────────┘
 │            │
 │            ▼
 │      ┌────────────────────┐
 │      │ Trigger Manual     │
 │      │ Driver Flow Sync   │
 │      └─────┬──────────────┘
 │            │
 │            │ Wait 15-30 min
 │            │
 └────────────┴──────────┐
                         │
                         ▼
              ┌──────────────────┐
              │ Check Flow Run   │
              │ Result           │
              └────┬─────────────┘
                   │
          ┌────────┴─────────┐
          │                  │
      Success            Failed
          │                  │
          ▼                  ▼
   ┌─────────────┐    ┌──────────────────┐
   │ Verify      │    │ Review Error     │
   │ Dataverse   │    │ Message          │
   │ Tables      │    └────┬─────────────┘
   └──┬──────────┘         │
      │                    │
      │ Data present?      │ Error Type?
      │                    │
  ┌───┴───┐           ┌────┴─────┬──────────┬────────┐
  │       │           │          │          │        │
 Yes      No       401/403    Timeout   Invalid   Other
  │       │           │          │      Connect    │
  │       │           ▼          │          │       │
  │       │      ┌─────────┐     │          │       │
  │       │      │ Fix     │     │          │       │
  │       │      │ Perms   │     │          │       │
  │       │      └─────────┘     │          │       │
  │       │                      │          │       │
  │       └──────────────────────┴──────────┘       │
  │                      │                          │
  │                      ▼                          │
  │              ┌───────────────┐                  │
  │              │ Check Env     │                  │
  │              │ Variables     │                  │
  │              └───┬───────────┘                  │
  │                  │                              │
  │                  ▼                              │
  │          ┌───────────────────┐                  │
  │          │ Force Full        │                  │
  │          │ Inventory Resync  │                  │
  │          └────┬──────────────┘                  │
  │               │                                 │
  │               │ Wait 30-60 min                  │
  │               │                                 │
  └───────────────┴─────────────────────────────────┘
                  │
                  ▼
       ┌────────────────────┐
       │ Verify in Admin    │
       │ View App           │
       └────┬───────────────┘
            │
       ┌────┴─────┐
       │          │
   Working    Still Issues
       │          │
       ▼          ▼
   ┌──────┐  ┌───────────────────┐
   │ Done │  │ Advanced          │
   │  ✓   │  │ Troubleshooting:  │
   └──────┘  │ - Check API Quota │
             │ - Review Logs     │
             │ - Service         │
             │   Principal       │
             │ - GitHub Issue    │
             └───────────────────┘
```

## Decision Points

### Flow Status Check
- **All On + Recent Success** → Problem likely in data visibility/app refresh
- **Suspended/Off** → Fix flow state and connections first
- **Old Runs** → Trigger manual sync, likely stopped running

### Connection Health
- **Warning Icons** → Re-authentication required
- **No Warnings but Flows Fail** → Permission issue, check admin role
- **Valid Connections** → Check environment variables

### Error Types
- **401/403** → Authentication/Authorization - Fix connections and permissions
- **429** → Throttling - Wait and retry, consider service principal
- **Timeout** → Large tenant - Normal for first sync, verify partial success
- **Invalid Connection** → Re-authenticate immediately

### Data Verification
- **In Dataverse but Not in App** → Check visibility flags in Environment table
- **Not in Dataverse** → Sync didn't run or failed for that environment
- **Old Data in Both** → Sync not running, start from top

## Time Estimates

| Step | Time Required | Wait Time |
|------|--------------|-----------|
| Check Flow Status | 2 min | - |
| Check Run History | 1 min | - |
| Fix Connections | 2 min | - |
| Turn On Flows | 1 min | - |
| Trigger Manual Sync | 2 min | 15-30 min |
| Verify Dataverse | 5 min | - |
| Force Full Resync | 5 min | 30-60 min |
| Verify Admin View | 5 min | - |
| **Total (typical case)** | **15-20 min active** | **15-30 min wait** |
| **Total (full resync)** | **20-25 min active** | **30-60 min wait** |

## Success Indicators

✅ Driver flow shows recent successful run  
✅ Dependent flows (Apps, Environments) also ran after Driver  
✅ Dataverse Environment table has all environments with recent Modified dates  
✅ Dataverse PowerApps App table has recent apps  
✅ Admin View app shows all environments in filter  
✅ Admin View app displays recently created apps  

## Common Root Causes (by frequency)

1. **Expired/Invalid Connections** (60%)
   - Fix: Re-authenticate with admin account

2. **Flows Suspended Due to Errors** (25%)
   - Fix: Resolve error, turn flow back on

3. **Environment Variables Misconfigured** (10%)
   - Fix: Verify "Is All Environments Inventory" = Yes

4. **API Throttling/Quota Limits** (3%)
   - Fix: Adjust schedule, use service principal

5. **Actual Product Bugs** (2%)
   - Fix: Upgrade to latest version, report to GitHub

## Quick Reference Commands

### PowerShell - Check Environment Access
```powershell
Get-AdminPowerAppEnvironment | Select-Object DisplayName, EnvironmentName
```

### PowerShell - List Recent Apps
```powershell
Get-AdminPowerApp -EnvironmentName <env-name> | Where-Object { $_.LastModifiedTime -gt (Get-Date).AddMonths(-1) }
```

## Related Documentation

- 📘 [Full Troubleshooting Guide](troubleshooting-admin-view-data-refresh.md)
- ⚡ [Quick Fix Guide](QUICKFIX-admin-view-not-updating.md)
- 📋 [Common Responses Playbook](COE-Kit-Common%20GitHub%20Responses.md)
- 🎯 [Issue Response Template](ISSUE-RESPONSE-admin-view-not-updating.md)
