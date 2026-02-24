# DLP Policy Safe Operations - Quick Reference Card

## 🚨 CRITICAL: Read This Before Using DLP Tools

### The Golden Rule

**For Production DLP Policies**: Always use [Power Platform Admin Center](https://admin.powerplatform.microsoft.com)  
**For Impact Analysis**: Use the CoE DLP Impact Analysis tool

### Quick Decision Matrix

| What I Need To Do | Use This Tool | Risk Level |
|-------------------|---------------|------------|
| Analyze impact of proposed DLP change | CoE DLP Impact Analysis Tool | ✅ Safe |
| Identify which flows would be affected | CoE DLP Impact Analysis Tool | ✅ Safe |
| Notify makers about upcoming DLP | CoE DLP Impact Analysis Tool | ✅ Safe |
| Create new DLP policy | Power Platform Admin Center | ✅ Safe |
| Copy existing DLP policy | Power Platform Admin Center | ✅ Safe |
| Modify DLP policy scope | Power Platform Admin Center | ⚠️ Medium |
| Delete DLP policy | Power Platform Admin Center | ⚠️ Medium |
| **Rapid policy changes** | **DON'T DO IT** | 🚨 HIGH |
| **Copy/modify via CoE tool** | **DON'T DO IT** | 🚨 HIGH |

---

## ⚠️ What Can Go Wrong

### Symptom: Flows Suspended Tenant-Wide

**Cause**: Rapid DLP policy changes or using CoE tool for policy operations  
**Duration**: 2-4 hours (due to caching)  
**Visibility**: No policy visible in PPAC (it's a cache issue)

### Immediate Fix

1. **Wait 2-4 hours** - Cache will expire, flows auto-resume
2. **Or** refresh connections for critical flows:
   - Edit flow → Connections → Remove → Re-add → Save

### If Still Broken After 4 Hours

**Contact Microsoft Support**: https://admin.powerplatform.microsoft.com/support  
**Request**: Manual DLP cache clear  
**Provide**: Tenant ID, timeline, affected environments

---

## ✅ Safe DLP Policy Operations

### Creating a New Policy (Safe Method)

1. Go to https://admin.powerplatform.microsoft.com
2. Navigate to **Policies** → **Data policies**
3. Click **New policy**
4. Configure **carefully**:
   - Name it clearly
   - Select **environment type**: OnlyEnvironments (safest)
   - Choose specific environments (not "All")
   - Configure connector groups
5. **Review** before saving
6. **Test** in one environment first
7. **Monitor** for 24 hours

### Copying a Policy (Safe Method)

1. In PPAC, find the policy to copy
2. Note its settings (screenshot or document)
3. Create **new** policy with same settings
4. **Do NOT** use copy feature if nervous about scope
5. **Verify** scope immediately after creation
6. **Test** in non-production environment first

### Modifying a Policy (Safe Method)

1. **Plan** the change - document what you'll do
2. **Time** the change - off-hours, maintenance window
3. **Make ONE change** at a time
4. **Wait 30 minutes** before next change
5. **Verify** in PPAC immediately after
6. **Monitor** for 24 hours

### Deleting a Policy (Safe Method)

1. **Wait 30+ minutes** after any recent modifications
2. **Document** which policy and why
3. **Verify** no critical flows depend on it
4. **Delete** in PPAC
5. **Do NOT** immediately create replacement
6. **Monitor** for unexpected suspensions

---

## 🚫 Absolute Don'ts

### NEVER Do This ⛔

❌ Copy → Modify → Delete in rapid succession  
❌ Broaden scope → Narrow scope → Delete within minutes  
❌ Use CoE tool to copy production DLP policies  
❌ Change policy scope multiple times quickly  
❌ Delete policy immediately after modifying it  
❌ Make DLP changes during business hours (unless urgent)  
❌ Skip testing in non-production first  

### Why These Are Dangerous

Power Platform caches DLP evaluations for **2-4 hours**:
- Rapid changes confuse the cache
- Deletion doesn't immediately clear cache
- Cached evaluation from "broadest scope" persists
- Flows get suspended tenant-wide
- Takes hours to resolve

---

## 📖 Understanding environmentType

### The Three Types

| Type | Meaning | Safety |
|------|---------|--------|
| `OnlyEnvironments` | Apply to specific environments only | ✅ Safest |
| `ExceptEnvironments` | Apply to all EXCEPT specific environments | ⚠️ Careful |
| `AllEnvironments` | Apply to EVERY environment | 🚨 DANGER |

### How to Check in PowerShell

```powershell
# Connect
Add-PowerAppsAccount

# Check all policies
Get-PowerAppDlpPolicy | Select-Object DisplayName, EnvironmentType

# Find dangerous ones
Get-PowerAppDlpPolicy | Where-Object { $_.EnvironmentType -eq "AllEnvironments" }
```

### When Copying a Policy

**CRITICAL**: Verify environmentType is preserved correctly
- Source: `OnlyEnvironments` → Destination: **MUST** be `OnlyEnvironments`
- If it changes to `AllEnvironments`, you'll have a bad time

---

## 🆘 Emergency Contacts

### If Things Go Wrong

1. **Stop making changes** immediately
2. **Wait 2-4 hours** for cache to clear
3. **Read**: [Troubleshooting DLP Policy Scope Issues](./TROUBLESHOOTING-DLP-POLICY-SCOPE.md)
4. **Run diagnostics**: PowerShell commands from troubleshooting guide
5. **Contact**: Microsoft Support if needed after 4 hours

### Microsoft Support

- **URL**: https://admin.powerplatform.microsoft.com/support
- **Severity**: High (production impact)
- **Request**: DLP cache clear
- **Provide**: Tenant ID, timeline, PowerShell output

---

## 📚 Full Documentation

For comprehensive guidance, see:

- **[Troubleshooting DLP Policy Scope Issues](./TROUBLESHOOTING-DLP-POLICY-SCOPE.md)** - Full remediation guide
- **[DLP Impact Analysis Safety Guidelines](../CenterofExcellenceCoreComponents/DLP-IMPACT-ANALYSIS-WARNINGS.md)** - Before using the tool
- **[Issue Response Templates](./ISSUE-RESPONSE-DLP-POLICY-SCOPE.md)** - For maintainers
- **[Issue Analysis](./ISSUE-ANALYSIS-DLP-TENANT-WIDE-ENFORCEMENT.md)** - Technical deep dive

---

## ✅ Pre-Change Checklist

Before making ANY DLP policy change, confirm:

- [ ] I have documented what I'm changing and why
- [ ] I have approval for this change (if needed)
- [ ] I am using Power Platform Admin Center (not CoE tool)
- [ ] I have tested in non-production environment
- [ ] I am making ONE change at a time
- [ ] I will wait 30+ minutes before next change
- [ ] I will NOT delete policy for at least 30 minutes after changes
- [ ] I have at least 2 hours to monitor after the change
- [ ] I know how to contact Microsoft Support if needed
- [ ] I have read the troubleshooting guide

**If you can't check ALL boxes, STOP and reconsider.**

---

## 🎯 Remember

**DLP policies are tenant-wide impacting.**  
**One mistake = hundreds of suspended flows.**  
**When in doubt, use PPAC.**  
**Wait between changes.**  
**Test in non-production first.**

---

**Quick Reference Version**: 1.0  
**Last Updated**: January 2026  
**Print this card and keep it handy!**

For the full story and technical details, see the comprehensive documentation linked above.
