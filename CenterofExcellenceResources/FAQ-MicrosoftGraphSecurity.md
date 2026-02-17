# FAQ: Microsoft Graph Access Security and Network Controls

## Overview

This document addresses common security questions about how the CoE Starter Kit uses Microsoft Graph, including authentication context, network/IP behavior, and recommended security controls for regulated enterprise environments.

---

## Quick Summary

| Question | Answer |
|----------|--------|
| **Authentication context** | Graph calls use delegated permissions via user connections (licensed Power Platform admin account) |
| **Source IP** | Power Platform infrastructure IPs (not customer-controlled, not static) |
| **IP restrictions** | Not reliably supported for Power Platform Graph calls |
| **Recommended controls** | Conditional Access, least-privilege scopes, audit logs, dedicated service accounts |

---

## Common Questions

### Q1: Are Graph calls executed under the registered Entra ID app/service principal or a Power Platform service context?

**A: Graph calls in CoE Starter Kit use delegated permissions through Power Platform connectors, not direct service principal authentication.**

#### How It Works

The CoE Starter Kit makes Microsoft Graph calls through several mechanisms:

1. **Office 365 Group Connector** (Delegated)
   - Used for adding makers to groups (`Admin | Add Maker to Group` flow)
   - Uses delegated permissions of the connection owner (typically the service account)
   - Calls Graph API: `POST /v1.0/groups/{id}/members`

2. **HTTP with Azure AD Connector** (Delegated)
   - Used by the Setup Wizard and Command Center flows
   - Calls Graph API: `GET /v1.0/serviceAnnouncements/messages`
   - Uses delegated permissions authenticated via the connection reference owner

3. **Custom Connectors** (Can be App-Only or Delegated)
   - If you configure custom connectors for Graph, you can use service principal (app-only) authentication
   - Standard CoE flows use the built-in connectors with delegated permissions

#### Authentication Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│ Power Platform Flow Execution                                        │
│                                                                       │
│  1. Flow triggers (scheduled or manual)                              │
│  2. Connection reference resolves to the connection owner            │
│  3. Power Platform requests delegated token from Azure AD             │
│  4. Token includes user's identity + connector's app registration    │
│  5. Graph API call made with delegated permissions                   │
│                                                                       │
│  ┌───────────────┐     ┌────────────────┐     ┌─────────────────┐  │
│  │ CoE Flow      │────▶│ Power Platform │────▶│ Azure AD        │  │
│  │ (e.g., Sync)  │     │ Connector      │     │ Token Service   │  │
│  └───────────────┘     └────────────────┘     └────────┬────────┘  │
│                                                         │           │
│                                                         ▼           │
│                                    ┌────────────────────────────┐  │
│                                    │ Microsoft Graph API        │  │
│                                    │ (graph.microsoft.com)      │  │
│                                    └────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
```

#### Key Points

- **Delegated permissions**: Most Graph calls are made on behalf of the signed-in user (the connection owner)
- **Connector app registration**: Power Platform connectors have their own Azure AD app registrations (managed by Microsoft)
- **User context**: The token includes the identity of the user who owns the connection
- **Entra ID app created during setup**: Used for setup wizard validation, not direct Graph API calls by flows

#### What the Entra ID App Registration Does

When you follow the setup instructions to "Create a Microsoft Entra app registration to connect to Microsoft Graph," that app is used for:
- **Setup Wizard**: Validating permissions during configuration
- **Command Center**: Retrieving M365 service messages
- **User details lookup**: Getting user profile information

The app registration uses **delegated permissions** (not application permissions), meaning calls still require a user context.

---

### Q2: What is the source IP behavior for these Graph calls? Are there official outbound IPs/service tags to allowlist?

**A: Graph calls from Power Platform originate from Microsoft's multi-tenant infrastructure, with dynamic and shared IP addresses that cannot be reliably allowlisted.**

#### Source IP Reality

Power Platform runs on a multi-tenant Microsoft infrastructure with these characteristics:

| Aspect | Details |
|--------|---------|
| **IP addresses** | Dynamic, shared across tenants, change without notice |
| **Service tags** | Azure service tags exist (`PowerPlatformInfra`) but are broad and not tenant-specific |
| **Static IPs** | Not available for Power Platform cloud flows |
| **Region-based** | IPs vary by geographic region of environment |

#### Why IP Allowlisting Is Challenging

1. **Multi-tenant infrastructure**: Power Platform shares infrastructure across thousands of tenants
2. **Dynamic scaling**: IPs change as Microsoft scales infrastructure
3. **No customer control**: Customers cannot configure or lock outbound IPs
4. **Broad service tags**: Azure service tags cover entire regions/services, not individual tenants
5. **No SLA for IP stability**: Microsoft doesn't guarantee IP address persistence

#### What Microsoft Says

From Microsoft documentation:
> "Power Automate cloud flows use shared infrastructure and dynamic IP addresses. It's not possible to configure static outbound IP addresses for cloud flows."

#### Available Service Tags (Limited Use)

If your security team requires some form of network controls, these Azure service tags exist:

| Service Tag | Description | Limitation |
|-------------|-------------|------------|
| `PowerPlatformInfra` | Power Platform infrastructure IPs | Broad, includes all tenants in region |
| `AzureCloud` | All Azure services | Very broad, not specific enough |

**Important**: These tags are meant for *inbound* traffic to your resources, not for restricting Microsoft Graph access at the Entra ID level.

#### Bottom Line

**IP-based restrictions for Power Platform to Microsoft Graph are not reliably implementable.** This is a platform architecture limitation, not specific to the CoE Starter Kit.

---

### Q3: What are the recommended security controls if IP restriction isn't supported?

**A: Implement a defense-in-depth approach using Conditional Access, least-privilege permissions, monitoring, and dedicated service accounts.**

#### Recommended Security Controls

##### 1. Use a Dedicated Service Account

Create a dedicated, non-interactive service account for CoE operations:

```
Account naming: svc-coe-admin@contoso.com
Purpose: Owns CoE flow connections
Access: Power Platform Administrator role only
Licensing: Power Apps Premium + Power Automate Premium
```

**Benefits**:
- ✅ Isolated identity for CoE operations
- ✅ Clear audit trail
- ✅ Easier to manage and monitor
- ✅ Can apply specific Conditional Access policies

##### 2. Conditional Access for Workload Identities

Apply Conditional Access policies to control access:

**Policy 1: Require Compliant Conditions**
```
Name: CoE-ServiceAccount-Restrictions
Target: svc-coe-admin@contoso.com (service account)
Conditions:
  - Client apps: All (or specific to Power Platform)
