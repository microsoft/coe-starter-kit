# CoE Starter Kit - Common GitHub Responses

This document contains ready-to-use explanations, known limitations, and common workarounds for the CoE Starter Kit. Use these responses when triaging GitHub issues.

## Table of Contents
- [Support and SLA](#support-and-sla)
- [Inventory and Data Collection](#inventory-and-data-collection)
- [BYODL (Bring Your Own Data Lake)](#byodl-bring-your-own-data-lake)
- [Licensing and Pagination](#licensing-and-pagination)
- [Language and Localization](#language-and-localization)
- [Cleanup Flows](#cleanup-flows)
- [Upgrade Issues](#upgrade-issues)
- [Setup Wizard](#setup-wizard)

---

## Support and SLA

### Unsupported / Best-Effort

**When to use**: User expects immediate support or SLA

**Response**:
```
The CoE Starter Kit is provided as a best-effort, unsupported solution. While the underlying Power Platform features and connectors are fully supported by Microsoft, the CoE Starter Kit itself represents sample implementations.

For issues with the kit:
- Report problems on GitHub: https://aka.ms/coe-starter-kit-issues
- Search existing issues before creating new ones
- Community support is available through GitHub discussions

For issues with the underlying Power Platform features:
- Use your standard Microsoft Support channels
- Microsoft Support can help with platform issues, not kit-specific implementations

Reference: https://learn.microsoft.com/power-platform/guidance/coe/starter-kit
```

---

## Inventory and Data Collection

### Flows and Apps Tables Not Populating

**When to use**: User reports that inventory tables are empty or not updating

**Response**:
```
The CoE inventory system uses a hierarchical approach:

1. **Admin - Sync Template v4 (Driver)** runs first and populates the Environments table
2. Once environments are synced, child flows trigger to collect Apps, Flows, and other resources
3. All child flows depend on the Environments table being populated

Troubleshooting steps:
1. Check if the Driver flow completed successfully (review run history)
2. Verify that the Environments table contains data with recent timestamps
3. Confirm all child flows (Apps, Flows, etc.) are turned ON
4. Review connection references - ensure all connections are valid
5. Allow 24-48 hours after upgrade for full inventory to complete

For large tenants, the Driver flow can take 1-4 hours to complete. Child flows trigger automatically after the Driver finishes.

See detailed troubleshooting: [docs/coe-knowledge/Troubleshooting-Inventory-Flows.md]
```

### Long-Running Flows

**When to use**: User reports flows running for extended periods

**Response**:
```
Long-running inventory flows are expected behavior, not a problem. The duration depends on tenant size:

- Small tenants (<100 apps): 30-60 minutes
- Medium tenants (100-500 apps): 1-2 hours  
- Large tenants (500-2000 apps): 2-4 hours
- Extra Large tenants (>2000 apps): 4-8 hours

The flows are designed to:
- Process data in batches to avoid API throttling
- Retry on transient errors
- Handle pagination for large datasets

If flows are running longer than expected:
- Check for throttling errors (429 responses)
- Verify network connectivity
- Review API call limits

Flows have a 30-day execution limit, so they will eventually complete or timeout.
```

### Full Inventory Required

**When to use**: User has partial data or data issues

**Response**:
```
To run a full inventory:

1. Navigate to the **Admin - Sync Template v4 (Driver)** flow
2. Click **Run** > **Run flow** to manually trigger
3. Wait for completion (1-4 hours depending on tenant size)
4. Child flows will automatically trigger after Driver completes
5. Monitor child flow run history within 15-30 minutes

After major upgrades or configuration changes, allow 24-48 hours for complete inventory refresh.

Note: The Driver flow runs automatically every 24 hours by default. Manual runs are only needed for troubleshooting or immediate refresh.
```

---

## BYODL (Bring Your Own Data Lake)

### BYODL No Longer Recommended

**When to use**: User asks about BYODL setup or has BYODL issues

**Response**:
```
⚠️ **Important**: BYODL (Bring Your Own Data Lake) is no longer recommended for new CoE Starter Kit implementations.

**Current direction**: Microsoft is aligning with Microsoft Fabric for advanced analytics scenarios.

**For existing BYODL users**:
- BYODL flows are still included in the solution for backward compatibility
- No new features will be added to BYODL components
- Consider migration planning to Fabric-based analytics

**For new implementations**:
- Use the standard Dataverse-based inventory (v4 Sync flows)
- Export data to Fabric using Dataverse connectors if advanced analytics are needed
- Avoid setting up new BYODL integrations

Reference: https://learn.microsoft.com/power-platform/guidance/coe/setup-powerbi
```

---

## Licensing and Pagination

### Pagination Limits and License Requirements

**When to use**: User encounters pagination errors or partial data collection

**Response**:
```
The CoE Starter Kit requires adequate Power Platform licensing for the admin account running the flows.

**License requirements**:
- Power Apps per-user or per-app plan (not trial)
- Power Automate per-user plan
- Appropriate admin roles (Power Platform Administrator or Global Administrator)

**Common pagination issues**:
1. **Trial licenses**: Have lower API limits and will hit pagination boundaries
2. **Insufficient license**: May result in partial data collection
3. **Shared mailbox accounts**: Cannot be licensed and will fail

**Testing license adequacy**:
1. Run the Driver flow manually
2. Check for pagination warnings in run history
3. Verify all environments are being processed
4. Compare record counts with actual tenant resources

**Solution**: Ensure the service account has a full, non-trial license with admin permissions.

Reference: https://learn.microsoft.com/power-platform/guidance/coe/setup#licensing-requirements
```

---

## Language and Localization

### English Language Pack Required

**When to use**: User reports errors or unexpected behavior in non-English environments

**Response**:
```
⚠️ **Language Limitation**: The CoE Starter Kit currently supports English only.

**Requirements**:
- The Dataverse environment must have the English language pack enabled
- The admin account should use English as the display language
- Canvas apps and flows contain English strings only

**If you're using a non-English environment**:
1. Enable English language pack in your environment settings
2. Set English as the base language for the CoE environment
3. Users can still use their preferred language for other operations

**Known issues in non-English environments**:
- Flow error messages may not display correctly
- Canvas app labels may appear as resource keys
- Date/time formatting may be inconsistent

We welcome community contributions to add localization support.

Reference: https://learn.microsoft.com/power-platform/guidance/coe/faq#does-the-coe-starter-kit-support-localization
```

---

## Cleanup Flows

### Using Cleanup and Maintenance Flows

**When to use**: User has stale data or synchronization issues

**Response**:
```
The CoE Starter Kit includes cleanup flows to maintain data quality:

**Main cleanup flows**:
- **CLEANUP - Admin - Sync Template v3 (App Shared With)**: Cleans up app sharing data
- **CLEANUP HELPER - Check Deleted v4 (Cloud Flows)**: Identifies deleted flows
- **CLEANUP HELPER - Check Deleted v4 (Desktop flows)**: Identifies deleted desktop flows
- **CLEANUP HELPER - Solution Objects**: Cleans up solution component data

**When to run cleanup**:
- After major tenant changes (mass deletions, environment removals)
- When you notice stale data in the CoE apps
- Before generating reports to ensure data accuracy
- After upgrade to clean up legacy data

**How to run**:
1. Navigate to the cleanup flow in Power Automate
2. Ensure the flow is turned ON
3. Check the run history to verify it's running on schedule
4. Manually trigger if immediate cleanup is needed

**Expected delays**: Cleanup flows run periodically (weekly/monthly by default) and may take time to process large datasets.

Reference: https://learn.microsoft.com/power-platform/guidance/coe/core-components#cleanup-flows
```

---

## Upgrade Issues

### After Upgrade - Flows Not Working

**When to use**: User reports issues immediately after upgrading the CoE Starter Kit

**Response**:
```
After upgrading the CoE Starter Kit, follow these steps:

**Immediate actions**:
1. **Check all flows are turned ON**: Upgrades may turn off flows
2. **Verify connection references**: Ensure all connections are still valid
3. **Review environment variables**: Confirm settings are preserved
4. **Allow 24-48 hours**: For full inventory to complete after upgrade

**Common upgrade issues**:
- **Unmanaged layers**: Remove unmanaged customizations to receive updates properly
  - Go to Solutions > Center of Excellence Core Components
  - Check for unmanaged layers on flows and remove them
- **Connection ownership**: Connections may need to be recreated
- **New flows added**: Recent upgrades may include new flows that need configuration

**Upgrade best practices**:
1. Review release notes before upgrading
2. Take backups of environment variables
3. Document any customizations
4. Test in development environment first
5. Run a full inventory after upgrade completes

Reference: https://learn.microsoft.com/power-platform/guidance/coe/after-setup#installing-upgrades
```

### Unmanaged Layers Blocking Updates

**When to use**: User cannot apply updates or receives warnings about unmanaged layers

**Response**:
```
Unmanaged layers occur when you modify managed components directly. These layers prevent updates from being applied.

**To remove unmanaged layers**:
1. Navigate to **Solutions** > **Center of Excellence - Core Components**
2. Select the component (flow, app, etc.) with the layer
3. Click **See solution layers**
4. Identify the unmanaged layer
5. Remove the unmanaged layer

**Alternative method**:
1. Export your customizations first (if needed)
2. Remove the unmanaged layer
3. Apply the upgrade
4. Re-apply your customizations in a separate unmanaged solution

**Prevention**:
- Always make customizations in a separate unmanaged solution
- Don't directly edit managed components
- Use environment variables for configuration instead of editing flows

Reference: https://learn.microsoft.com/power-platform/guidance/coe/faq#how-do-i-remove-an-unmanaged-layer
```

---

## Setup Wizard

### Setup Wizard Guidance

**When to use**: User asks about setup process or has setup wizard questions

**Response**:
```
The CoE Starter Kit includes a Setup Wizard to streamline initial configuration:

**Setup Wizard features**:
- Guides you through required configuration steps
- Sets up connection references
- Configures environment variables
- Validates prerequisites
- Turns on required flows

**Setup sequence**:
1. Install the Core Components solution
2. Launch the Setup Wizard app
3. Follow the step-by-step guidance
4. Configure connections and environment variables
5. Turn on inventory flows
6. Wait for initial inventory to complete (24-48 hours)

**Common setup issues**:
- **Missing permissions**: Ensure admin account has required roles
- **Connection errors**: Use the same admin account for all connections
- **Environment variable issues**: Verify all required variables are set
- **Flow activation failures**: Check connection references first

**After setup**:
- Allow 24-48 hours for initial inventory
- Monitor Driver flow run history
- Verify Environments table is populating
- Check child flows are triggering

Reference: https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components
```

---

## DLP and Governance

### DLP Policy Considerations

**When to use**: User reports flows failing due to DLP policies

**Response**:
```
The CoE Starter Kit requires specific connectors that may be affected by DLP policies:

**Required connectors**:
- Power Platform for Admins
- Power Apps for Admins  
- Dataverse
- Office 365 Users
- Office 365 Groups (optional)
- Microsoft Teams (for Teams integration)

**DLP recommendations**:
1. Create a dedicated environment for CoE Starter Kit
2. Exclude the CoE environment from restrictive DLP policies
3. Or create a DLP policy that allows required connectors for the CoE environment
4. Document the exception with security team

**If DLP blocks are unavoidable**:
- Some inventory flows may fail
- Consider using PowerShell scripts as alternative for data collection
- Work with security team to find acceptable workarounds

Remember: The CoE Starter Kit is an admin tool and should run in a controlled, monitored environment.

Reference: https://learn.microsoft.com/power-platform/guidance/coe/faq#how-do-dlp-policies-affect-the-coe-starter-kit
```

---

## Additional Resources

- **Official Documentation**: https://learn.microsoft.com/power-platform/guidance/coe/starter-kit
- **GitHub Issues**: https://github.com/microsoft/coe-starter-kit/issues
- **Release Notes**: https://github.com/microsoft/coe-starter-kit/releases
- **Community Forums**: https://powerusers.microsoft.com/t5/Power-Apps-Community/ct-p/PowerApps1

---

*This document is maintained by the CoE Starter Kit team. Last updated: December 2024*
