# CoE Starter Kit Knowledge Base

This directory contains supplementary documentation, troubleshooting guides, and common response templates for the CoE Starter Kit.

## Documents in This Directory

### [COE-Kit-Common GitHub Responses.md](./COE-Kit-Common%20GitHub%20Responses.md)
A comprehensive playbook containing:
- Standard responses for common issues
- Known product limitations and workarounds
- Best practices for setup and configuration
- Decision matrices for feature selection

**When to use**: Reference this document when responding to GitHub issues, answering user questions, or troubleshooting common problems.

### [Data-Export-V2-Status.md](./Data-Export-V2-Status.md)
Detailed information about the Data Export V2 feature:
- Current availability status (Not Yet Available)
- Why the option appears greyed out in Setup Wizard
- Recommended workaround (use Cloud Flows method)
- FAQ and troubleshooting steps
- Timeline and how to stay informed

**When to use**: Reference this document when users report the Data Export option being greyed out or ask about Data Export V2 availability.

## Quick Links

### Common Issues

| Issue | Document Section | Quick Answer |
|-------|-----------------|--------------|
| Data Export option greyed out | [Data Export V2 Status](./Data-Export-V2-Status.md) | Use Cloud Flows method - Data Export V2 not yet available |
| Should I use BYODL? | [COE-Kit-Common GitHub Responses.md](./COE-Kit-Common%20GitHub%20Responses.md#byodl-bring-your-own-data-lake) | No - BYODL is not recommended, use Cloud Flows |
| Which inventory method to choose? | [COE-Kit-Common GitHub Responses.md](./COE-Kit-Common%20GitHub%20Responses.md#choosing-the-right-method) | Cloud Flows (recommended for all scenarios) |

### External Resources

- **Official Documentation**: https://learn.microsoft.com/en-us/power-platform/guidance/coe/starter-kit
- **Setup Guide**: https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup-core-components
- **GitHub Repository**: https://github.com/microsoft/coe-starter-kit
- **GitHub Issues**: https://github.com/microsoft/coe-starter-kit/issues
- **GitHub Releases**: https://github.com/microsoft/coe-starter-kit/releases

## Contributing

To add or update documentation in this directory:

1. **Identify the need**: 
   - New common issue discovered
   - Product feature status change
   - Best practice update

2. **Create or update document**:
   - Use clear, concise language
   - Include step-by-step instructions
   - Add links to official Microsoft documentation
   - Provide standard response templates where applicable

3. **Submit pull request**:
   - Describe the change
   - Reference any related GitHub issues
   - Tag relevant maintainers for review

## Document Maintenance

### When to Update

These documents should be updated when:
- ✅ Product features become available (e.g., Data Export V2 GA)
- ✅ New common issues are identified with solutions
- ✅ Microsoft releases significant updates to Power Platform or CoE Starter Kit
- ✅ Best practices or recommendations change
- ✅ Links or external references become outdated

### Review Schedule

- **Quarterly**: Review all documents for accuracy
- **After major releases**: Update version references and new features
- **As needed**: Update immediately for critical issues or changes

## Contact

For questions about these documents or suggestions for improvements:
- Open a GitHub issue: https://github.com/microsoft/coe-starter-kit/issues
- Tag the issue with `documentation` label
- Provide specific feedback or suggestions

---

*This knowledge base is maintained by the CoE Starter Kit community and maintainers.*
*Last Updated: December 2025*
