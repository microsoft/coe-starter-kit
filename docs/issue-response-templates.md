# GitHub Issue Response Template - Sovereign Cloud / GCC High Questions

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

## Template: Teams Connection Required During Upgrade

**Use when:** Users ask about the new Teams connection requirement or encounter errors during CoE Core import

**Response:**

Thank you for your question about the Microsoft Teams connection requirement!

### What's Happening

Starting with recent versions of the CoE Starter Kit (mid-2024 and later), the **Core Components** solution requires a **Microsoft Teams connection** (`CoE Core - Teams`) during import and upgrade.

### Why This Connection is Required

The Teams connection enables:
- Real-time escalation notifications when inventory sync encounters critical errors
- Teams-based approval workflows for App Catalog access requests
- DLP policy impact notifications

The connection is required during solution import, but you can choose not to use Teams-based features if you prefer.

### What Permissions Do You Need?

**Good news:** No special or admin permissions are required! 

✅ **You only need:**
- Standard Microsoft Teams user access
- An M365 license that includes Teams
- Ability to send/receive Teams messages

❌ **You do NOT need:**
- Teams admin permissions
- Elevated API permissions
- Azure AD admin consent

### How to Set Up the Connection

**During Solution Import:**

1. When you see the **Connections** screen during import:
   - Look for "CoE Core - Teams" in the list (it will show a red warning icon)
   - Click on the connection row
   - Click **"+ New connection"** or the "+" button

2. **Authorize the connection:**
   - Sign in with the account that will run the CoE flows
   - Click **Allow** when prompted for Teams permissions
   - Wait for the green checkmark to appear

3. **Continue import:**
   - Select the newly created connection from the dropdown
   - Ensure all connections show green checkmarks
   - Click **Next** to proceed

### Detailed Documentation

For comprehensive setup instructions, troubleshooting, and FAQs, see:
- **[Teams Connection Setup Guide](./TEAMS-CONNECTION-SETUP.md)** - Complete guide with troubleshooting

### Common Issues and Solutions

**"Teams connector is blocked by our DLP policy"**
- Add Microsoft Teams connector to the same data group as Power Platform connectors
- Contact your Power Platform admin to update the DLP policy
- See [DLP troubleshooting section](./TEAMS-CONNECTION-SETUP.md#what-if-teams-connector-is-blocked-by-dlp-policy)

**"I don't have Teams in my organization"**
- Verify with your M365 admin if Teams is available
- Check if your license includes Teams
- See [troubleshooting section](./TEAMS-CONNECTION-SETUP.md#troubleshooting)

**"Which account should create this connection?"**
- Use the same service account that runs your CoE flows
- Ensure it has a Teams license
- Messages will be sent from this account's identity

### Quick Links

- [Full Teams Connection Setup Guide](./TEAMS-CONNECTION-SETUP.md)
- [CoE Setup Documentation](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components)
- [Upgrade Troubleshooting](../TROUBLESHOOTING-UPGRADES.md)

Let us know if you have any questions or encounter issues during setup!

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

**Template Version**: 1.0  
**Last Updated**: January 2026  
**Maintained by**: CoE Starter Kit Community