Controls:
  - Grant: Require MFA (if supported) OR require compliant device
Exclusions:
  - Consider excluding Power Platform service IPs if you must allow automated flows
```

**Policy 2: Block Legacy Authentication**
```
Name: Block-Legacy-Auth-CoE
Target: svc-coe-admin@contoso.com
Conditions:
  - Client apps: Legacy authentication clients
Controls:
  - Block access
```

**Policy 3: Session Controls**
```
Name: CoE-Session-Limits
Target: svc-coe-admin@contoso.com
Session:
  - Sign-in frequency: 1 hour (balance security vs. flow reliability)
  - Persistent browser session: Disabled
```

**Note on Workload Identity Conditional Access**: Microsoft has preview features for Conditional Access for workload identities (service principals). However, this applies to app-only authentication, not delegated authentication used by Power Platform connectors. Monitor Microsoft announcements for expanded capabilities.

##### 3. Least-Privilege Microsoft Graph Permissions

Configure the Entra ID app registration with minimum required permissions:

**Required Graph Permissions (Delegated)**:

| Permission | Type | Purpose |
|------------|------|---------|
| `User.Read` | Delegated | Read signed-in user profile |
| `User.Read.All` | Delegated | Look up other user profiles |
| `Group.ReadWrite.All` | Delegated | Manage maker group membership |
| `ServiceMessage.Read.All` | Delegated | Read M365 service announcements |
| `Directory.Read.All` | Delegated | Read directory data for user lookups |

**Permissions to Avoid** (not needed for standard CoE):

| Permission | Why Not Needed |
|------------|---------------|
| `Mail.ReadWrite` | CoE uses Office 365 Outlook connector, not Graph mail |
| `Files.ReadWrite.All` | CoE uses SharePoint connector, not Graph files |
| `Calendars.ReadWrite` | Not used by CoE |
| `Application permissions` | Use delegated permissions instead |

**How to Review/Restrict**:
1. Navigate to Azure Portal → Azure AD → App registrations
2. Find your CoE app registration
3. Go to **API permissions**
4. Remove any permissions not in the "Required" list above
5. Click **Grant admin consent** after changes

##### 4. Enable Comprehensive Audit Logging

Configure audit logging at multiple levels:

**Azure AD Sign-in Logs**:
- Enable diagnostic settings in Azure AD
- Send logs to Log Analytics workspace
- Create alerts for:
  - Failed sign-ins for service account
  - Sign-ins from unexpected locations
  - High volume of token requests

**Power Platform Activity Logging**:
- Enable activity logging in Power Platform Admin Center
- Monitor flow execution patterns
- Alert on unusual flow failures

**Microsoft Graph Activity Logs** (Preview):
- Enable Microsoft Graph activity logs if available in your tenant
- Monitor API calls made by your app registration
- Alert on unexpected API call patterns

**Sample Alert Conditions**:
```
Alert 1: Service account sign-in from unexpected IP range
Alert 2: Failed authentication attempts > 5 in 10 minutes
Alert 3: Graph API throttling (429 responses) indicating unusual activity
Alert 4: New consent grants to CoE app registration
```

##### 5. Implement Network Security Where Possible

While Power Platform outbound IPs cannot be controlled, implement network security on resources you control:

**For on-premises gateway scenarios**:
- If using on-premises data gateway, restrict gateway server network access
- Apply firewall rules to the gateway machine

**For Azure resources called by CoE**:
- Use Private Endpoints where available
- Configure service endpoints
- Apply Network Security Groups

**For custom connectors with Azure backend**:
- Use Azure API Management with IP restrictions
- Implement authentication in your custom APIs

##### 6. Regular Access Reviews

Implement periodic reviews:

| Review Type | Frequency | What to Check |
|-------------|-----------|---------------|
| **App permissions** | Quarterly | Are all Graph permissions still needed? |
| **Connection owners** | Monthly | Who owns the CoE connections? |
| **Service account access** | Quarterly | Does the service account have any new roles? |
| **Flow inventory** | Monthly | Are there unexpected flows using admin connections? |
| **Conditional Access** | Quarterly | Are policies still effective? |

##### 7. Application Consent Controls

Restrict who can consent to applications:

1. In Azure AD → Enterprise applications → Consent and permissions
2. Configure:
   - User consent: Disabled or restricted to verified publishers
   - Admin consent: Required for all Graph permissions
   - Admin consent workflow: Enabled

This ensures any new permissions for CoE or other apps require admin approval.

---

## Security Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         SECURITY CONTROLS LAYERED                        │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  Layer 1: Identity Controls                                              │
│  ┌────────────────────────────────────────────────────────────────────┐ │
│  │ • Dedicated service account (svc-coe-admin@contoso.com)           │ │
│  │ • Strong password + Azure Key Vault storage                        │ │
│  │ • Conditional Access policies                                      │ │
│  │ • MFA where possible (interactive scenarios)                       │ │
│  └────────────────────────────────────────────────────────────────────┘ │
│                                                                          │
│  Layer 2: Authorization Controls                                         │
│  ┌────────────────────────────────────────────────────────────────────┐ │
│  │ • Least-privilege Graph permissions (delegated only)              │ │
│  │ • Power Platform Admin role (minimum required)                     │ │
│  │ • Environment security groups                                      │ │
│  │ • DLP policies on CoE environment                                  │ │
│  └────────────────────────────────────────────────────────────────────┘ │
│                                                                          │
│  Layer 3: Detection & Monitoring                                         │
│  ┌────────────────────────────────────────────────────────────────────┐ │
│  │ • Azure AD sign-in logs                                            │ │
│  │ • Power Platform activity logs                                     │ │
│  │ • Microsoft Graph activity logs (where available)                  │ │
│  │ • Alerts for anomalous behavior                                    │ │
│  └────────────────────────────────────────────────────────────────────┘ │
│                                                                          │
│  Layer 4: Governance                                                     │
│  ┌────────────────────────────────────────────────────────────────────┐ │
│  │ • Regular access reviews                                           │ │
│  │ • Permission audits                                                │ │
│  │ • Consent controls                                                 │ │
│  │ • Documentation and change management                              │ │
│  └────────────────────────────────────────────────────────────────────┘ │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## CoE Starter Kit Graph API Usage Reference

### Flows That Use Microsoft Graph

| Flow Name | Graph API Used | Purpose |
|-----------|---------------|---------|
| `Command Center App > Get M365 Service Messages` | ServiceAnnouncements API | Retrieve Power Platform service updates |
| `Admin \| Add Maker to Group` | Groups API | Add discovered makers to M365 group |
| `Setup Wizard > Get User Details` | Users API | Validate user permissions during setup |
| `Setup Wizard > Get User Graph Permissions` | Me API | Check user's Graph permissions |
| `Setup Wizard > Create Group` | Groups API | Create maker groups during setup |
| `HELPER - Maker Check` | Users API | Validate maker information |
| `Admin Sync Template v4 (Security Roles)` | Users API | Get user details for security role sync |
| `CLEANUP - Orphaned Users/Makers` | Users API | Verify users still exist in directory |

### Connectors Used for Graph Access

| Connector | Purpose | Permissions |
|-----------|---------|-------------|
| **Office 365 Groups** | Group membership management | Group.ReadWrite.All (delegated) |
| **Office 365 Users** | User profile lookups | User.Read.All (delegated) |
| **HTTP with Azure AD** | Custom Graph API calls | Varies by flow |

---

## Comparison: CoE Flows vs. Custom Service Principal

| Aspect | Standard CoE Flows | Custom Service Principal |
|--------|-------------------|-------------------------|
| **Authentication** | Delegated (user context) | App-only (service context) |
| **IP behavior** | Power Platform infra IPs | Can use Azure Function with static IP |
| **Conditional Access** | User-based CA policies | Workload identity CA (preview) |
| **Maintenance** | Managed by Microsoft | Customer-managed |
| **Licensing** | Power Platform licenses | Azure Function costs |
| **Implementation effort** | Low (OOTB) | High (custom development) |

If your security requirements absolutely require static IPs or app-only authentication:
1. Consider custom Azure Functions with static outbound IPs
2. Use service principal authentication from Azure Functions
3. Create custom connectors in Power Platform to call your Azure Functions
4. Accept the additional development and maintenance overhead

**Note**: This approach requires significant custom development and is not part of the standard CoE Starter Kit.

---

## Frequently Asked Questions

### Can I use application permissions instead of delegated permissions?

**A**: The standard CoE flows use Power Platform connectors that require delegated permissions. To use application (app-only) permissions, you would need to create custom connectors or Azure Functions—this is significant custom development outside the standard CoE architecture.

### Will Microsoft eventually support static IPs for Power Platform?

**A**: There is no announced timeline for static outbound IPs for Power Platform cloud flows. Monitor the [Power Platform release plans](https://learn.microsoft.com/power-platform/release-plan/) for updates.

### Can I use Private Link for Microsoft Graph from Power Platform?

**A**: Microsoft Graph does not currently support Private Link. Private Link is available for some Azure services but not for Microsoft Graph APIs.

### How do I know if my Conditional Access policies are affecting CoE flows?

**A**: 
1. Check Azure AD sign-in logs for the service account
2. Look for "Conditional Access" in the failure reason
3. Review flow run history for authentication errors
4. Test policies in "Report-only" mode first

### What happens if I block all but specific IPs for my Graph app registration?

**A**: If you configure IP-based Conditional Access for your CoE service account and Power Platform flows execute from IPs outside your allowed list, the flows will fail with authentication errors. Since Power Platform IPs are dynamic and not customer-controlled, this will cause intermittent or complete flow failures.

---

## Additional Resources

### Microsoft Documentation
- [Power Platform security documentation](https://learn.microsoft.com/power-platform/admin/security)
- [Conditional Access for workload identities](https://learn.microsoft.com/azure/active-directory/conditional-access/workload-identity)
- [Microsoft Graph permissions reference](https://learn.microsoft.com/graph/permissions-reference)
- [Power Platform IP addresses](https://learn.microsoft.com/power-platform/admin/online-requirements)

### Related CoE Documentation
- [FAQ: Admin Role Requirements](FAQ-AdminRoleRequirements.md)
- [FAQ: Environment Access Control](FAQ-EnvironmentAccessControl.md)
- [Service Principal Support](../docs/ServicePrincipalSupport.md)
- [CoE Setup Guide](https://learn.microsoft.com/power-platform/guidance/coe/setup)

### Community Resources
- [CoE Starter Kit GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues)
- [Power Platform Community](https://powerusers.microsoft.com/)
- [CoE Starter Kit Office Hours](https://aka.ms/coeofficehours)

---

## Need Help?

If you have additional security questions about the CoE Starter Kit:

1. **Review documentation**: Check the [CoE Starter Kit documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
2. **Search existing issues**: Look for similar questions in [GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues)
3. **Ask the community**: Use the [question template](https://github.com/microsoft/coe-starter-kit/issues/new/choose)
4. **Join office hours**: Participate in [CoE Starter Kit Office Hours](https://aka.ms/coeofficehours)
5. **Microsoft Support**: For production-critical security questions, contact Microsoft Support

---

**Applies to:** CoE Starter Kit Core Components (v4.50+)  
**Last Updated:** February 2026  
**Version:** 1.0
