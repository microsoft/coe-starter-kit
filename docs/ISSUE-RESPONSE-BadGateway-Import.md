# Issue Response Template: BadGateway Error During Solution Import

This template is used when responding to issues where users encounter BadGateway (502) errors during CoE Starter Kit solution imports or upgrades.

---

## Template Response

Thank you for reporting this issue! I can help you resolve the **BadGateway error** you're experiencing during the upgrade from Core Components 4.50.2 to 4.50.6.

### Quick Summary

**BadGateway (HTTP 502)** is a **transient Power Platform service error**, not a bug in the CoE Starter Kit or a configuration issue in your environment. The error indicates that the Power Automate backend service was temporarily unavailable when importing the "HELPER - Add User to Security Role" flow.

### ✅ Resolution Steps

**Primary Solution: Wait and Retry**

This approach resolves 95% of BadGateway errors:

1. **Wait 30-60 minutes** (or longer - 2-4 hours is even better)
2. **Retry the import** using the same solution file
   - Go to [Power Platform Admin Center](https://admin.powerplatform.microsoft.com)
   - Navigate to your CoE environment → **Solutions**
   - Import the 4.50.6 solution file again
   - Use the **Upgrade** option (default and recommended)
3. **If it fails again**, try during off-peak hours:
   - Early morning: 2 AM - 6 AM (your local time)
   - Late evening: 10 PM - 12 AM (your local time)
   - Weekends

**Why this works:** BadGateway errors are almost always temporary service availability issues that resolve on their own after a short time.

### 🔍 Before Retrying

1. **Check service health**: Visit [Microsoft Service Health Dashboard](https://admin.microsoft.com/AdminPortal/Home#/servicehealth)
   - Look for Power Platform or Power Automate incidents
   - If there's an active incident, wait for it to be resolved before retrying

2. **Verify your environment status**:
   - Ensure sufficient database storage (>10% free)
   - Confirm environment is not in admin mode
   - Check that no other maintenance operations are running

### 📚 Additional Resources

For comprehensive troubleshooting steps, advanced options, and FAQs, please see:

**[Complete BadGateway Troubleshooting Guide](troubleshooting/solution-import-badgateway.md)**

This guide includes:
- Alternative import methods (PowerShell/PAC CLI)
- Advanced troubleshooting options
- When to contact Microsoft Support
- Comparison with other error types (TooManyRequests, etc.)
- FAQ section with common questions

### 🎯 Important Notes

- ✅ It's **safe to retry** the import - you won't lose data or create duplicates
- ✅ This error can affect **any flow** - it's not specific to "HELPER - Add User to Security Role"
- ✅ No changes needed to your environment, flows, or solution files
- ✅ This is not related to permissions, connections, or configurations
- ❌ Don't modify the solution file or flow definitions
- ❌ Don't try to import individual components separately

### 📞 If the Error Persists

If BadGateway errors continue after 3-4 retry attempts over 24 hours:

1. **Contact Microsoft Support** (for platform-level service issues)
   - Open a support ticket through your standard support channel
   - Reference: "BadGateway error during solution import"
   - Provide the Client Request Id from the error details

2. **Report here on GitHub** (for community support)
   - Update this issue with:
     - Number of retry attempts and times
     - Whether service health showed any incidents
     - Any other error details or patterns observed

### 🔗 Related Documentation

- [CoE Starter Kit Upgrade Guide](https://learn.microsoft.com/en-us/power-platform/guidance/coe/after-setup)
- [Troubleshooting Upgrades - General Guide](../../TROUBLESHOOTING-UPGRADES.md)
- [TooManyRequests Error Guide](../../TROUBLESHOOTING-UPGRADES.md#toomanyreqs-error-during-upgrade) (different from BadGateway)

---

## Common Follow-up Questions

### Q: How is this different from TooManyRequests errors?

**A:** They're different error types:
- **BadGateway (502)**: Transient service unavailability - wait and retry
- **TooManyRequests (429)**: Rate limiting - requires incremental upgrades and longer waits

See [Understanding BadGateway vs Other Errors](troubleshooting/solution-import-badgateway.md#understanding-badgateway-vs-other-errors)

### Q: Should I use an incremental upgrade path?

**A:** For 4.50.2 → 4.50.6 (patch versions), a **direct upgrade** is recommended. BadGateway is not caused by version gaps - it's a service issue. However, if the error persists, trying during off-peak hours is more effective than incremental upgrades for this specific error.

### Q: Will this error go away on its own?

**A:** The underlying service issue causing BadGateway will resolve, but you need to **manually retry the import** when the service is healthy again. The import won't automatically resume or succeed without retrying.

---

## When to Close the Issue

This issue can be closed when:
- ✅ User confirms the import succeeded after retry
- ✅ User confirms they've reviewed the troubleshooting guide
- ✅ User escalates to Microsoft Support for persistent issues (after 24+ hours of retries)

---

**Template Version**: 1.0  
**Last Updated**: January 2026  
**Applies to**: All CoE Starter Kit versions  
**Error Type**: BadGateway (HTTP 502)
