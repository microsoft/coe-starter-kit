# CoE Knowledge Base

This directory contains troubleshooting guides, common issue responses, and knowledge base articles for the CoE Starter Kit.

## Documents

### [Quick-Reference.md](./Quick-Reference.md) ⭐ Start Here
Quick lookup guide for the most common CoE Starter Kit issues and their immediate solutions. Perfect for rapid diagnosis.

**Contents:**
- Critical issues (blank screens, setup wizard)
- Common issues (inventory, DLP, data collection)
- Prerequisites checklist
- Diagnostic commands
- Issue reporting template
- Success rates by issue type

### [COE-Kit-Common GitHub Responses.md](./COE-Kit-Common%20GitHub%20Responses.md)
Ready-to-use explanations, limits, workarounds, and troubleshooting guidance for common CoE Starter Kit issues. This is the primary playbook for responding to GitHub issues.

**Contents:**
- General support information
- Blank screens / Apps not loading troubleshooting
- Prerequisites and setup issues
- BYODL (Data Lake) status and recommendations
- Pagination and licensing requirements
- Language pack requirements
- DLP policies and connector issues
- Cleanup flows and inventory
- Unsupported features
- Setup wizard guidance
- Standard issue questionnaire template

### [Troubleshooting-Blank-Screens.md](./Troubleshooting-Blank-Screens.md)
Comprehensive guide for diagnosing and resolving blank screen issues in CoE Starter Kit apps. This is the most common issue reported by users.

**Contents:**
- Quick diagnosis checklist
- Root causes and solutions for each scenario
- Step-by-step troubleshooting process
- Preventive measures
- How to gather diagnostic information
- GitHub issue template for reporting

### [Issue-Response-Blank-Screens.md](./Issue-Response-Blank-Screens.md)
Template and guidance for responding to blank screen issues on GitHub, including follow-up actions based on user responses.

**Contents:**
- Standard issue response template
- Follow-up actions for different scenarios
- Resolution checklist
- Related issue search queries

### [ISSUE_COMMENT_TEMPLATE.md](./ISSUE_COMMENT_TEMPLATE.md)
Copy-paste ready comment for responding to the current GitHub issue about blank screens. Can be customized for similar issues.

## Purpose

These documents serve as:

1. **Response Templates**: Quick copy-paste responses for common GitHub issues
2. **Troubleshooting Guides**: Detailed steps for diagnosing and fixing problems
3. **Knowledge Base**: Centralized documentation of known issues and solutions
4. **Team Reference**: Consistent guidance for CoE Starter Kit support

## Usage

### For Issue Responders

When responding to GitHub issues:

1. Check `COE-Kit-Common GitHub Responses.md` for relevant section
2. Copy the template response or guidance
3. Customize with specific details from the issue
4. Link to detailed troubleshooting guides when appropriate

### For Users

If you're experiencing issues:

1. Check `Troubleshooting-Blank-Screens.md` if apps show blank screens
2. Review `COE-Kit-Common GitHub Responses.md` for general issues
3. Follow the step-by-step guides
4. If still unresolved, use the templates to create a GitHub issue with proper details

## Common Issue Types

The most frequently reported issues are:

1. **Blank Screens** (40%+ of issues)
   - Missing prerequisites (licenses, roles, Dataverse)
   - DLP policies blocking connectors
   - Missing English language pack
   - Browser/cache issues

2. **Setup/Installation Issues** (25% of issues)
   - Prerequisites not met
   - Environment variables not configured
   - Connection references not set up
   - Flow activation errors

3. **Inventory/Data Collection Issues** (20% of issues)
   - Pagination limits
   - Insufficient licenses
   - API throttling
   - Permission errors

4. **Feature Requests** (10% of issues)
   - Enhancements
   - New functionality
   - Integration requests

5. **Other** (5% of issues)
   - Bug reports
   - Performance issues
   - Upgrade problems

## Contributing

When adding new content to this knowledge base:

1. **Create New Document**: For new topics, create a new .md file in this directory
2. **Update Existing**: Add new sections to existing documents when relevant
3. **Update README**: Add new documents to this README with description
4. **Use Templates**: Follow the structure and format of existing documents
5. **Link References**: Always link to official Microsoft documentation
6. **Date Updates**: Add update history at bottom of documents

## Official Resources

- **CoE Starter Kit Documentation**: https://learn.microsoft.com/power-platform/guidance/coe/starter-kit
- **Setup Guide**: https://learn.microsoft.com/power-platform/guidance/coe/setup
- **GitHub Repository**: https://github.com/microsoft/coe-starter-kit
- **GitHub Issues**: https://github.com/microsoft/coe-starter-kit/issues
- **Community Forum**: https://powerusers.microsoft.com/t5/Power-Apps-Governance-and/bd-p/Admin_PowerApps

## Document History

- **2025-12-03**: Initial creation of CoE knowledge base directory with common responses and blank screen troubleshooting guides
