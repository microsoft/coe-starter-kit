# GitHub Issue Response Templates

This document contains standardized templates for responding to common issues and questions about the CoE Starter Kit.

## Available Templates

1. **[Inactivity Notification Emails](../Documentation/ISSUE_RESPONSE_INACTIVITY_NOTIFICATIONS.md)** - For questions about repeated emails, manager notifications, and Archive Approval lifecycle
2. **Sovereign Cloud / GCC High Questions** - For deployment and upgrade questions in sovereign clouds
3. **Azure DevOps Email Notifications** - For unexpected notifications after Core Components upgrades

---

# Sovereign Cloud / GCC High Questions

This template can be used when responding to issues related to sovereign cloud deployments, GCC High upgrades, or connector availability.

---

## Template: GCC High Upgrade Availability

**Use when:** Users ask about upgrading CoE Starter Kit in GCC High or sovereign clouds

**Response:**

Thank you for your question about upgrading the CoE Starter Kit in GCC High!

### Good News! 

With the availability of the **Power Platform for Admins V2** connector in GCC High tenants, you can now upgrade to recent versions of the CoE Starter Kit.

### Quick Answer for Your Situation

Since you're currently on:
- Core Components: v4.42
- Governance: v3.25

And it's been over a year since your last upgrade, here's what I recommend:

1. **Verify Connector Availability**: Confirm the "Power Platform for Admins V2" connector is enabled in your GCC High tenant
2. **Review New Documentation**: We've created comprehensive guides specifically for sovereign cloud upgrades:
   - [Sovereign Cloud Support Guide](../docs/sovereign-cloud-support.md)
   - [GCC High Upgrade Quick Start](../docs/gcc-high-upgrade-quickstart.md)

### Upgrade Path

For your scenario, a **direct upgrade to the latest version** is recommended:

✅ The major blocker (V2 connector availability) is now resolved  
✅ You can skip intermediate versions  
✅ Plan for 4-8 hours of upgrade time including testing  

