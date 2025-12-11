# Bing Maps Visual Deprecation in CoE Dashboards - FAQ

## Question
**Will the deprecation of Bing Maps visuals in Power BI affect the CoE Starter Kit dashboards?**

## Answer

### Summary
Yes, the deprecation of Bing Maps visuals in Power BI **may affect** the CoE Starter Kit dashboards if they contain Bing Maps visuals. However, Microsoft is providing a clear migration path to Azure Maps visuals, and the impact can be managed proactively.

### Timeline
- **Current Status (November 2024)**: Bing Maps visuals are still functional but deprecated
- **Planned Deprecation**: Bing Maps visual support will be removed with the **October 2025 Power BI release**
- **Action Required**: Migrate to Azure Maps before October 2025 to avoid disruption

### Impact on CoE Starter Kit Dashboards

The CoE Starter Kit includes several Power BI dashboard templates:
- `Production_CoEDashboard_July2024.pbit`
- `BYODL_CoEDashboard_July2024.pbit`
- `PowerPlatformGovernance_CoEDashboard_July2024.pbit`
- `Pulse_CoEDashboard.pbit`
- `Power Platform Administration Planning.pbit`

**If these dashboards use Bing Maps visuals for geographic visualizations** (such as showing maker locations, app usage by country/region, or other location-based data), they will need to be updated to use Azure Maps visuals instead.

### What You Need to Do

#### 1. **Check Your Dashboards**
Open your CoE Dashboard in Power BI Desktop and identify if any pages use map visualizations:
- Look for Map or Filled Map visuals
- Check for geographic data visualizations (country, region, city, location fields)

#### 2. **Migrate to Azure Maps** (if map visuals exist)

Power BI provides an automatic migration tool:

**Automatic Conversion:**
- Open the report in Power BI Desktop (April 2025 version or later)
- You'll receive a prompt to upgrade all Map/Filled Map visuals to Azure Maps
- Click to convert all visuals in one operation
- Most properties and settings will carry over automatically

**Manual Conversion:**
- Select the Map or Filled Map visual you want to convert
- In the Visualizations pane, find and select the Azure Maps visual
- The conversion will maintain your data fields and most settings

#### 3. **Test Your Dashboards**
After migration:
- Verify all map visualizations display correctly
- Check that bubble sizes, colors, and tooltips work as expected
- Test filtering and drill-down capabilities
- Note: Bubble sizes may appear slightly smaller in Azure Maps compared to Bing Maps

#### 4. **Republish to Power BI Service**
- Save your updated .pbit template
- Republish to your Power BI workspace
- Test in the Power BI Service to ensure everything works

### Important Considerations

#### Azure Maps Benefits:
- ✅ Modern, faster performance
- ✅ Better long-term support from Microsoft
- ✅ Improved styling options
- ✅ Regular updates and new features

#### Azure Maps Limitations to Be Aware Of:
- ⚠️ **Regional Support**: Azure Maps may not yet be supported in all regions (China, Korea, some government clouds)
- ⚠️ **Publish to Web**: Azure Maps currently does not support "Publish to Web" feature (if you're using public sharing)
- ⚠️ **Data Processing**: Azure Maps data may be processed outside your tenant's geographic region
- ⚠️ **Visual Differences**: Minor differences in bubble sizing and visual styling

#### For Power BI Administrators:
- Ensure Power BI Desktop is updated to April 2025 version or later
- Review and enable Azure Maps tenant settings in Power BI Admin Portal
- Configure appropriate data processing boundaries and compliance settings
- Review the split Azure Maps controls for refined management

### Resources and Documentation

**Microsoft Official Documentation:**
- [Convert Map and Filled map visuals to Azure Maps](https://learn.microsoft.com/en-us/azure/azure-maps/power-bi-visual-conversion)
- [Set up the CoE Power BI dashboard](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup-powerbi)
- [Monitor with the CoE Power BI dashboard](https://learn.microsoft.com/en-us/power-platform/guidance/coe/power-bi-monitor)

**Additional Information:**
- [Power BI Community Discussion on Map Visual Retirement](https://community.fabric.microsoft.com/t5/Desktop/Are-default-Map-and-Filled-Map-visuals-being-retired-in-Power-BI/td-p/4779834)
- [Azure Maps Migration Guide](https://www.hubsite365.com/en-ww/crm-pages/bing-maps-are-going-away-convert-to-azure-maps-in-power-bi.htm)

### Recommendations

1. **Start Early**: Don't wait until October 2025 - begin migration planning now
2. **Test Thoroughly**: Allocate time for testing after conversion to ensure accuracy
3. **Communicate**: Inform stakeholders about the change and any visual differences
4. **Monitor**: Watch for updates from Microsoft and the CoE Starter Kit team
5. **Check for Updates**: The CoE Starter Kit may release updated templates with Azure Maps already configured - check the [releases page](https://github.com/microsoft/coe-starter-kit/releases) regularly

### Need Help?

- **CoE Starter Kit Issues**: File an issue on the [GitHub repository](https://github.com/microsoft/coe-starter-kit/issues)
- **Power BI Questions**: Ask in the [Power BI Community](https://community.fabric.microsoft.com/)
- **Power Platform Governance**: Post in the [Power Apps Community forum](https://powerusers.microsoft.com/t5/Power-Apps-Governance-and/bd-p/Admin_PowerApps)

---

**Last Updated**: November 2024  
**Status**: Bing Maps deprecation scheduled for October 2025  
**Action Required**: Migrate to Azure Maps before October 2025
