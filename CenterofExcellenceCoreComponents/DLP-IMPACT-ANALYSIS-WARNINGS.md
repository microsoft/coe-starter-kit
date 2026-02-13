# DLP Impact Analysis Tool - Safety Guidelines and Warnings

## ⚠️ READ BEFORE USING THIS TOOL

The **DLP Impact Analysis** tool is designed for **analysis and impact assessment only**. It helps you understand the impact of proposed DLP policy changes before they are applied.

## What This Tool Is For ✅

- **Analyzing** the potential impact of DLP policy changes
- **Identifying** which flows and apps would be affected by a proposed policy
- **Notifying** makers about upcoming DLP enforcement
- **Visualizing** connector usage patterns across your tenant
- **Planning** DLP rollout strategies

## What This Tool Is NOT For ❌

- ❌ Creating production DLP policies
- ❌ Copying DLP policies for production use
- ❌ Making rapid or repeated policy modifications
- ❌ Critical production policy operations
- ❌ Emergency policy changes

## ⚠️ CRITICAL WARNING: Tenant-Wide Enforcement Risk

Using this tool to **copy or modify DLP policies** can result in:

### Potential Impact
- ✋ **Flows suspended across ALL environments** (beyond intended scope)
- ✋ **Continued suspension even after policy deletion** (can persist 2-4 hours due to caching)
- ✋ **No visible "All Environments" policy** in Power Platform Admin Center
- ✋ **Business disruption** requiring manual remediation
- ✋ **Emergency support engagement** to resolve

### Known Issue Scenario

This has occurred when users:
1. Copy an environment-scoped DLP policy using this tool
2. Briefly broaden the policy scope (even excluding some environments)
3. Immediately narrow the scope again
4. Delete the policy shortly after

**Result**: Hundreds of flows suspended tenant-wide, persisting even after policy deletion.

## Safe Practices

### For Analysis Only ✅

If you're using this tool for its intended purpose (analysis):
- ✅ Review impact reports
- ✅ Identify affected resources
- ✅ Communicate with makers
- ✅ Export reports for documentation
- ✅ Plan your DLP strategy

**Then STOP. Do not use this tool to apply changes.**

### For Policy Operations ⚠️

If you need to actually create, copy, or modify a DLP policy:

**Option 1: Power Platform Admin Center (Recommended)**
- 🔗 Navigate to: https://admin.powerplatform.microsoft.com
- ➡️ Go to **Policies** → **Data policies**
- ➡️ Use the built-in UI to create/copy/modify policies
- ✅ **Benefits**: Direct API calls, immediate validation, real-time visibility

**Option 2: PowerShell (For Automation)**
```powershell
# Install module
Install-Module -Name Microsoft.PowerApps.Administration.PowerShell

# Connect
Add-PowerAppsAccount

# Create policy with specific scope
New-PowerAppDlpPolicy -DisplayName "My Policy" `
    -EnvironmentName "env-guid-1","env-guid-2" `
    -BlockedConnectors @() `
    -BusinessConnectors @("shared_office365users") `
    -NonBusinessConnectors @("shared_sql")
```
- ✅ **Benefits**: Scriptable, version controlled, auditable

## If You Choose to Use This Tool for Policy Operations

Despite the warnings above, if you decide to use this tool for policy operations, **follow these safety rules**:

### Before You Start
- [ ] This is NOT a production-critical policy
- [ ] You have a rollback plan documented
- [ ] You've communicated with affected makers
- [ ] You have at least 2 hours available for monitoring
- [ ] You're prepared to wait between changes
- [ ] You have PowerShell access for troubleshooting

### During Operation
1. **Make ONE change at a time** (never combine operations)
2. **Wait 5-10 minutes** between each change
3. **Verify in PPAC** after each step: https://admin.powerplatform.microsoft.com
4. **Document each action** with timestamp
5. **DO NOT make rapid changes** (broaden → narrow → delete within minutes)

