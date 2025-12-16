# GitHub Issue Response Templates

This document contains pre-written responses for common CoE Starter Kit issues on GitHub. Use these templates to provide consistent, helpful responses to community members.

## Template: Blank Screen Issues

### Initial Response Template

```markdown
Hi @[username],

Thank you for reporting this issue. Blank screens in CoE Starter Kit apps are one of the most common issues, and they're typically caused by missing prerequisites or configuration problems.

I can see from your screenshots that the apps are loading (headers visible) but the content area is blank. This pattern usually indicates one of these issues:

1. **Missing or insufficient licensing** (most common)
2. **Missing System Administrator role in the CoE environment**
3. **Canvas PCF components not enabled**
4. **DLP policies blocking required connectors**

## Quick Diagnostic Steps

Please work through this checklist and let us know the results:

### Prerequisites Checklist
- [ ] I have **Power Apps Premium** or **Power Apps Per User** license (NOT trial or per-app)
- [ ] I have **Global Admin** or **Power Platform Admin** role at tenant level
- [ ] I have **System Administrator** security role in the CoE Dataverse environment
- [ ] My environment has a Dataverse database provisioned
- [ ] English language pack is enabled in my environment
- [ ] Canvas PCF components are enabled (Settings > Features > "Power Apps component framework for canvas apps")
- [ ] I've waited 10-15 minutes after enabling PCF components
- [ ] Required connectors are allowed in DLP policies (Dataverse, Power Apps for Admins, Power Automate Management, Office 365 Users)

### Troubleshooting Attempted
- [ ] Tested in InPrivate/Incognito browser mode
- [ ] Checked Power Apps Monitor for errors (Ctrl+Alt+Shift+M)
- [ ] Verified inventory flows have run successfully
- [ ] Checked environment variables are configured

## Detailed Troubleshooting Resources

Please review these guides for step-by-step instructions:

- **[Troubleshooting Blank Screens Guide](../docs/TROUBLESHOOTING-BLANK-SCREENS.md)** - Comprehensive troubleshooting steps
- **[Quick Reference Card](../docs/QUICK-REFERENCE-BLANK-SCREENS.md)** - Printable checklist
- **[FAQ - Common Issues](../docs/FAQ-COMMON-ISSUES.md)** - Quick answers to common questions

## Next Steps

Please complete the checklist above and share the results. Once we know which prerequisites are met, we can provide more specific guidance.

Also, if you can open the app and press **Ctrl+Alt+Shift+M** to view the Monitor, please share any error messages you see (look for red entries).

Looking forward to helping you resolve this!
```

### Follow-up: License Issue Identified

```markdown
Based on your checklist, it appears you're using a [trial/per-app/O365] license. This is the most common cause of blank screens in CoE apps.

## The Issue

Trial licenses and insufficient licenses have the following limitations that cause blank screens:
- Limited API pagination (causes data retrieval failures)
- PCF components may fail to load
- Dataverse queries timeout or fail silently

## The Solution

You need to assign a **Power Apps Premium** or **Power Apps Per User** license to the account running the CoE apps.

**Steps:**
1. Go to [Microsoft 365 Admin Center](https://admin.microsoft.com)
2. Navigate to **Users > Active users**
3. Find your account and click on it
4. Select **Licenses and apps**
5. Assign **Power Apps Premium** or **Power Apps Per User**
6. Save changes
7. Wait a few minutes for the license to propagate
8. Sign out and sign back into Power Apps
9. Try opening the app again

**Important:** Trial licenses may appear to work intermittently but will cause ongoing issues. Per-App licenses are insufficient for admin apps like the CoE Starter Kit.

Let us know if this resolves the issue!
```

### Follow-up: Role Issue Identified

```markdown
I see you have Power Platform Administrator at the tenant level, but you also need the **System Administrator** security role within the specific CoE Dataverse environment.

## Why Both Are Needed

- **Tenant-level role** (Power Platform Admin): Allows you to manage environments and view tenant-wide data
- **Environment-level role** (System Administrator): Allows you to access and interact with data in the specific CoE environment

Having Power Platform Administrator alone is NOT sufficient for CoE apps to function.

## How to Assign System Administrator Role

1. Go to [Power Platform Admin Center](https://admin.powerplatform.microsoft.com)
2. Select your CoE environment from the list
3. Click **Settings** in the top menu
4. Navigate to **Users + permissions > Users**
5. Find your account in the list
6. Click on your name to open user details
7. Select **Manage security roles**
8. Check the **System Administrator** role
9. Click **Save**
10. Wait a few minutes for the role to propagate
11. Sign out and sign back into Power Apps
12. Try opening the app again

Let us know if this resolves the issue!
```

### Follow-up: PCF Not Enabled

```markdown
Based on your feedback, it looks like Canvas PCF components are not enabled in your environment. This is required for CoE apps to render properly.

## Enable Canvas PCF Components

1. Go to [Power Platform Admin Center](https://admin.powerplatform.microsoft.com)
2. Select your CoE environment
3. Click **Settings** in the top menu
4. Navigate to **Features**
5. Find **"Power Apps component framework for canvas apps"**
6. Toggle it to **On**
7. Click **Save**
8. **Wait 10-15 minutes** for the setting to propagate across the environment
9. Clear your browser cache or use InPrivate/Incognito mode
10. Try opening the app again

**Important:** The 10-15 minute wait is crucial. The setting needs time to propagate. During this time:
- Clear your browser cache
- Close and reopen your browser
- After waiting, try accessing the app in InPrivate/Incognito mode first

Let us know if this resolves the issue!
```

### Follow-up: DLP Policy Blocking

