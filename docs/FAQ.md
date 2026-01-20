# CoE Starter Kit - Frequently Asked Questions (FAQ)

This document addresses common questions about the Microsoft Power Platform Center of Excellence (CoE) Starter Kit.

## General Questions

### Is the CoE Starter Kit being retired or deprecated?

**No.** The CoE Starter Kit is **not** being retired. It continues to be actively developed and maintained by Microsoft.

There may be confusion due to:
- **Office Hours being paused**: The monthly CoE Starter Kit Office Hours sessions are currently on pause. This is a temporary pause of the community calls, **not** a retirement of the toolkit itself.
- **Misinformation**: Occasional social media posts or third-party sources may incorrectly state that the CoE Starter Kit is being retired. Always refer to official Microsoft sources for accurate information.

**Evidence of active development:**
- Regular releases continue to be published (see [Releases](https://github.com/microsoft/coe-starter-kit/releases))
- The GitHub repository is actively maintained with ongoing bug fixes and feature enhancements
- Official Microsoft documentation is kept up-to-date at [Microsoft Learn](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- The product roadmap shows future planned features and improvements

**How to verify the current status:**
- Check the [latest release](https://github.com/microsoft/coe-starter-kit/releases/latest) date
- Review [open milestones](https://github.com/microsoft/coe-starter-kit/milestones?state=open) for upcoming features
- Monitor this GitHub repository for commits and pull requests

### What is the support model for the CoE Starter Kit?

The CoE Starter Kit is provided as a **best-effort, community-supported** toolkit:
- **Not covered by Microsoft product support SLAs**: The CoE Starter Kit is provided as-is and is not covered under Microsoft's standard product support agreements
- **GitHub-based support**: Issues, questions, and feature requests should be raised via [GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues)
- **Community-driven**: The Microsoft team and community members actively respond to issues and contribute improvements
- **No guaranteed response times**: While the team makes best efforts to respond, there are no SLA guarantees

### How can I stay informed about CoE Starter Kit updates?

1. **Subscribe to releases**: 
   - Click "Watch" on this repository
   - Select "Custom" > "Releases" to get notified of new versions
2. **Monitor milestones**: Check [open milestones](https://github.com/microsoft/coe-starter-kit/milestones?state=open) for planned features
3. **Read release notes**: Review [release notes](https://github.com/microsoft/coe-starter-kit/releases) for details on new features and bug fixes
4. **Follow official documentation**: Bookmark [Microsoft Learn - CoE Starter Kit](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)

## Technical Questions

### What are the prerequisites for installing the CoE Starter Kit?

Key prerequisites include:
- **Environment**: A dedicated Power Platform environment (production environment recommended for production use)
- **Licensing**: Appropriate Power Apps and Power Automate licenses (Per User or Per App licenses recommended)
- **Permissions**: Global Admin or Power Platform Admin permissions for initial setup
- **Language pack**: English language pack must be enabled in the environment
- **Data storage**: Dataverse database in the environment

For complete setup instructions, see: https://learn.microsoft.com/power-platform/guidance/coe/setup

### Is BYODL (Bring Your Own Data Lake) still supported?

**BYODL is no longer recommended** for new implementations:
- Microsoft is moving toward Fabric-based solutions for data lake integration
- Existing BYODL setups can continue to be used
- Future enhancements will focus on Fabric integration rather than BYODL
- New customers should avoid setting up BYODL and wait for Fabric-based guidance

### Why do my inventory flows take a long time or fail?

Common causes and solutions:
- **Tenant size**: Large tenants may take several hours for initial inventory runs - this is expected
- **Licensing issues**: Insufficient licenses on the service account can cause pagination limits and failures
  - Solution: Ensure the service account has a Power Apps Per User or Power Apps Per App license
- **API throttling**: Power Platform APIs have rate limits that may slow down inventory collection
  - Solution: Adjust flow run frequency and batch sizes as documented
- **First run**: Initial inventory runs always take longer than subsequent incremental runs

### Can I customize the CoE Starter Kit?

**Yes**, the CoE Starter Kit is designed to be customized:
- Treat it as a template or starting point for your organization's needs
- Follow best practices for customization: https://learn.microsoft.com/power-platform/guidance/coe/modify-components
- **Important**: Remove unmanaged layers to receive automatic updates from new releases
- Test customizations in a development environment before deploying to production

### What languages are supported?

**English only**. The CoE Starter Kit is currently localized for English only.
- Your Power Platform environment must have the English language pack enabled
- Using non-English environments may cause display issues or errors

## Getting Help

### Where should I ask questions or report issues?

- **Questions**: Use the [Question issue template](https://github.com/microsoft/coe-starter-kit/issues/new/choose)
- **Bugs**: Use the appropriate bug report template for your component
- **Feature requests**: Use the feature request template
- **General Power Platform governance questions** (not CoE Starter Kit-specific): Use the [Power Apps Community forum](https://powerusers.microsoft.com/t5/Power-Apps-Governance-and/bd-p/Admin_PowerApps)

### What information should I provide when reporting an issue?

To help us resolve issues efficiently, please provide:
- Solution name and version you're using
- Specific app or flow experiencing the issue
- Method used for inventory/telemetry collection
- Steps to reproduce the issue
- Expected vs. actual behavior
- Screenshots or error messages (if applicable)
- Any other relevant context

## Additional Resources

- **Official documentation**: https://learn.microsoft.com/power-platform/guidance/coe/starter-kit
- **Setup instructions**: https://learn.microsoft.com/power-platform/guidance/coe/setup
- **Upgrade guide**: https://learn.microsoft.com/power-platform/guidance/coe/after-setup
- **ALM Accelerator**: https://learn.microsoft.com/power-platform/guidance/coe/setup-almacceleratorpowerplatform-cli
- **Common responses**: [docs/coe-knowledge/COE-Kit-Common-GitHub-Responses.md](docs/coe-knowledge/COE-Kit-Common-GitHub-Responses.md)

---

*Last updated: January 2026*

*Have a question that's not answered here? [Open a question issue](https://github.com/microsoft/coe-starter-kit/issues/new/choose) and help us improve this FAQ.*
