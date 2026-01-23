# Troubleshooting: Unexpected Azure DevOps Email Notifications

## Issue Description

After reimporting or upgrading the CoE Starter Kit Core Components, you may receive unexpected email notifications with subjects similar to:
- "Sync Issues to Azure DevOps..."
- Flow failure notifications related to Azure DevOps
- Emails about Innovation Backlog features

These emails may appear even when:
- Azure DevOps is not being used
- The ALM Accelerator or Pipeline Accelerator is not installed
- The Innovation Backlog component is not installed or not being actively used

## Root Cause

The CoE Starter Kit Core Components include a flow called **"Admin | Sync Template v3 Configure Emails"** that automatically configures email templates for various CoE components. This flow:

1. Runs after solution upgrades or imports
2. Checks which CoE solutions are installed in your environment
3. Attempts to configure email templates for all detected solutions
4. May trigger or reference flows that check for dependencies on other solutions

If you have previously installed (or have remnants of) the Innovation Backlog, ALM Accelerator, or Pipeline Accelerator solutions, the Configure Emails flow may attempt to set up related email templates or dependencies, even if those solutions are not actively being used.

Additionally, Power Platform automatically sends email notifications when flows fail or encounter errors. If any flow is trying to sync with or configure features for Azure DevOps/Innovation Backlog but cannot complete successfully (due to missing connections, solutions, or configurations), you will receive failure notifications.

## Resolution Steps

### Option 1: Turn Off Specific Flow Notifications (Recommended)

If you can identify the specific flow that's sending the notifications:

1. **Navigate to Power Automate** in your CoE environment
2. **Go to "My flows"** or **"Cloud flows"**
3. **Search for flows** containing keywords like:
   - "Sync"
   - "Azure DevOps"
   - "Innovation Backlog"
   - "Issue"
4. **For each problematic flow:**
   - Open the flow details
   - Click on the **three dots (...)** menu
   - Select **"Settings"**
   - Under **"Run only users"**, turn off email notifications for failures
   - Or, if the flow is not needed, **turn off the flow** completely

### Option 2: Turn Off the Flow Completely

If the flow is related to a CoE component you're not using:

1. **Identify the flow** causing notifications
2. **Open the flow** in Power Automate
3. **Turn off the flow** using the toggle switch in the command bar
4. **Note**: Only turn off flows for features you don't use (e.g., if you don't use Innovation Backlog, you can safely turn off Innovation Backlog-related flows)

### Option 3: Complete the Setup for Innovation Backlog

If you intentionally have the Innovation Backlog installed but haven't completed setup:

1. **Install the Innovation Backlog solution** completely if partially installed
2. **Configure all required connections** for Innovation Backlog flows
3. **Set up environment variables** as documented in the [official CoE Starter Kit documentation](https://learn.microsoft.com/power-platform/guidance/coe/setup-innovationbacklog)
4. **Test the flows** to ensure they run successfully

### Option 4: Remove Unused Solutions

If you have Innovation Backlog, ALM Accelerator, or Pipeline Accelerator installed but don't use them:

1. **Navigate to Power Apps** → **Solutions** in your CoE environment
2. **Find these solutions:**
   - Center of Excellence - Innovation Backlog
   - Center of Excellence - ALM Accelerator for Makers (if present)
   - Center of Excellence - Pipeline Accelerator (if present)
3. **Delete** the solution(s) you're not using
4. **Note**: This may require removing dependent solutions first. Follow the deletion prompts carefully.
5. **After removal**, run the "Admin | Sync Template v3 Configure Emails" flow again to update email configurations

### Option 5: Check for Orphaned Flow Runs

Sometimes flows that were previously installed remain in a "failed" state and continue to send notifications:

1. **Go to Power Automate** → **Action items**
2. **Review any flows** showing errors or failures
3. **Clear old error notifications**
4. **For flows that no longer exist** but still show errors, contact your administrator to clean up orphaned flow references

## Verification

After applying one of the resolution steps:

1. **Monitor your email** for 24-48 hours
2. **If notifications continue**, check:
   - Flow run history in Power Automate
   - The specific error message in the email
   - Whether the flow is still active
3. **Document the exact email subject line** and flow name for further troubleshooting

## Prevention

To avoid this issue in future upgrades:

1. **Only install CoE components you actually need**
2. **Remove unused solutions** before upgrading Core Components
3. **Complete setup** for all installed CoE components, including:
   - All required connections
   - All environment variables
   - Initial flow testing
4. **Review the [Upgrade Troubleshooting Guide](../TROUBLESHOOTING-UPGRADES.md)** before each upgrade
5. **Document your CoE architecture** to track which components are in use

## Additional Context

### Why Does This Happen?

The CoE Starter Kit is modular, with Core Components providing shared infrastructure for other components like Innovation Backlog, ALM Accelerator, and Governance. When you upgrade Core Components:

- Core Components checks which other CoE solutions are installed
- It attempts to configure shared resources (like email templates) for those solutions
- If those solutions are partially installed, not configured, or have dependency issues, flows may fail
- Power Platform sends automatic failure notifications for these failed flows

### About Innovation Backlog

The Innovation Backlog component was designed to help organizations crowdsource ideas and manage a backlog of potential Power Platform projects. It includes features to:
- Collect idea submissions from makers
- Vote on and prioritize ideas
- Track pain points and potential solutions

However, **Innovation Backlog does NOT natively include Azure DevOps sync functionality**. If you're seeing references to Azure DevOps in the context of Innovation Backlog, this is likely:
- A misconfiguration
- A custom extension added to your environment
- Or an error message that's being misinterpreted

### About ALM Accelerator and Pipeline Accelerator

The ALM Accelerator for Makers (and its successor, Pipeline Accelerator) DO include Azure DevOps integration. If you have either of these installed, even if not actively used, flows may attempt to sync with Azure DevOps and fail if not properly configured.

## When to Seek Further Help

Open a new GitHub issue if:

1. **Notifications persist** after trying all resolution steps
2. **You cannot identify the flow** sending the notifications
3. **The flow is critical** to your CoE operations and cannot be turned off
4. **You encounter errors** when trying to remove unused solutions

When opening an issue, include:

- Exact email subject line
- Screenshot of the email notification
- Flow name (if identifiable)
- CoE Starter Kit version
- List of installed CoE solutions
- Steps you've already attempted

## Related Documentation

- [CoE Starter Kit - Innovation Backlog Setup](https://learn.microsoft.com/power-platform/guidance/coe/setup-innovationbacklog)
- [CoE Starter Kit - Core Components Setup](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components)
- [Upgrade Troubleshooting Guide](../TROUBLESHOOTING-UPGRADES.md)
- [Managing Flows in Power Automate](https://learn.microsoft.com/power-automate/disable-turn-off-delete-flow)

## Summary

**Key Takeaway**: Email notifications about "Sync Issues to Azure DevOps" after upgrading Core Components are typically caused by:
1. Partially installed or unconfigured CoE components (Innovation Backlog, ALM Accelerator, Pipeline Accelerator)
2. Flows that check for these components and fail when they're not properly set up
3. Power Platform's automatic notification system alerting you to these failures

**Recommended Action**: Identify the specific flow sending notifications, then either:
- Turn off the flow if you don't need the feature
- Complete the setup if you do need the feature
- Remove the related solution if you're not using it

This is **normal behavior** after upgrades and can be safely resolved using the options above.
