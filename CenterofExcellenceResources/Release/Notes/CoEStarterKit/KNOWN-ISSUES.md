# Known Issues - CoE Starter Kit

This document tracks known issues, limitations, and workarounds for the CoE Starter Kit.

## Import and Upgrade Issues

### Transient Import Errors During Upgrade

**Affected Versions**: All versions  
**Components**: Core Components, Audit Components, Nurture Components  
**Severity**: Medium  
**Status**: By Design (Service-level transient errors)

#### Description
Users may experience transient errors during solution import or upgrade operations, particularly in production environments. Common error codes include:
- **80097376**: BadGateway error during flow import
- **80072031**: Operation completed without reporting status

#### Impact
- Solution import may fail on first attempt
- Requires manual retry of import operation
- Can cause delays in production upgrades

#### Workaround
1. Wait 5-10 minutes and retry the import
2. Verify service health at [https://admin.microsoft.com/servicehealth](https://admin.microsoft.com/servicehealth)
3. Import during off-peak hours to reduce likelihood
4. Delete partially imported solution before retrying

#### Related Documentation
- [Troubleshooting Import Errors](./TROUBLESHOOTING-IMPORT-ERRORS.md)
- [Official Upgrade Guide](https://docs.microsoft.com/power-platform/guidance/coe/after-setup)

---

### DLP Flow Import Failures

**Affected Versions**: 4.47+  
**Components**: Core Components (DLP-related flows)  
**Severity**: Low  
**Status**: Transient

#### Description
Flows related to DLP Impact Analysis (e.g., "DLP Request | Sync Policy to Dataverse (Child)") may fail during import with BadGateway errors.

#### Impact
- DLP features may not be immediately available after import
- Does not affect core inventory functionality
- Can be resolved with retry

#### Workaround
1. Retry the solution import after waiting
2. If you don't use DLP features, you can disable these flows after import
3. Ensure Power Platform for Admins connector is properly configured

---

## Setup and Configuration Issues

### Language Pack Requirements

**Affected Versions**: All versions  
**Components**: All  
**Severity**: High  
**Status**: By Design

#### Description
The CoE Starter Kit is only available in English and requires the English language pack to be enabled in the target environment.

#### Impact
- Import may fail if English is not available
- UI elements may not display correctly
- Flows and apps may not function properly

#### Workaround
1. Ensure English language pack is enabled in the environment
2. Set English as the base language for the environment
3. See [Language Support Documentation](https://docs.microsoft.com/power-platform/guidance/coe/setup#language-support)

---

### Pagination and Licensing Limitations

**Affected Versions**: All versions  
**Components**: Core Components (Inventory flows)  
**Severity**: High  
**Status**: By Design

#### Description
Trial licenses or insufficient license profiles will encounter pagination limits when running inventory flows, preventing complete inventory collection.

#### Impact
- Incomplete inventory data
- Missing apps, flows, or other resources
- Pagination errors in flow run history

#### Workaround
1. Ensure the account running inventory flows has a Premium Power Platform license
2. Validate license adequacy using the license check flow
3. Avoid using trial licenses for production CoE implementations
4. See [Licensing Requirements](https://docs.microsoft.com/power-platform/guidance/coe/setup#licensing-requirements)

---

### Bring Your Own Data Lake (BYODL) - Deprecated

**Affected Versions**: All versions  
**Components**: Audit Components (BYODL integration)  
**Severity**: Medium  
**Status**: No longer recommended

#### Description
The Bring Your Own Data Lake (BYODL) integration is no longer recommended for new implementations. Microsoft is moving towards Microsoft Fabric integration.

#### Impact
- BYODL setup may encounter issues
- Limited support for BYODL-related problems
- Future updates may not include BYODL enhancements

#### Recommendation
1. For new implementations, wait for Fabric integration guidance
2. For existing BYODL implementations, continue using but plan for migration
3. Do not invest in new BYODL setups
4. See [Data Export Options](https://docs.microsoft.com/power-platform/guidance/coe/setup-auditlogs)

---

## Flow and App Issues

### Cleanup Flows - Long Running Operations

**Affected Versions**: All versions  
**Components**: Core Components (Cleanup flows)  
**Severity**: Low  
**Status**: By Design

#### Description
Cleanup flows (e.g., "Admin | Compliance detail request") can take significant time to complete, especially in large tenants.

#### Impact
- Flows may run for hours
- May appear to be stuck
- Can time out in very large environments

#### Workaround
1. Allow flows sufficient time to complete (24+ hours for large tenants)
2. Monitor flow run history for progress
3. Consider running cleanup flows during off-peak hours
4. For very large tenants, consider batching cleanup operations

---

### Connection References Configuration

**Affected Versions**: All versions  
**Components**: All  
**Severity**: High  
**Status**: By Design

#### Description
After import, connection references must be manually configured before flows will run successfully.

#### Impact
- Flows remain in "Off" state until connections are configured
- Apps cannot connect to data sources
- Features will not work until setup is complete

#### Workaround
1. Follow the setup wizard to configure all connection references
2. Ensure the account used has appropriate permissions
3. Test connections after configuration
4. See [Setup Instructions](https://docs.microsoft.com/power-platform/guidance/coe/setup)

---

## Unmanaged Customizations

### Unmanaged Layers Block Updates

**Affected Versions**: All versions  
**Components**: All  
**Severity**: High  
**Status**: By Design

#### Description
If you create unmanaged customizations to CoE Starter Kit components, you will not receive updates to those components in future releases.

#### Impact
- Customized components won't update with new versions
- Bug fixes won't be applied to customized components
- May cause conflicts during upgrade

#### Recommendation
1. Avoid direct modifications to managed solution components
2. Use proper extensibility patterns (separate solutions)
3. Remove unmanaged layers before upgrading
4. Document all customizations
5. See [Customization Best Practices](https://docs.microsoft.com/power-platform/guidance/coe/modify-components)

---

## Support and Community

### CoE Starter Kit is Not Officially Supported

**Affected Versions**: All versions  
**Components**: All  
**Severity**: Info  
**Status**: By Design

#### Description
The CoE Starter Kit is provided as best-effort, community-supported toolkit and is not covered by official Microsoft support agreements.

#### Impact
- No SLA for issue resolution
- Support is provided via GitHub community
- Issues must be reported on GitHub, not through Microsoft support

#### Recommendation
1. For toolkit issues, create an issue on [GitHub](https://github.com/microsoft/coe-starter-kit/issues)
2. Search existing issues before creating new ones
3. For Power Platform service issues, contact Microsoft support
4. Participate in the community to help others

---

## Environment-Specific Issues

### Multi-Geo Tenant Considerations

**Affected Versions**: All versions  
**Components**: Core Components (Inventory)  
**Severity**: Medium  
**Status**: By Design

#### Description
In multi-geo tenants, inventory collection may require special configuration to discover all environments across regions.

#### Impact
- Environments in other regions may not be inventoried
- Incomplete tenant-wide visibility
- Regional-specific connector issues

#### Workaround
1. Ensure the service account has permissions across all regions
2. Configure Power Platform environment variable correctly for your region
3. Review [Multi-Geo Setup Guidance](https://docs.microsoft.com/power-platform/guidance/coe/setup#multi-geo)

---

### DLP Policy Conflicts

**Affected Versions**: All versions  
**Components**: All  
**Severity**: High  
**Status**: Environmental

#### Description
Existing DLP policies in the target environment can prevent CoE Starter Kit components from functioning if required connectors are blocked.

#### Impact
- Flows cannot run if connectors are blocked
- Import may succeed but functionality is broken
- Apps cannot connect to data sources

#### Workaround
1. Review DLP policies before installing CoE Starter Kit
2. Create exception for the CoE environment if needed
3. Ensure required connectors are allowed:
   - Dataverse
   - Power Platform for Admins
   - Office 365 Users
   - Office 365 Outlook
   - HTTP (for some scenarios)
4. See [DLP Configuration Guide](https://docs.microsoft.com/power-platform/guidance/coe/setup#dlp-policy-considerations)

---

## How to Report New Issues

If you encounter an issue not listed here:

1. **Search Existing Issues**: Check [GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues) first
2. **Gather Information**:
   - Error messages and codes
   - Solution version
   - Environment details
   - Steps to reproduce
   - Screenshots
3. **Create New Issue**: Use the [issue template](https://github.com/microsoft/coe-starter-kit/issues/new/choose)
4. **Provide Details**: More information helps faster resolution

## Additional Resources

- [Troubleshooting Import Errors](./TROUBLESHOOTING-IMPORT-ERRORS.md)
- [CoE Starter Kit Documentation](https://docs.microsoft.com/power-platform/guidance/coe/starter-kit)
- [Setup Instructions](https://docs.microsoft.com/power-platform/guidance/coe/setup)
- [Community Forum](https://powerusers.microsoft.com/t5/Power-Apps-Governance-and/bd-p/Admin_PowerApps)

---

**Last Updated**: 2025-11-19  
**Document Version**: 1.0
