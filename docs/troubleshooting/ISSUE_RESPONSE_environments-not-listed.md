# Response to Issue: Some Environments Not Listed in Power Platform Admin App

Hello Sunil,

Thank you for reporting this issue with the CoE Toolkit configuration. The issue where some environments are not appearing in the Power Platform Admin App is a common one, and I've created comprehensive documentation to help you resolve it.

## Most Likely Cause

The most common reason environments don't appear is the **"Excuse From Inventory"** field setting. This field controls whether each environment is included in the CoE inventory tracking.

## Quick Solution Steps

### Step 1: Check if the Environment Exists in the Database
1. Open the **Power Platform Admin View** app (part of CoE Core Components)
2. Navigate to **Environments**
3. Search for one of the missing environments by name

### Step 2A: If the Environment IS Found
If you can find the environment in the list:
1. Open the environment record
2. Look for the **"Excuse From Inventory"** field
3. If it's set to **"Yes"**, change it to **"No"**
4. Save the record
5. Go to Power Automate and manually run the **"Admin | Sync Template v4 (Driver)"** flow
6. Wait for the flow to complete (usually 10-30 minutes)
7. Refresh the Power Platform Admin View app

### Step 2B: If the Environment IS NOT Found
If the environment doesn't exist in the table at all:
1. Go to Power Automate in your CoE environment
2. Find the **"Admin | Sync Template v4 (Driver)"** flow
3. Check the run history:
   - Has it run recently? (within the last 24 hours)
   - Did it complete successfully?
   - Are there any error messages?
4. If it hasn't run or has errors, manually trigger it by clicking **Run**
5. Wait for completion and check if environments now appear

### Step 3: Verify "Track All Environments" Setting
1. In Power Apps, go to **Solutions**
2. Open **Center of Excellence - Core Components** solution
3. Go to **Environment Variables**
4. Find **"Track All Environments"**
5. Ensure it's set to **True** (this makes all new environments automatically tracked)

## Common Issues and Additional Checks

### Issue 1: License/Pagination Problem
If you have many environments (100+) and exactly 100 are showing:
- The service account may have a trial license causing pagination limits
- **Solution**: Assign a full Power Apps Premium license to the service account

### Issue 2: Permissions Problem
If the sync flow shows permission errors:
- The service account needs Power Platform Administrator role
- **Solution**: Assign the role in Microsoft 365 Admin Center

### Issue 3: First Time Setup
If this is a new installation:
- Initial sync can take several hours
- Environments appear progressively
- **Solution**: Wait for the full sync to complete

## Detailed Documentation

I've created comprehensive guides to help you:

1. **Quick Reference** (Start here): `/docs/troubleshooting/environment-inventory-quick-reference.md`
   - Decision tree for quick diagnosis
   - Common scenarios and fixes
   - Expected wait times

2. **Detailed Troubleshooting Guide**: `/docs/troubleshooting/environments-not-listed.md`
   - In-depth explanations
   - Step-by-step resolution procedures
   - Verification steps

## Need More Help?

If the environment is still not appearing after following these steps, please provide:
1. What version of the CoE Starter Kit are you using?
2. Are you using Cloud flows or Data Export for inventory?
3. Has the "Admin | Sync Template v4 (Driver)" flow run successfully?
4. How many environments do you have in your tenant?
5. How many are currently showing in the app?
6. Screenshots of:
   - Sync flow run history (last 3-5 runs)
   - One of the missing environment records (if it exists in the Environments table)
   - Any error messages from the flows

This information will help me provide more specific guidance.

## Additional Resources

- [CoE Starter Kit Official Documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- [Setup Instructions](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components)
- [CoE Starter Kit GitHub Repository](https://github.com/microsoft/coe-starter-kit)

I hope this helps! Please let me know if you have any questions or if you need additional assistance.

Best regards,
CoE Support Team
