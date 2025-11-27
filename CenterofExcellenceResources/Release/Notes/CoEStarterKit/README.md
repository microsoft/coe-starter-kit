# CoE Starter Kit Release Notes and Documentation

This directory contains release notes, troubleshooting guides, and known issues documentation for the CoE Starter Kit.

## Quick Links

### 📖 Documentation
- **[Troubleshooting Import Errors](./TROUBLESHOOTING-IMPORT-ERRORS.md)** - Comprehensive guide for resolving solution import and upgrade errors
- **[Known Issues](./KNOWN-ISSUES.md)** - Current known issues, limitations, and workarounds
- **[Release Notes](./RELEASENOTES.md)** - Links to setup, upgrade, and customization documentation

### 🔧 Common Issues & Quick Fixes

#### Import/Upgrade Failures
If you encounter errors during solution import:
- **Error 80097376 (BadGateway)**: Wait 5-10 minutes and retry → [Details](./TROUBLESHOOTING-IMPORT-ERRORS.md#error-80097376---badgateway)
- **Error 80072031 (Status Unknown)**: Check import status, then safely retry → [Details](./TROUBLESHOOTING-IMPORT-ERRORS.md#error-80072031---operation-status-unknown)
- **General Import Issues**: See the [troubleshooting guide](./TROUBLESHOOTING-IMPORT-ERRORS.md) for step-by-step resolution

#### Setup & Configuration
- **Language Requirements**: English language pack must be enabled → [Known Issues](./KNOWN-ISSUES.md#language-pack-requirements)
- **License Requirements**: Premium licenses needed to avoid pagination issues → [Known Issues](./KNOWN-ISSUES.md#pagination-and-licensing-limitations)
- **Connection Setup**: Configure connection references after import → [Known Issues](./KNOWN-ISSUES.md#connection-references-configuration)

### 🌐 External Resources

#### Official Documentation
- [CoE Starter Kit Overview](https://docs.microsoft.com/power-platform/guidance/coe/starter-kit)
- [First-Time Setup Guide](https://docs.microsoft.com/power-platform/guidance/coe/setup)
- [Upgrade Instructions](https://docs.microsoft.com/power-platform/guidance/coe/after-setup)
- [Customization Best Practices](https://docs.microsoft.com/power-platform/guidance/coe/modify-components)

#### Community & Support
- [GitHub Repository](https://github.com/microsoft/coe-starter-kit)
- [GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues)
- [GitHub Discussions](https://github.com/microsoft/coe-starter-kit/discussions)
- [Power Platform Community Forum](https://powerusers.microsoft.com/t5/Power-Apps-Governance-and/bd-p/Admin_PowerApps)
- [Latest Releases](https://github.com/microsoft/coe-starter-kit/releases)

### 📊 Service Health
- [Microsoft 365 Service Health](https://admin.microsoft.com/servicehealth) - Check for Power Platform service issues

---

## Getting Help

### Before Opening an Issue
1. ✅ Check the [Known Issues](./KNOWN-ISSUES.md) document
2. ✅ Review the [Troubleshooting Guide](./TROUBLESHOOTING-IMPORT-ERRORS.md)
3. ✅ Search [existing GitHub issues](https://github.com/microsoft/coe-starter-kit/issues)
4. ✅ Review [official documentation](https://docs.microsoft.com/power-platform/guidance/coe/starter-kit)

### Reporting New Issues
If your issue isn't documented:
1. Use the [GitHub issue template](https://github.com/microsoft/coe-starter-kit/issues/new/choose)
2. Provide complete error details (codes, messages, screenshots)
3. Include environment information (version, region, license type)
4. List troubleshooting steps already attempted

### Support Channels
- **CoE Starter Kit Issues**: [GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues) (best-effort community support)
- **Power Platform Service Issues**: Microsoft Support (through your normal support channels)
- **Questions & Discussions**: [GitHub Discussions](https://github.com/microsoft/coe-starter-kit/discussions) or [Community Forum](https://powerusers.microsoft.com/t5/Power-Apps-Governance-and/bd-p/Admin_PowerApps)

---

## Document History

| Date | Document | Version | Changes |
|------|----------|---------|---------|
| 2025-11-19 | TROUBLESHOOTING-IMPORT-ERRORS.md | 1.0 | Initial creation - Added guidance for errors 80097376 and 80072031 |
| 2025-11-19 | KNOWN-ISSUES.md | 1.0 | Initial creation - Documented known issues and limitations |
| 2025-11-19 | README.md | 1.0 | Created this index document |

---

**Note**: The CoE Starter Kit is a best-effort, community-supported toolkit and is not covered by official Microsoft support. For platform-level issues, please contact Microsoft support through your normal channels.
