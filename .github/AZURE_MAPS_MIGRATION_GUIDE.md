# Azure Maps Migration Guide for CoE Starter Kit Dashboards

This guide provides detailed technical steps for migrating CoE Starter Kit Power BI dashboards from Bing Maps to Azure Maps visuals.

## Overview

Microsoft is deprecating Bing Maps visuals in Power BI with the October 2025 release. This guide helps you migrate your CoE Starter Kit dashboards to use Azure Maps visuals instead.

## Prerequisites

- Power BI Desktop (April 2025 version or later)
- CoE Starter Kit dashboards deployed in your environment
- Power BI Admin rights (for tenant-level settings)
- Access to your CoE Power BI workspace

## Pre-Migration Assessment

### Step 1: Identify Affected Dashboards

Check each of your CoE dashboard files:

```
CenterofExcellenceResources/Release/Collateral/CoEStarterKit/
├── Production_CoEDashboard_July2024.pbit
├── BYODL_CoEDashboard_July2024.pbit
├── PowerPlatformGovernance_CoEDashboard_July2024.pbit
├── Pulse_CoEDashboard.pbit
└── Power Platform Administration Planning.pbit
```

### Step 2: Inventory Your Map Visuals

For each dashboard:
1. Open in Power BI Desktop
2. Navigate through all report pages
3. Document any pages that contain:
   - Map visuals
   - Filled Map visuals
   - Geographic data (Country, Region, City, Location fields)
4. Take screenshots of current visualizations for comparison

## Migration Steps

### Option 1: Automatic Conversion (Recommended)

This is the fastest method for converting all map visuals at once.

1. **Update Power BI Desktop**
   - Ensure you have Power BI Desktop April 2025 or later
   - Download from: https://powerbi.microsoft.com/desktop/

2. **Open Your Dashboard**
   - Open the .pbit template file in Power BI Desktop
   - Connect to your data source (Dataverse)

3. **Convert All Map Visuals**
   - When the report opens, you should see a conversion prompt
   - The dialog will list all Map and Filled Map visuals found
   - Click "Convert all" to upgrade all visuals to Azure Maps
   - Power BI will automatically:
     - Replace visual types
     - Maintain data field mappings
     - Preserve filters and interactions
     - Retain most formatting settings

4. **Save Changes**
   - Save the updated .pbit file
   - Use a clear naming convention (e.g., `Production_CoEDashboard_July2024_AzureMaps.pbit`)

### Option 2: Manual Conversion

Use this method if you want to convert visuals individually or if automatic conversion is unavailable.

1. **Select the Visual**
   - Click on the Map or Filled Map visual you want to convert

2. **Change Visual Type**
   - In the Visualizations pane, locate "Azure Maps"
   - Click the Azure Maps visual icon
   - The visual will convert automatically

3. **Verify Field Mappings**
   - Check that Location, Latitude, Longitude fields are correctly mapped
   - Verify Size, Color, and Tooltip fields
   - Adjust as needed

4. **Repeat for Each Visual**
   - Continue with remaining map visuals
   - Save after converting each page or section

### Post-Migration Testing

After conversion, thoroughly test each dashboard:

#### Visual Verification
- [ ] All geographic data displays correctly
- [ ] Map locations are accurate
- [ ] Colors and legends match expectations
- [ ] Bubble sizes are appropriate (may be smaller than before)
- [ ] Tooltips show correct information

#### Functionality Testing
- [ ] Filters work correctly with map visuals
- [ ] Drill-through capabilities function
- [ ] Cross-filtering between visuals works
- [ ] Bookmarks and page navigation work
- [ ] Mobile layout displays correctly

#### Performance Testing
- [ ] Dashboard loads within acceptable time
- [ ] Map visuals render quickly
- [ ] Interactions are responsive

## Tenant Configuration

Power BI administrators must enable Azure Maps at the tenant level.

### Configure Tenant Settings

1. **Access Power BI Admin Portal**
   - Go to https://app.powerbi.com
   - Click Settings (gear icon) > Admin portal

2. **Enable Azure Maps**
   - Navigate to: Tenant settings > Integration settings
   - Locate "Azure Maps visual" settings (three separate controls as of mid-2025):
     - Azure Maps visual
     - Azure Maps visual (with custom settings)
     - Azure Maps visual (geographic data processing)
   - Enable the appropriate settings for your organization
   - Configure any data processing boundary requirements

3. **Review Compliance Settings**
   - Consider data residency requirements
   - Review where Azure Maps data will be processed
   - Ensure compliance with organizational policies

4. **Apply Settings**
   - Save tenant settings
   - Settings may take up to 15 minutes to propagate

## Known Differences and Considerations

### Visual Differences

| Aspect | Bing Maps | Azure Maps |
|--------|-----------|------------|
| Bubble Size | Larger default size | Smaller default size |
| Map Style | Classic Bing style | Modern Azure style |
| Performance | Standard | Generally faster |
| Zoom Levels | Limited | More granular |

