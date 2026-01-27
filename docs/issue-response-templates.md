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

---

## Template: Inactivity Notification Questions

**Use when:** Users ask about how inactivity notification flows work, environment scope, or the admin_ProductionEnvironment variable

**Response:**

Thank you for your questions about the CoE Starter Kit Inactivity Notification flows!

### Question 1: Environment Scope

**The inactivity notification flows scan ALL environments in your tenant**, not just the ones you see selected in the Environment table.

#### How It Works:
- The flows query the entire `admin_apps` and `admin_flows` Dataverse tables
- These tables contain inventory from across your entire tenant
- The flows **only exclude** environments where:
  - `admin_excusefromarchivalflows` is set to **Yes**
  - The environment has been deleted

#### The Environment Table
The Environment table stores metadata about your environments. While you may only see a few environments initially, the Core Components inventory flows populate all environments over time.

#### To Exclude Specific Environments:
1. Open the **Admin - Add Environment Properties** app (Core Components)
2. Find the environment you want to exclude
3. Set **"Excuse from archival flows"** to **Yes**
4. Save the record

Apps and flows in that environment will no longer be scanned for inactivity.

### Question 2: Changing the Test Approval Recipient

When `admin_ProductionEnvironment` is set to **No**, approvals are sent to the admin account for testing. 

**To send to your account instead of the default admin:**

1. Go to your CoE environment and find the environment variables
2. Locate **Admin eMail (admin_AdminMail)**
3. Change the value to your email address
4. Save the change

Now when `admin_ProductionEnvironment = No`, all test approvals will go to your email address.

**How It Works:**
- `admin_ProductionEnvironment = Yes` → Approvals go to actual resource owners
- `admin_ProductionEnvironment = No` → Approvals go to the email in `admin_AdminMail`

This prevents accidentally sending test notifications to real makers during testing.

### Additional Resources

We've created a comprehensive FAQ document that covers these and many other questions:
- [FAQ: Inactivity Notifications](../../CenterofExcellenceResources/FAQ-InactivityNotifications.md)

This FAQ includes:
- Detailed explanation of environment filtering
- How to configure test mode
- Managing orphaned apps and flows
- Customizing notification emails
- Troubleshooting common issues
- Best practices for governance rollout

### Next Steps

Before deploying to production:
1. ✅ Set `admin_ProductionEnvironment` to **No** for testing
2. ✅ Set `admin_AdminMail` to your test email
3. ✅ Review and adjust `admin_ArchivalPastTimeInterval` (default: 6 months)
4. ✅ Exclude any environments that shouldn't be scanned
5. ✅ Test the approval flow with a test app/flow
6. ✅ Communicate the governance program to your maker community
7. ✅ Set `admin_ProductionEnvironment` to **Yes** when ready for production

### Official Documentation

- [CoE Starter Kit Overview](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- [Governance Components](https://learn.microsoft.com/power-platform/guidance/coe/governance-components)
- [Setup Instructions](https://learn.microsoft.com/power-platform/guidance/coe/setup)

Please let us know if you have any other questions!

---

**Template Version**: 1.0  
**Last Updated**: January 2026  
**Maintained by**: CoE Starter Kit Community
