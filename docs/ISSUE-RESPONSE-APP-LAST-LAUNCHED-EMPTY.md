# Issue Response: "App Last Launched On" Field Empty

## Quick Response Template

Use this template when responding to issues where the `admin_applastlaunchedon` field is empty in the Power Platform Admin View.

---

## Response

Thank you for reporting this issue. The **"App Last Launched On"** field being empty is typically a **configuration requirement** rather than a bug.

### Root Cause

The `admin_applastlaunchedon` field requires the **Audit Log component** to be set up and configured. This field is populated by:

1. **Office 365 Audit Logs** (must be enabled in Microsoft 365)
2. **Audit Log flows** (part of Core Components v4.17.4+ or standalone Audit Logs solution)
3. **Active subscription** to Office 365 Management Activity API

**Without these components, the field will remain empty for all apps.**

### Quick Diagnostic Questions

Please help us understand your setup:

1. **Is Office 365 Audit Log enabled in your tenant?**
   - Check: [Microsoft 365 Compliance Center](https://compliance.microsoft.com/auditlogsearch)
   - Required: "Start recording user and admin activity" must be ON

2. **What version of Core Components are you running?**
   - Audit log capability was added in v4.17.4
   - Earlier versions require separate Audit Logs solution

3. **Do you see flows with "Audit Logs" in the name?**
   - Look for: `Admin | Audit Logs | Sync Audit Logs V2`
   - Look for: `Admin | Audit Logs | Update Data (V2)`
   - If missing: Audit log component is not installed

### Solution Path

Based on your situation, follow the appropriate path:

#### Path A: Office 365 Audit Logs Not Enabled
If audit logging is disabled in Microsoft 365:

1. Go to [M365 Compliance Center](https://compliance.microsoft.com/auditlogsearch)
2. Click "Start recording user and admin activity"
3. Wait **24-48 hours** for audit log infrastructure to activate
4. Proceed to Path B or C

**Licensing Note:** Requires Microsoft 365 E3/E5 or Business Premium license

#### Path B: Audit Log Solution Not Installed
If you have Core Components **v4.17.4 or later**:

1. Audit log flows are included - verify they're turned ON:
   - `Admin | Audit Logs | Office 365 Management API Subscription` → Run once
   - `Admin | Audit Logs | Sync Audit Logs V2` → Turn ON (runs daily)
   - `Admin | Audit Logs | Update Data (V2)` → Turn ON (automatic trigger)

2. Configure environment variables:
   - `AuditLog_TenantID` → Your Microsoft 365 Tenant ID
   - `AuditLog_Publisher` → Office 365 Management API Publisher GUID
   
3. Test by launching an app and waiting 30 minutes

**If you have Core Components earlier than v4.17.4:**

1. Install the standalone **CenterofExcellenceAuditLogs** solution, OR
2. Upgrade to Core Components v4.17.4 or later

#### Path C: Audit Log Flows Not Running
If audit log flows exist but aren't running:

1. Check flow **run history** for errors:
   - Authentication failures → Re-authenticate connections
   - Throttling errors → Enable `admin_DelayAuditLogSync = Yes`
   - Permission errors → Verify service account has required roles

2. Verify connections:
   - Dataverse connection must be active
   - HTTP with Azure AD connection must be authenticated
   - Office 365 Management connector (if using standalone solution)

3. Run subscription flow manually:
   - `Admin | Audit Logs | Office 365 Management API Subscription`
   - Check for successful completion

### Alternative Solutions

If you **cannot** use Office 365 Audit Logs (licensing, compliance, etc.):

**Option 1:** Use `modifiedon` field instead
- Tracks when app definition was last changed
- ⚠️ **Limitation:** Doesn't track app USAGE, only app EDITS
- Use case: Basic inactivity detection

**Option 2:** Use Power Apps Analytics (Canvas apps only)
- Limited retention period
- Requires separate configuration
- Canvas apps only

**Option 3:** Accept field remains empty
- Use other governance metrics
- Focus on app ownership and compliance instead of usage tracking

### Testing Your Setup

After configuration, test the end-to-end flow:

1. **Launch a test app** (Canvas or Model-Driven)
2. **Wait 30 minutes** (audit log ingestion delay)
3. **Check audit log table:**
   - Go to Advanced Find in your CoE environment
   - Table: "Audit Logs" (`admin_auditlog`)
   - Filter: `admin_operation = 'LaunchPowerApp'`
   - Verify event exists with your test app's ID

4. **Check app record:**
   - Table: "PowerApps Apps" (`admin_app`)
   - Find your test app
   - Verify `admin_applastlaunchedon` is populated

### Expected Timeline

If setting up from scratch:

| Time | What Happens |
|------|--------------|
| **Day 0** | Enable Office 365 Audit Logs |
| **Day 1-2** | Audit log infrastructure activates |
| **Day 2** | Install/enable audit log flows |
| **Day 2** | Configure environment variables |
| **Day 2** | Run subscription flow |
| **Day 3** | First app launch events captured |
| **Day 3+** | `admin_applastlaunchedon` starts populating |

**Note:** Historical app launches BEFORE audit log setup will NOT be captured.

### Common Pitfalls

❌ **Audit logs enabled but no events appearing**
- Check: Audit log retention period hasn't expired (90 days E3, 1 year E5)
- Check: Apps are actually being launched by users
- Check: Sync flow is retrieving events successfully

❌ **Flow runs but field still empty**
- Check: Update Data (V2) flow is turned ON
- Check: Service account has permissions to update app records
- Check: No DLP policies blocking required connectors

❌ **Field shows old dates only**
- Check: Sync flow stopped running (check run history)
- Check: Authentication expired on connections
- Check: Throttling causing sync to skip recent events

### Documentation Links

**Full troubleshooting guide:**
- [ISSUE-ANALYSIS-APP-LAST-LAUNCHED-EMPTY.md](../ISSUE-ANALYSIS-APP-LAST-LAUNCHED-EMPTY.md)

**Official Microsoft documentation:**
- [Set up Audit Log Connector](https://learn.microsoft.com/power-platform/guidance/coe/setup-auditlog)
- [Office 365 Audit Log Search](https://learn.microsoft.com/microsoft-365/compliance/audit-log-search)
- [CoE Core Components Setup](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components)

**Related CoE documentation:**
- [Inactivity Notification Flows Guide](../Documentation/InactivityNotificationFlowsGuide.md) - Explains how this field is used for governance

### Need More Help?

Please provide the following information for further troubleshooting:

1. **CoE Core Components version:** (e.g., v4.20)
2. **Office 365 Audit Logs status:** Enabled / Disabled / Don't know
3. **Audit log flows present?** Yes / No
4. **License type:** E3, E5, Business Premium, Other
5. **Error messages (if any):** (paste flow run errors)

This will help us provide targeted assistance for your specific setup.

---

## For GitHub Issues

When responding to GitHub issues about this topic, use the following:

### Issue Labels
- `question` - Most cases are configuration questions
- `documentation` - If docs need clarification
- `needs-info` - If user hasn't provided setup details

### Triage Questions
Copy-paste into issue:

```markdown
Thank you for reporting this issue. To help diagnose the problem, please provide:

1. **CoE Core Components version:** 
2. **Is Office 365 Audit Log enabled in your Microsoft 365 tenant?**
   - Check at: https://compliance.microsoft.com/auditlogsearch
3. **Do you see flows named "Admin | Audit Logs | ..." in your CoE environment?**
4. **If yes, are they turned ON and running successfully?**
5. **What license type does your organization use?** (E3, E5, Business Premium, etc.)

The "App Last Launched On" field requires audit log configuration to work. See our [troubleshooting guide](../ISSUE-ANALYSIS-APP-LAST-LAUNCHED-EMPTY.md) for details.
```

### Close Criteria

This issue can be closed when:
- ✅ User confirms audit logs weren't enabled (expected behavior, not a bug)
- ✅ User confirms audit log flows weren't installed (configuration requirement)
- ✅ User successfully configures audit logs and field populates
- ✅ User acknowledges alternative approaches for scenarios where audit logs can't be used

### Related Issues

Cross-reference with:
- Issues about **inactivity notifications** not working correctly
- Issues about **missing telemetry data**
- Issues about **audit log setup failures**

---

## Summary for Support Team

### Key Points
1. 📌 **Not a bug** - This is a configuration requirement
2. 📌 **Requires Office 365 Audit Logs** - Must be enabled in M365
3. 📌 **Requires Audit Log component** - Core v4.17.4+ or standalone solution
4. 📌 **Requires active flows** - Three flows must be running
5. 📌 **License dependency** - E3/E5 or Business Premium needed
6. 📌 **No historical data** - Only captures launches AFTER setup

### Quick Decision Tree
```
Field empty → Check M365 audit logs enabled?
  └─ Yes → Check audit log flows installed?
      └─ Yes → Check flows running?
          └─ Yes → Check flow run history for errors
          └─ No → Turn on flows
      └─ No → Install audit log component
  └─ No → Enable in M365 Compliance Center
```

### Escalation Path
Escalate to product team if:
- Audit logs enabled ✅
- Audit log flows installed ✅
- Flows running successfully ✅
- Events appearing in `admin_auditlog` table ✅
- **BUT** `admin_applastlaunchedon` still not populating ❌

This would indicate an actual bug in the Update Data flow logic.

---

**Last updated:** February 2025  
**Related Documents:** ISSUE-ANALYSIS-APP-LAST-LAUNCHED-EMPTY.md, InactivityNotificationFlowsGuide.md
