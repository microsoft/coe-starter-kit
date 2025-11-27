# Documentation Index - CoE Audit Log Components

This directory contains comprehensive documentation for setting up and troubleshooting the CoE Audit Log components.

## 📚 Documentation Files

### For End Users

| Document | Purpose | When to Use |
|----------|---------|-------------|
| **[README.md](./README.md)** | Overview, architecture, and quick start guide | First stop for understanding Audit Log components |
| **[QUICK-FIX.md](./QUICK-FIX.md)** | Fast solution for the most common error | When you see "Microsoft.PowerPlatform provider not registered" error |
| **[AZURE-KEYVAULT-SETUP.md](./AZURE-KEYVAULT-SETUP.md)** | Complete step-by-step Key Vault setup | Setting up Azure Key Vault integration from scratch |
| **[TROUBLESHOOTING.md](./TROUBLESHOOTING.md)** | Comprehensive troubleshooting guide | When encountering any setup or runtime issues |

### For Maintainers & Support Team

| Document | Purpose | When to Use |
|----------|---------|-------------|
| **[ISSUE-RESPONSE-TEMPLATE.md](./ISSUE-RESPONSE-TEMPLATE.md)** | Pre-written responses for GitHub issues | Responding to user issues on GitHub |
| **[DOCUMENTATION-INDEX.md](./DOCUMENTATION-INDEX.md)** | This file - overview of all documentation | Understanding what documentation exists and when to use it |

## 🎯 Quick Navigation by Scenario

### Scenario: User Reports Error - "Microsoft.PowerPlatform provider not registered"

