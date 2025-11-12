# Answer to Issue #10449: Bing Maps Visuals Deprecation Impact on CoE Dashboards

## Direct Answer to the Question

**Question**: "Will this upcoming change cause an issue with the CoE Dashboards?"

**Answer**: **Yes, potentially** - If your CoE dashboards contain Bing Maps visuals for geographic visualizations, they will be affected when Microsoft removes Bing Maps support in the **October 2025 Power BI release**. However, this is manageable with proper planning.

## Key Points

### What's Happening
- Microsoft is deprecating Bing Maps visuals in Power BI
- Support will end with the October 2025 Power BI Desktop release
- After that date, reports using Bing Maps visuals may stop displaying map data correctly

### Impact on CoE Starter Kit
The CoE Starter Kit includes several Power BI dashboard templates that **may** use map visuals to display:
- Maker locations by geography
- App usage by country/region
- Resource distribution across locations
- Other geographic insights

**If your dashboards use these map visualizations, action is required.**

### What You Need to Do

1. **Check Your Dashboards** (Action: Now)
   - Open your CoE dashboards in Power BI Desktop
   - Identify if any pages use Map or Filled Map visuals
   - Document which dashboards are affected

2. **Migrate to Azure Maps** (Action: Before October 2025)
   - Power BI provides an automatic conversion tool
   - Most settings and data mappings transfer automatically
   - Minor visual adjustments may be needed

3. **Timeline**
   - **Now - March 2025**: Plan and test migration
   - **April - September 2025**: Complete migration in production
   - **October 2025**: Bing Maps support removed

### The Good News

✅ **Microsoft provides an easy migration path**
- Automatic conversion tool in Power BI Desktop
- Most configurations transfer automatically
- Azure Maps offers better performance and modern features

✅ **You have time**
- Over 10 months until deprecation (from November 2024)
- Plenty of time for planning, testing, and migration

✅ **Azure Maps is better**
- Faster performance
- Modern styling
- Better long-term support
- Regular feature updates

### Resources Created

I've created two comprehensive guides to help you:

1. **[Bing Maps Deprecation FAQ](.github/BING_MAPS_DEPRECATION_FAQ.md)**
   - Quick reference guide
   - Timeline and impact summary
   - Step-by-step migration overview
   - Recommendations and resources

2. **[Azure Maps Migration Guide](.github/AZURE_MAPS_MIGRATION_GUIDE.md)**
   - Detailed technical migration steps
   - Pre-migration assessment checklist
   - Troubleshooting guide
   - Rollout strategy and best practices

## Immediate Next Steps

1. **Assess Your Environment**
   ```
   - Open each CoE dashboard template
   - Check for Map or Filled Map visuals
   - Document affected reports
   ```

2. **Test in Non-Production**
   ```
   - Update Power BI Desktop (April 2025+ version)
   - Test conversion on a copy of your dashboard
   - Verify results meet your needs
   ```

3. **Plan Your Migration**
   ```
   - Schedule migration work
   - Allocate time for testing
   - Communicate timeline to stakeholders
   ```

## Additional Information

### Will This Break My Dashboards?
- **Not immediately** - Bing Maps still works until October 2025
- **Yes, eventually** - After October 2025, Bing Maps visuals won't function
- **Action required** - Migrate to Azure Maps before October 2025

### Is This Difficult?
- **No** - Power BI provides automatic conversion
- Migration typically takes minutes per dashboard
- Most settings transfer automatically
- Testing and validation take the most time

### Official Microsoft Resources
- [Convert Map and Filled map visuals to Azure Maps](https://learn.microsoft.com/en-us/azure/azure-maps/power-bi-visual-conversion)
- [CoE Dashboard Setup Guide](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup-powerbi)
- [Power BI Community Discussion](https://community.fabric.microsoft.com/t5/Desktop/Are-default-Map-and-Filled-Map-visuals-being-retired-in-Power-BI/td-p/4779834)

## Summary

**Yes, this change will affect CoE dashboards that use Bing Maps visuals, but:**
- You have until October 2025 to migrate
- Microsoft provides easy migration tools
- Azure Maps is a better solution long-term
- Comprehensive guides are now available to help you

**Recommendation**: Start planning your migration now, but don't panic - you have plenty of time to test and migrate properly.

---

**Issue Reference**: #10449  
**Documentation Created**: November 2024  
**Deprecation Date**: October 2025
