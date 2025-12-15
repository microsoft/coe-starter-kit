# CoE Kit Common GitHub Responses

This document contains standard responses and known information for common CoE Starter Kit issues and questions.

## Table of Contents
- [Data Export V2 Status](#data-export-v2-status)
- [BYODL (Bring Your Own Data Lake)](#byodl-bring-your-own-data-lake)
- [Inventory and Telemetry Methods](#inventory-and-telemetry-methods)
- [Setup and Configuration](#setup-and-configuration)

---

## Data Export V2 Status

### Issue: Data Export Option Greyed Out in Setup Wizard

**Status**: Known Product Limitation - Feature Not Yet Available

**Symptoms**:
- The "Data Export" option appears greyed out in the Initial Setup Wizard
- Message displayed: "_Today inventory is only available using cloud flows that crawl your tenant to store inventory in Dataverse. A new version of the kit which integrates with Data Export V2 will be available ~Fall 2024_"
- Occurs in CoE Starter Kit version 4.5.7 and related versions

**Root Cause**:
Data Export V2 is a Power Platform product feature that was planned for release but is not yet generally available. The CoE Starter Kit setup wizard has been prepared to support this feature once it becomes available, but until the product team releases Data Export V2, this option will remain unavailable (greyed out).

**Expected Behavior**:
Currently, there are two inventory methods available:
1. **Cloud Flows (Recommended)** - Uses Power Automate flows to crawl your tenant and store inventory in Dataverse
2. **BYODL (Bring Your Own Data Lake)** - Legacy approach using Azure Data Lake Storage (Not Recommended - see BYODL section below)

The Data Export V2 option is a future method that will be enabled when the Power Platform product team releases the feature.

**Workaround / Resolution**:
1. **Use Cloud Flows method** (Recommended):
   - Select the "Cloud Flows" option in the Setup Wizard
   - This is the currently supported and recommended approach
   - Provides full inventory and telemetry capabilities
   - Reference: [Setup Core Components - Choose Data Source](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup-core-components#choose-data-source)

2. **Do NOT use BYODL** (See BYODL section below for details)

3. **Monitor for Data Export V2 availability**:
   - Watch the [CoE Starter Kit Releases](https://github.com/microsoft/coe-starter-kit/releases) for announcements
   - Check Power Platform release notes for Data Export V2 general availability

**Additional Information**:
- The greyed-out option is intentional behavior, not a bug
- The option has been pre-built into the wizard to support quick adoption once the feature is released
- There is no ETA for Data Export V2 general availability
- The "~Fall 2024" message in the wizard refers to an estimated timeframe that may change based on product team schedules

**Standard Response Template**:
```markdown
Thank you for reporting this issue. The Data Export option appearing greyed out is expected behavior.

**Current Status**: Data Export V2 is a Power Platform product feature that is not yet generally available. While the CoE Starter Kit has been prepared to support this feature, it cannot be enabled until Microsoft releases Data Export V2.

**Recommended Action**: Please use the **Cloud Flows** inventory method, which is the currently supported and recommended approach for collecting inventory and telemetry data.

**Steps**:
1. In the Setup Wizard, select the "Cloud Flows" option
2. Complete the setup following the documentation: https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup-core-components#choose-data-source

We will update the CoE Starter Kit and announce when Data Export V2 becomes generally available. Please subscribe to [Release notifications](https://github.com/microsoft/coe-starter-kit/releases) to stay informed.
```

---

## BYODL (Bring Your Own Data Lake)

### Status: Not Recommended - Legacy Feature

**Important Notice**: BYODL (Bring Your Own Data Lake) is **no longer recommended** for new implementations of the CoE Starter Kit.

**Reasons**:
- Microsoft is moving towards Microsoft Fabric for data lake scenarios
- BYODL setup is complex and requires significant Azure infrastructure
- Maintenance overhead is higher compared to Cloud Flows method
- Future direction focuses on native Power Platform capabilities and Fabric integration

**Recommendation**:
- **New implementations**: Use Cloud Flows method
- **Existing BYODL implementations**: Consider migrating to Cloud Flows method when feasible
- **Future-proofing**: Plan for Microsoft Fabric integration as it becomes available

**Migration Path**:
For organizations currently using BYODL who want to migrate:
1. Set up Cloud Flows inventory method in parallel
2. Validate data collection is working correctly
3. Deprecate BYODL infrastructure once Cloud Flows is fully operational
4. Keep historical data in Azure Data Lake for reference if needed

**Standard Response for BYODL Questions**:
```markdown
Thank you for your question about BYODL (Bring Your Own Data Lake).

**Important**: BYODL is no longer the recommended approach for CoE Starter Kit inventory and telemetry. Microsoft is moving towards Microsoft Fabric for data lake scenarios, and the recommended method for new implementations is **Cloud Flows**.

**For New Implementations**:
- Use the Cloud Flows inventory method
- Follow the setup guide: https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup-core-components

**For Existing BYODL Users**:
- Your current setup will continue to work
- Consider planning migration to Cloud Flows method
- Monitor for Microsoft Fabric integration announcements

If you have specific requirements that you believe necessitate BYODL, please share your use case so we can explore alternatives.
```

---

## Inventory and Telemetry Methods

### Current Supported Methods

1. **Cloud Flows (Recommended)**
   - **Description**: Uses Power Automate flows to crawl tenant and store inventory in Dataverse
   - **Pros**: 
     - Fully supported and maintained
     - No additional Azure infrastructure required
     - Easier to set up and maintain
     - Regular updates and improvements
   - **Cons**: 
     - Requires appropriate Power Platform licenses
     - May hit API throttling limits in very large tenants
   - **Setup**: [Cloud Flows Setup Guide](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup-core-components)

2. **BYODL - Bring Your Own Data Lake (Not Recommended)**
   - **Description**: Exports data to Azure Data Lake Storage
   - **Status**: Legacy, not recommended for new implementations
   - **See**: BYODL section above for details

3. **Data Export V2 (Future)**
   - **Description**: Will use Power Platform Data Export V2 service when available
   - **Status**: Not yet available - option greyed out in Setup Wizard
   - **See**: Data Export V2 Status section above for details

### Choosing the Right Method

For most organizations, **Cloud Flows** is the correct choice because:
- It's the actively maintained and recommended approach
- It requires no additional Azure resources
- It provides complete inventory and telemetry capabilities
- It receives regular updates and bug fixes

**Decision Matrix**:
| Requirement | Cloud Flows | BYODL | Data Export V2 |
|------------|-------------|-------|----------------|
| Easy Setup | ✅ Yes | ❌ No | ⏳ Future |
| No Azure Required | ✅ Yes | ❌ No | ⏳ Future |
| Actively Maintained | ✅ Yes | ⚠️ Limited | ⏳ Future |
| Recommended | ✅ Yes | ❌ No | ⏳ Future |

---

## Setup and Configuration

### Setup Wizard Known Behaviors

1. **Data Export Option Greyed Out**: See Data Export V2 Status section above

2. **Language Requirements**:
   - CoE Starter Kit supports **English only**
   - Ensure your environment has English language pack enabled
   - Non-English environments may experience issues

3. **License Requirements**:
   - Per-user licensing or trial licenses may hit pagination limits
   - Test your license adequacy before full deployment
   - Refer to official documentation for license requirements

4. **Environment Considerations**:
   - Install in a dedicated environment
   - Do not install in default environment
   - Ensure environment is not a trial environment for production use

### Common Setup Issues and Solutions

#### Issue: Cannot Select Data Source
- **Symptom**: All data source options appear greyed out or non-selectable
- **Resolution**: 
  1. Verify you have appropriate permissions (System Administrator role)
  2. Check that environment is properly configured
  3. Ensure all prerequisite environment variables are configured
  4. Review browser console for JavaScript errors

#### Issue: Setup Wizard Not Loading
- **Symptom**: Setup wizard app fails to load or shows errors
- **Resolution**:
  1. Clear browser cache
  2. Verify solution is installed correctly
  3. Check that all flows are turned on
  4. Ensure connections are properly authenticated

---

## Additional Resources

- **Official Documentation**: https://learn.microsoft.com/en-us/power-platform/guidance/coe/starter-kit
- **GitHub Issues**: https://github.com/microsoft/coe-starter-kit/issues
- **GitHub Releases**: https://github.com/microsoft/coe-starter-kit/releases
- **Power Platform Admin Center**: https://admin.powerplatform.microsoft.com/

---

## Contributing to This Document

This document should be updated when:
- New product features become available (e.g., Data Export V2)
- Common issues are identified and solutions are found
- Best practices change or evolve
- Microsoft documentation or guidance is updated

To update this document, submit a pull request with:
1. Clear description of the change
2. Link to any relevant issues or documentation
3. Standard response templates for new common issues

---

*Last Updated: December 2025*
*Document Version: 1.0*