1. **Quick Fix**: Direct them to [QUICK-FIX.md](./QUICK-FIX.md)
2. **Full Guide**: If they need more context, [TROUBLESHOOTING.md](./TROUBLESHOOTING.md#error-microsoftpowerplatform-provider-not-registered)
3. **Setup Guide**: For complete setup, [AZURE-KEYVAULT-SETUP.md](./AZURE-KEYVAULT-SETUP.md#1-register-microsoftpowerplatform-resource-provider)
4. **Issue Response**: Use [ISSUE-RESPONSE-TEMPLATE.md](./ISSUE-RESPONSE-TEMPLATE.md) for GitHub reply

### Scenario: User Reports Error - "Invalid client secret provided"

1. **Troubleshooting**: [TROUBLESHOOTING.md](./TROUBLESHOOTING.md#error-invalid-client-secret-provided)
2. **Setup Guide**: [AZURE-KEYVAULT-SETUP.md](./AZURE-KEYVAULT-SETUP.md#4-store-the-client-secret-in-key-vault)
3. **Issue Response**: Use [ISSUE-RESPONSE-TEMPLATE.md](./ISSUE-RESPONSE-TEMPLATE.md) for GitHub reply

### Scenario: User Reports Error - "Access denied" to Key Vault

1. **Troubleshooting**: [TROUBLESHOOTING.md](./TROUBLESHOOTING.md#error-key-vault-access-denied)
2. **Setup Guide**: [AZURE-KEYVAULT-SETUP.md](./AZURE-KEYVAULT-SETUP.md#3-configure-key-vault-access)

### Scenario: New User Setting Up Audit Logs

1. **Overview**: Start with [README.md](./README.md)
2. **Setup**: Follow [AZURE-KEYVAULT-SETUP.md](./AZURE-KEYVAULT-SETUP.md)
3. **Reference**: Keep [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) handy for any issues

### Scenario: User Reports Audit Logs Not Appearing

1. **Troubleshooting**: [TROUBLESHOOTING.md](./TROUBLESHOOTING.md#issue-audit-logs-not-appearing-in-coe-dashboard)

## 📖 Documentation Statistics

- **Total Documents**: 6 markdown files
- **Total Lines**: ~975+ lines of documentation
- **Coverage**:
  - ✅ Setup instructions
  - ✅ Troubleshooting guides
  - ✅ Quick reference cards
  - ✅ Issue response templates
  - ✅ Architecture diagrams
  - ✅ Security best practices
  - ✅ Common mistakes and solutions

## 🔗 Related Documentation

- **Official Microsoft Docs**: https://docs.microsoft.com/power-platform/guidance/coe/setup-auditlog
- **CoE Starter Kit Main README**: [../../README.md](../../README.md)
- **Audit Components README**: [../CenterofExcellenceAuditComponents/README.md](../CenterofExcellenceAuditComponents/README.md)

## 🔄 Maintenance Guidelines

### Updating Documentation

When updating these docs:

1. **Keep consistency** across all documents
2. **Update cross-references** if you change section names
3. **Test all commands** and procedures
4. **Update the "Last Updated" date** at the bottom of each document
5. **Maintain the Table of Contents** in TROUBLESHOOTING.md

### Adding New Content

If adding new troubleshooting content:

1. Add to [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) with detailed steps
2. If it's a common issue, create a quick reference in [QUICK-FIX.md](./QUICK-FIX.md)
3. Update [ISSUE-RESPONSE-TEMPLATE.md](./ISSUE-RESPONSE-TEMPLATE.md) with response template
4. Update this index with the new scenario

### Versioning

These documents apply to:
- **CoE Starter Kit**: v4.x and later
- **Last Major Update**: 2025-11-03
- **Maintained By**: CoE Starter Kit Team

## 🎓 Training Resources

### For Support Team Members

Read in this order:
1. [README.md](./README.md) - Understand the components
2. [AZURE-KEYVAULT-SETUP.md](./AZURE-KEYVAULT-SETUP.md) - Learn the setup process
3. [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) - Master troubleshooting
4. [ISSUE-RESPONSE-TEMPLATE.md](./ISSUE-RESPONSE-TEMPLATE.md) - Use for consistent responses

### For End Users

Recommended reading path:
1. Start: [README.md](./README.md)
2. Setup: [AZURE-KEYVAULT-SETUP.md](./AZURE-KEYVAULT-SETUP.md)
3. Troubleshoot: [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) (as needed)
4. Quick fixes: [QUICK-FIX.md](./QUICK-FIX.md) (for specific errors)

## 📊 Document Purpose Matrix

| Question | Document to Reference |
|----------|----------------------|
| How do I set up Key Vault? | [AZURE-KEYVAULT-SETUP.md](./AZURE-KEYVAULT-SETUP.md) |
| What is this solution? | [README.md](./README.md) |
| My flow is failing, why? | [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) |
| Quick fix for provider error? | [QUICK-FIX.md](./QUICK-FIX.md) |
| How do I respond to GitHub issues? | [ISSUE-RESPONSE-TEMPLATE.md](./ISSUE-RESPONSE-TEMPLATE.md) |
| What's the architecture? | [README.md](./README.md#architecture) |
| What are the prerequisites? | [README.md](./README.md#prerequisites) |
| How do I verify my setup? | [AZURE-KEYVAULT-SETUP.md](./AZURE-KEYVAULT-SETUP.md#6-verify-the-configuration) |
| What are common mistakes? | [AZURE-KEYVAULT-SETUP.md](./AZURE-KEYVAULT-SETUP.md#common-configuration-mistakes) |
| Security best practices? | [AZURE-KEYVAULT-SETUP.md](./AZURE-KEYVAULT-SETUP.md#security-best-practices) |

## 🏷️ Document Tags

### By Audience
- **End Users**: README.md, AZURE-KEYVAULT-SETUP.md, QUICK-FIX.md, TROUBLESHOOTING.md
- **Support Team**: ISSUE-RESPONSE-TEMPLATE.md, DOCUMENTATION-INDEX.md
- **Administrators**: AZURE-KEYVAULT-SETUP.md, TROUBLESHOOTING.md
- **Developers**: README.md (Architecture section)

### By Purpose
- **Reference**: README.md, DOCUMENTATION-INDEX.md
- **Setup**: AZURE-KEYVAULT-SETUP.md
- **Troubleshooting**: TROUBLESHOOTING.md, QUICK-FIX.md
- **Support**: ISSUE-RESPONSE-TEMPLATE.md

### By Experience Level
- **Beginner**: README.md, QUICK-FIX.md
- **Intermediate**: AZURE-KEYVAULT-SETUP.md, TROUBLESHOOTING.md
- **Advanced**: All documents for comprehensive understanding

## 📝 Feedback

If you have suggestions for improving this documentation:

1. Open an issue at https://github.com/microsoft/coe-starter-kit/issues
2. Label it with `documentation`
3. Reference the specific document that needs improvement
4. Provide specific suggestions or examples

---

**Index Version**: 1.0  
**Last Updated**: 2025-11-03  
**Maintained By**: CoE Starter Kit Team  
**Next Review Date**: 2025-12-03 (or when new version releases)
