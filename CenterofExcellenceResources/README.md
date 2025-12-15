# CoE Starter Kit - How-To Guides and Resources

This directory contains supplementary documentation, guides, and resources for the Center of Excellence (CoE) Starter Kit.

## Quick Start Guides

### Customizing Maker Notifications

Learn how to customize and filter maker notification emails in the Governance solution:

- **[Overview: Filtering Maker Notifications](./FilteringMakerNotifications.md)**  
  Comprehensive guide covering all approaches to filtering notifications, including by environment, user, and other criteria.

- **[How-To: Restrict Notifications to Specific Environments](./HowTo-RestrictNotificationsToEnvironment.md)**  
  Step-by-step guide to configure environment-based filtering for maker notifications. Ideal for excluding certain environments or targeting specific ones.

- **[How-To: Restrict Notifications to Pilot Users](./HowTo-RestrictNotificationsToPilotUsers.md)**  
  Detailed instructions for setting up pilot testing with a select group of users. Perfect for phased rollouts and testing governance workflows.

## About These Guides

These how-to guides provide practical, step-by-step instructions for common customization scenarios that aren't covered in the core CoE Starter Kit setup documentation.

### What You'll Find

- **Detailed Steps**: Clear, numbered instructions with examples
- **Multiple Approaches**: Different methods to solve the same problem
- **Code Samples**: Ready-to-use expressions and configurations  
- **Troubleshooting**: Common issues and solutions
- **Best Practices**: Recommendations from the community

### When to Use These Guides

- You need to customize the CoE Starter Kit beyond default configuration
- You want to pilot test governance features with a subset of users
- You need to exclude certain environments from notifications
- You're implementing a phased rollout of CoE features

## Official Documentation

These guides supplement the official Microsoft documentation:

- [CoE Starter Kit Overview](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- [Setup Instructions](https://learn.microsoft.com/power-platform/guidance/coe/setup)
- [Governance Components](https://learn.microsoft.com/power-platform/guidance/coe/governance-components)
- [Core Components](https://learn.microsoft.com/power-platform/guidance/coe/core-components)

## Contributing

Found an issue or have a suggestion? 

- [Report an issue](https://github.com/microsoft/coe-starter-kit/issues)
- [Submit a question](https://github.com/microsoft/coe-starter-kit/issues/new/choose)
- [Contribute improvements](../../HOW_TO_CONTRIBUTE.md)

## Additional Resources

### Release Information

- [Release Notes](./Release/Notes/) - Detailed release notes for all components
- [Latest Release](https://github.com/microsoft/coe-starter-kit/releases) - Download the latest version

### Community Resources

- [Office Hours](./OfficeHours/OFFICEHOURS.md) - Schedule and recordings
- [Power Platform Community Forum](https://powerusers.microsoft.com/t5/Power-Apps-Governance-and/bd-p/Admin_PowerApps)
- [CoE Starter Kit Wiki](https://github.com/microsoft/coe-starter-kit/wiki)

## Support

The CoE Starter Kit is provided as-is. For support:

1. **Check the Documentation**: Start with the official Microsoft docs and these guides
2. **Search GitHub Issues**: Your question may already be answered
3. **Ask the Community**: Use the community forum for general questions
4. **Report Bugs**: File issues on GitHub for bugs or feature requests

### What's Supported

- ✅ Questions about setup and configuration
- ✅ Bug reports with clear reproduction steps
- ✅ Feature requests and suggestions
- ✅ Documentation improvements

### What's Not Supported

- ❌ Custom development unrelated to the CoE Starter Kit
- ❌ General Power Platform questions (use the community forum)
- ❌ Support for heavily modified/forked versions
- ❌ SLA or guaranteed response times

## Important Notes

### Customization Impact

When you customize CoE Starter Kit components:

- ⚠️ **Upgrades**: Your modifications may be overwritten during upgrades
- ⚠️ **Support**: Custom code is your responsibility to maintain
- ⚠️ **Testing**: Always test in non-production environments first
- ⚠️ **Documentation**: Document your changes for future reference

### Best Practices

- Export modified flows/apps to a separate solution
- Keep track of customizations for reapplication after upgrades
- Test thoroughly before deploying to production
- Review upgrade notes for breaking changes
- Maintain separate environment for testing new versions

## Quick Links

| Resource | Description | Link |
|----------|-------------|------|
| GitHub Repository | Source code and issues | [microsoft/coe-starter-kit](https://github.com/microsoft/coe-starter-kit) |
| Microsoft Docs | Official documentation | [learn.microsoft.com](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit) |
| Releases | Download solutions | [Releases](https://github.com/microsoft/coe-starter-kit/releases) |
| Community Forum | Ask questions | [Power Platform Community](https://powerusers.microsoft.com/) |
| Office Hours | Live support sessions | [Schedule](./OfficeHours/OFFICEHOURS.md) |

## Version Information

These guides are maintained alongside the CoE Starter Kit and are updated with each major release.

- **Current Documentation Version**: Aligned with CoE Starter Kit v3.x
- **Last Major Update**: December 2024
- **Compatibility**: CoE Starter Kit v3.0 and later

Check the "Last Updated" date in each guide for specific version information.

---

**Feedback Welcome**: If you find these guides helpful or have suggestions for improvement, please let us know by [opening an issue](https://github.com/microsoft/coe-starter-kit/issues/new/choose).
