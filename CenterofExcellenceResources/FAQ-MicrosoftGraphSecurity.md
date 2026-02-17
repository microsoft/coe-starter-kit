# FAQ: Microsoft Graph Security and IP Restrictions for CoE Starter Kit

## Overview

This document provides authoritative guidance on Microsoft Graph usage, authentication context, network behavior, and security controls for the Power Platform CoE Starter Kit in regulated enterprise environments.

**Reference Setup Documentation:** [Set up the CoE Admin Command Center app](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup-core-components#set-up-the-coe-admin-command-center-app)

---

## Key Questions

### Q1: Are Graph calls executed under the registered Entra ID app/service principal or a Power Platform service context?

**A: Graph calls are executed under the registered Entra ID app/service principal context.**

**Technical Details:**

The CoE Starter Kit uses **direct Microsoft Graph API calls** via the **HTTP with Azure AD** connector. When you follow the setup steps to "Create a Microsoft Entra app registration to connect to Microsoft Graph," the flows authenticate using:

- **Client Credentials Flow** (OAuth 2.0)
- **Application Permissions** (not delegated permissions)
- **Service Principal Identity** (the Azure AD app registration)

**Authentication Method:**
```json
{
  "type": "ActiveDirectoryOAuth",
  "authority": "https://login.microsoftonline.com/",
  "tenant": "<your-tenant-id>",
  "audience": "https://graph.microsoft.com",
  "clientId": "<app-client-id>",
  "secret": "<app-client-secret>"
}
```

**What This Means:**
- ✅ Graph calls originate from your **Azure AD application's service principal**
- ✅ Requests include the app's **Application ID (Client ID)** in the OAuth token
- ✅ Authentication uses **Client ID + Client Secret** stored in environment variables
- ❌ NOT executed via a generic "Power Platform service context"
- ❌ NOT using user delegation (no user sign-in involved)

**Specific Flows Using Microsoft Graph:**

1. **CommandCenterAppGetM365ServiceMessages** - Retrieves Microsoft 365 service health messages
   - API Endpoint: `https://graph.microsoft.com/v1.0/admin/serviceAnnouncement/messages`
   - Permissions Required: `ServiceHealth.Read.All` or `ServiceMessage.Read.All`

2. **HELPER-MakerCheck** - Validates user information
   - API Endpoint: `https://graph.microsoft.com/v1.0/users/{userId}`
   - Permissions Required: `User.Read.All`

3. **AdminAuditLogsSyncAuditLogsV2** - Retrieves audit log data
   - API Endpoint: `https://graph.microsoft.com/v1.0/auditLogs/directoryAudits`
   - Permissions Required: `AuditLog.Read.All`

**Required Microsoft Graph API Permissions:**

The Azure AD app registration requires these **Application permissions**:
- `User.Read.All` - Read all users' full profiles
- `AuditLog.Read.All` - Read audit log data
- `ServiceHealth.Read.All` - Read service health
- `ServiceMessage.Read.All` - Read service announcements

> **Note:** Application permissions require **admin consent** and execute without a user context.

---

### Q2: What is the source IP behavior for these Graph calls? Are there official outbound IPs or service tags to allowlist?

**A: Source IPs are dynamic and originate from the Power Platform connector infrastructure. IP-based restrictions are NOT supported or recommended.**

**Source IP Behavior:**

When a Power Automate flow makes an HTTP with Azure AD call to Microsoft Graph:

1. **The request originates from Power Platform's connector infrastructure**
2. **Source IPs are shared, regional, and dynamic** - not specific to your tenant or app
3. **IPs can change without notice** as Microsoft scales and maintains the service
4. **No official IP ranges or service tags** are published for Power Platform connector outbound traffic

**Why IP Restrictions Don't Work:**

| Issue | Impact |
|-------|--------|
| **Shared Infrastructure** | Multiple tenants share the same outbound IPs |
| **Dynamic IP Assignment** | IPs rotate across Microsoft's global infrastructure |
| **Regional Variability** | Different regions use different IP pools |
| **No Guarantees** | Microsoft doesn't publish or guarantee stable IPs for connectors |
| **Service Changes** | Updates to Power Platform can change IP routing |

**Microsoft's Position:**

From Microsoft Support and product documentation:
> "Power Platform connectors use shared, dynamic infrastructure. Source IP addresses are not guaranteed and should not be used for security boundaries."

**What This Means for Your Security Design:**

- ❌ **Cannot** use Conditional Access location-based policies with specific IPs
- ❌ **Cannot** configure Azure firewall rules to restrict by source IP
- ❌ **Cannot** rely on network-level controls for Graph API access
- ✅ **Must** use application-level security controls (see Q3)

**Regional Considerations:**

While Power Platform has regional data centers, the connector infrastructure is global and shared:
- Requests may egress from any regional connector gateway
- IP addresses are managed by Microsoft's global network
- No tenant-specific or app-specific IP assignment

---

### Q3: If IP restriction isn't supported, what are the recommended supported controls without breaking CoE functionality?

**A: Use application-level, identity-based security controls. IP restrictions are not compatible with Power Platform connector architecture.**

## Recommended Security Controls for Regulated Enterprises

### 1. **Conditional Access for Workload Identities** ⭐ (RECOMMENDED)

Microsoft Entra ID now supports Conditional Access for service principals (workload identities):

**Setup:**
1. Navigate to **Entra ID** > **Protection** > **Conditional Access**
2. Create a new policy for **Workload identities**
3. Target the CoE app registration specifically

**Supported Controls:**
- ✅ **Authentication Context** - Require specific claims in tokens
- ✅ **Risk-based Access** - Block high-risk sign-ins
- ✅ **Service Principal Risk Policies** - Detect compromised credentials
- ✅ **Block Legacy Protocols** - Enforce modern authentication only
- ❌ **Location-based (IP)** - Not compatible with Power Platform connectors

**Example Policy:**
```
Policy Name: CoE Graph API - High Risk Block
Assignment:
  - Workload identities: CoE-GraphAPI-App
Conditions:
  - Service principal risk: High
Access controls:
  - Block access
```

**Documentation:** [Conditional Access for workload identities](https://learn.microsoft.com/entra/identity/conditional-access/workload-identity)

---

### 2. **Least Privilege API Permissions** ⭐ (REQUIRED)

Grant **only** the minimum Graph API permissions needed:

**For CoE Admin Command Center:**
```
Application Permissions (Required):
✅ User.Read.All           - User validation
✅ ServiceHealth.Read.All  - Service health messages
✅ AuditLog.Read.All       - Audit logs (if using audit component)

❌ User.ReadWrite.All      - NOT needed (read-only access sufficient)
❌ Directory.ReadWrite.All - NOT needed (CoE doesn't modify directory)
❌ Mail.Send               - NOT needed (uses Office 365 Outlook connector instead)
```

**How to Audit Permissions:**
1. Navigate to **Entra ID** > **App registrations**
2. Select your CoE app registration
3. Go to **API permissions**
4. Remove any permissions with "Write", "Create", or "Delete" unless absolutely necessary
5. Review and remove unused permissions quarterly

**Principle:** If CoE breaks after removing a permission, you can add it back. Start restrictive.

---

### 3. **Certificate-Based Authentication** (RECOMMENDED for High Security)

Replace client secrets with X.509 certificates for stronger authentication:

**Benefits:**
- ✅ Stronger cryptographic authentication
- ✅ Cannot be phished or stolen through social engineering
- ✅ Easier to rotate with automation
- ✅ Better audit trail in Entra ID sign-in logs

**Setup:**
1. Generate an X.509 certificate:
   ```powershell
   $cert = New-SelfSignedCertificate -Subject "CN=CoE-GraphAPI-Cert" `
       -CertStoreLocation "Cert:\CurrentUser\My" `
       -KeyExportPolicy Exportable `
       -KeySpec Signature `
       -KeyLength 2048 `
       -KeyAlgorithm RSA `
       -HashAlgorithm SHA256 `
       -NotAfter (Get-Date).AddYears(2)
   ```

2. Upload certificate to Azure AD app:
   - **Entra ID** > **App registrations** > Your app > **Certificates & secrets**
   - Upload the .cer file

3. Update CoE environment variable:
   - Replace `admin_GraphAPISecret` with certificate thumbprint
   - Update connector authentication to use certificate

**Important:** The HTTP with Azure AD connector in Power Automate currently supports client secrets more easily than certificates. For certificate support, you may need to:
- Use Azure Key Vault to store the certificate
- Use custom connectors with certificate authentication
- Or continue with secrets but implement strict rotation policies (see below)

---

### 4. **Secret Rotation and Lifecycle Management** ⭐ (REQUIRED)

Implement automated secret rotation policies:

**Best Practices:**
- ⏰ **Maximum secret lifetime: 90 days** (180 days absolute maximum)
- 🔄 **Automate rotation** using Azure Key Vault with managed rotation
- 📧 **Set up expiration alerts** 30 days before expiry
- 🔐 **Store secrets in Azure Key Vault**, not in environment variables directly

**Setup with Azure Key Vault:**

1. Create an Azure Key Vault
2. Store the app client secret in Key Vault
3. Update CoE environment variable `admin_GraphAPISecret` to reference Key Vault:
   - Type: `Azure Key Vault Secret`
   - Point to your Key Vault secret URI

4. Configure Key Vault access:
   - Grant the CoE app registration `Get` permission on secrets
   - Enable Key Vault firewall if available

**Secret Rotation Process:**
1. Generate new client secret in Azure AD app
2. Update Key Vault secret with new value
3. Wait 24 hours for cache invalidation
4. Delete old secret from Azure AD app

**Automation:**
Use Azure Automation or Logic Apps to:
- Monitor secret expiration dates
- Generate new secrets automatically
- Update Key Vault
- Send notifications to admins

---

### 5. **Application-Level Monitoring and Alerting** ⭐ (RECOMMENDED)

Implement comprehensive monitoring for the service principal:

**What to Monitor:**

1. **Entra ID Sign-in Logs (Service Principal Sign-ins)**
   - Navigate to **Entra ID** > **Monitoring** > **Sign-in logs** > **Service principal sign-ins**
   - Look for:
     - Failed authentication attempts
     - Unusual request volumes
     - Calls from unexpected applications
     - High-risk sign-ins

2. **Microsoft Graph API Audit Logs**
   - Track all Graph API calls made by the app
   - Monitor for unusual patterns (e.g., sudden spike in requests)

3. **Azure Monitor Alerts**

**Example Alerts to Configure:**

```
Alert 1: Failed Service Principal Authentication
Condition: Failed sign-in count > 5 in 15 minutes
Action: Email security team + Create ticket

Alert 2: High-Risk Service Principal Sign-in
Condition: Risk level = High
Action: Block access (via Conditional Access) + Page on-call

Alert 3: Unusual API Call Volume
Condition: Graph API requests > 1000 in 1 hour
Action: Email CoE admins for investigation

Alert 4: Secret Expiring Soon
Condition: Secret expires in < 30 days
Action: Email admins + Create rotation ticket
```

**Setup via Azure Monitor:**
1. Create a Log Analytics Workspace
2. Connect Entra ID diagnostic logs to the workspace
3. Create alert rules based on KQL queries
4. Configure action groups for notifications

---

### 6. **Restrict App to Specific Resources (Resource-Based Policies)**

Limit what the app can access even with granted permissions:

**Not Directly Supported for Graph API, but Consider:**

1. **Administrative Units (Preview for Apps)**
   - If available, restrict User.Read.All to specific administrative units
   - Currently limited support for application permissions

2. **Application Permission Grants Policies**
   - Configure tenant-wide policies that limit what apps can do
   - Navigate to **Entra ID** > **Enterprise applications** > **Consent and permissions** > **Permission policies**

3. **PIM for Service Principals (Roadmap)**
   - Just-in-time permissions for service principals
   - Currently not available but on Microsoft's roadmap

**Current Limitation:**
Application permissions like `User.Read.All` grant access to **all users** in the directory. There's no built-in way to scope to specific users or groups for application permissions (unlike delegated permissions).

**Workaround:**
- Keep permissions as read-only
- Implement audit logging for all Graph API calls
- Monitor for data exfiltration patterns

---

### 7. **Network Segmentation (Indirect Controls)**

While you cannot restrict by source IP, you can implement other network controls:

**1. Restrict Management Access to the CoE Environment**
- Require users accessing the CoE environment to connect via corporate network
- Use Conditional Access for **user sign-ins** (separate from the app registration)

**2. DLP Policies for the CoE Environment**
- Prevent copying data outside the environment
- Block connectors that could exfiltrate data
- See [TROUBLESHOOTING-DLP-APPFORBIDDEN.md](../docs/TROUBLESHOOTING-DLP-APPFORBIDDEN.md)

**3. Azure Private Endpoints (For Other Azure Resources)**
- Not applicable to Microsoft Graph API calls
- Cannot place Graph API behind private endpoints
- Graph API is a public Microsoft service

---

### 8. **Dedicated Service Principal per Component**

Separate service principals for different CoE components:

**Architecture:**
```
CoE-GraphAPI-ServiceHealth  → Only ServiceHealth.Read.All
CoE-GraphAPI-Users          → Only User.Read.All
CoE-GraphAPI-AuditLogs      → Only AuditLog.Read.All
```

**Benefits:**
- ✅ Least privilege per component
- ✅ Easier to audit what each component does
- ✅ If one credential is compromised, blast radius is limited
- ✅ Can disable individual components without affecting others

**Implementation:**
1. Create separate Azure AD app registrations for each use case
2. Grant minimum permissions to each
3. Configure separate environment variables in CoE
4. Update flows to use the appropriate app registration

**Tradeoff:**
- More management overhead (more secrets to rotate)
- May be overkill for smaller deployments

---

### 9. **Regular Access Reviews and Auditing**

Establish a governance process:

**Quarterly Reviews:**
- [ ] Review all API permissions granted to CoE app registrations
- [ ] Verify permissions are still needed
- [ ] Check for new least-privilege alternatives
- [ ] Audit who has access to modify the app registration
- [ ] Review sign-in logs for anomalies

**Access Control for App Registration:**
- Limit who can modify the app registration to 2-3 authorized admins
- Use Entra ID **Privileged Identity Management (PIM)** for just-in-time admin access
- Require approval workflow for changes to app permissions

**Audit Checklist:**
```
✅ App owner is current employee (not a former employee)
✅ Client secrets have not expired
✅ No unnecessary permissions granted
✅ Conditional Access policies are still active
✅ Monitoring alerts are working
✅ No failed authentication spikes in last 90 days
✅ Secret rotation is on schedule
✅ Certificate (if used) is not expiring soon
```

---

### 10. **Data Residency and Sovereignty Controls**

For regulated industries with data residency requirements:

**Understanding Data Flow:**

1. **CoE Dataverse Environment** 
   - Data stored in your specified geo (e.g., EU, US, UK)
   - Follows standard Dataverse data residency

2. **Microsoft Graph API Calls**
   - API calls route through Microsoft's global infrastructure
   - Response data transits globally but is then stored in your Dataverse environment

3. **Power Platform Connector Infrastructure**
   - Connectors are regional but may route globally
   - Not guaranteed to stay within a specific geo boundary

**Controls:**
- ✅ Deploy CoE environment in your required compliance region
- ✅ Ensure Dataverse stores data in compliant location
- ⚠️ Understand that API traffic may transit other regions temporarily
- ❌ Cannot guarantee Graph API calls never leave a specific region

**For Strict Data Residency:**
If Graph API call transit violates compliance:
- Consider **not using** the Microsoft Graph features of CoE
- Disable flows that call Graph API
- Use only Power Platform admin connectors for inventory (which don't use Graph)

---

## Summary: Recommended Security Baseline for Regulated Enterprises

### ✅ Required (Must Implement)

1. **Least privilege API permissions** - Review and minimize
2. **Secret rotation every 90 days** - Use Azure Key Vault
3. **Monitor service principal sign-ins** - Set up alerts
4. **Restrict who can modify app registration** - Use PIM

### ⭐ Highly Recommended

5. **Conditional Access for workload identities** - Block high-risk sign-ins
6. **Certificate-based authentication** - Replace secrets (if feasible)
7. **Dedicated app registrations per component** - Reduce blast radius
8. **Regular quarterly access reviews** - Governance process

### 🔍 Optional (Enhanced Security)

9. **Application-level monitoring with custom alerts** - Advanced threat detection
10. **Data residency documentation** - Compliance mapping

---

## What DOES NOT Work

❌ **Source IP restrictions** - Power Platform connectors use dynamic IPs  
❌ **Location-based Conditional Access** - Not compatible with connector infrastructure  
❌ **Azure Firewall IP allowlists** - IPs are shared and change frequently  
❌ **Network-level security** - Must use application-level controls  
❌ **Private endpoints for Graph API** - Graph is a public service  

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│ Power Platform (Your Tenant)                                │
│                                                              │
│  ┌────────────────────────────────────────┐                 │
│  │ CoE Core Components Environment        │                 │
│  │  ┌──────────────────────────────────┐  │                 │
│  │  │ Power Automate Flow              │  │                 │
│  │  │                                  │  │                 │
│  │  │  HTTP with Azure AD Connector    │  │                 │
│  │  │  ├─ Client ID: <app-id>          │  │                 │
│  │  │  ├─ Client Secret: (from env var)│  │                 │
│  │  │  └─ Tenant ID: <tenant-id>       │  │                 │
│  │  └──────────────────────────────────┘  │                 │
│  └────────────────────────────────────────┘                 │
└─────────────────────────────────────────────────────────────┘
                          │
                          │ OAuth 2.0 Client Credentials Flow
                          │ Source IP: Dynamic (Power Platform connector infrastructure)
                          ▼
┌─────────────────────────────────────────────────────────────┐
│ Microsoft Entra ID                                          │
│  ┌────────────────────────────────────────┐                 │
│  │ App Registration: CoE-GraphAPI-App     │                 │
│  │  ├─ Client ID: abc123...               │                 │
│  │  ├─ Client Secret: ***                 │                 │
│  │  └─ API Permissions:                   │                 │
│  │      ├─ User.Read.All                  │                 │
│  │      ├─ ServiceHealth.Read.All         │                 │
│  │      └─ AuditLog.Read.All              │                 │
│  └────────────────────────────────────────┘                 │
│                                                              │
│  Security Controls:                                         │
│  ├─ Conditional Access (Workload Identity)                  │
│  ├─ Certificate or Secret Authentication                    │
│  ├─ Sign-in Logs & Monitoring                               │
│  └─ Secret Rotation Policies                                │
└─────────────────────────────────────────────────────────────┘
                          │
                          │ Access Token with App Permissions
                          ▼
┌─────────────────────────────────────────────────────────────┐
│ Microsoft Graph API (graph.microsoft.com)                   │
│  └─ /v1.0/admin/serviceAnnouncement/messages                │
│  └─ /v1.0/users/{userId}                                    │
│  └─ /v1.0/auditLogs/directoryAudits                         │
└─────────────────────────────────────────────────────────────┘
```

---

## Frequently Asked Questions

### Q: Can we use a managed identity instead of an app registration?

**A:** Not directly. Managed identities are for Azure resources (VMs, Functions, etc.). Power Automate flows cannot authenticate as a managed identity. You must use an app registration with client credentials.

However, you could:
- Use Azure Functions with managed identity to call Graph
- Have Power Automate call your Azure Function
- This adds complexity and is not necessary for most scenarios

---

### Q: Our compliance team requires IP-based restrictions. What do we tell them?

**A:** Provide this documentation and explain:

1. **Technical Limitation:** Power Platform connectors use Microsoft's shared, dynamic infrastructure. Source IPs are not static or tenant-specific.

2. **Microsoft's Design:** This is by design for scalability and reliability. Microsoft does not publish or guarantee connector IP ranges.

3. **Alternative Controls:** The recommended approach is defense-in-depth using identity-based controls (Conditional Access, least privilege, monitoring) rather than network controls.

4. **Industry Standard:** Modern cloud security follows a "Zero Trust" model based on identity verification, not network location.

5. **Comparison:** Similar to how Microsoft 365 and Azure services work - you trust the identity, not the IP address.

**Escalation Path:**
If this is a blocker, contact Microsoft Support or your Microsoft account team to:
- Confirm this is platform behavior (not specific to CoE Kit)
- Discuss if your compliance framework can accept identity-based controls
- Explore if a Microsoft Cloud for Sovereignty solution might be required (for extremely regulated scenarios)

---

### Q: What if our Azure AD app registration gets compromised?

**A:** Immediate response steps:

1. **Disable the app registration:**
   - Entra ID > App registrations > Your app > Properties > "Enabled for users to sign-in?" > No

2. **Rotate the client secret:**
   - Generate a new secret
   - Update Azure Key Vault or environment variable
   - Delete the old secret

3. **Review sign-in logs:**
   - Check for unauthorized access
   - Identify scope of compromise
   - Look for unusual Graph API calls

4. **Check audit logs:**
   - See what data was accessed
   - Determine if sensitive information was read

5. **Create a new app registration:**
   - If compromise is severe, create a new app
   - Grant minimum permissions
   - Reconfigure CoE to use the new app
   - Delete the old app registration

6. **Post-incident:**
   - Implement certificate-based auth (if using secrets)
   - Add Conditional Access policy to block high-risk sign-ins
   - Set up better monitoring/alerting
   - Review: How did the compromise occur?

---

### Q: Can we use a different authentication method?

**A:** Options and limitations:

| Method | Supported? | Notes |
|--------|-----------|-------|
| **Client Secret** | ✅ Yes | Default method, rotate every 90 days |
| **Client Certificate** | ⚠️ Partial | Requires Azure Key Vault or custom connector |
| **Managed Identity** | ❌ No | Not compatible with Power Automate cloud flows |
| **User Delegation** | ❌ No | CoE uses application permissions, not delegated |
| **Federated Credentials** | ⚠️ Experimental | Workload identity federation - limited support |

---

### Q: Do audit logs show which app made Graph API calls?

**A:** Yes! Entra ID sign-in logs track service principal authentication:

**To View:**
1. **Entra ID** > **Monitoring** > **Sign-in logs**
2. Filter by **Service principal sign-ins**
3. Look for your CoE app registration name
4. See:
   - Timestamp
   - IP address (the Power Platform connector IP)
   - Authentication method
   - Resource accessed (Microsoft Graph)
   - Success/failure

**To Track Specific Graph Calls:**
- Not directly in sign-in logs
- Use Microsoft Graph API activity logs (requires premium features)
- Or implement application-side logging within flows

---

## Additional Resources

### Official Microsoft Documentation

- [Set up CoE Admin Command Center](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup-core-components#set-up-the-coe-admin-command-center-app)
- [Conditional Access for workload identities](https://learn.microsoft.com/entra/identity/conditional-access/workload-identity)
- [Microsoft Graph API permissions reference](https://learn.microsoft.com/graph/permissions-reference)
- [Secure service principals in Entra ID](https://learn.microsoft.com/entra/architecture/service-accounts-principal)
- [Zero Trust security model](https://learn.microsoft.com/security/zero-trust/)

### CoE Starter Kit Documentation

- [Admin Role Requirements FAQ](./FAQ-AdminRoleRequirements.md)
- [Service Principal Support](../docs/ServicePrincipalSupport.md)
- [Quick Setup Checklist](./QUICK-SETUP-CHECKLIST.md)
- [Troubleshooting Setup Wizard](./TROUBLESHOOTING-SETUP-WIZARD.md)

### Security Best Practices

- [Microsoft Cloud Security Benchmark](https://learn.microsoft.com/security/benchmark/azure/introduction)
- [Azure AD security operations guide](https://learn.microsoft.com/entra/architecture/security-operations-introduction)
- [Power Platform security white paper](https://learn.microsoft.com/power-platform/admin/wp-security)

---

## Support and Escalation

### For CoE Starter Kit Questions
- [GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues) - Use "Question" template
- [GitHub Discussions](https://github.com/microsoft/coe-starter-kit/discussions)
- [CoE Office Hours](https://aka.ms/coeofficehours)

### For Microsoft Graph Security Questions
- Microsoft Support (via Azure Portal)
- Microsoft Premier Support
- Your Microsoft account team

### For Conditional Access / Entra ID
- [Entra ID support](https://learn.microsoft.com/entra/fundamentals/how-to-get-support)
- Azure Support ticket

---

**Document Version:** 1.0  
**Last Updated:** February 2026  
**Applies To:** CoE Starter Kit v4.50.6+  
**Validated By:** CoE Starter Kit Team

---

## Document Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | Feb 2026 | Initial creation - comprehensive Microsoft Graph security guidance for regulated enterprises |
