# Issue Response: CoE Dataflows Not Refreshing Automatically

---

## Summary
Thank you for reporting this issue. The behavior you're describing—where the Maker dataflow refreshes automatically but the remaining dataflows (Environment, Flow, App, Model App) do not—is a common configuration issue with the CoE Starter Kit's BYODL (Bring Your Own Data Lake) setup.

## Root Cause
The CoE dataflows are designed to refresh **sequentially** using a chain of cloud flows:

1. **Maker Dataflow** (scheduled refresh)
   - ↓ On completion triggers →
2. **Environment Dataflow**
   - ↓ On completion triggers (in parallel) →
3. **Flow, App, and Model App Dataflows**

Each step relies on a "When dataflow refresh completes" cloud flow that:
- Monitors for completion of the previous dataflow
- Processes the refreshed data
- Triggers the next dataflow(s) in the sequence

When subsequent dataflows don't refresh, it typically means one of these cloud flows is either:
- Not enabled (turned OFF)
- Missing required configuration (environment variables)
- Has invalid connection references

## Most Common Fixes

### 1. ✅ Enable the "When Dataflow Refresh Completes" Cloud Flows

Navigate to **Power Automate → Solutions → Center of Excellence - Core Components**

Verify that these flows are **turned ON**:
- ✔️ `CoE BYODL - When Maker dataflow refresh is complete`
- ✔️ `CoE BYODL - When Environment dataflow refresh is complete`
- ✔️ `CoE BYODL - When Flow dataflow refresh is complete`
- ✔️ `CoE BYODL - When App dataflow refresh is complete`
- ✔️ `CoE BYODL - When Model App dataflow refresh is complete`

### 2. ✅ Configure Dataflow ID Environment Variables

The cloud flows need to know which dataflows to trigger. These are stored in environment variables.

**Find Your Dataflow IDs:**
1. Go to https://make.powerapps.com
2. Select your CoE/Test Governance environment
3. Navigate to **Dataflows**
4. Open each dataflow and copy the ID from the URL:
   ```
   https://make.powerapps.com/environments/{environment-id}/dataflows/{dataflow-id}
                                                                      ^^^^^^^^^^^^^^^^^
                                                                      Copy this part
   ```

**Update Environment Variables:**

In **Power Automate → Solutions → Center of Excellence - Core Components → Environment variables**, update:

| Environment Variable | Schema Name | What to Enter |
|---------------------|-------------|---------------|
| Current Environment | admin_CurrentEnvironment | Your environment ID (with region suffix) |
| Maker Dataflow ID | admin_MakerDataflowID | ID of your Makers dataflow |
| Environment Dataflow ID | admin_EnvironmentDataflowID | ID of your Environment dataflow |
| Flow Dataflow ID | admin_FlowDataflowID | ID of your Flow dataflow |
| App Dataflow ID | admin_AppDataflowID | ID of your App dataflow |
| Model App Dataflow ID | admin_ModelAppDataflowID | ID of your Model App dataflow |

### 3. ✅ Verify Connection References

Ensure these connections are configured and valid:

In **Power Automate → Solutions → Center of Excellence - Core Components → Connection References**:

- `admin_CoECoreDataverse2` → Dataverse connection
- `admin_CoEBYODLDataverse` → Dataverse connection (for BYODL tables)
- `admin_CoEBYODLPowerQuery` → Power Query/Dataflow connection

Each connection should use an account with:
- System Administrator role in the CoE environment
- Valid (non-trial) license
- Power Platform Administrator or Dynamics 365 Administrator role

## Testing the Configuration

After applying the fixes above:

1. **Manually trigger the Maker dataflow:**
   - Go to **Power Apps → Dataflows**
   - Open "CoE BYODL Makers" dataflow
   - Click **Refresh Now**

2. **Monitor the chain:**
   - Go to **Power Automate → Cloud flows**
   - Watch for the "CoE BYODL - When Maker dataflow refresh is complete" flow to run
   - Check the run history for success/failure

3. **Verify subsequent triggers:**
   - After the Maker dataflow completes, the flow should trigger the Environment dataflow
   - After the Environment dataflow completes, it should trigger Flow, App, and Model App dataflows in parallel

4. **Check dataflow timestamps:**
   - Go back to **Power Apps → Dataflows**
   - Verify that "Last Refresh" timestamps update for each dataflow as they complete

## Expected Timeline

The complete dataflow refresh chain can take **several hours** to complete, especially for large tenants. This is normal behavior because:
- Each dataflow processes significant amounts of data
- Dataflows run sequentially (except for the final three which run in parallel)
- Power Platform has limits on concurrent dataflow refreshes

## Important Notes

⚠️ **BYODL Deprecation Notice**

BYODL (Bring Your Own Data Lake) is **no longer the recommended approach** for CoE data collection. Microsoft is transitioning to **Fabric integration** for data export. 

For new implementations, consider using **cloud flows** for inventory collection instead of BYODL, as documented in the latest CoE Starter Kit guidance.

📊 **License Requirements**

Trial or insufficient license profiles can cause pagination limits and dataflow refresh failures. Ensure you're using appropriate licenses (e.g., Power Apps Per User, Power Automate Per User) for production CoE deployments.

## Additional Resources

- **Detailed Troubleshooting Guide:** [TROUBLESHOOTING-DATAFLOWS.md](../TROUBLESHOOTING-DATAFLOWS.md)
- **CoE Setup Documentation:** https://learn.microsoft.com/power-platform/guidance/coe/setup
- **CoE Starter Kit Overview:** https://learn.microsoft.com/power-platform/guidance/coe/starter-kit

## Need More Help?

If you've followed these steps and are still experiencing issues, please provide:

1. **Solution version** you're using (e.g., 4.50.6)
2. **Status of environment variables** (Are they populated with actual IDs?)
3. **Status of cloud flows** (Are they turned ON?)
4. **Flow run history** (Any errors in the run history? Screenshots help!)
5. **Error messages** from failed flow runs
6. **Setup method used** (Setup Wizard or manual configuration?)

This information will help us provide more specific guidance for your situation.

---

**Related Issues:**
- Search for similar dataflow issues: https://github.com/microsoft/coe-starter-kit/issues?q=dataflow+refresh
