# Identity Requirements and Security Guidance for CoE Starter Kit

This document addresses common questions and concerns about identity requirements for the CoE Starter Kit, especially for security-conscious organizations.

## Overview

The CoE Starter Kit has specific identity requirements that are driven by technical limitations in the Power Platform connectors and APIs. This document explains the rationale behind these requirements and provides guidance on how to configure accounts securely.

## Key Documentation References

- [Which identity should I use to install the CoE Starter Kit?](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup#which-identity-should-i-use-to-install-the-coe-starter-kit)
- [Limitations: Service Principals](https://learn.microsoft.com/en-us/power-platform/guidance/coe/limitations#service-principals)
- [Limitations: Multifactor Authentication](https://learn.microsoft.com/en-us/power-platform/guidance/coe/limitations#multifactor-authentication)
- [Limitations: PIM (Privileged Identity Management)](https://learn.microsoft.com/en-us/power-platform/guidance/coe/limitations#pim-privileged-identity-management)

## Understanding the Requirements

### Why Power Platform Admin Role is Required

The CoE Starter Kit needs to gather inventory data from across your tenant, including:
- All environments
- All apps (canvas and model-driven)
- All flows
- All connectors
- Maker information

To access this cross-tenant data, the identity running the CoE flows needs administrative permissions. The **Power Platform Administrator** role is the recommended minimum; Global Administrator is not required.

### Why Service Principals Cannot Be Used

The Power Platform Admin connectors used by the CoE Starter Kit currently do not support Service Principal authentication. This is a product limitation, not a design choice by the CoE Starter Kit team. The connectors require a user context to authenticate and retrieve data.

**Note**: The ALM Accelerator for Power Platform does support Service Principals for its deployment pipelines, which are separate from the CoE Starter Kit inventory components.

### Why MFA Presents Challenges

Cloud flows in Power Automate use connection references that require periodic re-authentication. When MFA is enforced:
- Connections may expire more frequently
- Re-authentication requires interactive login with MFA challenge
- Automated flows cannot complete MFA challenges without user interaction

This can cause flows to fail if connections expire when no one is available to re-authenticate.

### Why PIM (Privileged Identity Management) Presents Challenges

If using PIM for just-in-time elevation:
- The identity needs active (not eligible) role assignments for flows to run
- Flows run on schedules and cannot request PIM elevation
- If PIM elevation expires, flows will fail until re-elevated

## Security Best Practices

While the CoE Starter Kit has these identity requirements, here are recommendations to minimize security risk:

### 1. Use a Dedicated Service Account

Create a dedicated service account specifically for the CoE Starter Kit:
- Do NOT use a personal admin account
- Do NOT use your Global Administrator account
- Create a new account with a clear naming convention (e.g., `svc-coestarter@contoso.com`)

### 2. Apply Principle of Least Privilege

- Assign only **Power Platform Administrator** role, not Global Administrator
- This role is sufficient for all CoE Starter Kit functionality
- Review [Azure AD built-in roles](https://learn.microsoft.com/en-us/azure/active-directory/roles/permissions-reference) for role definitions

### 3. Configure Conditional Access Policies

Instead of MFA for interactive login, use Conditional Access policies to secure the account:

- **Restrict sign-in locations**: Allow sign-in only from your corporate network or specific IP addresses
- **Restrict device platforms**: Limit to specific device types if applicable
- **Restrict sign-in risk**: Block sign-ins with elevated risk levels
- **Require compliant device**: Require the device to be Entra ID joined and compliant

Example Conditional Access policy configuration:
1. Create a new Conditional Access policy
2. Target the CoE service account
3. Conditions:
   - Exclude trusted locations (your corporate IPs)
   - Include all locations
4. Access controls: Block access

This means the account can only sign in from your corporate network.

### 4. Monitor the Account

- Enable Azure AD audit logs for the account
- Set up alerts for suspicious sign-in attempts
- Review the sign-in logs periodically
- Consider using Microsoft Sentinel or similar SIEM for monitoring

### 5. Secure the Password

- Use a strong, unique password (25+ characters recommended)
- Store the password in a secure password vault (Azure Key Vault, enterprise password manager)
- Rotate the password periodically
- Limit knowledge of the password to essential personnel only

### 6. Limit Connection Sharing

- The connection references used by CoE flows should only be shared with the CoE service account
- Do not share connections with other users
- Review connection sharing periodically

### 7. Use a Dedicated Environment

- Install the CoE Starter Kit in a dedicated, production Dataverse environment
- Limit who has access to this environment
- Apply appropriate DLP (Data Loss Prevention) policies

## Alternative Approaches

### Cloud Flows with Manual Triggers

For organizations with strict MFA requirements, consider:
- Running inventory flows manually with scheduled reminders
- This allows an admin to complete MFA during the manual trigger
- Less automated but more compatible with strict security policies

### Hybrid Approach

Some organizations use a hybrid approach:
- Service account for non-sensitive inventory collection
- Personal admin account for sensitive operations with MFA

### PowerShell Scripts as Supplement

For specific scenarios, PowerShell scripts can supplement the CoE Starter Kit:
- [Power Platform Admin PowerShell](https://learn.microsoft.com/en-us/power-platform/admin/powerapps-powershell-getting-started)
- Scripts can use Service Principal authentication where connectors cannot

## Frequently Asked Questions

### Q: Can I use Global Administrator instead of Power Platform Administrator?

A: Global Administrator will work, but it's not recommended due to principle of least privilege. Power Platform Administrator provides all necessary permissions.

### Q: What happens if my connections expire?

A: Flows will fail until connections are re-authenticated. We recommend:
- Setting up alerts for flow failures
- Scheduling periodic connection health checks
- Documenting the re-authentication process

### Q: Is the CoE Starter Kit supported by Microsoft Support?

A: The CoE Starter Kit is provided as a sample/template and is not officially supported through Microsoft Support. Issues should be reported on [GitHub](https://aka.ms/coe-starter-kit-issues). However, the underlying Power Platform features and services are fully supported.

### Q: Will Service Principal support be added in the future?

A: The CoE Starter Kit team continues to work with product teams to improve connector capabilities. Check the [GitHub issues](https://github.com/microsoft/coe-starter-kit/issues) and [Power Platform roadmap](https://learn.microsoft.com/en-us/power-platform/release-plan/) for updates.

## Summary

While the identity requirements for the CoE Starter Kit may seem concerning at first glance, they can be implemented securely by:

1. Using a dedicated service account with Power Platform Administrator role (not Global Admin)
2. Applying Conditional Access policies to restrict where the account can sign in
3. Monitoring the account for suspicious activity
4. Following security best practices for password management
5. Limiting access to the CoE environment and connections

These mitigations allow organizations to gain the benefits of the CoE Starter Kit while maintaining a strong security posture.

## Additional Resources

- [CoE Starter Kit Documentation](https://learn.microsoft.com/en-us/power-platform/guidance/coe/starter-kit)
- [CoE Starter Kit Setup Guide](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup)
- [CoE Starter Kit Limitations](https://learn.microsoft.com/en-us/power-platform/guidance/coe/limitations)
- [Power Platform Admin Center](https://admin.powerplatform.microsoft.com/)
- [Azure AD Conditional Access](https://learn.microsoft.com/en-us/azure/active-directory/conditional-access/overview)
- [GitHub Issues for CoE Starter Kit](https://github.com/microsoft/coe-starter-kit/issues)
