# CoE Starter Kit - Frequently Asked Questions (FAQ)

## Common Issues and Quick Solutions

### Q: My CoE apps show blank screens. What should I do first?

**A:** The most common cause is missing or insufficient licensing. Verify you have:
1. **Power Apps Premium** or **Power Apps Per User** license (NOT trial or per-app)
2. **System Administrator** role in the CoE Dataverse environment
3. **Canvas PCF components** enabled in environment settings

See the [Troubleshooting Blank Screens Guide](./TROUBLESHOOTING-BLANK-SCREENS.md) for detailed steps.

### Q: I have Power Platform Administrator role but apps still show blank. Why?

**A:** Power Platform Administrator at the tenant level is not sufficient. You must also have the **System Administrator** security role assigned within the specific CoE Dataverse environment.

**How to assign:**
1. Go to [Power Platform Admin Center](https://admin.powerplatform.microsoft.com)
2. Select your CoE environment
3. Go to **Settings > Users + permissions > Users**
4. Find your account and click **Manage security roles**
5. Assign **System Administrator** role

### Q: The Setup Wizard loads but stays blank after "Confirm pre-requisites". What's wrong?

**A:** This typically indicates:
1. **Missing PCF component support**: Enable "Power Apps component framework for canvas apps" in environment settings
2. **Environment variables not set**: Check Core Components solution and ensure variables are configured
3. **Browser cache issues**: Try in InPrivate/Incognito mode

### Q: Do I need a premium license? Can I use trial licenses?

**A:** 
- **Yes**, you need **Power Apps Premium** or **Power Apps Per User** license
- **Trial licenses will cause issues**: They hit pagination limits and cause intermittent blank screens
- **Per-App licenses are insufficient**: They don't provide the necessary API access
- **Office 365 included licenses won't work**: They don't include premium connectors and Dataverse access

See [Microsoft License Requirements](https://learn.microsoft.com/power-platform/guidance/coe/setup#what-identity-should-i-install-the-coe-starter-kit-with)

### Q: I enabled PCF components but apps are still blank. What else should I check?

**A:** After enabling PCF components:
1. **Wait 10-15 minutes** for settings to propagate
2. **Clear browser cache** or try in InPrivate/Incognito mode
3. **Verify DLP policies** aren't blocking required connectors
4. **Check environment variables** in Core Components solution
5. **Ensure flows have run** to populate data

### Q: What connectors must be allowed in DLP policies?

**A:** The following connectors must be in the **Business** data group (or environment excluded from restrictive policies):
- Microsoft Dataverse
- Power Apps for Admins
- Power Automate Management  
- Office 365 Users
- Office 365 Groups
- Microsoft Dataverse (legacy)

**How to check:**
1. Go to [Power Platform Admin Center](https://admin.powerplatform.microsoft.com)
2. Select **Data policies**
3. Review policies applied to your CoE environment
4. Move required connectors to **Business** group or exclude the environment

### Q: My apps show headers but no content. Is this the same as blank screens?

**A:** Yes, this is the same issue. When apps show navigation/headers but blank content area, it's typically:
1. PCF components failing to load (enable Canvas PCF)
2. Data not available (flows not run or failed)
3. Permissions insufficient (System Administrator role needed)
4. License limitations (trial or per-app license)

### Q: How long does initial data synchronization take?

**A:** 
- **Small tenants** (< 100 apps/flows): 30 minutes to 2 hours
- **Medium tenants** (100-1000 apps/flows): 2-6 hours  
- **Large tenants** (> 1000 apps/flows): 6-24 hours or more

Apps may show blank or incomplete data until initial sync completes. Check flow run history to monitor progress.

### Q: The apps worked before but now show blank. What changed?

**A:** Common causes of sudden blank screens:
1. **License expired or changed**: Check your Power Apps license
2. **Security role removed**: Verify System Administrator role still assigned
3. **DLP policy updated**: Check if new policies block required connectors
4. **Solution update failed**: Check for solution import errors
5. **Environment variables cleared**: Verify variables are still set
6. **PCF setting reverted**: Confirm Canvas PCF still enabled

### Q: Can I use the CoE Starter Kit in languages other than English?

**A:** No, the CoE Starter Kit is only localized in English. Using it in environments with other primary languages may cause:
- Blank screens
- Missing labels
- Flow failures
- Data synchronization issues

**Workaround:**
1. Ensure English language pack is installed in the environment
2. Users can set their personal language to English in Power Apps settings
3. Consider using a dedicated English-language environment for CoE

### Q: I've checked everything but apps are still blank. What should I include in a bug report?

**A:** When filing a bug report, include:

1. **Prerequisites checklist results**:
   - License type assigned
   - Roles assigned (tenant and environment level)
   - PCF components enabled (yes/no)
   - DLP policies checked (yes/no)
   - Environment variables configured (yes/no)

2. **Detailed information**:
   - Solution version (e.g., 4.50.6)
   - Specific app(s) affected
   - Browser and version
   - Screenshots showing blank screen with visible headers
   - Monitor errors (press Ctrl+Alt+Shift+M to view)

3. **Troubleshooting attempted**:
   - List all steps you've tried
   - Results of each step
   - Whether incognito mode works

4. **Environment details**:
   - Region
   - Environment type (production, sandbox, trial)
   - When issue first occurred

Use the [Bug Report Template](https://github.com/microsoft/coe-starter-kit/issues/new/choose)

### Q: Where can I find more help?

**A:** Resources for help:
1. **Detailed troubleshooting**: [Troubleshooting Blank Screens Guide](./TROUBLESHOOTING-BLANK-SCREENS.md)
2. **Official documentation**: [CoE Starter Kit Documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
3. **GitHub issues**: [Search existing issues](https://github.com/microsoft/coe-starter-kit/issues)
4. **Community forum**: [Power Apps Community](https://powerusers.microsoft.com/t5/Power-Apps-Governance-and/bd-p/Admin_PowerApps)
5. **Office Hours**: Check [OFFICEHOURS.md](../CenterofExcellenceResources/OfficeHours/OFFICEHOURS.md) for scheduled community calls

### Q: Is the CoE Starter Kit officially supported by Microsoft?

**A:** The CoE Starter Kit is a **community-supported template** provided "as-is" without official Microsoft support SLA. 

- **Issue tracking**: via GitHub Issues
- **Community support**: via GitHub and Power Platform community forums
- **No formal support SLA**: Microsoft doesn't provide formal support tickets for the kit itself
- **Product issues**: If you find underlying Power Platform issues, those should be reported through normal support channels

### Q: My flows are failing with "pagination limit exceeded". How do I fix this?

**A:** This is almost always a licensing issue:

**Cause**: Trial licenses and insufficient licenses have lower pagination limits for API calls.

**Solution**:
1. Assign **Power Apps Premium** or **Power Apps Per User** license
2. Remove trial licenses
3. Do NOT use Power Apps Per App licenses
4. Verify the service account running flows has proper licensing

**Test your license adequacy**:
```
Run the "Admin | Sync Template v3" flow manually and check:
- Does it complete successfully?
- Does it process all environments?
- Are there pagination warnings in the flow run history?
```

### Q: Should I install CoE in a production or dedicated environment?

**A:** **Best Practice: Use a dedicated environment**

**Recommended:**
- Create a dedicated Dataverse environment for CoE
- Use production environment type (not trial)
- Separate from maker/user environments
- Allows for isolation and cleaner management

**Why not production apps environment:**
- CoE generates significant data volume
- Inventory flows run continuously
- Easier to troubleshoot in isolation
- Can be deleted/recreated without affecting apps

See [Setup Prerequisites](https://learn.microsoft.com/power-platform/guidance/coe/setup#prerequisites)

### Q: How do I update the CoE Starter Kit without losing my customizations?

**A:** Follow the upgrade process:

1. **Never modify managed solution directly**: Customizations should be in separate unmanaged solutions
2. **Export your customizations**: Before upgrading, export any custom work
3. **Remove unmanaged layers**: Use solution layers feature to remove any unmanaged changes to managed components
4. **Import new version**: Import the new managed solution
5. **Reapply customizations**: Import your custom solution after upgrade

**Important**: Unmanaged layers prevent managed solution updates from applying.

See [Upgrade Documentation](https://learn.microsoft.com/power-platform/guidance/coe/setup#updating-the-coe-starter-kit)

---

## Quick Troubleshooting Checklist

Copy this checklist when troubleshooting blank screens:

```
[ ] Power Apps Premium or Per User license assigned
[ ] NOT using trial or per-app license
[ ] Global Admin or Power Platform Admin role (tenant-level)
[ ] System Administrator role in CoE environment
[ ] Dataverse database exists in environment
[ ] English language pack enabled
[ ] Canvas PCF components enabled
[ ] Required connectors in Business DLP group
[ ] Environment variables configured
[ ] Inventory flows have run successfully
[ ] Tested in InPrivate/Incognito mode
[ ] Checked Monitor for errors (Ctrl+Alt+Shift+M)
[ ] Cleared browser cache
```

---

**Last Updated**: 2024-12-16  
**Applies to**: CoE Starter Kit Core Components v1.0+
