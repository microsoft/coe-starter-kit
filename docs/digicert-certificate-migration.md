# DigiCert Certificate Migration Impact on CoE Starter Kit

## Summary

The CoE Starter Kit **does not have any special certificate pinning configurations or hardcoded certificate references** that would be affected by the DigiCert Global Root G1 to G2 migration scheduled for January 7, 2026.

## Analysis Details

### Certificate Configuration Check

We have conducted a comprehensive audit of the CoE Starter Kit repository to determine if there are any certificate-related configurations that might be impacted by the DigiCert certificate authority migration:

1. **No Certificate Pinning**: The CoE Starter Kit does not implement certificate pinning at the application level
2. **No Hardcoded Certificates**: No hardcoded certificate references, root CA configurations, or certificate validation logic found in the codebase
3. **No DigiCert-Specific Settings**: No DigiCert-specific configurations detected in any solution files

### What is the CoE Starter Kit?

The Center of Excellence (CoE) Starter Kit is a collection of Power Platform solutions including:
- Power Apps canvas and model-driven applications
- Power Automate flows
- Dataverse entities and business logic
- Power BI reports for analytics

### Technology Stack and Certificate Handling

The CoE Starter Kit relies on:

1. **Power Platform Infrastructure**: All HTTPS communications are handled by Microsoft's Power Platform infrastructure
2. **Microsoft-Managed Certificates**: Certificate trust chains are managed entirely by the underlying Microsoft services
3. **Standard Connectors**: Uses standard Power Platform connectors (HTTP, Office 365, SharePoint, etc.) which rely on the platform's certificate store

### Why This Migration Should Not Impact CoE Starter Kit

The DigiCert root certificate migration affects the underlying trust chain used by operating systems and browsers. Since the CoE Starter Kit:

- Does not implement custom certificate validation
- Does not pin certificates in code
- Relies entirely on Power Platform's certificate management
- Uses only Microsoft-managed infrastructure

**The certificate migration should be transparent to CoE Starter Kit users**, as Microsoft will handle the certificate updates at the platform level.

## Recommended Actions for Users

While the CoE Starter Kit itself doesn't require changes, we recommend the following for your environment:

### 1. Ensure Power Platform Service Health
- Monitor Microsoft 365 Service Health dashboard for any Power Platform updates related to certificate changes
- Review the Microsoft announcement: MC1193408 - Trust DigiCert Global Root G2 Certificate Authority in the Microsoft 365 Admin Center Message Center

### 2. Client Device Preparation
While not specific to CoE Starter Kit, ensure that:
- Windows devices are updated to support the new certificate chain
- Browsers (Edge, Chrome, Firefox) are kept up to date
- Corporate certificate stores include DigiCert Global Root G2

### 3. Custom Integrations Check
If you have created **custom extensions** to the CoE Starter Kit that:
- Make direct HTTPS calls from custom code
- Use custom connectors with certificate validation
- Implement on-premises data gateways with specific certificate configurations

Then you should review those components separately for certificate migration impacts.

### 4. On-Premises Data Gateway
If you use on-premises data gateways with the CoE Starter Kit:
- Ensure the gateway machines have updated Windows certificate stores
- Verify the gateway can establish secure connections after the migration date
- Review: [On-premises data gateway documentation](https://learn.microsoft.com/power-platform/guidance/coe/setup#on-premises-data-gateway)

## Testing Recommendations

To proactively verify your environment's readiness:

1. **Pre-Migration Testing** (Before January 7, 2026):
   - Verify all CoE Starter Kit flows execute successfully
   - Test custom connector connections
   - Validate Power BI report data refresh

2. **Post-Migration Verification** (After January 7, 2026):
   - Monitor flow run history for any connection failures
   - Check app connectivity
   - Verify data gateway connections (if applicable)

## Support and Resources

- **CoE Starter Kit Documentation**: https://learn.microsoft.com/power-platform/guidance/coe/starter-kit
- **Power Platform Service Status**: https://admin.powerplatform.microsoft.com/servicehealth
- **Report Issues**: [GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues)

## Technical Background

### Why Certificate Updates Matter

Certificate authorities occasionally update their root certificates to maintain security standards. The migration from DigiCert Global Root G1 to G2:
- Strengthens cryptographic algorithms
- Extends certificate validity periods
- Aligns with modern security best practices

### Trust Chain Hierarchy

```
DigiCert Global Root G2 (New)
└── Intermediate CA Certificates
    └── Server Certificates (e.g., *.dynamics.com, *.powerapps.com)
```

Power Platform services will present certificates signed by intermediates that chain back to DigiCert Global Root G2. Client operating systems and browsers must trust this root to establish secure connections.

## Conclusion

The CoE Starter Kit requires **no code changes or configuration updates** for the DigiCert certificate migration. The migration will be handled transparently by Microsoft's Power Platform infrastructure.

Users should focus on ensuring their client devices and any custom integrations are prepared for the certificate change following Microsoft's guidance.

---

## Document Information

- **Last Updated**: January 2026
- **Applies To**: All versions of CoE Starter Kit
- **Category**: Security, Infrastructure
- **Related Announcements**: MC1193408

## Questions?

If you have questions about this certificate migration and its impact on your CoE Starter Kit deployment, please:
1. Review the Microsoft announcement linked above
2. Check this GitHub repository for updates
3. Open a [GitHub Issue](https://github.com/microsoft/coe-starter-kit/issues/new/choose) if you encounter specific problems after the migration

---

**Note**: This document is based on analysis of the CoE Starter Kit codebase as of January 2026. Always refer to official Microsoft guidance for infrastructure-level changes.
