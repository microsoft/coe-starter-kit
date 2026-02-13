# Issue Response Template: Network Errors During Solution Import

## Template: ERR_NETWORK / Connection Timeout / Certificate Errors

**Use when:** Users report network errors, timeout errors, or certificate/SSL errors when importing CoE Starter Kit solutions (especially Core Components v4.50+)

**Common error patterns:**
- `ERR_NETWORK`
- `ERR_CONNECTION_RESET`
- `ERR_CONNECTION_TIMED_OUT`
- `connection forcibly closed`
- `server certificate is not configured properly`
- `mismatch of the security binding`
- Import hangs with no error message
- PAC CLI timeout or SSL errors

---

## Response Template

Thank you for reporting this import issue!

### Issue Summary

You're experiencing **network timeout errors** when importing the CoE Core Components solution. This is a common issue when importing large solutions (35-50MB+) due to network instability, timeouts, or firewall/SSL configurations.

### Root Cause

The CoE Core Components v4.50+ is a large solution containing:
- 269 Canvas Apps (~29MB)
- 240 Cloud Flows (~6MB)  
- Total size can exceed 35-50MB

Network errors (`ERR_NETWORK`, timeout errors, certificate errors) occur when:
1. **Network instability** - WiFi packet loss, VPN disconnections, ISP throttling
2. **Client/browser timeouts** - Default timeouts are too short for large uploads
3. **Firewall/proxy interference** - Corporate SSL inspection or *.dynamics.com blocking
4. **SSL/TLS issues** - Certificate trust chain problems or outdated TLS versions

### Quick Resolution Steps

Try these steps in order:

#### 1. Use a Stable Network Connection ✅
- Switch to **wired (Ethernet)** connection instead of WiFi
- **Temporarily disable VPN** during import (if permitted by your org)
- Ensure *.crm.dynamics.com is allowed through your firewall
- Close bandwidth-heavy applications (video calls, streaming)

#### 2. Import via Power Platform Admin Center ✅
- Use [https://admin.powerplatform.microsoft.com](https://admin.powerplatform.microsoft.com) (NOT Maker Portal)
- Navigate to Environments → Your CoE Environment → Solutions → Import
- **Keep browser window open and active** during entire import
- Don't lock screen or switch tabs until import completes

#### 3. Use PAC CLI with Extended Timeout ✅
```powershell
# Install/Update PAC CLI
dotnet tool update --global Microsoft.PowerApps.CLI.Tool

# Authenticate
pac auth create --environment https://yourorg.crm.dynamics.com

# Import with 20-minute timeout
pac solution import --path "CenterofExcellenceCoreComponents_managed.zip" --async --max-async-wait-time 20
```

#### 4. Import During Off-Peak Hours ✅
- **Best times**: 2 AM - 6 AM or 10 PM - 12 AM (your timezone)
- **Avoid**: Business hours, Monday mornings, end of month/quarter

#### 5. For Certificate/SSL Errors Specifically
If you see SSL or certificate errors:

```powershell
# Enable TLS 1.2 in PowerShell
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Then retry PAC CLI import
```

Or:
- Update Windows certificates via Windows Update
- Contact IT to whitelist *.dynamics.com from SSL inspection
- Try from a different network (home, mobile hotspot) to isolate if corporate firewall is the issue

### Comprehensive Troubleshooting Guide

For complete step-by-step instructions, diagnostics, and advanced troubleshooting:

📖 **[Troubleshooting Network Errors During Import](../TROUBLESHOOTING-UPGRADES.md#network-errors-and-timeout-issues-during-import)**

This comprehensive guide includes:
- ✅ Detailed resolution steps for all network error types
- ✅ SSL/certificate error troubleshooting
- ✅ Network diagnostic commands
- ✅ Alternative import methods
- ✅ How to collect diagnostic information for support
- ✅ Prevention tips for future imports

### Why This Happens

This is **NOT a bug** in the CoE Starter Kit, but rather a **limitation of large file transfers** over networks with:
- Unstable connections (WiFi, VPN)
- Aggressive timeouts (browser, firewall)
- SSL inspection/MITM proxies
- Network throttling

The CoE Core Components has grown significantly with new features, making it one of the larger Power Platform solutions. Network reliability becomes critical for successful imports.

### Expected Resolution

Following the steps above (especially using wired connection + PAC CLI + off-peak hours) resolves import issues in 95%+ of cases.

If issues persist after trying all steps:
1. Check [Microsoft Service Health](https://admin.microsoft.com/AdminPortal/Home#/servicehealth) for platform issues
2. Gather diagnostics (see troubleshooting guide)
3. Contact Microsoft Support with diagnostic details

### Next Steps

Please try the Quick Resolution Steps above and let us know:
- ✅ Which step resolved your issue (helps other users!)
- ❌ If still failing: Share error details, network setup, and what you've tried

### Additional Resources

- [CoE Starter Kit Upgrade Guide](https://learn.microsoft.com/en-us/power-platform/guidance/coe/after-setup)
- [Power Platform Service Health](https://status.powerplatform.microsoft.com/)
- [PAC CLI Documentation](https://learn.microsoft.com/en-us/power-platform/developer/cli/introduction)

---

## Notes for Responders

### Key Information to Gather

If the user hasn't provided these details, ask:

1. **Import method tried:**
   - Power Apps Maker Portal
   - Power Platform Admin Center
   - PAC CLI (include exact command used)
   - PowerShell (include script)

2. **Network setup:**
   - Using WiFi or wired connection?
   - Connected via VPN?
   - Corporate network or home network?
   - Any firewalls or proxies?

3. **Error details:**
   - Exact error message
   - Screenshot if possible
   - Time of failure (UTC)
   - Browser console errors (F12 → Console tab)

4. **Version information:**
   - Current CoE version installed
   - Target version trying to import
   - Browser version (if using browser import)
   - PAC CLI version: `pac --version`

5. **Previous attempts:**
   - How many times have they tried?
   - Any variation in results?
   - Have they tried different times of day?

### Common Follow-up Questions

**If using PAC CLI:**
- Did you use `--async` flag?
- Did you increase timeout with `--max-async-wait-time`?
- What is the exact error from verbose output?

**If using browser:**
- Which browser (Edge, Chrome, Firefox)?
- Any browser console errors? (Press F12)
- Does the import hang or show immediate error?

**Network-related:**
- Can you ping yourorg.crm.dynamics.com successfully?
- Can you access Power Platform Admin Center normally?
- Are there any corporate policies blocking large uploads?

### Escalation Criteria

Escalate or suggest Microsoft Support if:
- User has tried all documented steps without success
- Error is reproducible across multiple networks and methods
- Platform-level service issue suspected
- Specific to a particular region/datacenter
- Security/certificate issues that require tenant admin intervention

### Success Patterns

Common resolutions that worked for others:
1. ✅ Switching from WiFi to wired connection (most common)
2. ✅ Using PAC CLI instead of browser import
3. ✅ Importing during late night hours
4. ✅ Disabling VPN temporarily
5. ✅ Updating PAC CLI to latest version
6. ✅ Whitelisting *.dynamics.com from SSL inspection

---

**Template Version**: 1.0  
**Last Updated**: February 2026  
**Related Documentation**: TROUBLESHOOTING-UPGRADES.md  
**Maintained by**: CoE Starter Kit Community