```markdown
It appears a Data Loss Prevention (DLP) policy may be blocking connectors required by the CoE apps.

## Required Connectors

The following connectors must be in the **Business** data group (or the CoE environment must be excluded from restrictive policies):
- Microsoft Dataverse
- Power Apps for Admins
- Power Automate Management
- Office 365 Users
- Office 365 Groups
- Microsoft Dataverse (legacy)

## How to Fix DLP Policies

1. Go to [Power Platform Admin Center](https://admin.powerplatform.microsoft.com)
2. Select **Data policies** from the left navigation
3. Review any policies applied to your CoE environment (check the scope)
4. For each policy affecting your environment:
   - Click on the policy name to edit it
   - Review the connector classifications
   - Ensure all required connectors (listed above) are in the **Business** group
   - If they're in **Non-business** or **Blocked**, move them to **Business**
5. Save changes to each policy
6. Wait 5-10 minutes for policies to propagate
7. Try opening the app again

**Alternative:** If you cannot modify DLP policies, you can exclude your CoE environment from the policy:
1. Edit the DLP policy
2. Go to **Scope** or **Apply to** section
3. Select **Exclude certain environments**
4. Add your CoE environment to the exclusion list
5. Save the policy

Let us know if this resolves the issue!
```

### Follow-up: Multiple Issues

```markdown
Based on your checklist, I see multiple prerequisites are not met:
- [List the specific issues]

This combination is preventing the apps from loading properly. Let's address these one at a time:

1. **First priority: [Most critical issue]**
   [Specific guidance for that issue]

2. **Second priority: [Next issue]**
   [Specific guidance for that issue]

3. **Third priority: [Another issue]**
   [Specific guidance for that issue]

## Recommended Order

I recommend addressing these in the order listed above, as some may be blocking others. Please start with [First priority] and let us know once that's resolved, then we can move to the next step.

Feel free to ask questions about any of these steps!
```

### Closing Template: Issue Resolved

```markdown
Great news that the issue is resolved! 🎉

For reference, the solution was:
- [Summarize what fixed it]

This is helpful for others who may encounter the same issue. I'm going to close this issue now, but feel free to reopen it or create a new issue if you encounter any other problems.

## Helpful Resources for Future Reference

- [Troubleshooting Blank Screens Guide](../docs/TROUBLESHOOTING-BLANK-SCREENS.md)
- [FAQ - Common Issues](../docs/FAQ-COMMON-ISSUES.md)
- [Official CoE Documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)

Thank you for working through the troubleshooting process with us!
```

### Template: Insufficient Information

```markdown
Hi @[username],

Thank you for reporting this issue. To help diagnose the problem effectively, we need some additional information.

## Required Information

Please provide the following details:

1. **Solution version**: Which version of CoE Starter Kit are you using? (e.g., 4.50.6)
2. **Specific app(s) affected**: Which CoE app(s) show blank screens?
3. **Prerequisites status**: Have you completed the [prerequisites checklist](../docs/QUICK-REFERENCE-BLANK-SCREENS.md)?
4. **Screenshots**: Can you provide screenshots showing:
   - The blank screen (similar to what you've already shared)
   - Your Power Platform Admin Center > Environments > [Your CoE Env] > Settings > Features page
   - Your license assignment page (can blur sensitive info)
5. **Monitor errors**: Can you open the app and press **Ctrl+Alt+Shift+M** to view the Monitor, then share any error messages (look for red entries)?
6. **Troubleshooting attempted**: What troubleshooting steps have you already tried?

## Quick Diagnostic

While gathering that information, please also try these quick tests:

1. **InPrivate/Incognito test**: Does the app work in InPrivate/Incognito browser mode?
2. **Flow check**: Have your inventory flows (Admin | Sync Template v3) run successfully?
3. **License check**: Do you have Power Apps Premium or Per User license (not trial or per-app)?

## Resources

Here are some resources that may help while we wait for more information:

- **[Troubleshooting Blank Screens Guide](../docs/TROUBLESHOOTING-BLANK-SCREENS.md)** - Step-by-step troubleshooting
- **[Quick Reference Card](../docs/QUICK-REFERENCE-BLANK-SCREENS.md)** - Printable checklist
- **[FAQ](../docs/FAQ-COMMON-ISSUES.md)** - Common questions and answers

Looking forward to your response so we can help resolve this issue!
```

## Usage Notes

- **Personalize**: Always replace `@[username]` with the actual GitHub username
- **Adapt**: Modify templates based on the specific details provided in the issue
- **Be empathetic**: Remember users are often frustrated; maintain a helpful, friendly tone
- **Link appropriately**: Ensure links work from the issue context (use full URLs if needed)
- **Follow up**: Check back on issues and provide additional help if needed
- **Tag appropriately**: Add labels like `needs-info`, `license-issue`, `dlp-policy`, `pcf-components`, etc.

## Template Selection Guide

Use this guide to quickly select the right template:

| Issue Characteristics | Template to Use |
|----------------------|-----------------|
| New blank screen issue, minimal details | Initial Response Template |
| User mentions trial/per-app license | License Issue Follow-up |
| Has tenant admin but not env admin role | Role Issue Follow-up |
| PCF not mentioned in initial report | PCF Not Enabled Follow-up |
| Mentions DLP or connector errors | DLP Policy Blocking Follow-up |
| Multiple prerequisites not met | Multiple Issues Follow-up |
| Issue resolved by user | Closing Template |
| Insufficient details to diagnose | Insufficient Information Template |

---

**Last Updated**: 2024-12-16  
**Maintainers**: Feel free to improve these templates based on community feedback and new patterns discovered.
