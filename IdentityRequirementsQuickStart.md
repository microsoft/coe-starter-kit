# CoE Starter Kit - Identity Requirements Quick Start Guide

This quick start guide provides a concise overview and checklist for setting up a secure identity for the CoE Starter Kit.

For more details, see:
- [Identity Requirements and Security Guidance](IdentityRequirementsAndSecurity.md) - Full documentation
- [Identity Requirements FAQ](IdentityRequirementsFAQ.md) - Common questions

## What You Need

✅ A dedicated service account (not a personal account)  
✅ **Power Platform Admin** role (try this first) or **Global Admin** (only if required)  
✅ Azure AD Conditional Access policies configured  
✅ Monitoring and alerting set up  
✅ Secure credential storage  

## Why These Requirements?

The CoE Starter Kit needs to:
- Inventory all Power Platform resources across your tenant
- Access Power Platform admin APIs
- Run automated flows on schedules
- Collect usage and telemetry data

These operations require admin-level privileges and automated execution.

## 5-Minute Security Setup

### 1. Create Service Account (2 minutes)

```
Account: coe-service@yourdomain.com
Purpose: CoE Starter Kit automation only
Password: Generate strong 20+ character password
Storage: Azure Key Vault or secure password manager
```

### 2. Assign Role (1 minute)

