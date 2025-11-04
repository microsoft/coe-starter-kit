# Audit Logs Documentation Overview

This document provides an overview of the audit logs documentation created to help users troubleshoot and configure the "Admin | Audit Logs | Sync Audit Logs (V2)" flow.

## Documentation Structure

### User-Facing Documents

#### 1. [TROUBLESHOOTING-AUDIT-LOGS.md](../TROUBLESHOOTING-AUDIT-LOGS.md)
**Purpose:** Comprehensive troubleshooting guide for end users

**When to use:**
- Flow is failing and you need to diagnose the issue
- You see the "Get_Azure_Secret" error
- You need step-by-step troubleshooting instructions
- You have questions about authentication methods

**Contents:**
- Explanation of the "Get_Azure_Secret" error
- Actual root causes of failures
- Detailed troubleshooting steps
- FAQ section
- Environment variable reference

#### 2. [CenterofExcellenceCoreComponents/AUDIT-LOGS-SETUP.md](../CenterofExcellenceCoreComponents/AUDIT-LOGS-SETUP.md)
**Purpose:** Complete setup and configuration guide

**When to use:**
- Setting up audit logs for the first time
- Switching between authentication methods
- Configuring Azure AD app registration
- Understanding the flow architecture

**Contents:**
- Authentication methods comparison
- Step-by-step setup instructions
- Azure AD app registration guide
- API permissions requirements
- Environment variable configuration
- Testing and verification steps

#### 3. [QUICK-DIAGNOSIS-CHECKLIST.md](../QUICK-DIAGNOSIS-CHECKLIST.md)
**Purpose:** Quick diagnostic checklist for rapid issue identification

**When to use:**
- You need to quickly diagnose an issue
- You're supporting multiple users with similar issues
- You want a systematic approach to troubleshooting
- You need to document your troubleshooting steps

**Contents:**
- Step-by-step diagnosis checklist
- Common issue patterns
- Quick fix checklist
- When to seek additional help

### Support Team Documents

#### 4. [.github/ISSUE_TEMPLATE_RESPONSES/audit-logs-get-azure-secret-error.md](../.github/ISSUE_TEMPLATE_RESPONSES/audit-logs-get-azure-secret-error.md)
**Purpose:** Template response for GitHub issues

**When to use:**
- Responding to GitHub issues about Get_Azure_Secret errors
- Providing quick guidance to users
- Need a consistent response format

**Contents:**
- Quick response summary
- Root cause analysis
- Resolution steps
- Links to detailed documentation

#### 5. [ISSUE-RESPONSE-SUMMARY.md](../ISSUE-RESPONSE-SUMMARY.md)
**Purpose:** Internal document for support team

**When to use:**
- Understanding the issue analysis
- Preparing responses to similar issues
- Training new support team members
- Reference for issue resolution

**Contents:**
- Complete issue analysis
- Technical details about the flow
- Recommended response to users
- Follow-up actions

## Quick Reference Guide

### For End Users

**I'm seeing an error on Get_Azure_Secret:**
1. Don't worry - this is usually expected
2. Read: [TROUBLESHOOTING-AUDIT-LOGS.md](../TROUBLESHOOTING-AUDIT-LOGS.md)
3. Follow the troubleshooting steps for the ACTUAL failing action

**I'm setting up audit logs for the first time:**
1. Read: [AUDIT-LOGS-SETUP.md](../CenterofExcellenceCoreComponents/AUDIT-LOGS-SETUP.md)
2. Follow the step-by-step setup instructions
3. Test your configuration

**I need to diagnose an issue quickly:**
1. Use: [QUICK-DIAGNOSIS-CHECKLIST.md](../QUICK-DIAGNOSIS-CHECKLIST.md)
2. Work through the checklist systematically
3. Document your findings

### For Support Team

**Responding to a GitHub issue about Get_Azure_Secret:**
1. Use template: [audit-logs-get-azure-secret-error.md](../.github/ISSUE_TEMPLATE_RESPONSES/audit-logs-get-azure-secret-error.md)
2. Review: [ISSUE-RESPONSE-SUMMARY.md](../ISSUE-RESPONSE-SUMMARY.md)
3. Customize response based on specific user details

**Training new team member:**
1. Start with: [ISSUE-RESPONSE-SUMMARY.md](../ISSUE-RESPONSE-SUMMARY.md)
2. Review: [AUDIT-LOGS-SETUP.md](../CenterofExcellenceCoreComponents/AUDIT-LOGS-SETUP.md)
3. Practice with: [QUICK-DIAGNOSIS-CHECKLIST.md](../QUICK-DIAGNOSIS-CHECKLIST.md)

