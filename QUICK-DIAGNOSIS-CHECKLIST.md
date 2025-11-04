# Quick Diagnosis Checklist: Sync Audit Logs V2 Failures

Use this checklist to quickly diagnose issues with the "Admin | Audit Logs | Sync Audit Logs (V2)" flow.

## Step 1: Identify the ACTUAL Failing Action

- [ ] Open the flow run history
- [ ] Look past the "Get_Azure_Secret" action (this may show as failed - that's OK if using text secret)
- [ ] Identify which action is ACTUALLY failing:
  - [ ] AuditLogQuery (Graph API path)
  - [ ] ListAuditLogContent (Management API path)
  - [ ] GetContentDetails (Management API path)
  - [ ] Other action

**Action that is failing:** ___________________________

**Error message:** ___________________________

## Step 2: Check Environment Variable Configuration

Navigate to Power Platform admin center → Your Environment → Settings → Environment variables

- [ ] `admin_TenantID` is populated
- [ ] `admin_AuditLogsClientID` is populated
- [ ] `admin_AuditLogsClientSecret` is populated (if using text secret)
- [ ] `admin_AuditLogsUseGraphAPI` is set to `yes` or `no`
- [ ] All values are correct (no copy-paste errors, no spaces)

**Configuration looks correct:** ☐ Yes ☐ No

## Step 3: Verify Azure AD App Registration

Navigate to [Azure Portal](https://portal.azure.com) → Azure Active Directory → App registrations

- [ ] App exists with the Client ID from `admin_AuditLogsClientID`
- [ ] App is not expired or disabled
- [ ] Client secret exists and is not expired (Certificates & secrets)
- [ ] Secret value matches `admin_AuditLogsClientSecret` environment variable

**App registration is valid:** ☐ Yes ☐ No

## Step 4: Check API Permissions

In your Azure AD App registration → API permissions

**If `admin_AuditLogsUseGraphAPI` = yes:**
- [ ] Microsoft Graph → AuditLog.Read.All (Application) is added
- [ ] Status shows "Granted for [Tenant Name]" with green checkmark
- [ ] "Admin consent required" column shows "Yes" and consent is granted

**If `admin_AuditLogsUseGraphAPI` = no:**
- [ ] Office 365 Management APIs → ActivityFeed.Read (Application) is added
- [ ] Office 365 Management APIs → ActivityFeed.ReadDlp (Application) is added
- [ ] Status shows "Granted for [Tenant Name]" with green checkmark
- [ ] "Admin consent required" column shows "Yes" and consent is granted

**Permissions are correct:** ☐ Yes ☐ No

**Admin consent is granted:** ☐ Yes ☐ No

## Step 5: Test Authentication

Create a test flow or use an HTTP tool to test authentication:

**For Graph API (if using Graph API):**
```
GET https://graph.microsoft.com/beta/security/auditLog/queries
Authorization: Bearer {token}
```

**For Management API (if using Management API):**
```
GET https://manage.office.com/api/v1.0/{tenantId}/activity/feed/subscriptions/list
Authorization: Bearer {token}
```

- [ ] Test request succeeds with HTTP 200
- [ ] Test request fails with 401 Unauthorized → Permission issue
- [ ] Test request fails with 403 Forbidden → Consent issue

**Authentication test:** ☐ Pass ☐ Fail (_____ error code)

## Step 6: Verify Connection References

In Power Automate → Connections

- [ ] Find connections used by the flow
- [ ] All connections show as "Connected"
- [ ] Connections are authenticated with correct account
- [ ] No "Fix connection" warnings

**Connections are valid:** ☐ Yes ☐ No

## Common Issue Patterns

### Pattern 1: "Get_Azure_Secret" Failed + Flow Succeeds
**Status:** ✅ This is NORMAL
**Reason:** Using text-based secret, flow handles the error automatically
**Action:** None needed

### Pattern 2: "Get_Azure_Secret" Failed + "ListAuditLogContent" Unauthorized
**Status:** ❌ Permission Issue
**Reason:** Missing or ungranted API permissions for Office 365 Management APIs
**Action:** Add permissions and grant admin consent (see Step 4)

### Pattern 3: "Get_Azure_Secret" Failed + "AuditLogQuery" Unauthorized
**Status:** ❌ Permission Issue
**Reason:** Missing or ungranted API permissions for Microsoft Graph
**Action:** Add AuditLog.Read.All permission and grant admin consent (see Step 4)

### Pattern 4: All Actions Succeed But No Data Collected
**Status:** ⚠️ Configuration Issue
**Reason:** Flow is running but not finding audit logs in the time window
**Action:** Check time window settings, verify Power Apps are being launched/deleted in your tenant

### Pattern 5: "Invalid client secret" Error
**Status:** ❌ Secret Issue
**Reason:** Secret expired or incorrect value in environment variable
**Action:** Generate new secret in Azure AD, update environment variable

## Quick Fix Checklist

If you've identified a permission issue:

1. [ ] Go to Azure Portal → Azure Active Directory → App registrations → [Your App]
2. [ ] Click API permissions
3. [ ] Verify correct permissions are added (see Step 4)
4. [ ] Click "Grant admin consent for [Tenant]"
5. [ ] Wait 5-10 minutes for propagation
6. [ ] Return to Power Automate
7. [ ] Manually run the flow
8. [ ] Verify flow completes successfully
9. [ ] Check Dataverse for new audit log records

## When to Seek Additional Help

Seek additional help if:
- [ ] All checklist items are verified but flow still fails
- [ ] Error messages don't match any common patterns
- [ ] Issue persists after granting admin consent and waiting 24 hours
- [ ] Flow worked previously but suddenly stopped

**Gather this information before creating an issue:**
1. Flow run ID
2. Screenshot of the ACTUAL failing action (not Get_Azure_Secret)
3. Screenshot of API permissions page showing granted consent
4. Your `admin_AuditLogsUseGraphAPI` setting value
5. Error message from failing action

## Additional Resources

- [Complete Troubleshooting Guide](TROUBLESHOOTING-AUDIT-LOGS.md)
- [Setup Guide](CenterofExcellenceCoreComponents/AUDIT-LOGS-SETUP.md)
- [Issue Response Template](.github/ISSUE_TEMPLATE_RESPONSES/audit-logs-get-azure-secret-error.md)

---

**Diagnosis Result Summary:**

- Issue Identified: ☐ Yes ☐ No
- Root Cause: ___________________________
- Resolution Applied: ☐ Yes ☐ No ☐ Pending
- Flow Status After Fix: ☐ Success ☐ Still Failing ☐ Not Yet Tested
