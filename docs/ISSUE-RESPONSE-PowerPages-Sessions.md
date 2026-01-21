# GitHub Issue Response Template

## For Issue: Power Pages Session Tracking Enhancement Request

---

### Response to @JanusAllenCapili

Hi @JanusAllenCapili,

Thank you for raising this enhancement request and for the detailed feedback on the Power BI CoE Inventory Report functionality for Power Pages sites. This is a valuable use case that would help CoE admins better understand Power Pages utilization and ROI.

## Summary

Your request is to add a **number of unique sessions per month** column to the Power Pages section of the CoE Inventory Report, ideally with real-time refresh capability.

## Current Analysis

I've conducted a thorough analysis of this enhancement request. After investigating the current implementation, available APIs, and architectural considerations, I need to share that:

### ❌ **This feature is not currently feasible with available Microsoft APIs**

#### Why:
1. **No Public API Available**: Microsoft does not currently expose a public API for Power Pages session analytics or telemetry data
2. **No Dataverse Table**: Unlike other Power Platform components (e.g., Power Virtual Agents has `conversationtranscripts`), there is no equivalent session tracking table in Dataverse for Power Pages
3. **Architecture Limitation**: Power Pages session analytics are currently only available in the Power Pages Admin Center UI and cannot be accessed programmatically

#### What the CoE Starter Kit Currently Collects for Power Pages:
- ✅ Portal metadata (name, ID, dates)
- ✅ Owner information
- ✅ Environment details
- ✅ Configuration settings (authentication, registration, permissions)
- ❌ Session analytics
- ❌ Usage telemetry
- ❌ Performance metrics

## Alternative Solutions

While we cannot implement this feature directly today, here are recommended alternatives:

### 🎯 **Option 1: Application Insights Integration (Recommended)**

**What it is**: Configure Azure Application Insights for each Power Pages site to track comprehensive analytics including sessions, page views, performance, and more.

**How it would work**:
1. Enable Application Insights for Power Pages sites (requires per-site configuration)
2. Create a Power Automate flow to query Application Insights API
3. Store aggregated metrics in a Dataverse custom table
4. Include in Power BI report

**Pros**:
- ✅ More comprehensive than just session counts
- ✅ Microsoft-supported solution
- ✅ Works with existing CoE architecture

**Cons**:
- ❌ Requires Application Insights setup per site (not automatic)
- ❌ Additional Azure costs
- ❌ Complex implementation (3-4 weeks effort)

### 🎯 **Option 2: Feature Request to Microsoft Product Team**

**Immediate action we can take**: Submit a feature request to the Power Pages product team requesting a public API for session analytics.

**Benefits**:
- ✅ Addresses the root cause
- ✅ Would benefit all CoE users when available
- ✅ Proper Microsoft-supported solution

**Next steps**:
1. Submit idea to [Power Pages Ideas Forum](https://ideas.powerpages.microsoft.com/)
2. Reference this CoE use case
3. Community can vote/promote the idea

## Commitment

**If Microsoft releases a Power Pages Analytics API in the future**, we commit to:
1. Implementing session tracking in the CoE Starter Kit
2. Adding the field to the Power BI Inventory Report
3. Estimated implementation time: 1-2 sprints (2-4 weeks)

## Documentation

I've created a comprehensive analysis document that details:
- Complete feasibility assessment
- Technical limitations
- Alternative solutions with pros/cons
- Future implementation plan (when API becomes available)
- Files that would need modification

📄 **[View Full Analysis Document](docs/ENHANCEMENT-ANALYSIS-PowerPages-Sessions.md)**

## Next Steps

1. **For your immediate needs**: Consider the Application Insights approach if session analytics are critical for your organization
2. **For the CoE community**: I recommend we submit a feature request to Microsoft's Power Pages team
3. **For future implementation**: The CoE Starter Kit team will monitor for API availability and implement this feature when it becomes technically feasible

## Questions?

If you have any questions about this analysis or would like to discuss the alternative solutions in more detail, please let me know. I'm happy to provide additional guidance on implementing Application Insights integration if that's a path you'd like to explore.

Thank you again for this valuable feedback!

---

**Status**: Analysis Complete - Not Feasible (No API Available)  
**Tracking**: Will implement when Microsoft releases Power Pages Analytics API  
**Documentation**: [ENHANCEMENT-ANALYSIS-PowerPages-Sessions.md](docs/ENHANCEMENT-ANALYSIS-PowerPages-Sessions.md)
