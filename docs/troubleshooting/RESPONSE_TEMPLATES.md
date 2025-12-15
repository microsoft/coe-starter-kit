# CoE Starter Kit - Issue Response Templates

This document contains standardized responses for common CoE Starter Kit issues to ensure consistent and helpful support.

## Environments Not Listed in Power Platform Admin App

### Initial Response Template

```markdown
Hello @[username],

Thank you for reaching out about environments not appearing in the Power Platform Admin App.

To help troubleshoot this issue effectively, I need some additional information:

1. **Solution version**: What version of the CoE Starter Kit are you using?
2. **Inventory method**: Are you using Cloud flows or Data Export for inventory?
3. **Sync flow status**: Has the "Admin | Sync Template v4 (Driver)" flow run successfully?
4. **Specific environments**: Can you provide examples of environment names that are missing?
5. **Expected vs Actual**: How many environments do you expect to see vs. how many are showing?

In the meantime, here are the most common causes and quick checks:

### Quick Diagnostic Steps

1. **Check the "Excuse From Inventory" setting**:
   - Open the Power Platform Admin View app
   - Navigate to Environments and search for one of the missing environments
   - If found, check if "Excuse From Inventory" is set to "Yes"
   - If set to "Yes", change it to "No" to include it in inventory

2. **Verify the sync flow has run**:
   - Go to Power Automate in your CoE environment
   - Find the "Admin | Sync Template v4 (Driver)" flow
   - Check the run history for recent successful runs
   - If not running, trigger it manually

3. **Check the "Track All Environments" setting**:
   - In Power Apps, go to Solutions → Center of Excellence - Core Components
   - Check Environment Variables → "Track All Environments"
   - Ensure it's set to "True" if you want all environments tracked automatically

I've created a comprehensive troubleshooting guide that covers these and other scenarios:
📖 [Troubleshooting: Environments Not Listed](../docs/troubleshooting/environments-not-listed.md)

Please review the guide and let me know what you find. I'm here to help if you need further assistance!
```

### Follow-up: License/Pagination Issue

```markdown
It appears you may be encountering a pagination issue. The CoE Starter Kit requires adequate licensing for the service account to retrieve all environments in large tenants.

**Required**:
- The account running the sync flows needs a Power Apps Premium (or equivalent) license
- Trial licenses will cause pagination limits that prevent full inventory

**To verify**:
1. Check the license assigned to the service account
2. Review the flow run history for the Driver flow - look for exactly 100 environments returned (indicates pagination limit hit)

**Resolution**:
Assign a full Power Apps Premium license to the service account and re-run the sync flow.

See: [Microsoft Learn - Setup Considerations](https://learn.microsoft.com/power-platform/guidance/coe/setup#what-identity-should-i-install-the-coe-starter-kit-with)
```

### Follow-up: Permission Issue

```markdown
The issue appears to be related to permissions. The account used for the sync flows needs sufficient permissions to list all environments.

**Required Permissions**:
- Power Platform Administrator role OR
- Dynamics 365 Administrator role

**To verify**:
1. Go to Microsoft 365 Admin Center
2. Check the roles assigned to the service account
3. Ensure it has one of the above roles

**Resolution**:
Assign the appropriate admin role and re-run the sync flow.
```

### Follow-up: First Time Setup

```markdown
If this is your first time setting up the CoE Starter Kit, please note:

1. **Initial sync takes time**: The first inventory sync can take several hours depending on the size of your tenant
2. **Staged rollout**: Environments are discovered and synced progressively
3. **Normal behavior**: It's normal for some environments to appear before others

**Recommended Actions**:
- Wait for the initial sync to complete fully (check flow run history)
- Run the Driver flow manually if it hasn't run in the last 24 hours
- Check back after the sync completes

For setup guidance, see: [CoE Starter Kit Setup](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components)
```

### Resolution Confirmation

```markdown
Great to hear the issue is resolved! 

For future reference, the troubleshooting guide is available at:
📖 [Troubleshooting: Environments Not Listed](../docs/troubleshooting/environments-not-listed.md)

If you encounter any other issues or have questions about the CoE Starter Kit, please don't hesitate to open a new issue.

Closing this issue as resolved. Thank you for using the CoE Starter Kit!
```

## General Guidelines

When responding to issues:

1. **Be friendly and professional**: Users may be frustrated; empathy goes a long way
2. **Ask for specifics**: Get version numbers, error messages, and repro steps
3. **Provide actionable steps**: Give clear, numbered instructions
4. **Link to documentation**: Always reference official docs or troubleshooting guides
5. **Avoid assumptions**: Don't assume user expertise level
6. **Follow up**: Check back on issues that remain open
7. **Close resolved issues**: Once confirmed fixed, close with a summary

## Escalation Criteria

Escalate or request maintainer help when:
- Security vulnerabilities are reported
- Product bugs affecting multiple users
- Feature requests requiring architecture changes
- Issues requiring access to internal Microsoft systems
- User cannot resolve after following all troubleshooting steps
