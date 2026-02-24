# GitHub Issue Response Template - DLP Policy Scope Issues

This template should be used when responding to issues related to DLP policy scope problems, tenant-wide enforcement, or unexpected flow suspension after using the DLP Impact Analysis tool.

---

## Template: Tenant-Wide DLP Enforcement After Policy Copy/Modification

**Use when:** Users report flows suspended across multiple/all environments after using CoE DLP tools, or DLP enforcement persisting after policy deletion

**Response:**

Thank you for reporting this critical DLP policy scope issue. This is a known risk when copying or rapidly modifying DLP policies through automation tools.

### Issue Summary

You're experiencing unintended tenant-wide DLP enforcement, which can manifest as:
- ✅ Flows suspended across multiple environments (beyond intended scope)
- ✅ Suspension persisting even after policy deletion
- ✅ No visible "All Environments" DLP policy in PPAC or CoE Admin Center
- ✅ Continuous re-suspension of flows

### Root Cause

This typically occurs due to:
1. **Environment type preservation failure** during policy copy operations
2. **Rapid policy scope changes** (broaden → narrow → delete in short timeframe)
3. **DLP policy evaluation caching** in Power Platform backend (can persist 2-4 hours)
4. **Asynchronous policy propagation** not completing before deletion

### Immediate Actions

**Step 1: Verify Current DLP Policies**

```powershell
# Connect to Power Platform
Add-PowerAppsAccount

# List all DLP policies
Get-PowerAppDlpPolicy | Select-Object DisplayName, PolicyName, EnvironmentType, CreatedTime, LastModifiedTime

# Specifically check for AllEnvironments policies
Get-PowerAppDlpPolicy | Where-Object { $_.EnvironmentType -eq "AllEnvironments" }
```

**Step 2: Wait for Cache Expiration**

DLP policy evaluations are cached for up to **4 hours**. If you recently deleted the problematic policy:
- ⏳ Wait 2-4 hours for natural cache expiration
- ✅ Check if flows automatically resume after this period

**Step 3: Refresh Flow Connections**

For critical flows that need immediate restoration:
1. Open the flow in Power Automate
2. Go to **Edit** → **Connections**
3. Remove the connection
4. Re-add the connection
5. Save and test the flow

This forces a fresh DLP policy evaluation.

**Step 4: Contact Microsoft Support (If Needed)**

If flows remain suspended after 4+ hours with no visible DLP violation:
- 📞 Open support ticket: https://admin.powerplatform.microsoft.com/support
- 📋 Request manual DLP cache clear for your tenant
- 📄 Provide: Tenant ID, affected environment IDs, timeline of changes

### Comprehensive Documentation

We've created detailed documentation for this issue:
- **[Troubleshooting DLP Policy Scope Issues](./TROUBLESHOOTING-DLP-POLICY-SCOPE.md)**

This covers:
- Prevention strategies
- Detailed remediation steps
- PowerShell scripts for diagnosis
- Best practices for DLP policy management

### Future Prevention

**Critical Recommendations:**

⚠️ **For production DLP policies**: Use **Power Platform Admin Center** directly, not CoE automation tools
- More reliable for critical operations
- Immediate scope validation
- Real-time visibility

⚠️ **If using CoE DLP Impact Analysis tool**:
- Use ONLY for analysis and impact assessment
- Do NOT use for production policy modifications
- Always validate scope in PPAC after any change
- Wait 30+ minutes between scope changes
- Document each step for audit trail

⚠️ **Never do this**:
- Copy policy → Broaden scope → Narrow scope → Delete (all within minutes)
- Make rapid successive scope changes
- Delete policy immediately after modification

### Questions for Additional Context

To help diagnose your specific situation:

1. **Timeline**: What was the exact sequence and timing of your DLP policy changes?
   - When did you copy the policy?
   - When did you modify the scope?
   - When did you delete it?
   - How much time between each action?

2. **Policy Details**:
   - What was the source policy's `environmentType`? (OnlyEnvironments / ExceptEnvironments / AllEnvironments)
   - What was the intended scope for the new/modified policy?
   - How many environments were in scope?

3. **Current State**:
   - How many flows are currently suspended?
   - Across how many environments?
   - Can you run the PowerShell commands above and share output?

4. **Method Used**:
   - Did you use the DLP Impact Analysis canvas app?
   - Did you use any flows (which ones)?
   - Or direct Power Platform Admin Center?

### Next Steps

Based on your responses, we can:
1. Determine if this is a caching issue (will auto-resolve) or requires intervention
2. Provide specific PowerShell scripts for your situation
3. Help you contact Microsoft Support with the right information
4. Document any new learnings for the community

### Related Issues

Have there been similar reports? Let me search...
- Search: `is:issue dlp policy scope tenant-wide`
- Search: `is:issue dlp suspended flows`

(Check for prior issues and link them here)

---