### Feature Limitations

**Currently NOT Supported in Azure Maps:**
- Publish to Web (public sharing)
- Some sovereign cloud regions (China, Korea)
- Certain government cloud configurations

**If you require these features:**
- Consider alternative visualization approaches
- Contact Microsoft support for guidance
- Monitor Azure Maps feature updates

### Data Processing

**Important**: Azure Maps may process data outside your tenant's geographic region. 

- Review your organization's data governance policies
- Configure appropriate tenant settings
- Document any compliance exceptions needed

## Troubleshooting

### Issue: Conversion Dialog Doesn't Appear

**Solution:**
- Update Power BI Desktop to the latest version
- Close and reopen the report file
- Try manual conversion instead

### Issue: Map Visual Shows "Unable to Display"

**Solution:**
- Check that Azure Maps is enabled in tenant settings
- Verify location fields have valid data
- Ensure geographic data is in a recognized format
- Check that data source connections are active

### Issue: Bubbles Too Small After Conversion

**Solution:**
- Select the Azure Maps visual
- Go to Format visual pane
- Under "Bubble layer", increase:
  - Minimum bubble size
  - Maximum bubble size
  - Default bubble size

### Issue: Missing Data After Conversion

**Solution:**
- Verify all field mappings in the visual
- Check data source query didn't change
- Refresh data in the report
- Compare field names with original visual

### Issue: Performance Degradation

**Solution:**
- Reduce number of data points if possible
- Use aggregation in data model
- Consider using heat map instead of bubble map for dense data
- Enable query reduction in report settings

## Best Practices

### Before Migration
- ✅ Back up all .pbit files
- ✅ Document current dashboard configurations
- ✅ Take screenshots of all map visuals
- ✅ Test in a non-production environment first

### During Migration
- ✅ Convert one dashboard at a time
- ✅ Test thoroughly after each conversion
- ✅ Keep notes on any issues encountered
- ✅ Save multiple versions during testing

### After Migration
- ✅ Update documentation
- ✅ Train users on any visual differences
- ✅ Monitor performance and user feedback
- ✅ Schedule regular reviews of Azure Maps updates

## Rollout Strategy

### Phase 1: Preparation (Weeks 1-2)
- Update Power BI Desktop
- Inventory all dashboards
- Test in development environment
- Configure tenant settings

### Phase 2: Pilot (Weeks 3-4)
- Migrate one non-critical dashboard
- Test with small user group
- Gather feedback
- Refine process

### Phase 3: Production Rollout (Weeks 5-8)
- Migrate remaining dashboards
- Communicate changes to users
- Provide support documentation
- Monitor for issues

### Phase 4: Optimization (Weeks 9-12)
- Fine-tune visual settings
- Address user feedback
- Optimize performance
- Update training materials

## Support and Resources

### Microsoft Documentation
- [Azure Maps Visual Documentation](https://learn.microsoft.com/en-us/azure/azure-maps/power-bi-visual)
- [Convert Map Visuals Guide](https://learn.microsoft.com/en-us/azure/azure-maps/power-bi-visual-conversion)
- [Azure Maps in Power BI Tutorial](https://learn.microsoft.com/en-us/azure/azure-maps/power-bi-visual-get-started)

### CoE Starter Kit Resources
- [CoE Dashboard Documentation](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup-powerbi)
- [GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues)
- [Release Notes](https://github.com/microsoft/coe-starter-kit/releases)

### Community Support
- [Power BI Community Forum](https://community.fabric.microsoft.com/)
- [Power Platform Community](https://powerusers.microsoft.com/)

## Checklist

Use this checklist to track your migration progress:

### Pre-Migration
- [ ] Power BI Desktop updated to April 2025+
- [ ] All CoE dashboards identified
- [ ] Map visuals inventoried and documented
- [ ] Screenshots taken of current state
- [ ] Tenant settings reviewed
- [ ] Test environment prepared

### Migration
- [ ] Automatic conversion attempted
- [ ] Manual conversions completed (if needed)
- [ ] Field mappings verified
- [ ] Visual formatting adjusted
- [ ] All pages reviewed

### Testing
- [ ] Visual accuracy verified
- [ ] Functionality tested
- [ ] Performance validated
- [ ] Cross-filtering works
- [ ] Mobile layouts checked
- [ ] User acceptance testing completed

### Deployment
- [ ] Production files backed up
- [ ] Migrated dashboards published
- [ ] User documentation updated
- [ ] Training materials created
- [ ] Users notified of changes
- [ ] Support process established

### Post-Deployment
- [ ] User feedback collected
- [ ] Issues logged and tracked
- [ ] Performance monitored
- [ ] Optimizations applied
- [ ] Lessons learned documented

---

**Last Updated**: November 2024  
**Version**: 1.0  
**Applies To**: CoE Starter Kit Power BI Dashboards