Start with **Power Platform Admin** (least privilege):
1. Go to [Microsoft 365 Admin Center](https://admin.microsoft.com)
2. Navigate to Roles → Power Platform Administrator
3. Add the service account
4. Only escalate to Global Admin if absolutely necessary

### 3. Configure Security (2 minutes)

**Minimum Security Controls:**

✅ **Azure AD Conditional Access Policy:**
- Name: "CoE Service Account Security"
- Target: Your service account
- Block access from outside corporate network
- Require compliant device (if applicable)
- Block high-risk sign-ins

✅ **Monitoring Alert:**
- Alert on failed sign-ins
- Alert on sign-ins from unexpected locations
- Alert on account changes

## Complete Setup Checklist

### Before Setup

- [ ] **Security Team Approval**
  - Share documentation with security team
  - Explain security controls
  - Get written approval

- [ ] **Account Creation**
  - Create dedicated service account
  - Generate strong password (20+ characters)
  - Store credentials in secure vault
  - Document account purpose

- [ ] **Role Assignment**
  - Assign Power Platform Admin role
  - Document why this role is needed
  - Plan escalation to Global Admin only if required

### Security Configuration

- [ ] **Conditional Access**
  - Create CA policy for service account
  - Configure IP/network restrictions
  - Configure device compliance (if applicable)
  - Configure location restrictions
  - Configure risk-based blocking
  - Test policy with service account

- [ ] **Monitoring Setup**
  - Enable Azure AD sign-in logging
  - Enable Azure AD audit logging
  - Configure Power Platform audit logging
  - Create alerts for suspicious activity
  - Test alert delivery

- [ ] **Credential Protection**
  - Store password in Azure Key Vault or password manager
  - Limit access to 2-3 people maximum
  - Document who has access
  - Set quarterly rotation reminder

### Environment Configuration

- [ ] **CoE Environment**
  - Create dedicated environment for CoE
  - Apply DLP policies
  - Restrict access to CoE administrators only
  - Enable audit logging
  - Document environment purpose

### Documentation

- [ ] **Architecture Documentation**
  - Document account setup
  - Document security controls
  - Document monitoring approach
  - Document access procedures

- [ ] **Emergency Procedures**
  - Document break-glass procedures
  - Document incident response plan
  - Document who to contact
  - Test procedures annually

### Validation

- [ ] **Security Testing**
  - Test Conditional Access policies
  - Verify monitoring alerts work
  - Test credential access procedures
  - Verify audit logging is working

- [ ] **Security Review**
  - Schedule monthly review meetings
  - Schedule quarterly full assessment
  - Document review process
  - Get ongoing security team approval

## Common Scenarios

### Scenario 1: "Our policy requires MFA on all accounts"

**Solution:** Request exception with compensating controls
1. Document the technical limitation (automated flows can't do interactive MFA)
2. Present alternative security controls (Conditional Access, monitoring)
3. Show this is more secure than traditional MFA for service accounts
4. Get exception approved by security team

### Scenario 2: "We can only use Service Principals"

**Solution:** Hybrid approach
1. Use Service Principals for PowerShell automation where possible
2. Use secured service account for Power Automate flows
3. Document which operations use which identity
4. Monitor for platform improvements to expand Service Principal support

### Scenario 3: "We require time-limited access (PIM)"

**Solution:** Separate accounts
1. Use PIM-enabled account for manual administration tasks
2. Use permanent service account with strong CA for automation
3. Document when to use each account
4. Implement comprehensive monitoring for service account

## Security Controls Summary

| Control | Purpose | Implementation |
|---------|---------|----------------|
| **Dedicated Account** | Clear audit trail, single purpose | Create coe-service@domain.com |
| **Conditional Access** | Alternative to MFA for automation | IP restrictions, device compliance |
| **Monitoring** | Detect anomalies and attacks | Azure Monitor alerts |
| **Credential Protection** | Prevent credential theft | Azure Key Vault, limited access |
| **Environment Isolation** | Limit blast radius | Dedicated CoE environment |
| **Regular Reviews** | Ensure ongoing compliance | Monthly logs, quarterly assessment |

## Red Flags to Avoid

❌ Using a personal account instead of dedicated service account  
❌ Assigning Global Admin without trying Power Platform Admin first  
❌ No Conditional Access policies configured  
❌ No monitoring or alerting set up  
❌ Storing password in plain text or shared document  
❌ Giving multiple people access to service account  
❌ No documentation of security controls  
❌ No regular security reviews scheduled  

## Success Criteria

You've successfully set up secure identity when:

✅ Security team has reviewed and approved approach  
✅ Dedicated service account created and documented  
✅ Least privilege role assigned (Power Platform Admin preferred)  
✅ Conditional Access policies configured and tested  
✅ Monitoring and alerting operational  
✅ Credentials secured in vault with limited access  
✅ Documentation complete and accessible  
✅ Regular review schedule established  

## Time Investment

| Task | Time Required |
|------|---------------|
| Security team discussions | 2-4 hours |
| Account creation and role assignment | 30 minutes |
| Conditional Access configuration | 1-2 hours |
| Monitoring and alerting setup | 1-2 hours |
| Documentation | 1-2 hours |
| Testing and validation | 1 hour |
| **Total Initial Setup** | **6-12 hours** |
| Monthly reviews | 30 minutes |
| Quarterly assessments | 2 hours |

## Quick Reference Commands

### Create Conditional Access Policy (PowerShell)

```powershell
# Connect to Azure AD
Connect-AzureAD

# Get service account
$user = Get-AzureADUser -Filter "userPrincipalName eq 'coe-service@yourdomain.com'"

# Create CA policy targeting this user
# Note: Use Azure Portal for full CA policy configuration
# This is a reference for the programmatic approach
```

### Monitor Sign-in Activity (PowerShell)

```powershell
# Connect to Azure AD
Connect-AzureAD

# Get recent sign-ins for service account
Get-AzureADAuditSignInLogs -Filter "userPrincipalName eq 'coe-service@yourdomain.com'" -Top 50
```

### Check Power Platform Admin Role

```powershell
# Install module if needed
Install-Module Microsoft.PowerApps.Administration.PowerShell

# Connect
Add-PowerAppsAccount

# Check admin access
Get-AdminPowerAppEnvironment
```

## Next Steps

1. **Review Full Documentation**
   - Read [Identity Requirements and Security Guidance](IdentityRequirementsAndSecurity.md)
   - Review [Identity Requirements FAQ](IdentityRequirementsFAQ.md)

2. **Plan with Security Team**
   - Schedule meeting with security team
   - Present documentation and security controls
   - Address concerns and questions
   - Get approval to proceed

3. **Implement Security Controls**
   - Follow the Complete Setup Checklist above
   - Test each control as you implement it
   - Document everything

4. **Install CoE Starter Kit**
   - Follow [official setup guide](https://learn.microsoft.com/power-platform/guidance/coe/setup)
   - Use the secured service account
   - Monitor during setup

5. **Establish Operations**
   - Set up regular review schedule
   - Monitor alerts and logs
   - Maintain documentation
   - Rotate credentials quarterly

## Getting Help

- **Technical questions:** [GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues)
- **Security guidance:** Your organization's security team
- **Platform issues:** Microsoft Support

## Additional Resources

- [Official CoE Setup Documentation](https://learn.microsoft.com/power-platform/guidance/coe/setup)
- [Azure AD Conditional Access](https://learn.microsoft.com/azure/active-directory/conditional-access/)
- [Power Platform Admin Center](https://admin.powerplatform.microsoft.com)
- [Power Platform Security](https://learn.microsoft.com/power-platform/admin/security/)

---

**Last Updated:** December 2024  
**Version:** 1.0

For the most current information, refer to official Microsoft documentation at [https://learn.microsoft.com/power-platform/guidance/coe/](https://learn.microsoft.com/power-platform/guidance/coe/).
