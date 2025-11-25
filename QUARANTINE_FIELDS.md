# Quarantine Fields in CoE Starter Kit Governance Solution

This document explains the function of the two quarantine-related fields in the PowerApps App (admin_app) entity of the CoE Starter Kit Governance solution.

## Overview

The quarantine functionality allows administrators to temporarily block access to Power Apps that are non-compliant with organizational policies. This is part of the governance capabilities provided by the CoE Starter Kit.

## Fields

### 1. Quarantine App (admin_quarantineapp)

**Technical Details:**
- **Field Name:** `admin_quarantineapp`
- **Display Name:** Quarantine App
- **Type:** Boolean (Yes/No)
- **Introduced Version:** 3.33.1 (from Entity.xml metadata)
- **Default Value:** No (false)

**Purpose:**
This field is a **record-keeping field** that indicates whether a quarantine action has been requested or applied to an app. It is updated in the following scenarios:

**How It's Used:**

1. **User Interface Actions (Quarantine App button)**:
   - When an admin clicks the "Quarantine App" button in Power Platform Admin View, the Canvas App dialog:
     - First calls `PowerAppsforAdmins.SetAppQuarantineState()` to directly quarantine the app in Power Platform
     - Then patches `admin_quarantineapp` to `true` and sets `admin_quarantineappdate` to today's date
   - The field is updated AFTER the actual quarantine action completes

2. **User Interface Actions (Unquarantine App button)**:
   - When an admin clicks the "Unquarantine App" button, the Canvas App dialog:
     - First calls `PowerAppsforAdmins.SetAppQuarantineState()` to directly unquarantine the app
     - Then patches `admin_quarantineapp` to `false`

3. **Compliance Automation**: The **"Admin | Quarantine non-compliant apps"** flow sets this field to `true` for apps that have been non-compliant for too long
   - This flow updates ONLY this field - it does NOT directly quarantine the app
   - The actual quarantine happens via a separate mechanism (see flows section)

**Important Notes:**
- This field does NOT trigger any flow when updated
- It is primarily used for record-keeping and tracking which apps have had quarantine actions applied
- The field value itself doesn't prevent users from accessing the app - it's the actual quarantine state in Power Platform that does
- The field may not always reflect the current quarantine state accurately

### 2. App Is Quarantined (admin_appisquarantined)

**Technical Details:**
- **Field Name:** `admin_appisquarantined`
- **Display Name:** App Is Quarantined
- **Type:** Boolean (Yes/No)
- **Introduced Version:** 4.48.1 (from Entity.xml metadata)
- **Default Value:** No (false)

**Purpose:**
This field is a **read-only status indicator field** that reflects the **current quarantine state** of the app in the Power Platform environment. 

**How It's Used:**
1. **Status Display**: Shows whether an app is currently quarantined or not
2. **Flow Trigger**: Changes to this field trigger the **"Admin | Set app quarantine status"** flow (more details below)
3. **Filtering**: Used in flows and views to identify quarantined apps
4. **Compliance Tracking**: The **"Admin | Quarantine non-compliant apps"** flow uses this field to:
   - Filter out apps that are already quarantined
   - Identify apps that need to be quarantined based on compliance status
   
**Automated Updates:**
This field is automatically updated by:
- The inventory sync flows (e.g., "Admin | Sync Template v4 (Apps)") that read the actual quarantine state from Power Platform and update this field to match
- When the sync flows detect a change in the quarantine state, they update this field
- The field reflects the reality of whether users can access the app or not

**Important Notes:**
- This is a **read-only status field** - administrators should not manually edit it
- As documented in the Entity.xml: *"used to track if an app is currently quarantined. Not to set the quarantine state, just to read current state."*
- The field accurately reflects whether users can or cannot access the app
- Changes to this field trigger the quarantine/unquarantine flow

## Related Fields

### Quarantine App Date (admin_quarantineappdate)

**Technical Details:**
- **Field Name:** `admin_quarantineappdate`
- **Display Name:** Quarantine App Date
- **Type:** Date
- **Introduced Version:** 3.39.1 (from Entity.xml metadata)

**Purpose:**
Stores the date when the app was quarantined. This field is:
- Set to the current date when an app is quarantined via the UI buttons or by the "Admin | Set app quarantine status" flow
- Cleared (set to null) when an app is unquarantined
- Also set/maintained by inventory sync flows based on the actual quarantine state in Power Platform
- Used for tracking and reporting purposes

## Flows

### 1. Admin | Set app quarantine status

