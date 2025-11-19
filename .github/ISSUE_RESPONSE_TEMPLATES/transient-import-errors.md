# Issue Response Template - Transient Import Errors

Use this template when responding to issues related to solution import failures with error codes 80097376, 80072031, or other transient service errors.

---

## Response Template

Thank you for reporting this issue. The errors you're experiencing (Error Code: 80097376 "BadGateway" and Error Code: 80072031 "Operation Status Unknown") are **transient service-level errors** that can occur during solution import operations. These are not bugs in the CoE Starter Kit code, but temporary connectivity or service availability issues with the Power Platform services.

### Root Cause
- **Error 80097376**: Indicates temporary connectivity issues between Power Platform services (Flow service specifically)
- **Error 80072031**: Occurs when the import operation completes but fails to report its completion status properly

### Immediate Resolution Steps

1. **Wait and Retry** (Most Common Solution)
   - Wait 5-10 minutes before attempting another import
   - Delete the partially imported solution if it exists
   - Re-import the solution using the same managed solution file

2. **Check Service Health**
   - Visit the [Microsoft 365 Service Health Dashboard](https://admin.microsoft.com/Adminportal/Home#/servicehealth)
   - Look for any active incidents affecting Power Platform or Power Automate
   - If there's an active incident, wait for Microsoft to resolve it

3. **Import During Off-Peak Hours**
   - If errors persist, try importing during off-peak hours (evenings or weekends)
   - Ensure no other large operations are running in your environment

### Comprehensive Troubleshooting Guide

We've created detailed documentation to help you resolve these issues:

📖 **[Troubleshooting Import Errors](../../CenterofExcellenceResources/Release/Notes/CoEStarterKit/TROUBLESHOOTING-IMPORT-ERRORS.md)** - Complete guide with:
- Detailed explanations of both error codes
- Step-by-step resolution procedures
- Prevention best practices
- PowerShell alternative import methods
- General troubleshooting checklist
- Upgrade best practices

📋 **[Known Issues](../../CenterofExcellenceResources/Release/Notes/CoEStarterKit/KNOWN-ISSUES.md)** - Lists all known issues including:
- Transient import errors
- Language and licensing requirements
- DLP-related considerations
- Support channel guidance

### Alternative Import Method

If standard import continues to fail, try using the Power Platform CLI:

```powershell
# Install Power Platform CLI if not already installed
# pac install latest

# Authenticate
pac auth create --url https://yourorg.crm.dynamics.com

# Import solution
pac solution import --path "CenterofExcellenceCoreComponents_managed.zip" --async
```

### Best Practices for Production Upgrades

To minimize the risk of import failures in production:

1. ✅ Test the upgrade in a development or test environment first
2. ✅ Schedule upgrades during maintenance windows (off-peak hours)
3. ✅ Disable flows before upgrading
4. ✅ Allow sufficient time (2-4 hours recommended)
5. ✅ Document current environment variable values as backup
6. ✅ Verify service health before starting

### When to Escalate

Contact Microsoft Support if:
- Errors persist after 3-4 retry attempts over 24 hours
- Service health dashboard shows no issues
- Import succeeds in test environment but fails in production

### Additional Resources

- [CoE Starter Kit Setup Documentation](https://docs.microsoft.com/power-platform/guidance/coe/setup)
- [Upgrade Instructions](https://docs.microsoft.com/power-platform/guidance/coe/after-setup)
- [Latest Releases](https://github.com/microsoft/coe-starter-kit/releases)

---

**Please let us know if the retry resolves the issue or if you continue to experience problems after following these steps.**

---

## Specific Response for DLP Flow Errors

If the error specifically mentions DLP-related flows (e.g., "DLP Request | Sync Policy to Dataverse (Child)"):

The DLP flows are part of the DLP Impact Analysis feature. If you don't plan to use DLP features immediately:
- You can safely skip errors related to DLP flows during import
- After successful import, you can disable these flows if not needed
- The core inventory and other features will function normally without DLP flows enabled

If you do plan to use DLP features:
1. Ensure the Power Platform for Admins connector is properly configured
2. Verify your account has appropriate admin permissions
3. Retry the import following the steps above
4. See our [DLP setup documentation](https://docs.microsoft.com/power-platform/guidance/coe/setup-dlp-policies)

---

## Issue Closure Criteria

This issue can be closed when:
- [ ] User confirms successful import after retry
- [ ] User confirms errors were resolved by following troubleshooting guide
- [ ] User has been directed to Microsoft Support for persistent issues (not a CoE Kit bug)
- [ ] User confirms they will retry during off-peak hours and report back

## Labels to Apply

- `question` - If user is asking for help
- `documentation` - Reference to new troubleshooting docs
- `transient-error` - For categorization
- `import-upgrade` - For categorization
- Close with `wontfix` if confirmed as transient service error (not a code issue)

---

**Note**: These are service-level transient errors, not bugs in the CoE Starter Kit code. The solution is to retry the import after waiting, check service health, or import during off-peak hours.
