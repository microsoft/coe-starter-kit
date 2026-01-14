# How-To: Restrict Maker Notifications to Specific Users (Pilot Testing)

## Scenario

You want to test maker notifications with a select group of users before rolling out to your entire organization. This guide shows you how to configure the CoE Starter Kit to send notifications only to users in your pilot group.

## Use Cases

- **Pilot Testing**: Test governance workflows with a small group
- **Phased Rollout**: Gradually introduce maker notifications
- **Specific Teams**: Target notifications to specific departments or teams
- **VIP Users**: Send notifications only to specific user groups

## Prerequisites

- CoE Starter Kit Governance solution installed
- System Administrator or System Customizer role in the CoE environment
- Access to modify flows in Power Automate
- List of pilot user email addresses

## Solution Overview

We'll create an environment variable or custom table to store pilot user emails and modify notification flows to check if the maker is in the pilot list before sending emails.

## Method 1: Using Environment Variable (Simple)

### Step 1: Create Environment Variable for Pilot Users

1. Navigate to **Power Apps** (make.powerapps.com)
2. Select your **CoE environment**
3. Go to **Solutions** → **Center of Excellence - Core Components**
4. Click **+ New** → **More** → **Environment variable**
5. Configure:
   - **Display name**: `Notification Pilot Users`
   - **Name**: `admin_NotificationPilotUsers`
   - **Data Type**: Text
   - **Default Value**: Leave blank
   - **Description**: `Semicolon-separated list of user email addresses to receive maker notifications during pilot. Leave empty to disable pilot mode.`
6. Click **Save**

### Step 2: Set Pilot User Emails

1. Click **+ New environment variable value**
2. In **Value** field, enter email addresses separated by semicolons:
   ```
   user1@contoso.com;user2@contoso.com;user3@contoso.com
   ```
3. Click **Save**

> **Note**: Use semicolons (;) instead of commas to avoid issues with email addresses containing commas.

### Step 3: Modify the Welcome Email Flow

1. In **Solutions**, open **Center of Excellence - Core Components**
2. Find flow **Admin | Welcome Email v3**
3. Click **Edit**
4. After the trigger, add these steps:

#### Add Compose Action for Pilot Users

- **Action**: Compose
- **Name**: `Get Pilot Users List`
- **Inputs**: 
  ```
  @parameters('Notification Pilot Users (admin_NotificationPilotUsers)')
  ```

#### Add Compose Action for Maker Email

- **Action**: Compose  
- **Name**: `Get Maker Email`
- **Inputs**: Select the maker's email from the trigger data (typically `admin_makerid` → email field)

#### Add Condition

- **Action**: Condition
- **Name**: `Check if User is in Pilot or Pilot Mode Disabled`
- Configure the condition:
  - **Condition 1** (Or): `Get Pilot Users List` **is equal to** (empty)
  - **Condition 2** (Or): `Get Pilot Users List` **contains** `Get Maker Email`

#### Update Flow Logic

1. Move all existing notification actions into the **If yes** branch
2. In the **If no** branch:
   - **Action**: Terminate
   - **Status**: Cancelled  
   - **Message**: `User not in pilot list - notification skipped`
3. **Save** the flow

### Step 4: Test the Configuration

1. Have a pilot user create an app or flow
2. Verify they receive the welcome email
3. Have a non-pilot user create an app or flow  
4. Verify no email is sent (check flow run history)

## Method 2: Using Custom Table (Advanced)

For better management of pilot users and additional metadata:

### Step 1: Create Custom Table

1. In **Solutions** → **Center of Excellence - Core Components**
2. Click **+ New** → **Table**
3. Configure table:
   - **Display name**: Notification Pilot Users
   - **Plural name**: Notification Pilot Users
   - **Name**: admin_notificationpilotusers
   - **Primary column**: User Email
4. Add columns:
   - **User Email** (Single line of text) - Primary column
   - **Full Name** (Single line of text)
   - **Department** (Single line of text)
   - **Include in Pilot** (Yes/No) - Default: Yes
   - **Start Date** (Date only)
   - **End Date** (Date only) - Optional
   - **Notes** (Multiple lines of text)

### Step 2: Populate Pilot Users

1. Open the table
2. Add records for each pilot user:
   ```
   User Email: user1@contoso.com
   Full Name: John Doe
   Department: IT
   Include in Pilot: Yes
   Start Date: [Today's date]
   ```

### Step 3: Modify Flow with Table Lookup

1. Edit the flow **Admin | Welcome Email v3**
2. After the trigger, add:

#### List Rows Action

- **Action**: List rows
- **Name**: `Check if User is Pilot User`
- **Table**: Notification Pilot Users
- **Filter rows**: 
  ```
  admin_useremail eq '@{triggerBody()?['admin_makerid']?['internalemailaddress']}' and admin_includeinpilot eq true
  ```
- **Select columns**: `admin_useremail,admin_fullname`
- **Row count**: 1

#### Add Condition

- **Action**: Condition
- **Name**: `Is User in Pilot List`
- **Condition**: 
  ```
  length(outputs('Check_if_User_is_Pilot_User')?['body/value'])
  ```
  **is greater than** `0`

#### Update Flow Logic

1. Move notification actions into **If yes** branch
2. In **If no** branch, add **Terminate** action
3. **Save** the flow