**Key Steps:**
1. Back up your current configurations
2. Download the latest release from [Releases](https://github.com/microsoft/coe-starter-kit/releases)
3. Import solutions in order (Core → Governance → Other)
4. Update connections to use Power Platform for Admins V2
5. Trigger initial inventory sync

### About Issue #8835

Issue #8835 was tracking the connector availability in GCC High. It was closed because the blocking issue has been resolved - the connector is now available. You can proceed with upgrades.

### Next Steps

1. Review the [GCC High Upgrade Quick Start](../docs/gcc-high-upgrade-quickstart.md) guide
2. Verify the V2 connector is available in your tenant
3. Follow the upgrade steps in the documentation
4. If you encounter specific issues during upgrade, please create a new issue with:
   - Error messages
   - Flow run history screenshots
   - Steps you've already attempted

Let us know if you have any specific questions about the upgrade process!

---

## Template: Sovereign Cloud Feature Availability

**Use when:** Users ask if specific features work in sovereign clouds

**Response:**

Thank you for asking about [FEATURE] availability in [SOVEREIGN CLOUD]!

### General Sovereign Cloud Status

Sovereign clouds (GCC, GCC High, DoD) typically receive Power Platform features 2-12 months after commercial cloud deployment.

### For Your Specific Question

[Customize based on feature being asked about]

Common scenarios:

**If feature is available:**
✅ [FEATURE] is available in [SOVEREIGN CLOUD]
✅ Configuration steps: [link or brief description]
✅ Known limitations: [if any]

**If feature is not available:**
⏳ [FEATURE] is not yet available in [SOVEREIGN CLOUD]  
📅 Expected timeline: [if known]  
🔄 Workaround: [if available]

**If status is unknown:**
❓ Feature availability status is unclear for [SOVEREIGN CLOUD]  
✅ Check: [Power Platform release planner link]  
✅ Verify: Test in your environment directly

### Resources

- [Sovereign Cloud Support Documentation](../docs/sovereign-cloud-support.md)
- [Power Platform US Government Docs](https://learn.microsoft.com/power-platform/admin/powerapps-us-government)

---

## Template: Cannot Upgrade / Missing Connector

**Use when:** Users report they cannot upgrade due to missing connectors

**Response:**

Thank you for reporting this issue!

### Diagnosis

It sounds like you may be experiencing connector availability issues. Let's troubleshoot:

#### Step 1: Verify Connector Availability

1. Go to Power Automate in your [CLOUD TYPE] tenant
2. Navigate to Data → Connectors
3. Search for "Power Platform for Admins V2"
4. Confirm it appears in the list

#### Step 2: Check Tenant Type

Confirm your tenant type:
- Is this GCC, GCC High, DoD, or another sovereign cloud?
- What region is your tenant in?

#### Step 3: Admin Center Access

- Can you access the Power Platform Admin Center for your cloud?
- Do you see the new admin center interface or the classic?

### Expected Status by Cloud Type

| Cloud Type | V2 Connector Status | Notes |
|------------|-------------------|--------|
| Commercial | ✅ Available | Fully supported |
| GCC | ✅ Available | Check tenant settings |
| GCC High | ✅ Available (2026+) | Recent availability |
| DoD | ⏳ Limited | Check with tenant admin |

### Next Steps

Please provide:
1. Your specific cloud type (GCC/GCC High/DoD/Other)
2. Screenshot of connector search results
3. Current CoE Starter Kit version
4. Error messages you're seeing

This will help us provide more specific guidance.

### Resources

- [Sovereign Cloud Support Guide](../docs/sovereign-cloud-support.md)
- [Troubleshooting Section](../docs/sovereign-cloud-support.md#troubleshooting-common-issues)

---

## Template: Closing Issue - Question Answered

**Use when:** Closing an issue after providing guidance

**Response:**

I'm closing this issue as the question has been answered. 

### Summary

[Brief 2-3 sentence summary of the resolution]

### Key Resources Provided

- [Link to relevant documentation]
- [Link to upgrade guide if applicable]
- [Any other relevant links]

### If You Need More Help

If you encounter specific technical issues while following this guidance:
1. Try the troubleshooting steps in the [documentation](../docs/sovereign-cloud-support.md)
2. Search [existing issues](https://github.com/microsoft/coe-starter-kit/issues)
3. Open a new issue with specific error details

Thank you for using the CoE Starter Kit! 🎉

---

## Notes for Responders

### Key Points to Remember

1. **Be empathetic**: Sovereign cloud users often face delays and limitations
2. **Be specific**: Provide exact connector names, versions, and cloud types
3. **Link to docs**: Always reference the sovereign cloud documentation
4. **Manage expectations**: Be clear about support boundaries (community vs. Microsoft Support)
5. **Follow up**: If you're unsure, say so and ask for clarification

### Common Questions to Ask

When gathering more information:
- What specific cloud type? (GCC/GCC High/DoD/National cloud)
- What version are you currently on?
- What error messages are you seeing?
- Have you verified connector availability?
- How long has it been since your last upgrade?
- Do you have extensive customizations?

### Escalation Criteria

Create or reference separate issues for:
- Actual bugs in sovereign cloud deployments
- Feature requests for sovereign cloud support
- Documentation gaps or errors
- Confirmed connector availability problems

---

## Template: Unexpected Azure DevOps Email Notifications After Upgrade

**Use when:** Users report receiving unexpected email notifications about "Sync Issues to Azure DevOps" or similar after upgrading Core Components, despite not using Azure DevOps, ALM Accelerator, or Innovation Backlog

**Response:**

Thank you for reporting this! This is a known and expected behavior after upgrading Core Components, and it can be safely resolved.

### What's Happening

After upgrading Core Components (especially to January 2026 or later versions), the **"Admin | Sync Template v3 Configure Emails"** flow runs automatically to configure email templates. This flow:

1. Checks which CoE solutions are installed in your environment
2. Attempts to configure email templates for all detected solutions
3. May trigger flows that check for dependencies on other components

If you have previously installed (or have remnants of) the Innovation Backlog, ALM Accelerator, or Pipeline Accelerator solutions, flows may attempt to configure features for these components and fail if they're not properly set up. Power Platform then sends automatic failure notifications.

### This is Normal and Expected ✅

These email notifications are **not errors in the Core Components** themselves, but rather:
- Power Platform's automatic notification system alerting you to flows that cannot complete
- Usually related to optional CoE components (Innovation Backlog, ALM Accelerator, Pipeline Accelerator) that aren't fully configured

### Resolution Steps

You have several options depending on your needs:

**Option 1: Turn Off the Specific Flow** (if you don't use the feature)
1. Go to Power Automate in your CoE environment
2. Find the flow mentioned in the email notification
3. Turn it off if you don't need that feature

**Option 2: Remove Unused Solutions** (recommended if not using them)
1. Go to Power Apps → Solutions
2. Remove any of these if you're not using them:
   - Center of Excellence - Innovation Backlog
   - Center of Excellence - ALM Accelerator for Makers  
   - Center of Excellence - Pipeline Accelerator

**Option 3: Complete the Setup** (if you want to use the feature)
- Follow the setup guide for the specific component causing the notification
- Configure all required connections and environment variables

### Detailed Troubleshooting Guide

For comprehensive step-by-step instructions, see:

📖 **[Troubleshooting Azure DevOps Email Notifications](../docs/TROUBLESHOOTING-AZURE-DEVOPS-EMAILS.md)**

This guide includes:
- Detailed explanations of why this occurs
- Multiple resolution strategies
- Prevention tips for future upgrades  
- When to seek additional help

### Prevention for Next Upgrade

1. Only install CoE components you actively need
2. Remove unused solutions before upgrading Core Components
3. Complete setup for all installed components (connections + environment variables)
4. Review the [Upgrade Troubleshooting Guide](../TROUBLESHOOTING-UPGRADES.md) before upgrades

### Summary

**Key Takeaway**: These emails are normal after Core Components upgrades and indicate flows trying to configure optional features you may not be using. Simply turn off those flows or remove the unused solutions.

Let us know if the notifications continue after trying these steps!

---

## Template: DLP Impact Analysis Export Timeout

**Use when:** Users report that they cannot export DLP Impact Analysis results due to timeouts or large dataset sizes

**For the complete response template, see**: [ISSUE-RESPONSE-dlp-impact-analysis-export-timeout.md](ISSUE-RESPONSE-dlp-impact-analysis-export-timeout.md)

**Quick Response:**

Thank you for reporting this issue with exporting DLP Impact Analysis data!

This is a **known limitation** when analyzing DLP policies with broad scope (such as "Strict" policies that block many connectors). The large number of impacted apps and flows creates too many records to export through standard methods.

### Quick Reference

We've created comprehensive documentation with **5 different solutions** based on your scenario:

🔗 **[DLP Impact Analysis Export Timeout Troubleshooting Guide](troubleshooting/dlp-impact-analysis-export-timeout.md)**

| Your Scenario | Recommended Solution | Complexity |
|--------------|---------------------|------------|
| < 2,000 records | Filter in Canvas App and export | ✅ Low |
| 2,000 - 50,000 records | Use filtered views in model-driven app | ✅ Low |
| > 50,000 records | **Power Automate batch export** | ⚠️ Medium |
| Technical users | PowerShell with FetchXML pagination | 🔧 High |
| Analysis only | Power BI integration | ✅ Low-Medium |

### Tools Available

- **PowerShell Script**: [Export-DLPImpactAnalysis.ps1](scripts/Export-DLPImpactAnalysis.ps1)
- **Step-by-step Power Automate instructions**: [In troubleshooting guide](troubleshooting/dlp-impact-analysis-export-timeout.md#solution-1-power-automate-flow-export-recommended-for-large-datasets)

Let me know if you need guidance on which approach would work best for your situation!

---

**Template Version**: 1.0  
**Last Updated**: January 2026  
**Maintained by**: CoE Starter Kit Community
