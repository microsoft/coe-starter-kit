# Sample Issue Responses

This document contains sample responses for common issue patterns that can be copied and customized when responding to GitHub issues.

## Table of Contents

1. [Setup Wizard - Dataflow Step Skipped](#setup-wizard---dataflow-step-skipped)
2. [Power BI Dashboard Blank/No Data](#power-bi-dashboard-blankno-data)
3. [Combined Setup Wizard and Power BI Issues](#combined-setup-wizard-and-power-bi-issues)
4. [Missing Information Request](#missing-information-request)

---

## Setup Wizard - Dataflow Step Skipped

**Use when:** User reports that setup wizard skips "Configure dataflows (Data export)" step

```markdown
Thank you for reporting this issue. The behavior you're seeing with the setup wizard skipping the "Configure dataflows (Data export)" step is **expected behavior** in most scenarios.

### Why the Step is Skipped

The "Configure dataflows (Data export)" step only appears when **all** of the following conditions are met:

1. ✅ You selected **"Data Export"** as your inventory and telemetry method in the "Configure inventory data source" step
2. ✅ Data Export features are enabled in your environment
3. ✅ Your licensing supports Dataverse Data Export capabilities

If you selected **"Cloud flows"** (which is the recommended method for most organizations) or **"None"** as your inventory method, the dataflows step will automatically be skipped. This is by design.

### How to Verify Your Selection

To confirm which method you're using:

1. In the Setup Wizard, navigate back to the "Configure inventory data source" step
2. Check which option is selected:
   - **Cloud flows** → Dataflows step will be skipped ✓
   - **Data Export** → Dataflows step should appear
   - **None** → Dataflows step will be skipped ✓

### Recommended Approach

**Cloud flows** is the recommended inventory method for most organizations because:
- ✅ Easier to set up and maintain
- ✅ Works with standard Power Platform licensing
- ✅ Provides all necessary data for CoE dashboards and apps
- ✅ No additional infrastructure required

**Note:** BYODL (Bring Your Own Data Lake) / Data Export is no longer the recommended approach. Microsoft is moving toward integration with Microsoft Fabric for advanced analytics scenarios.

### Next Steps

If you selected "Cloud flows" as your method, you can proceed with the setup:
1. Continue to the next step (Share Apps)
2. Complete the remaining wizard steps
3. Wait for inventory flows to complete (4-8 hours)

If you intended to use Data Export and need the dataflow step:
1. Return to "Configure inventory data source" step
2. Select "Data Export"
3. Complete the setup with Data Export configuration

### References

- [Choose your inventory method](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup-core-components#inventory-and-telemetry)
- [Setup wizard documentation](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup-core-components)
- [CoE Starter Kit setup overview](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup)

Please let us know if you have any questions or if the issue persists after verifying your inventory method selection.
```

---

## Power BI Dashboard Blank/No Data

**Use when:** User reports Power BI dashboard shows no data or blank visualizations

```markdown
Thank you for reporting this issue. A blank Power BI dashboard is a common scenario that typically has a straightforward resolution. Let me help you troubleshoot this.

### Most Common Cause: Inventory Collection Not Complete

The most frequent cause of a blank dashboard is that the **initial inventory collection hasn't completed yet**. This process takes time, especially for the first run.

**Expected timeline:**
- First-time inventory: **4-8 hours minimum**
- Large tenants (many environments/apps): Up to 24 hours
- Incremental updates: 1-2 hours

### Verification Steps

Please complete these steps to diagnose the issue:

#### 1. Verify Inventory Flows Have Run

1. Navigate to **Cloud flows** in your CoE environment
2. Find the **"Admin | Sync Template v3"** flow
3. Check the **28-day run history**:
   - ✅ Successful runs (green checkmarks) → Inventory is running
   - ❌ Failed runs (red X) → There's an issue with the flows
   - ⏱️ In-progress runs → Wait for completion

4. If you just completed the setup wizard:
   - **Wait at least 4-8 hours** before expecting data
   - Check back periodically for completion

#### 2. Check Data in Dataverse Tables

1. Open your **CoE environment** in Power Apps
2. Navigate to **Tables** (under Dataverse in the left menu)
3. Check if these key tables contain records:
   - **Environment** - Should have entries for your tenant's environments
   - **Power Apps App** - Should contain app inventory  
   - **Flow** - Should contain flow inventory
   - **Power Apps Connector** - Should list connectors in use

4. If these tables are **empty**:
   - Inventory flows haven't completed successfully yet
   - Review flow run history for errors

5. If these tables **have data** but dashboard is still blank:
   - Continue to step 3 below

#### 3. Verify Power BI Configuration

1. **Use the correct template file:**
   - Download the `.pbit` template file from the latest CoE Starter Kit release
   - File name: `Production_CoEDashboard_[version].pbit`

2. **Open template in Power BI Desktop:**
   - Requires Power BI Desktop (not Power BI Service)
   - Latest version recommended

3. **Enter your CoE environment URL when prompted:**
   - Format: `https://[your-org-name].crm[region].dynamics.com/`
   - Example for North America: `https://contoso.crm.dynamics.com/`
   - Example for Europe: `https://contoso.crm4.dynamics.com/`
   
   **How to find your environment URL:**
   - Go to [Power Platform Admin Center](https://admin.powerplatform.microsoft.com)
   - Select **Environments**
   - Find your CoE environment
   - Copy the **Environment URL**

4. **Sign in with appropriate credentials:**
   - Use your organizational account
   - Account must have access to the CoE environment

5. **Wait for data to load:**
   - Initial load may take 5-10 minutes
   - Don't close Power BI during loading

6. **Verify data appears:**
   - Check that visualizations show data
   - Navigate through report pages

### Common Issues and Solutions

**Issue:** Connected to wrong environment
- **Solution:** Verify the environment URL matches your CoE environment

**Issue:** Insufficient permissions  
- **Solution:** Ensure your user has read access to CoE Dataverse tables

**Issue:** Stale cached data
- **Solution:** Click **Refresh** button in Power BI Desktop

### Next Steps

Based on the symptoms you described, please:

1. **Check when you completed the setup wizard:**
   - If it was less than 8 hours ago → **Wait for inventory to complete**
   - If it was more than 24 hours ago → Check flow run history for errors

2. **Verify the Dataverse tables contain data** (as described above)

3. **Confirm your Power BI configuration** uses the correct environment URL

4. **Share your findings** with the following information:
   - How long ago did you complete the setup wizard?
   - Do the Dataverse tables contain records?
   - What environment URL did you use in Power BI?
   - Any error messages in flow run history?

### Additional Resources

- [Setup Power BI Dashboard](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup-powerbi)
- [Troubleshooting Guide](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup-core-components#troubleshooting)
- [Power BI Dashboard Documentation](https://learn.microsoft.com/en-us/power-platform/guidance/coe/power-bi)

Please let us know the results of your verification steps, and we can provide more specific guidance based on what you find.
```

---

## Combined Setup Wizard and Power BI Issues

**Use when:** User reports both setup wizard behavior and Power BI dashboard issues (like the current issue)

```markdown
Thank you for reporting these issues. Let me address both of your concerns about the setup wizard and Power BI dashboard.

## Issue 1: Configure Dataflows Step Skipped

The behavior you're seeing where the setup wizard skips "Configure dataflows (Data export)" and moves directly to "Share Apps" is **expected behavior** in most scenarios.

### Why This Happens

The "Configure dataflows (Data export)" step only appears when you've selected **"Data Export"** as your inventory and telemetry method. If you selected **"Cloud flows"** (which is the recommended method), this step is automatically skipped by design.

**Cloud flows is recommended** because:
- ✅ Easier to set up and maintain
- ✅ Works with standard licensing
- ✅ Provides all necessary data for dashboards
- ✅ No additional infrastructure required

**Note:** BYODL (Bring Your Own Data Lake) / Data Export is no longer the recommended approach per Microsoft's latest guidance.

### To Verify

Check which inventory method you selected:
1. In Setup Wizard, go to "Configure inventory data source" step
2. If "Cloud flows" is selected → Dataflows step will be skipped (expected ✓)
3. If "Data Export" is selected → Dataflows step should appear

**Recommendation:** Continue with Cloud flows. The setup wizard behavior is correct.

## Issue 2: Power BI Dashboard Shows Blank/No Data

This is a very common scenario with a straightforward resolution. The most likely cause is that **inventory collection hasn't completed yet**.

### Expected Timeline

Initial inventory collection takes significant time:
- **Minimum**: 4-8 hours
- **Large tenants**: Up to 24 hours  
- **Incremental updates**: 1-2 hours

### Immediate Action Items

Please complete these verification steps:

#### 1. Check Inventory Flow Status

1. Navigate to **Cloud flows** in your CoE environment
2. Open **"Admin | Sync Template v3"** flow
3. Check the **run history**:
   - Look for successful runs (green checkmarks)
   - Check if flows are still in progress
   - Look for any failed runs (red X)

**If just completed setup:** Wait at least 4-8 hours before expecting data in the dashboard.

#### 2. Verify Data in Dataverse

1. Open your CoE environment in **Power Apps**
2. Go to **Tables** (under Dataverse)
3. Check if these tables contain records:
   - **Environment**
   - **Power Apps App**
   - **Flow**
   - **Power Apps Connector**

**If tables are empty:** Inventory hasn't completed yet - wait for flows to finish.
**If tables have data:** Continue to step 3.

#### 3. Configure Power BI Dashboard Correctly

The screenshot you shared shows you're viewing the dashboard in Power Apps, which may not be the right approach. Here's the proper setup:

1. **Download the Power BI template file:**
   - From CoE Starter Kit release: `Production_CoEDashboard_[version].pbit`

2. **Open in Power BI Desktop:**
   - You need Power BI Desktop installed (free download)
   - Don't use Power BI Service for initial setup

3. **Enter your environment URL:**
   - Format: `https://[orgname].crm[region].dynamics.com/`
   - Find this in Power Platform Admin Center > Environments

4. **Authenticate and load data:**
   - Sign in with your admin account
   - Wait for data to load (5-10 minutes)

5. **Verify visualizations show data**

### What to Expect at "Publish Power BI Dashboard" Step

At the "Publish Power BI Dashboard" step in the setup wizard:

1. **No automatic publishing happens** - This is just informational
2. You need to **manually download and configure** the .pbit file as described above
3. Click "Next" to proceed to "Finish"
4. After wizard completion, set up the dashboard separately

### Accessing the Dashboard

There are two ways to access the Power BI dashboard:

**Option A: Power BI Desktop** (Recommended for initial setup)
- Download and open .pbit template
- Configure with your environment URL
- View and interact with data locally

**Option B: Power BI Service** (For sharing)
- After configuring in Desktop, publish to Power BI Service
- Requires Power BI Pro/Premium licenses
- Can share with other users

The dashboard you showed in your screenshot appears to be a Power App, not the Power BI dashboard. The Power BI dashboard is a separate component accessed through Power BI Desktop or Service.

### Summary of Next Steps

1. ✅ **Accept that dataflow step being skipped is expected** (if using Cloud flows)
2. ⏱️ **Wait 4-8 hours** after setup completion for inventory to collect
3. ✅ **Verify inventory flows are running** successfully
4. ✅ **Check Dataverse tables** contain records
5. 📊 **Download and configure Power BI template** in Power BI Desktop with correct environment URL
6. 📋 **Report back** with your findings so we can provide more specific help

### What Information Would Help Us

To provide more targeted assistance, please share:

1. **How long ago did you complete the setup wizard?**
2. **What inventory method did you select?** (Cloud flows or Data Export)
3. **Do the Dataverse tables contain records?** (Environment, Apps, Flows)
4. **Have the inventory flows run successfully?** (Check run history)
5. **Are you trying to open the dashboard in Power BI Desktop or elsewhere?**

### References

- [Setup Core Components](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup-core-components)
- [Setup Power BI Dashboard](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup-powerbi)
- [Choose Inventory Method](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup-core-components#inventory-and-telemetry)
- [Troubleshooting Guide](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup-core-components#troubleshooting)

We're here to help! Please provide the requested information, and we'll guide you through resolving these issues.
```

---

## Missing Information Request

**Use when:** Issue doesn't contain enough detail for diagnosis

```markdown
Thank you for raising this issue. To help us resolve it efficiently, could you please provide the following details:

### Required Information

1. **Solution name and version:**
   - Which CoE solution? (Core, Governance, Nurture, etc.)
   - What version number?

2. **Environment details:**
   - Is this a production or trial environment?
   - What region is your environment in?
   - What licensing do you have? (Power Apps Per User, Microsoft 365, etc.)

3. **Inventory/telemetry method:**
   - Are you using Cloud flows, Data Export, or None?
   - Was this selected during setup wizard?

4. **Timing:**
   - When did you complete the setup wizard?
   - How long ago did the issue start?
   - Is this after an upgrade or initial setup?

5. **Steps to reproduce:**
   - What specific steps led to this issue?
   - Can you reproduce it consistently?

6. **Expected vs Actual behavior:**
   - What did you expect to happen?
   - What actually happened?
   - Are there any error messages?

7. **Supporting information:**
   - Screenshots of the issue
   - Flow run history (if applicable)
   - Error messages or logs
   - Environment URL format (with sensitive info redacted)

### Why This Information Helps

These details help us:
- ✅ Identify if this is a known issue with existing solutions
- ✅ Determine root cause more quickly
- ✅ Provide accurate troubleshooting steps
- ✅ Prevent back-and-forth requests for information
- ✅ Help others who may encounter similar issues

### Next Steps

Once you provide this information, we'll:
1. Analyze the issue against known patterns
2. Search for similar resolved issues
3. Provide specific troubleshooting steps
4. Guide you toward resolution

Thank you for helping us help you! We'll respond as soon as you provide the requested details.

### Helpful Links While You Gather Information

- [Setup documentation](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup-core-components)
- [Troubleshooting guide](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup-core-components#troubleshooting)
- [CoE Starter Kit overview](https://learn.microsoft.com/en-us/power-platform/guidance/coe/starter-kit)
```

---

## Contributing

When you identify a new pattern or successfully resolve an issue that could benefit others:

1. Document the issue pattern
2. Create a sample response
3. Add to this file
4. Submit a PR

Include:
- Clear trigger criteria (when to use this response)
- Complete response text
- Links to official documentation
- Troubleshooting steps where applicable

---

*Last updated: 2025-12-10*
