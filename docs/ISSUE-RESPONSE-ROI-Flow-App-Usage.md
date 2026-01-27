# Issue Response: ROI Computation for Power Automate Flows and Power Apps

## Response to Feature Request

Thank you for submitting this comprehensive enhancement request for ROI computation capabilities in the CoE Starter Kit. This is a valuable use case that many organizations face when trying to demonstrate business value from their Power Platform investments.

I've conducted a thorough analysis of your requirements and the technical feasibility. Here's a summary of findings and recommendations.

## Summary of Your Request

You're seeking enhanced data collection and reporting to support ROI computation across your tenant, specifically:

**Data Needs:**
- Flow and App metadata (Name, Environment, Type, Status) ✅ **Already collected**
- Ownership details (Primary Owner, Co-owners, Business Unit) ✅ **Partially available** (Primary Owner yes, Business Unit can be added)
- Trigger and action details, including connectors/APIs used ✅ **Already collected**
- Execution metrics (Run count, success/failure rate, frequency, duration) ⚠️ **Partially available** (see below)
- Environment classification (Production, Non-Production, Sandbox) ✅ **Already collected**

**Business Objectives:**
- Aggregate flows and apps across the tenant ✅ **Supported**
- Apply cost/effort-saving rates per run or action ⚠️ **Can be implemented with limitations**
- Calculate ROI metrics (time saved, cost avoidance, business value) ⚠️ **Can be implemented with limitations**
- Trend analysis over time ⚠️ **Can be implemented with limitations**

## Good News: What's Already Available

The CoE Starter Kit **already collects** significant data that supports ROI analysis:

### For Flows:
- ✅ Flow metadata (name, environment, type, state, created/modified dates)
- ✅ Owner information
- ✅ Trigger type identification
- ✅ Connector and action details (via admin_FlowActionDetail table)
- ✅ Premium connector usage flags
- ✅ Last run timestamp
- ✅ Environment information

### For Apps:
- ✅ App metadata (name, environment, type, published status)
- ✅ Owner information
- ✅ Connection references
- ✅ Shared user counts
- ✅ App launches via Office 365 audit logs (when audit log solution is configured)

### For Environments:
- ✅ Environment classification capabilities
- ✅ Business area tagging (can be used for business unit classification)

## The Challenge: Execution Metrics at Scale

The primary gap is **comprehensive execution metrics** (run counts, durations, detailed success/failure tracking). Here's why this is challenging:

### API Limitations

**Power Automate Run History API:**
- ✅ **EXISTS** - Microsoft provides APIs to query flow run history
- ⚠️ **BUT** - Requires individual API calls per flow
- ⚠️ **BUT** - Subject to strict throttling limits
- ⚠️ **BUT** - Data retention typically 30-90 days (not suitable for long-term trends)
- ❌ **MISSING** - No tenant-wide aggregated analytics API
- ❌ **MISSING** - Billable action counts per run not exposed

**Practical Implications:**
- For a tenant with 1,000 flows, retrieving monthly run statistics requires 1,000+ API calls
- Large tenants (10,000+ flows) cannot practically query all flows regularly without hitting throttling
- Continuous monitoring is not feasible at tenant-wide scale

**Power Apps Usage Data:**
- ⏸️ Limited to app launch events from audit logs
- ⏸️ No session duration or feature-level usage without Application Insights

### Similar Analysis - Power Pages Sessions

This is similar to a recent enhancement request for Power Pages session tracking (see [ENHANCEMENT-ANALYSIS-PowerPages-Sessions.md](./ENHANCEMENT-ANALYSIS-PowerPages-Sessions.md)). In that case, Microsoft also does not expose session analytics via public API.

**Pattern**: Power Platform analytics are visible in Admin Center UI but not available via comprehensive public APIs suitable for tenant-wide automated collection.

## Recommended Solution: Phased Implementation

Despite API limitations, we can implement valuable ROI tracking through a **phased, pragmatic approach**:

### Phase 1: Business Context & Focused Monitoring (Recommended to Start)

**What This Provides:**
1. **Business Context Fields** (NEW)
   - Add fields to Flow and App entities for:
     - Business Unit / Cost Center
     - ROI Category (Time Savings, Cost Avoidance, Revenue Generation)
     - Estimated time savings per run (minutes)
     - Estimated cost savings per run ($)
     - Manual process baseline cost
   - These fields can be populated manually by makers or semi-automatically through enrichment flows

2. **Focused Flow Run Monitoring** (NEW)
   - Add "Monitor for ROI" flag to flows
   - Collect detailed run statistics for tagged flows only (not entire tenant)
   - Monthly scheduled flow queries run history for monitored flows
   - Stores aggregated data: run counts, success rates, monthly trends
   - Avoids API throttling by limiting scope

3. **ROI Calculation Framework** (NEW)
   - New flow calculates ROI metrics:
     - Reads run counts for monitored flows
     - Multiplies by time/cost savings rates
     - Generates monthly/quarterly ROI reports
   - Stores results in dedicated ROI Metrics table
   - Powers new Power BI dashboard pages

4. **Enhanced Power BI Reports** (NEW)
   - "ROI Dashboard" page showing:
     - Total time saved across tenant
     - Total cost savings
     - Top ROI contributors
     - ROI by Business Unit
     - Month-over-month trends
   - "Detailed ROI Analysis" page

**Why This Approach Works:**
- ✅ Focuses effort on high-value flows/apps
- ✅ Avoids API throttling by limiting scope
- ✅ Combines available metrics (run counts) with business context (manual rates)
- ✅ Provides actionable ROI insights
- ✅ Scalable (add more flows to monitoring as capacity allows)
- ✅ Leverages existing audit log data for apps

