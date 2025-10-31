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
This field is an **action trigger field** used by administrators or automated processes to initiate the quarantine or unquarantine action for an app. When this field is updated, it indirectly triggers the workflow that performs the actual quarantine operation.

**How It's Used:**
1. **User Interface Actions**: The field is connected to two command bar buttons in the Power Platform Admin View:
   - **"Quarantine App"** button (`admin__QuarantineApp`) - Updates this field to initiate quarantine
   - **"Unquarantine App"** button (`admin__UnquarantineApp`) - Updates this field to initiate unquarantine

2. **Compliance Automation**: The **"Admin | Quarantine non-compliant apps"** flow sets this field to `true` for apps that have been non-compliant for too long

3. **Trigger Mechanism**: When the `admin_quarantineapp` field is updated, it causes a change that eventually triggers the **"Admin | Set app quarantine status"** flow to execute the actual quarantine/unquarantine operation

**Important Notes:**
- This is an **action trigger field**, not a status field
- It does not reliably reflect the current quarantine state of the app
- It's primarily used to initiate changes to the quarantine status
- The field value itself doesn't prevent users from accessing the app - it's the actual quarantine state in Power Platform that does

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
- Set to the current date (UTC) when an app is quarantined by the "Admin | Set app quarantine status" flow
- Cleared (set to null) when an app is unquarantined
- Used for tracking and reporting purposes

## Flows

### 1. Admin | Set app quarantine status

**Display Name:** Admin | Set app quarantine status
**Flow Name (Technical):** AdminSetappquarantinestatus
**Trigger:** When the `admin_appisquarantined` field is added, modified, or deleted on the admin_app entity

**What It Does:**
1. **Triggered by**: Changes to the `admin_appisquarantined` field (typically caused by inventory sync detecting a change, or when the appaction buttons update the field)
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
This flow is reactive - it responds to changes in the `admin_appisquarantined` field and then performs the corresponding action in Power Platform. The flow does NOT update `admin_appisquarantined` itself; that's done by the inventory sync flows.

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
   - This initiates the quarantine process (details below in workflow section)

**Environment Variable:**
- **Quarantine Apps after x days of non-compliance** (`admin_QuarantineAppsafterxdaysofnoncompliance`)
  - Default: 7 days
  - Description: If using the Compliance flow for apps to gather compliance details from makers, specify if you want to quarantine apps if they're not compliant, specified in days.

## Complete Workflow

Here's how the quarantine system works end-to-end:

### Scenario 1: Manual Quarantine by Admin

1. **Admin Action**: Admin clicks "Quarantine App" button in Power Platform Admin View (appaction)
2. **Field Update**: The button's JavaScript updates the `admin_quarantineapp` field to `true`
3. **Appaction triggers**: The appaction may also directly update `admin_appisquarantined` field (implementation detail of the appaction)
4. **Flow Triggered**: The change to `admin_appisquarantined` triggers the "Admin | Set app quarantine status" flow
5. **Flow Reads**: The flow reads the current `admin_appisquarantined` value from the record
6. **Flow Decides**: Since `admin_appisquarantined` indicates quarantine is needed, the flow:
   - Calls Power Platform Admin connector to quarantine the app
   - Sets `admin_quarantineappdate` to today's date
7. **Email Sent**: The flow sends an email to the app maker notifying them of the quarantine
8. **Sync Updates**: Later, when the inventory sync flows run, they read the actual quarantine state from Power Platform and confirm `admin_appisquarantined` is correctly set to `true`

### Scenario 2: Automated Quarantine for Non-Compliance

1. **Scheduled Run**: The "Admin | Quarantine non-compliant apps" flow runs daily at 10:00 AM UTC
2. **Query Execution**: The flow finds apps that have been non-compliant for more than X days
3. **Filter Applied**: It filters out apps that are already quarantined (using `admin_appisquarantined`)
4. **Field Update**: For each non-compliant app, it sets `admin_quarantineapp` to `true`
5. **Indirect Trigger**: This update causes a subsequent update to `admin_appisquarantined`
6. **Flow Execution**: Steps 4-8 from Scenario 1 (Flow Triggered through Email Sent) then execute automatically for each app

### Scenario 3: Unquarantine an App

1. **Admin Action**: Admin clicks "Unquarantine App" button in Power Platform Admin View
2. **Field Update**: The button's JavaScript updates the `admin_quarantineapp` field (and possibly `admin_appisquarantined`)
3. **Flow Triggered**: The change to `admin_appisquarantined` triggers the "Admin | Set app quarantine status" flow
4. **Flow Reads**: The flow reads the current `admin_appisquarantined` value
5. **Flow Decides**: Since `admin_appisquarantined` is `false`, the flow:
   - Calls Power Platform Admin connector to unquarantine the app
   - Clears `admin_quarantineappdate` (sets to null)
6. **Email Sent**: The flow sends an email to the app maker notifying them of the release from quarantine
7. **Sync Updates**: Later, inventory sync flows confirm the state matches reality

## Key Takeaways

1. **Quarantine App (admin_quarantineapp)** = **Action Trigger** 
   - Used to initiate quarantine/unquarantine actions
   - Updated by admin UI buttons or compliance flows
   - Does NOT reflect current status reliably

2. **App Is Quarantined (admin_appisquarantined)** = **Status Indicator & Flow Trigger**
   - Shows the current quarantine state
   - Changes to this field trigger the "Admin | Set app quarantine status" flow
   - Updated by inventory sync flows to match Power Platform reality
   - Should not be manually edited

3. **The Flow Relationship**:
   - `admin_quarantineapp` is updated → causes update to `admin_appisquarantined` → triggers flow
   - The flow reads `admin_appisquarantined` and performs the corresponding action
   - The actual quarantine is performed by calling Power Platform Admin connector
   - Inventory sync flows later update `admin_appisquarantined` to reflect true state

4. **Email Notifications**: App makers are notified when their apps are quarantined or released

5. **Automated Compliance**: Daily flows can automatically quarantine non-compliant apps after a grace period

6. **Environment Control**: The `ProductionEnvironment` variable controls whether quarantine actions actually execute in Power Platform (for testing purposes)

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