## Method 3: Hybrid Approach (Environment + User Filtering)

Combine both environment and user filtering:

### Flow Structure

```
┌──────────────────────┐
│  Trigger             │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│  Get Pilot Config    │
└──────────┬───────────┘
           │
           ▼
     ┌─────┴─────┐
     │ Pilot     │
     │ Enabled?  │
     └─────┬─────┘
           │
      Yes  │  No
           │
    ┌──────┴──────┐
    ▼             ▼
┌────────┐   ┌────────┐
│ Check  │   │ Send   │
│ User & │   │ to All │
│ Env    │   │        │
└───┬────┘   └────────┘
    │
    ▼
┌────────┐
│ Send   │
│ Email  │
└────────┘
```

## Managing Pilot Users

### Adding Users

**Environment Variable Method**:
1. Edit environment variable value
2. Add new email to semicolon-separated list
3. Save

**Table Method**:
1. Add new row to Notification Pilot Users table
2. Set Include in Pilot = Yes

### Removing Users

**Environment Variable Method**:
1. Edit environment variable value
2. Remove email from list
3. Save

**Table Method**:
1. Edit user record
2. Set Include in Pilot = No
3. Or delete the record

### Disabling Pilot Mode

**Environment Variable Method**:
- Clear the environment variable value (leave empty)
- Flows will then send notifications to all users

**Table Method**:
- Option A: Set all records' "Include in Pilot" to No
- Option B: Remove the pilot check condition from flows

## Applying to Other Notification Flows

Apply the same modifications to:

1. **Admin | Compliance Details Request eMail (Apps)**
2. **Admin | Compliance Details Request eMail (Flows)**  
3. **Admin | Compliance Details Request eMail (Custom Connectors)**
4. **Admin | Compliance Details Request eMail (Chatbots)**
5. **Admin | Compliance Details Request eMail (Desktop Flows)**

For compliance request flows:
- The maker/owner email is typically in the resource record
- You may need to add a **Get row** action to retrieve owner information
- Adapt the filter to check against the owner's email

## Advanced Scenarios

### Time-Based Pilot

Add date-based conditions to automatically enable/disable pilot users:

```
Condition: 
  Start Date <= Today 
  AND (End Date is empty OR End Date >= Today)
```

### Department-Based Filtering

Filter by department:

```
Filter rows: 
  admin_useremail eq '[MAKER_EMAIL]' 
  and admin_department eq 'IT'
  and admin_includeinpilot eq true
```

### Notification Preference

Add a preference column to let users opt-in/opt-out:

```
Columns:
  - Notification Preference (Choice): 
    - All Notifications
    - Critical Only  
    - None
```

## Monitoring and Reporting

### Track Pilot User Activity

Create a Power BI report or Canvas app to monitor:
- Number of pilot users
- Notifications sent to pilot users
- Pilot user engagement
- Apps/flows created by pilot users

### Flow Run History

Monitor flow runs to track:
- How many notifications were sent
- How many were skipped (not in pilot)
- Any errors or failures

### Query Example

```
List rows from Flow Runs
Filter: Flow Name contains 'Welcome Email'
        and Status eq 'Cancelled'
        and Cancelled Message contains 'pilot'
```

## Troubleshooting

### Pilot users not receiving emails

1. Verify email addresses are correct (no typos)
2. Check environment variable/table has correct values
3. Review flow run history for errors
4. Ensure pilot user actually created a resource that triggers the flow
5. Check maker email in CoE database matches pilot list

### Non-pilot users receiving emails

1. Confirm pilot mode is enabled (environment variable not empty or table has records)
2. Verify flow modifications were saved
3. Check condition logic is correct
4. Ensure flow is using the latest version

### Flow errors

1. Review error message in flow run history
2. Common issues:
   - Email field not available in trigger data
   - Incorrect table/column names
   - Missing permissions
3. Test with a known pilot user first

## Best Practices

1. **Start Small**: Begin with 5-10 pilot users
2. **Document**: Keep a list of pilot users and reasons for inclusion
3. **Communicate**: Inform pilot users they're in the pilot program
4. **Gather Feedback**: Collect feedback from pilot users
5. **Plan Rollout**: Define criteria for exiting pilot mode
6. **Backup Flows**: Export flows before modification

## Transitioning Out of Pilot

When ready to enable for all users:

1. **Environment Variable Method**: 
   - Clear the environment variable value
   - Save and test

2. **Table Method**:
   - Option A: Disable the pilot check in flows
   - Option B: Add all users to the pilot table (not recommended)
   - Option C: Modify condition to check if pilot mode is disabled

3. **Gradual Rollout**:
   - Add users in batches (e.g., 50 users per week)
   - Monitor notification volume and user feedback
   - Adjust as needed

## Related Documentation

- [Filtering Maker Notifications](./FilteringMakerNotifications.md) - Overview of all filtering options
- [How-To: Restrict to Specific Environments](./HowTo-RestrictNotificationsToEnvironment.md)
- [CoE Starter Kit Governance](https://learn.microsoft.com/power-platform/guidance/coe/governance-components)

## Support

If you need help:
- [GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues)
- [Power Platform Community](https://powerusers.microsoft.com/)
- Review flow run history for detailed errors

---

**Last Updated**: December 2024  
**Applies to**: CoE Starter Kit v3.0 and later
