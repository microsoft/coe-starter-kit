# 🚀 Quick Fix: Sync Audit Logs Taking 3+ Days

## The Problem
Your "Admin | Audit Logs | Sync Audit Logs (V2)" flow is taking days to complete.

## The 5-Minute Solution ✅

### Step 1: Open Power Platform Admin Center
Navigate to: https://admin.powerplatform.microsoft.com

### Step 2: Go to Your CoE Environment
1. Click on **Environments**
2. Select your **CoE environment** (where the CoE Starter Kit is installed)

### Step 3: Open Solutions
1. Click **Solutions** in the left menu
2. Find and open: **Center of Excellence - Core Components**

### Step 4: Find the Environment Variable
1. In the solution, filter by **Environment variables**
2. Search for: **Audit Logs - Use Graph API**
   - Or search by schema name: `admin_AuditLogsUseGraphAPI`

### Step 5: Change the Value
1. Click on the environment variable
2. Edit the **Current Value**
3. Change from `false` to **`true`**
4. Save

### Step 6: Verify (Optional)
Check that your app registration has the Graph API permission:
- Permission: `AuditLogsQuery.Read.All`
- Type: Application
- Status: Granted and consented

---

## Expected Results

| Before | After |
|--------|-------|
| ❌ 3+ days to complete | ✅ 5-15 minutes |
| ❌ Thousands of sequential HTTP calls | ✅ Single optimized query |
| ❌ Risk of timeouts | ✅ Reliable completion |

## Why This Works

The flow has two paths:
- **Office 365 Management API** (default) - Legacy, slow, 3 nested sequential loops
- **Graph API** (recommended) - Modern, fast, single parallel loop

By setting the environment variable to `true`, you switch from the slow path to the fast path.

## What to Monitor

After making the change:
1. Wait for the next scheduled run (flows run hourly)
2. Check the flow run history
3. Verify the duration is now **5-15 minutes** instead of hours/days
4. Confirm no errors in the run details

## Need More Details?

For comprehensive information, see:
- 📖 [Full Performance Guide](AUDIT_LOGS_PERFORMANCE.md)
- 🏗️ [Architecture Comparison](AUDIT_LOGS_ARCHITECTURE.md)
- 💬 [GitHub Issue Response](GITHUB_ISSUE_COMMENT.md)

## Still Having Issues?

If enabling Graph API doesn't resolve the issue:
1. Verify the app registration permissions
2. Check for any error messages in the flow run history
3. Review the detailed troubleshooting section in [AUDIT_LOGS_PERFORMANCE.md](AUDIT_LOGS_PERFORMANCE.md)
4. Report back on the GitHub issue with details

---

**TL;DR**: Set environment variable `admin_AuditLogsUseGraphAPI = true` in your CoE solution to fix the performance issue immediately.
