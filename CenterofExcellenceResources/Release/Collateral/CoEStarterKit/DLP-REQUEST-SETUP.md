# DLP Request Feature - Setup Guide

This guide explains how to configure DLP policies so they appear in the CoE Maker Command Center for DLP exemption requests.

## Overview

The DLP Request feature allows makers to request exemptions from DLP policies through the Maker Command Center app. However, DLP policies are **not automatically synced** from the Power Platform Admin Center to the CoE Dataverse tables. Administrators must manually configure which policies should be visible to makers.

## Why Isn't My New DLP Policy Visible?

If you've created a new DLP policy in the Power Platform Admin Center and it's not visible in the Maker Command Center, this is expected behavior. The DLP Request flows only sync policies that:

1. Already exist in the **DLP Policy** table in Dataverse
2. Have the **Is Shared** field set to **Yes**

## How to Make a DLP Policy Visible to Makers

### Step 1: Create a DLP Policy Record in Dataverse

1. Open the CoE Power Platform Admin View (Model-driven app)
2. Navigate to **DLP Policies** table
3. Click **+ New** to create a new record
4. Fill in the following fields:
   - **Name**: The display name of your DLP policy (as it appears in Power Platform Admin Center)
   - **Policy Id**: The unique identifier (GUID) of the policy from Power Platform Admin Center
   - **Description**: (Optional) Details about the policy that will be shown to makers
   - **Scope**: Select the appropriate scope (All environments, Include certain environments, or Exclude certain environments)
   - **Is Shared**: Set to **Yes** to make this policy visible to makers

### Step 2: Get the Policy Id from Power Platform Admin Center

To find the Policy Id:
1. Go to [Power Platform Admin Center](https://admin.powerplatform.microsoft.com)
2. Navigate to **Policies** > **Data policies**
3. Click on your DLP policy
4. The Policy Id is shown in the URL: `https://admin.powerplatform.microsoft.com/policies/dlp/[POLICY-ID]/edit`

### Step 3: Enable the Sync Flows

Ensure the following flows are enabled in your CoE environment:

- **DLP Request: Sync Shared Policies** - Runs daily to sync blocked connectors for shared policies
- **DLP Request: Sync new Policy** - Triggers when a DLP Policy record is modified with Is Shared = Yes
- **DLP Request: Sync Policy to Dataverse (Child)** - Child flow that syncs the blocked connectors

## How the Sync Process Works

1. **DLP Request: Sync Shared Policies** runs daily and queries Dataverse for all DLP Policy records where `Is Shared = Yes`
2. For each shared policy, it calls the child flow to sync blocked connectors from the Power Platform API
3. **DLP Request: Sync new Policy** triggers immediately when a DLP Policy record is created or modified with `Is Shared = Yes`
4. The blocked connectors are then stored in Dataverse and displayed in the Maker Command Center

## Troubleshooting

### Policy still not visible after setup

1. Verify the **Policy Id** matches exactly with the Power Platform Admin Center
2. Confirm **Is Shared** is set to **Yes**
3. Check that the sync flows are enabled and running successfully
4. Wait for the **DLP Request: Sync Shared Policies** flow to run (runs daily) or manually trigger it

### Blocked connectors not showing correctly

1. Run the **DLP Request: Sync Shared Policies** flow manually
2. Check the flow run history for any errors
3. Verify the Power Platform for Admins connection reference is configured correctly

## Related Flows

| Flow Name | Purpose | Trigger |
|-----------|---------|---------|
| DLP Request: Sync Shared Policies | Syncs all shared policies daily | Scheduled (Daily) |
| DLP Request: Sync new Policy | Syncs newly shared policies | Dataverse row change |
| DLP Request: Sync Policy to Dataverse (Child) | Child flow to sync blocked connectors | Called by parent flows |
| DLP Request: Apply Policy to Environment (Child) | Applies policy exemptions | Called when exemption approved |
| DLP Request: Process Approved Policy Change | Processes approved exemption requests | Approval workflow |

## Additional Resources

- [CoE Starter Kit Documentation](https://docs.microsoft.com/power-platform/guidance/coe/starter-kit)
- [DLP Policies Overview](https://docs.microsoft.com/power-platform/admin/wp-data-loss-prevention)