### After Operation
1. **Monitor for 24 hours** for unexpected flow suspensions
2. **Be prepared** for cache-related issues (2-4 hour duration)
3. **Have contact** for Microsoft Support ready
4. **Document the outcome** for future reference

### NEVER Do This ⛔
- ⛔ Copy → Modify scope → Modify again → Delete (all within 30 minutes)
- ⛔ Change policy scope multiple times rapidly
- ⛔ Delete a policy immediately after modifying its scope
- ⛔ Use this tool during business hours for production policies
- ⛔ Use this tool without a clear understanding of `environmentType` values

## Understanding environmentType Field

DLP policies have an `environmentType` that determines scope:

| environmentType | Scope | Environments List |
|----------------|-------|-------------------|
| `AllEnvironments` | Every environment in tenant | Empty or N/A |
| `OnlyEnvironments` | Only specific environments | Must contain environment IDs |
| `ExceptEnvironments` | All except specific environments | Contains excluded environment IDs |

**CRITICAL**: When copying a policy, the `environmentType` MUST be correctly set. Incorrect values can result in:
- `OnlyEnvironments` policy becoming `AllEnvironments` (worst case)
- Empty environments list causing undefined behavior
- Scope broader than intended

## Troubleshooting

If you experience issues after using this tool:

### Immediate Actions
1. **Stop making changes** immediately
2. **Check PPAC** for visible policies: https://admin.powerplatform.microsoft.com → Policies → Data policies
3. **Run diagnostic PowerShell**:
```powershell
Add-PowerAppsAccount
Get-PowerAppDlpPolicy | Select-Object DisplayName, EnvironmentType, CreatedTime, LastModifiedTime
```

### Remediation
See detailed remediation steps in:
📖 **[Troubleshooting DLP Policy Scope Issues](./TROUBLESHOOTING-DLP-POLICY-SCOPE.md)**

This includes:
- PowerShell diagnostic scripts
- Cache clearing techniques
- Flow restoration procedures
- When to contact Microsoft Support

## Support

### For Issues with This Tool
- 🐛 Report at: https://github.com/microsoft/coe-starter-kit/issues
- 📋 Use template: "CoE Starter Kit - BUG"
- 🏷️ Include "DLP policy scope" in title
- 📎 Attach diagnostic PowerShell output

### For Tenant-Wide DLP Issues
- 📞 Contact Microsoft Support: https://admin.powerplatform.microsoft.com/support
- ⚡ Severity: High (production impact)
- 📄 Provide: Tenant ID, affected environments, timeline, PowerShell output

### Community Support
- 💬 Power Apps Community: https://powerusers.microsoft.com/t5/Power-Apps-Governance-and/bd-p/Admin_PowerApps
- 💡 CoE Starter Kit Discussions: https://github.com/microsoft/coe-starter-kit/discussions

## Additional Resources

- [Power Platform DLP Policies Documentation](https://learn.microsoft.com/power-platform/admin/wp-data-loss-prevention)
- [DLP Policy PowerShell Reference](https://learn.microsoft.com/powershell/module/microsoft.powerapps.administration.powershell/)
- [CoE Starter Kit Documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- [Troubleshooting DLP Policy Scope Issues](./TROUBLESHOOTING-DLP-POLICY-SCOPE.md)

## Acknowledgment

By proceeding to use this tool for policy operations (beyond analysis), you acknowledge that:
- ✅ You have read and understood these warnings
- ✅ You understand the risk of tenant-wide flow suspension
- ✅ You have a rollback plan and sufficient time for monitoring
- ✅ You accept responsibility for validating policy scope in PPAC
- ✅ You will follow the safe practices outlined above

**Consider this your final warning. For production-critical DLP operations, use Power Platform Admin Center directly.**

---

**Document Version**: 1.0  
**Last Updated**: January 2026  
**Solution**: Center of Excellence - Core Components v4.50.6+

**Note**: The CoE Starter Kit is provided as-is without official Microsoft Support. Use at your own risk for critical operations.