**Display Name:** Admin | Set app quarantine status
**Flow Name (Technical):** AdminSetappquarantinestatus
**Trigger:** When the `admin_appisquarantined` field is added, modified, or deleted on the admin_app entity

**What It Does:**
1. **Triggered by**: Changes to the `admin_appisquarantined` field (typically caused by inventory sync flows detecting a change in the actual quarantine state from Power Platform)
2. **Validates**: Checks if the app still exists and is not deleted
3. **Retrieves**: Gets the current app details from Dataverse including the current `admin_appisquarantined` status
4. **Decides**: Based on the current value of `admin_appisquarantined`:
   - If `admin_appisquarantined` is `false`: Unquarantine the app
   - If `admin_appisquarantined` is `true`: Quarantine the app
5. **Executes**: Calls the Power Platform Admin connector's `Set-AppQuarantineState` operation:
   - For unquarantine: Sets `quarantineStatus` to "Unquarantined"
   - For quarantine: Sets `quarantineStatus` to "Quarantined"
6. **Updates**: Modifies the Dataverse record:
   - Sets `admin_quarantineappdate` to current UTC time (for quarantine) 
   - Clears `admin_quarantineappdate` to null (for unquarantine)
7. **Notifies**: Sends email notification to the app maker about the status change

**Key Features:**
- Only executes the quarantine action if `ProductionEnvironment` environment variable is set to `true`
- In non-production environments, it skips the actual quarantine but still sends notifications
- Handles both production and non-production environments appropriately
- Provides email notifications to app makers with links to the Developer Compliance Center
- Maintains audit trail through the quarantine date field

**Important Note:**
This flow is NOT directly triggered by the UI buttons. The UI buttons directly call the Power Platform API to quarantine/unquarantine. This flow acts as a safety mechanism that responds when the `admin_appisquarantined` field changes (typically updated by sync flows) to ensure the Power Platform state matches what's recorded in Dataverse.

### 2. Admin | Quarantine non-compliant apps

**Display Name:** Admin | Quarantine non-compliant apps
**Flow Name (Technical):** AdminQuarantinenon-compliantapps
**Trigger:** Scheduled (Daily recurrence at 10:00 AM UTC)

**What It Does:**
1. **Runs**: On a daily schedule to enforce compliance policies
2. **Queries**: For apps that meet ALL these criteria:
   - Compliance was requested more than X days ago (configurable via environment variable `admin_QuarantineAppsafterxdaysofnoncompliance`, default: 7 days)
   - App has a risk assessment state of non-compliant (`admin_adminrequirementriskassessmentstate` = 597910001)
   - App is NOT currently quarantined (`admin_appisquarantined` is null or false)
   - Environment is NOT excused from the quarantine flow (`admin_excusefromappquarantineflow` = false)
   - Environment has a valid environment ID
   - App owner has a valid maker ID
3. **Updates**: For each non-compliant app found:
   - Sets the app's `admin_quarantineapp` field to `true`
   - **Note**: This does NOT directly quarantine the app - it only sets this field as a marker

**Environment Variable:**
- **Quarantine Apps after x days of non-compliance** (`admin_QuarantineAppsafterxdaysofnoncompliance`)
  - Default: 7 days
  - Description: If using the Compliance flow for apps to gather compliance details from makers, specify if you want to quarantine apps if they're not compliant, specified in days.

## Complete Workflow

Here's how the quarantine system works end-to-end:

### Scenario 1: Manual Quarantine by Admin (via UI Button)

1. **Admin Action**: Admin clicks "Quarantine App" button in Power Platform Admin View
2. **Canvas App Dialog**: Opens the quarantine confirmation Canvas App (`admin_ppadminviewquarantineapp`)
3. **Direct API Call**: The Canvas App calls `PowerAppsforAdmins.SetAppQuarantineState()` to directly quarantine the app in Power Platform
4. **Field Update**: After successful quarantine, the Canvas App patches:
   - `admin_quarantineapp` to `true`
   - `admin_quarantineappdate` to today's date
5. **Sync Later**: When inventory sync flows run, they:
   - Read the actual quarantine state from Power Platform
   - Update `admin_appisquarantined` to `true` (matching the Power Platform state)
6. **Flow Triggered (Optional)**: The change to `admin_appisquarantined` may trigger the "Admin | Set app quarantine status" flow, which will send email notifications

**Key Point**: The UI button directly calls the Power Platform API - it does NOT rely on the flow to perform the quarantine.

### Scenario 2: Automated Quarantine for Non-Compliance