**Limitations to Acknowledge:**
- ⚠️ Not fully automated for all flows (requires tagging/selection)
- ⚠️ Run counts are available, but detailed duration metrics limited
- ⚠️ Cost rates are manual/estimated (not automatic from billing)
- ⚠️ Historical trends limited by API data retention

**Estimated Effort:**
- Development: 6-8 weeks
- Testing & Documentation: 2-3 weeks
- **Total: 8-11 weeks**

### Phase 2: Enhanced App Usage & Advanced Options (Follow-On)

**Additional Capabilities:**
1. Enhanced audit log processing for better app usage patterns
2. Application Insights integration guide (optional, for customers with Azure)
3. PowerShell scripts for periodic deep-dive analysis
4. Expanded monitoring coverage based on Phase 1 learnings

**Estimated Effort:** 4-6 additional weeks

## Alternative Approaches Considered

### 1. Maker Self-Reporting (Complementary Approach)
- Leverage existing `business_value_core` solution for value story capture
- Makers provide ROI context that APIs cannot (business process details, manual baseline)
- Combine with automated run counts for comprehensive ROI stories
- **Benefit**: Captures qualitative value alongside quantitative metrics

### 2. PowerShell-Based Periodic Analysis (Supplement)
- Provide PowerShell scripts for quarterly deep-dive analysis
- Admins run manually for specific business units
- Exports detailed run history to CSV/Excel for analysis
- **Benefit**: Flexible, powerful, no continuous API load

### 3. Azure Log Analytics Integration (Enterprise/Advanced)
- For customers with Azure subscriptions
- Export diagnostic logs to Log Analytics
- Query and aggregate at scale
- **Benefit**: Comprehensive, but requires Azure and expertise

## What We're Asking Microsoft For

To support your use case and others like it, we recommend submitting feature requests to Microsoft for:

1. **Tenant-Wide Analytics API**: Aggregated flow execution metrics without per-flow calls
2. **Billable Action Exposure**: API access to billable action counts per run
3. **Extended Data Retention**: Longer retention for run history analytics
4. **Power Apps Session Analytics API**: Similar to PVA conversation transcripts
5. **Cost Attribution API**: Link execution data to billing/license usage

These enhancements would enable more comprehensive, automated ROI tracking in future CoE Starter Kit versions.

## Recommended Next Steps

### For CoE Starter Kit Maintainers:
1. ✅ **This analysis** documents feasibility and approach
2. Decide if Phase 1 should be prioritized for upcoming release
3. Create implementation issues if approved
4. Submit feature requests to Microsoft Power Platform team
5. Engage with community to refine requirements

### For You (Feature Requester):
1. **Review** the detailed analysis: [ENHANCEMENT-ANALYSIS-ROI-Flow-App-Usage.md](./ENHANCEMENT-ANALYSIS-ROI-Flow-App-Usage.md)
2. **Provide feedback**:
   - Does Phase 1 approach meet your core needs?
   - What's the relative priority (time savings vs. cost vs. other metrics)?
   - How many flows/apps would you want to monitor initially?
   - Is focused monitoring acceptable vs. full tenant coverage?
3. **Vote/upvote** this feature request to show community interest
4. **Consider interim solutions**:
   - Use existing `business_value_core` components for value story capture
   - Implement focused monitoring manually for top flows
   - Use PowerShell for periodic analysis while waiting for enhancement

### In the Meantime:

You can start capturing ROI value today using existing CoE components:

**business_value_core Solution:**
- The CoE Starter Kit already includes a `business_value_core` solution
- Provides value assessment story capture
- Allows tracking of personal productivity and value assessment data
- Can be used to document ROI stories for key flows/apps
- Path: `/business_value_core/` in the repository

**Manual ROI Tracking:**
- Use existing Flow and App data from CoE
- Create custom Power BI report connecting to CoE Dataverse
- Add manual ROI rates in Excel/SharePoint
- Join data for basic ROI reporting
- Provides bridge solution until automated collection is available

## Resources

- **Detailed Analysis**: [ENHANCEMENT-ANALYSIS-ROI-Flow-App-Usage.md](./ENHANCEMENT-ANALYSIS-ROI-Flow-App-Usage.md) (26+ pages)
- **Similar Request Analysis**: [ENHANCEMENT-ANALYSIS-PowerPages-Sessions.md](./ENHANCEMENT-ANALYSIS-PowerPages-Sessions.md)
- **Official CoE Docs**: [Microsoft Learn - CoE Starter Kit](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- **Power Automate Management**: [Power Automate Management Connector](https://learn.microsoft.com/connectors/flowmanagement/)
- **business_value_core**: Available in this repository

## Conclusion

**Summary:**
- ✅ **Most requested data is already collected** by CoE Starter Kit
- ⚠️ **Execution metrics (run counts, duration) are partially available** via API but with scale limitations
- ✅ **ROI computation IS feasible** through phased implementation combining available data with business context
- ❌ **Fully automated, tenant-wide, real-time execution tracking is NOT feasible** with current APIs
- ✅ **Pragmatic solution provides significant value** despite limitations

**Recommendation:**
We recommend implementing **Phase 1: Business Context & Focused Monitoring** as a valuable addition to the CoE Starter Kit. This provides actionable ROI insights while working within API constraints.

**Timeline:**
- Phase 1 implementation: 8-11 weeks (if prioritized)
- Community feedback period: 2-4 weeks
- Release in upcoming CoE Starter Kit version

Please provide feedback on this analysis and proposed approach. Your input will help refine the implementation and ensure it meets your organization's needs.

---

**Response Prepared By**: CoE Custom Agent  
**Date**: January 27, 2026  
**Status**: Awaiting User Feedback & Maintainer Decision
