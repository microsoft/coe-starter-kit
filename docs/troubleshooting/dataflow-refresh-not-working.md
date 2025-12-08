# Dataflow Refresh Not Working - Issue Response Template

## Issue Pattern
**Symptoms:**
- Only the first dataflow (Makers) refreshes on schedule
- Subsequent dataflows show old "last refresh" dates
- Dataflows were published but aren't refreshing sequentially

**Affected Components:**
- Core solution (BYODL configuration)
- Dataflows: Makers, Environment, Flow, App, Model App

## Standard Response

Thank you for reporting this issue. This is a common configuration issue with the CoE Starter Kit BYODL (Bring Your Own Data Lake) dataflow setup.

### Quick Diagnosis

The CoE dataflows are designed to refresh sequentially:
1. **Maker Dataflow** (scheduled) → triggers on completion →
2. **Environment Dataflow** → triggers on completion →
3. **Flow, App, and Model App Dataflows** (in parallel)

When only the first dataflow refreshes, it usually indicates one of these issues:

### Most Common Causes

#### 1. Environment Variables Not Set
The cloud flows that trigger subsequent dataflows rely on environment variables containing the dataflow IDs.

**Check these environment variables in your solution:**
- `Maker Dataflow ID` (admin_MakerDataflowID)
- `Environment Dataflow ID` (admin_EnvironmentDataflowID)  
- `Flow Dataflow ID` (admin_FlowDataflowID)
- `App Dataflow ID` (admin_AppDataflowID)
- `Model App Dataflow ID` (admin_ModelAppDataflowID)
- `Current Environment` (admin_CurrentEnvironment)

**How to find dataflow IDs:**
1. Navigate to https://make.powerapps.com
2. Select your CoE environment
3. Go to Dataflows
4. Open each dataflow
5. Copy the ID from the URL: `https://make.powerapps.com/environments/{env-id}/dataflows/{dataflow-id}`

Update the environment variables with the actual dataflow IDs.

#### 2. Cloud Flows Not Enabled
The "When dataflow refresh completes" flows must be turned ON.

**Turn on these flows:**
- `CoE BYODL - When Maker dataflow refresh is complete`
- `CoE BYODL - When Environment dataflow refresh is complete`  
- `CoE BYODL - When Flow dataflow refresh is complete`
- `CoE BYODL - When App dataflow refresh is complete`
- `CoE BYODL - When Model App dataflow refresh is complete`

#### 3. Missing Connection References
Verify these connections are configured:
- `admin_CoECoreDataverse2` (Dataverse)
- `admin_CoEBYODLDataverse` (Dataverse for BYODL)
- `admin_CoEBYODLPowerQuery` (Power Query/Dataflow connector)

### Step-by-Step Resolution

1. **Configure Environment Variables:**
   - Power Automate → Solutions → Center of Excellence - Core Components
   - Click "Environment variables"
   - Update each dataflow ID variable with the actual dataflow ID from your environment

2. **Enable Cloud Flows:**
   - In the same solution, go to Cloud flows
   - Find all flows starting with "CoE BYODL - When"
   - Turn each flow ON
   - Verify no connection errors

3. **Verify Connections:**
   - Click "Connection References" in the solution
   - Ensure all connections are valid and use an account with admin permissions

4. **Test the Chain:**
   - Go to Dataflows and manually trigger the Maker dataflow
   - Monitor the flow runs in Power Automate
   - Verify each flow triggers the next dataflow in sequence
   - Check that all dataflows show updated "last refresh" timestamps

### Additional Documentation

For detailed troubleshooting steps, see:
- [TROUBLESHOOTING-DATAFLOWS.md](../../TROUBLESHOOTING-DATAFLOWS.md)
- [CoE Starter Kit Setup Documentation](https://learn.microsoft.com/power-platform/guidance/coe/setup)

### Important Notes

⚠️ **BYODL Deprecation:** BYODL (Bring Your Own Data Lake) is no longer the recommended approach. Microsoft is moving toward Fabric integration for data export. Consider using cloud flows for inventory collection instead.

📊 **License Requirements:** Trial or limited licenses can cause pagination issues with dataflows. Ensure you're using appropriate licenses for production CoE Kit deployments.

⏱️ **Processing Time:** The full dataflow chain can take several hours to complete, especially for large tenants. This is expected behavior.

### Follow-up Questions

To better assist you, please provide:

1. **Solution Version:** What version of the CoE Starter Kit are you using?
2. **Environment Variable Values:** Are the dataflow ID environment variables populated?
3. **Flow Status:** Are the "When dataflow refresh completes" flows turned ON?
4. **Flow Run History:** Do you see any runs or errors in the flow run history?
5. **Error Messages:** Are there any specific error messages in failed flow runs?
6. **Setup Method:** Did you use the Setup Wizard or manual configuration?

Once we have this information, we can provide more specific guidance.

---

**Related Issues:**
- Search for similar issues: https://github.com/microsoft/coe-starter-kit/issues?q=dataflow+refresh
