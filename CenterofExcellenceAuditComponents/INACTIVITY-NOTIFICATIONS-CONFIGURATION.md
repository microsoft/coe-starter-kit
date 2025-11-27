# Inactivity Notifications - Configuration Guide

This guide explains where to find and how to configure the timeframe settings for the Inactivity Notifications approval flows in the CoE Starter Kit.

## Overview

The Inactivity Notifications feature helps you manage unused apps and flows in your tenant by:
1. Detecting apps/flows that haven't been modified in a specified time period (default: 6 months)
2. Sending approval requests to determine if they should be archived or deleted
3. Automatically taking action based on approval responses

## Configuration Locations

The timeframe configurations referenced in the approval messages are located in different places:

### 1. "6 months" - Configurable Environment Variables

**What it controls:** How far back to look for app/flow activity to determine if something is inactive.

**Location:** Environment variables in the solution:
- `admin_ArchivalPastTimeInterval` (default: `1`)
- `admin_ArchivalPastTimeUnit` (default: `Month`)

**How to modify:**
1. Go to your Power Platform environment
2. Navigate to Solutions > Center of Excellence - Audit Components
3. Select "Environment variables" from the solution components
4. Find and update:
   - **InactivityNotifications-PastTime-Interval** - Change the number (e.g., 6 for 6 months)
   - **InactivityNotifications-PastTime-Unit** - Change the unit (Month, Week, Day, etc.)

**Example configurations:**
- 6 months: Interval = `6`, Unit = `Month`
- 3 months: Interval = `3`, Unit = `Month`
- 90 days: Interval = `90`, Unit = `Day`

### 2. "3 weeks" - Approval Deletion Timeframe (Hardcoded)

**What it controls:** After an approval is granted (approved), the app/flow will be deleted after 3 weeks (21 days).

**Location:** Hardcoded in the flow definition files:
- `AdminInactivitynotificationsv2StartApprovalforApps-D740E841-7057-EB11-A812-000D3A9964A5.json` (line 256)
- `AdminInactivitynotificationsv2StartApprovalforFlow-7E68D839-0556-EB11-A812-000D3A996ADC.json` (line 659)

**Code reference:**
```json
"inputs": "@formatDateTime(addDays(first(body('Parse_JSON_this_one_approved'))['admin_approvalresponsedate'], 21), 'dd MMM yyy')"
```

**How to modify:**
1. Navigate to the flow in Power Automate:
   - **Admin | Inactivity notifications v2 - Start Approval for Apps**
   - **Admin | Inactivity notifications v2 - Start Approval for Flow**
2. Edit the flow
3. Find the action named "Date_to_Delete" (in the "Approved" branch)
4. Change the number `21` in the formula to your desired number of days
   - Example: For 4 weeks (28 days), change `21` to `28`
   - Example: For 2 weeks (14 days), change `21` to `14`

### 3. "4 weeks" - Rejection Exemption Timeframe (Hardcoded)

**What it controls:** After an approval is rejected, the app/flow will be exempt from additional approval requests for approximately 4 weeks (referenced as "1 month" in the flow).

**Location:** Hardcoded in the flow definition files:
- `AdminInactivitynotificationsv2StartApprovalforApps-D740E841-7057-EB11-A812-000D3A9964A5.json` (line 541)
- `AdminInactivitynotificationsv2StartApprovalforFlow-7E68D839-0556-EB11-A812-000D3A996ADC.json` (similar location)

**Code reference:**
```json
"inputs": "Request Rejected. That rejection will time out in 1 month and then will recreate"
```

**How to modify:**
This is currently a text description in a Compose action. To change the actual exemption period, you would need to modify the flow logic that filters out recently rejected approvals. This is controlled by the date comparison logic in the flow when checking for existing rejected approvals.

## Quick Reference Table

| Timeframe | What it Controls | Configuration Type | How to Change |
|-----------|-----------------|-------------------|---------------|
| **6 months** | Inactivity detection period | Environment Variable | Modify `admin_ArchivalPastTimeInterval` and `admin_ArchivalPastTimeUnit` |
| **3 weeks (21 days)** | Time until deletion after approval | Hardcoded in flow | Edit flow, find "Date_to_Delete" action, change `21` to desired days |
| **4 weeks (~1 month)** | Exemption period after rejection | Hardcoded in flow | Edit flow logic for rejection handling |

## Best Practices

1. **Test in a development environment first** - Changes to these flows can impact production resources
2. **Document your changes** - Keep track of any customizations you make
3. **Consider your organization's needs** - The default values may not fit all scenarios
4. **Align timeframes with policies** - Ensure these timeframes match your governance policies
5. **Communicate changes** - Let resource owners know about any changes to these timeframes

## Related Flows

- **Admin | Inactivity notifications v2 - Start Approval for Apps** - Handles app inactivity approvals
- **Admin | Inactivity notifications v2 - Start Approval for Flow** - Handles flow inactivity approvals
- **Admin | Inactivity notifications v2 - Clean Up and Delete** - Performs the actual deletion after approval

## Additional Resources

- [CoE Starter Kit Documentation](https://docs.microsoft.com/power-platform/guidance/coe/starter-kit)
- [Audit Components Overview](https://docs.microsoft.com/power-platform/guidance/coe/governance-components)