## Common Scenarios

### Scenario 1: User Reports Get_Azure_Secret Error

**Response:**
1. Acknowledge the report
2. Explain this is expected behavior when using text secrets
3. Ask for screenshot of the ACTUAL failing action
4. Direct to troubleshooting guide
5. Follow up on resolution

**Resources:**
- [audit-logs-get-azure-secret-error.md](../.github/ISSUE_TEMPLATE_RESPONSES/audit-logs-get-azure-secret-error.md) - Response template
- [TROUBLESHOOTING-AUDIT-LOGS.md](../TROUBLESHOOTING-AUDIT-LOGS.md) - For detailed steps

### Scenario 2: User Needs Setup Help

**Response:**
1. Verify they have prerequisites (Azure AD app registration)
2. Direct to setup guide
3. Offer to answer specific questions
4. Request feedback after setup

**Resources:**
- [AUDIT-LOGS-SETUP.md](../CenterofExcellenceCoreComponents/AUDIT-LOGS-SETUP.md) - Complete setup guide

### Scenario 3: Complex Issue Requiring Diagnosis

**Response:**
1. Request user work through diagnosis checklist
2. Review their findings
3. Identify root cause
4. Provide specific resolution steps
5. Follow up after fix

**Resources:**
- [QUICK-DIAGNOSIS-CHECKLIST.md](../QUICK-DIAGNOSIS-CHECKLIST.md) - Diagnosis tool
- [TROUBLESHOOTING-AUDIT-LOGS.md](../TROUBLESHOOTING-AUDIT-LOGS.md) - Resolution steps

## Issue Pattern Recognition

### Pattern: "Get_Azure_Secret failed" + "ListAuditLogContent Unauthorized"
**Root Cause:** Missing Office 365 Management API permissions
**Resolution:** Add ActivityFeed.Read and ActivityFeed.ReadDlp, grant admin consent
**Document:** [TROUBLESHOOTING-AUDIT-LOGS.md](../TROUBLESHOOTING-AUDIT-LOGS.md) - Step 3

### Pattern: "Get_Azure_Secret failed" + "AuditLogQuery Unauthorized"
**Root Cause:** Missing Microsoft Graph API permissions
**Resolution:** Add AuditLog.Read.All, grant admin consent
**Document:** [TROUBLESHOOTING-AUDIT-LOGS.md](../TROUBLESHOOTING-AUDIT-LOGS.md) - Step 3

### Pattern: Flow succeeds but no data collected
**Root Cause:** Time window or filter issues
**Resolution:** Check environment variables for time window settings
**Document:** [AUDIT-LOGS-SETUP.md](../CenterofExcellenceCoreComponents/AUDIT-LOGS-SETUP.md) - Performance section

### Pattern: "Invalid client secret"
**Root Cause:** Expired or incorrect secret
**Resolution:** Generate new secret, update environment variable
**Document:** [TROUBLESHOOTING-AUDIT-LOGS.md](../TROUBLESHOOTING-AUDIT-LOGS.md) - Step 2

## Maintenance

### Keeping Documentation Updated

When updating the flow or related components:
1. Review all documentation for accuracy
2. Update screenshots if UI changes
3. Add new troubleshooting scenarios as discovered
4. Update environment variable references

### Monitoring Common Issues

Track and review:
- GitHub issues with "audit logs" label
- Common patterns in support requests
- User feedback on documentation
- Resolution success rates

### Continuous Improvement

Quarterly review:
- User feedback on documentation clarity
- Most common issues not covered
- Documentation gaps
- Opportunities for automation

## Additional Resources

- [CoE Starter Kit Official Documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- [Office 365 Management APIs](https://learn.microsoft.com/office/office-365-management-api/office-365-management-apis-overview)
- [Microsoft Graph Audit Log API](https://learn.microsoft.com/graph/api/resources/azure-ad-auditlog-overview)
- [Azure AD App Registration](https://learn.microsoft.com/azure/active-directory/develop/quickstart-register-app)

## Contributing

To improve this documentation:
1. Identify gaps or unclear sections
2. Gather user feedback
3. Submit pull request with improvements
4. Include examples or screenshots where helpful

## Document History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-11-04 | Initial documentation created |
| | | - Troubleshooting guide |
| | | - Setup guide |
| | | - Quick diagnosis checklist |
| | | - Issue response template |
| | | - Documentation overview |