1. **Scheduled Run**: The "Admin | Quarantine non-compliant apps" flow runs daily at 10:00 AM UTC
2. **Query Execution**: The flow finds apps that have been non-compliant for more than X days
3. **Filter Applied**: It filters out apps that are already quarantined (using `admin_appisquarantined`)
4. **Field Update**: For each non-compliant app, it sets `admin_quarantineapp` to `true`
5. **Important**: This flow only updates the `admin_quarantineapp` field - it does NOT directly quarantine the app
6. **How Quarantine Happens**: The actual quarantine mechanism for compliance-flagged apps depends on subsequent inventory sync detection and the "Admin | Set app quarantine status" flow reacting to `admin_appisquarantined` changes

**Note**: There appears to be a gap in the automated compliance workflow - setting `admin_quarantineapp` alone does not trigger the actual quarantine. The full compliance enforcement mechanism may involve additional flows or manual admin review.

### Scenario 3: Unquarantine an App (via UI Button)

1. **Admin Action**: Admin clicks "Unquarantine App" button in Power Platform Admin View
2. **Canvas App Dialog**: Opens the unquarantine confirmation Canvas App (`admin_ppadminviewunquarantineapp`)
3. **Direct API Call**: The Canvas App calls `PowerAppsforAdmins.SetAppQuarantineState()` to directly unquarantine the app in Power Platform
4. **Field Update**: After successful unquarantine, the Canvas App patches `admin_quarantineapp` to `false`
5. **Sync Later**: When inventory sync flows run, they update `admin_appisquarantined` to `false`
6. **Flow Triggered (Optional)**: The change to `admin_appisquarantined` may trigger the "Admin | Set app quarantine status" flow for email notifications

## Key Takeaways

1. **Quarantine App (admin_quarantineapp)** = **Record-Keeping Field**
   - Updated by UI buttons AFTER quarantine action is complete
   - Updated by compliance flow to mark non-compliant apps
   - Does NOT trigger any flow when updated
   - Does NOT directly cause quarantine to happen

2. **App Is Quarantined (admin_appisquarantined)** = **Status Indicator & Flow Trigger**
   - Shows the current quarantine state from Power Platform
   - Changes to this field trigger the "Admin | Set app quarantine status" flow
   - Updated by inventory sync flows to match Power Platform reality
   - Should not be manually edited

3. **The Actual Workflow**:
   - **Manual Quarantine**: UI buttons directly call Power Platform API, then update `admin_quarantineapp` for record-keeping
   - **Sync Updates**: Inventory sync flows read Power Platform state and update `admin_appisquarantined`
   - **Flow Response**: Changes to `admin_appisquarantined` trigger the "Admin | Set app quarantine status" flow for email notifications and as a safety backup
   
4. **Where `admin_quarantineapp` is Updated**:
   - **Quarantine App Canvas App** (`admin_ppadminviewquarantineapp`): Sets to `true` after quarantining
   - **Unquarantine App Canvas App** (`admin_ppadminviewunquarantineapp`): Sets to `false` after unquarantining  
   - **Admin | Quarantine non-compliant apps flow**: Sets to `true` for non-compliant apps

5. **Email Notifications**: App makers are notified when their apps are quarantined or released (via the "Admin | Set app quarantine status" flow)

6. **Automated Compliance**: The daily compliance flow marks apps with `admin_quarantineapp = true`, but the full quarantine enforcement mechanism may require additional steps

7. **Environment Control**: The `ProductionEnvironment` variable controls whether quarantine actions actually execute in Power Platform (for testing purposes)

## Configuration

To use the quarantine functionality:

1. **Install** the CoE Governance solution and CoE Core solution
2. **Configure** environment variables:
   - `admin_QuarantineAppsafterxdaysofnoncompliance` - Set the compliance grace period (default: 7 days)
   - `admin_ProductionEnvironment` - Set to `true` for production, `false` for testing
3. **Turn on** the required flows:
   - Admin | Set app quarantine status (Audit Components solution)
   - Admin | Quarantine non-compliant apps (Audit Components solution) - if using automated compliance enforcement
   - Inventory sync flows (Core Components solution) - to update status fields
4. **Configure** connections:
   - Power Platform for Admins connector (to execute quarantine actions)
   - Dataverse connector (to read/update records)
5. **Use** the Power Platform Admin View app to manually quarantine/unquarantine apps as needed

## Additional Resources

- [CoE Starter Kit Documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- [Power Platform Admin Connector Documentation](https://learn.microsoft.com/connectors/powerplatformforadmins/)
- [App Quarantine Overview](https://learn.microsoft.com/power-platform/admin/powerapps-powershell#quarantine-apps)
- [CoE Governance Components](https://learn.microsoft.com/power-platform/guidance/coe/governance-components)