## Template: DLP Impact Analysis Tool - General Usage Question

**Use when:** Users ask about using the DLP Impact Analysis tool for policy operations

**Response:**

Thank you for your question about the DLP Impact Analysis tool!

### Purpose of the Tool

The **DLP Impact Analysis** tool in the CoE Starter Kit is designed for:

✅ **Analyzing** the impact of proposed DLP policy changes  
✅ **Identifying** which flows/apps would be affected by a policy  
✅ **Notifying** makers about upcoming DLP enforcement  
✅ **Visualizing** connector usage across your tenant  

### What the Tool Is NOT For

❌ Production-critical DLP policy operations  
❌ Copying policies that will be used in production  
❌ Rapid policy modifications  
❌ Real-time policy scope management  

### Recommended Approach

For your use case, I recommend:

**If you need to analyze impact**:
- ✅ Use the DLP Impact Analysis tool (that's what it's for!)
- ✅ Review the impact report
- ✅ Communicate with affected makers

**If you need to create/copy/modify a policy**:
- ✅ Use **Power Platform Admin Center** (https://admin.powerplatform.microsoft.com)
- ✅ Or use **PowerShell** cmdlets for automation
- ✅ Validate scope immediately after changes
- ✅ Allow time between changes (30+ minutes)

### Documentation

- [Power Platform DLP Policies](https://learn.microsoft.com/power-platform/admin/wp-data-loss-prevention)
- [DLP Policy PowerShell Cmdlets](https://learn.microsoft.com/powershell/module/microsoft.powerapps.administration.powershell/)
- [Troubleshooting DLP Policy Scope Issues](./TROUBLESHOOTING-DLP-POLICY-SCOPE.md) (for known issues)

### Questions?

If you have specific questions about:
- How to analyze impact: (provide guidance)
- How to safely modify policies: (refer to PPAC)
- Troubleshooting an existing issue: (use other template above)

Let me know what you're trying to achieve, and I can provide more specific guidance!

---

## Template: Closing Issue - DLP Issue Resolved

**Use when:** Closing an issue after DLP policy problem is resolved

**Response:**

Great to hear the issue is resolved! I'm closing this issue as completed.

### Resolution Summary

[Briefly describe what resolved the issue - e.g., "DLP cache expired after 4 hours and flows automatically resumed" or "Microsoft Support cleared cached policy evaluation"]

### Key Takeaways

Based on this issue, here are the key learnings:

1. **For others experiencing similar issues**:
   - [Specific advice based on what resolved it]
   - Reference: [Troubleshooting DLP Policy Scope Issues](./TROUBLESHOOTING-DLP-POLICY-SCOPE.md)

2. **Prevention**:
   - Use PPAC for production DLP policy operations
   - Allow adequate time between policy changes
   - Understand that DLP enforcement is cached (2-4 hours)

### If the Issue Returns

If you experience this issue again:
1. Check the troubleshooting guide linked above
2. Run the diagnostic PowerShell scripts
3. Open a new issue with the diagnostic output

### Feedback Welcome

If you have suggestions for improving the DLP tools or documentation:
- Open a feature request issue
- Describe your desired workflow
- We can work on making the tools safer

Thank you for reporting this issue and helping improve the CoE Starter Kit! 🎉

---

## Notes for Responders

### Key Points to Remember

1. **DLP policy issues are CRITICAL**: They can impact production workloads tenant-wide
2. **Cache is often the culprit**: 2-4 hour wait usually resolves "phantom" enforcement
3. **PPAC is safer**: Always recommend Power Platform Admin Center for critical operations
4. **Don't blame the user**: The tool should have better safeguards; acknowledge this
5. **Get diagnostic info**: PowerShell output is essential for understanding the problem

### Common Questions to Ask

When gathering more information:
- Exact timeline of changes (timestamps matter)
- Method used (CoE app, flow, PPAC, PowerShell)
- Source and target policy scope details
- Current state (which environments/flows affected)
- Whether they can run PowerShell diagnostic commands
- Whether they have Microsoft Support access

### Escalation Criteria

Escalate to Microsoft Support when:
- ✅ Flows remain suspended 4+ hours after policy deletion
- ✅ No visible DLP policy explains the enforcement
- ✅ PowerShell shows no AllEnvironments policies
- ✅ Refreshing connections doesn't resolve it
- ✅ Business-critical operations are impacted

### Documentation References

Always link to:
- [TROUBLESHOOTING-DLP-POLICY-SCOPE.md](./TROUBLESHOOTING-DLP-POLICY-SCOPE.md) - Detailed guide
- [Power Platform DLP Docs](https://learn.microsoft.com/power-platform/admin/wp-data-loss-prevention) - Official documentation
- [PPAC](https://admin.powerplatform.microsoft.com) - Where to make safe changes

---

**Template Version**: 1.0  
**Last Updated**: January 2026  
**Maintained by**: CoE Starter Kit Community
