# Enhancement Request Analysis: ROI Computation for Flows and Apps

## Issue Reference
- **Issue Title**: [CoE Starter Kit - Feature]: ROI computation for Power Automate flows and Power Apps
- **Status**: Under Analysis
- **Date**: January 2026

## Understanding & Summary

### Enhancement Request

The user is requesting enhanced data collection and reporting capabilities in the CoE Starter Kit to support comprehensive Return on Investment (ROI) computation for Power Automate flows and Power Apps across the entire tenant.

**Requested Data Points:**
1. **Flow and App Metadata**
   - Name, Environment, Type, Status
2. **Ownership Details**
   - Primary Owner, Co-owners, Business Unit
3. **Trigger and Action Details**
   - Connectors/APIs used
4. **Execution Metrics**
   - Run count, success/failure rate, frequency, duration
5. **Environment Classification**
   - Production, Non-Production, Sandbox, etc.

**Desired Capabilities:**
- Tenant-wide aggregation of flows and apps
- Application of predefined cost/effort-saving rates per run or action
- ROI calculation (time saved, cost avoidance, business value)
- Trend analysis over time (monthly/quarterly/yearly)

### Core Problem

The user needs to demonstrate business value and ROI for their Power Platform investment but lacks sufficient execution and usage data to:
- Calculate time savings from automation
- Attribute costs to specific business units or applications
- Track efficiency trends over time
- Justify continued or expanded Power Platform investment

## Current CoE Starter Kit Capabilities

### What Data IS Currently Collected

#### For Power Automate Flows (admin_Flow entity):
✅ **Metadata:**
- Flow Name, Display Name, Environment
- Flow Type (Cloud, Desktop, Business Process)
- State (Started, Suspended, Stopped)
- Created/Modified dates
- Owner information
- Orphaned status

✅ **Configuration:**
- Trigger type (via cr5d5_FlowTrigger field)
- Premium connector usage flag (admin_hasPremiumConnectors)
- Flow description
- Environment variables

✅ **Action Details (admin_FlowActionDetail entity):**
- Action Type (connector/action name)
- Linked to parent flow
- Connector information

✅ **Limited Execution Data:**
- Last run date (admin_FlowLastRunON)
- **Note**: This is a timestamp, not comprehensive execution metrics

#### For Power Apps (admin_App entity):
✅ **Metadata:**
- App Name, Display Name, Environment
- App Type (Canvas, Model-driven)
- Published status
- Created/Modified dates
- Owner information

✅ **Configuration:**
- Premium connector usage
- Shared user count
- Connection references

✅ **Usage via Audit Logs (when configured):**
- App launches (from Office 365 audit logs)
- User activity tracking
- **Limitation**: Requires audit log ingestion setup

### What Data IS NOT Currently Available

❌ **Flow Execution Metrics:**
- **Run count** (total runs per flow per period)
- **Run duration** (execution time per run)
- **Success/failure counts** (detailed reliability metrics)
- **Retry counts**
- **Action-level execution statistics**
- **Billable action counts** (for license cost calculation)

❌ **App Usage Metrics:**
- **Session counts** (how many times app was used)
- **Session duration** (time users spend in app)
- **Active user counts** (unique users per period)
- **Feature usage** (which screens/controls are used)

❌ **Business Context:**
- **Business Unit classification** (not automatically assigned)
- **Cost center/department tagging**
- **Business process categorization**

❌ **ROI Calculation Fields:**
- **Time saved per execution**
- **Cost savings per run**
- **Manual process cost baseline**
- **Automation efficiency metrics**

## Feasibility Assessment

### Technical Feasibility Analysis

#### API Availability Research

**Power Automate Run History API:**

✅ **PARTIALLY AVAILABLE** - but with significant limitations

1. **Flow Runs API** (Microsoft documentation):
   - Endpoint: `https://management.azure.com/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Logic/workflows/{workflowName}/runs`
   - Provides: Run status, start time, end time, duration
   - **Limitations**:
     - Requires per-flow API calls (not tenant-wide aggregation)
     - Rate limits apply (especially for large tenants)
     - Requires Azure Resource Manager permissions
     - Data retention: typically 30-90 days
     - Does not provide action-level cost/billing data

2. **Power Automate Management Connector:**
   - Available in Power Platform
   - Can query flow runs via "List Flows as Admin" and "Get Flow Run" actions
   - **Limitations**:
     - Pagination challenges for large datasets
     - API throttling (especially for tenant-wide queries)
     - Does not expose billable action counts
     - Run history limited by platform retention

3. **Power Platform Admin Center Analytics:**
   - Available via UI only
   - Shows run counts, success rates in portal
   - **Limitation**: No public API for these analytics

**Power Apps Usage Telemetry:**

⏸️ **LIMITED AVAILABILITY**

1. **Office 365 Audit Logs:**
   - ✅ App launch events captured
   - ✅ User and timestamp information
   - ❌ No session duration
   - ❌ No feature-level usage
   - Requires: Audit log ingestion (already supported in CoE Starter Kit)

2. **Application Insights (optional):**
   - ✅ Can be configured per-app for detailed telemetry
   - ❌ Not automatic/centralized
   - ❌ Requires Azure subscription and per-app setup
   - ❌ Not included in standard CoE Starter Kit

**Billing and License Data:**

❌ **NOT DIRECTLY AVAILABLE**

- Action-level billing/cost data not exposed via API
- License assignment can be queried (Microsoft Graph API)
- Actual billable action counts per flow run: NOT available
- Cost per action: Would need manual rate table

### Comparison with Existing CoE Capabilities

| Component | Usage Data | Success | Reason |
|-----------|-----------|---------|---------|
| **Power Virtual Agents** | Session transcripts | ✅ YES | Data available in Dataverse `conversationtranscripts` table |
| **Canvas Apps** | Launch events | ⚠️ PARTIAL | Via Office 365 audit logs (requires ingestion) |
| **Cloud Flows** | Last run date | ⚠️ MINIMAL | Only timestamp, not comprehensive metrics |
| **Power Pages** | Session analytics | ❌ NO | No public API (see ENHANCEMENT-ANALYSIS-PowerPages-Sessions.md) |
| **AI Builder** | Credit usage | ✅ YES | Via AI Builder APIs |

### Feasibility Conclusion

**⚠️ PARTIALLY FEASIBLE with significant limitations and effort**

**What CAN Be Implemented:**
1. ✅ Enhanced flow run history collection (basic run counts and status)
2. ✅ App launch tracking via audit logs (already exists, can be enhanced)
3. ✅ Business Unit/tagging (via custom fields and manual/semi-automated classification)
4. ✅ Basic trend analysis with available data
5. ✅ Manual ROI calculation framework (using custom rates)

**What CANNOT Be Fully Implemented:**
1. ❌ Comprehensive run duration tracking at scale (API limitations)
2. ❌ Billable action counts per execution (not exposed by platform)
3. ❌ Automatic cost attribution (no billing API)
4. ❌ Real-time, tenant-wide execution metrics (throttling constraints)
5. ❌ Detailed session duration for apps (limited telemetry)

**Key Blockers:**
- **API Rate Limits**: Tenant-wide flow run history queries would require thousands of API calls for large organizations, hitting throttling limits
- **Data Retention**: Platform run history is time-limited (30-90 days typically), not suitable for long-term trend analysis
- **Missing APIs**: No centralized telemetry/analytics API for Power Automate execution metrics
- **Cost Data**: Microsoft does not expose per-action billing data via API

## Proposed Implementation Approach

### Phase 1: Enhanced Basic Metrics Collection (Feasible Now)

#### 1.1 Flow Run Statistics Collection

**Objective**: Collect basic flow run counts and success rates

**Implementation:**

1. **New Dataverse Entity**: `admin_FlowRunStatistics`
   ```
   Fields:
   - admin_Flow (lookup to admin_Flow)
   - admin_Month (DateTime - first day of month)
   - admin_TotalRuns (Integer)
   - admin_SuccessfulRuns (Integer)
   - admin_FailedRuns (Integer)
   - admin_LastCalculated (DateTime)
   - admin_DataSource (OptionSet: API, Manual, Estimated)
   ```

2. **New Flow**: "Admin | Collect Flow Run Statistics"
   - **Trigger**: Scheduled (monthly)
   - **Logic**:
     - For each active flow (or sample of critical flows):
       - Call Power Automate Management API `List Flow Runs`
       - Aggregate runs by month
       - Calculate success/failure counts
       - Store in admin_FlowRunStatistics table
   - **Considerations**:
     - Implement batching to handle API throttling
     - Focus on "monitored" flows (tagged/filtered list)
     - Run during off-hours to minimize impact
     - Add retry logic for throttling responses

3. **Files to Create/Modify**:
   - `CenterofExcellenceCoreComponents/SolutionPackage/src/Entities/admin_FlowRunStatistics/Entity.xml` (new)
   - `CenterofExcellenceCoreComponents/SolutionPackage/src/Workflows/AdminCollectFlowRunStatistics-[GUID].json` (new)

**Limitations**:
- Cannot scale to ALL flows in large tenants
- API throttling will require careful batch management
- Historical data limited by platform retention

#### 1.2 Business Context Tagging

**Objective**: Enable ROI calculation by adding business context

**Implementation:**

1. **Add Fields to admin_Flow and admin_App**:
   ```
   New fields:
   - admin_BusinessUnit (Text/Lookup)
   - admin_CostCenter (Text)
   - admin_BusinessProcess (Text)
   - admin_ROICategory (OptionSet: Time Savings, Cost Avoidance, Revenue Generation, Compliance)
   - admin_EstimatedTimeSavingsPerRun (Decimal - in minutes)
   - admin_EstimatedCostSavingsPerRun (Currency)
   - admin_ManualProcessCost (Currency)
   - admin_ROICalculationMethod (Text/Memo)
   ```

2. **Update Flows**:
   - Modify inventory sync flows to preserve these fields during updates
   - Create flow to prompt makers for ROI data (via Power Apps form)

3. **Files to Modify**:
   - `CenterofExcellenceCoreComponents/SolutionPackage/src/Entities/admin_Flow/Entity.xml`
   - `CenterofExcellenceCoreComponents/SolutionPackage/src/Entities/admin_App/Entity.xml`

#### 1.3 ROI Calculation Framework

**Objective**: Provide calculated ROI metrics based on collected data and manual rates

**Implementation:**

1. **New Dataverse Entity**: `admin_ROIMetrics`
   ```
   Fields:
   - admin_Resource (lookup to admin_Flow or admin_App)
   - admin_ResourceType (OptionSet: Flow, App)
   - admin_Period (DateTime - start of period)
   - admin_PeriodType (OptionSet: Monthly, Quarterly, Yearly)
   - admin_RunsOrSessions (Integer)
   - admin_TotalTimeSaved (Decimal - hours)
   - admin_TotalCostSavings (Currency)
   - admin_CalculatedROI (Currency)
   - admin_CalculationDate (DateTime)
   ```

2. **New Flow**: "Admin | Calculate ROI Metrics"
   - **Trigger**: Scheduled (monthly/quarterly)
   - **Logic**:
     - For flows with ROI tags:
       - Read run statistics from admin_FlowRunStatistics
       - Multiply runs by admin_EstimatedTimeSavingsPerRun
       - Multiply runs by admin_EstimatedCostSavingsPerRun
       - Calculate total ROI
       - Store in admin_ROIMetrics
     - For apps with app launch data:
       - Read launch counts from audit log data
       - Apply session-based ROI calculations
       - Store results

3. **Files to Create**:
   - `CenterofExcellenceCoreComponents/SolutionPackage/src/Entities/admin_ROIMetrics/Entity.xml` (new)
   - `CenterofExcellenceCoreComponents/SolutionPackage/src/Workflows/AdminCalculateROIMetrics-[GUID].json` (new)

#### 1.4 Power BI Report Enhancements

**Objective**: Visualize ROI data in CoE Dashboard

**Implementation:**

1. **Add New Report Pages**:
   - "ROI Summary Dashboard"
     - Total time saved (tenant-wide)
     - Total cost savings
     - Top ROI flows/apps
     - ROI by Business Unit
   - "Trend Analysis"
     - Monthly/quarterly ROI trends
     - Adoption vs. ROI correlation
   - "Detailed ROI Breakdown"
     - Per-flow/per-app ROI details
     - Success rate correlation with ROI

2. **Files to Modify**:
   - `CenterofExcellenceResources/Release/Collateral/CoEStarterKit/Production_CoEDashboard_July2024.pbit`
   - `CenterofExcellenceResources/Release/Collateral/CoEStarterKit/PowerPlatformGovernance_CoEDashboard_July2024.pbit`

**Effort Estimate**: 
- Phase 1 Development: 6-8 weeks
- Testing & Documentation: 2-3 weeks
- **Total Phase 1**: 8-11 weeks

### Phase 2: Enhanced App Usage Tracking (Requires Additional Setup)

#### 2.1 Enhanced Audit Log Processing

**Objective**: Extract more detailed app usage patterns from audit logs

**Implementation:**

1. **Enhance Existing Audit Log Flows**:
   - Parse app launch events more granularly
   - Track unique users per app per period
   - Estimate session patterns (launch frequency)
   - Store aggregated data in new entity: `admin_AppUsageStatistics`

2. **Files to Modify**:
   - Existing audit log processing workflows in `CenterofExcellenceAuditComponents`

**Effort Estimate**: 3-4 weeks

#### 2.2 Application Insights Integration (Optional/Advanced)

**Objective**: Provide path for customers who want detailed telemetry

**Implementation:**

1. **Documentation & Guidance**:
   - Step-by-step guide for enabling Application Insights per app
   - Sample Power Automate flow to query Application Insights API
   - Guidance on aggregating AI data into CoE tables

2. **Optional Flow Template**:
   - "Admin | Collect App Insights Data"
   - Queries Application Insights REST API
   - Stores session duration, user counts in admin_AppUsageStatistics

**Files to Create**:
- `Documentation/AppInsights-ROI-Integration.md` (new)
- Optional flow template

**Effort Estimate**: 2-3 weeks (documentation + template)

### Phase 3: Community Input & Future API Support

#### 3.1 Feature Request to Microsoft

**Actions**:
1. Submit feature request to Power Platform Ideas forum:
   - Request: Public API for tenant-wide flow execution analytics
   - Request: Exposure of billable action counts per flow run
   - Request: Centralized usage analytics API for Power Apps
2. Reference this analysis and community need
3. Engage with Power Platform product group

#### 3.2 Monitoring & Future Implementation

**When/If Microsoft Releases Enhanced APIs**:
- Update flows to use new APIs
- Remove workarounds/limitations
- Enhance accuracy of ROI calculations
- Estimated effort: 2-3 weeks per API integration

## Alternative Solutions & Workarounds

### Option 1: Focused Monitoring (Recommended Short-Term)

**Description**: Rather than tenant-wide monitoring, focus on high-value flows/apps

**Implementation**:
- Create custom field: `admin_MonitorForROI` (boolean) on admin_Flow and admin_App
- Makers or admins tag critical flows/apps for ROI tracking
- Collect detailed metrics ONLY for tagged resources
- Reduces API calls and focuses effort where ROI matters most

**Pros**:
- ✅ Avoids API throttling issues
- ✅ Focuses on business-critical resources
- ✅ Manageable data volume
- ✅ Implementable immediately

**Cons**:
- ❌ Not tenant-wide
- ❌ Requires manual selection process
- ❌ May miss unexpected high-value automations

**Effort**: Low (2-3 weeks)

### Option 2: Maker Self-Reporting

**Description**: Provide apps/forms for makers to self-report ROI data

**Implementation**:
- Create Canvas App: "ROI Story Capture" (leverage existing business_value_core components)
- Makers provide:
  - Manual process time baseline
  - Automated process time
  - Frequency of execution
  - Business value metrics
- Combine with actual run counts from API where available
- Generate ROI reports from combination of data

**Pros**:
- ✅ Captures business context APIs cannot provide
- ✅ Engages maker community in ROI storytelling
- ✅ No API limitations
- ✅ Can leverage existing business_value_core solution

**Cons**:
- ❌ Relies on maker input (may be incomplete)
- ❌ Subjective data (requires validation)
- ❌ Additional maker burden

**Effort**: Medium (4-5 weeks, leveraging existing components)

### Option 3: PowerShell Script for Periodic Deep Dive

**Description**: Provide PowerShell scripts for manual deep-dive analysis

**Implementation**:
- Create PowerShell script using Power Automate Management module
- Admins run script periodically (quarterly) for specific business units
- Script queries flow runs, aggregates data, exports to Excel/CSV
- Import results into CoE manually or via import flow

**Pros**:
- ✅ Flexible and powerful
- ✅ Can run as-needed without constant API load
- ✅ Provides comprehensive point-in-time analysis

**Cons**:
- ❌ Manual process
- ❌ Not continuous monitoring
- ❌ Requires PowerShell expertise
- ❌ Still subject to API limits (but spread over time)

**Effort**: Low (1-2 weeks for script development)

### Option 4: Azure Logic Apps + Log Analytics (Advanced)

**Description**: Use Azure native services for comprehensive telemetry

**Implementation**:
- Export Power Automate diagnostic logs to Azure Log Analytics
- Create Azure Logic Apps to query and aggregate data
- Store results in Dataverse via custom APIs
- Power BI connects to both Dataverse and Log Analytics

**Pros**:
- ✅ Comprehensive telemetry
- ✅ Scalable Azure infrastructure
- ✅ Long-term data retention
- ✅ Advanced analytics capabilities

**Cons**:
- ❌ Requires Azure subscription
- ❌ Additional cost (Log Analytics ingestion/retention)
- ❌ Complex setup and maintenance
- ❌ Requires Azure expertise
- ❌ Not all flow telemetry automatically exported

**Effort**: High (8-12 weeks for full implementation)

## Recommendation

### Immediate Actions (Weeks 1-4)

1. **Acknowledge Current Limitations**
   - Document in CoE Starter Kit known limitations
   - Be transparent about API constraints
   - Set realistic expectations for ROI tracking

2. **Implement Phase 1.2 - Business Context Tagging** (Highest Value, Low Effort)
   - Add ROI fields to admin_Flow and admin_App entities
   - Update Power BI reports to show ROI data (when populated)
   - Create maker-facing app for ROI data capture
   - Provide guidance on ROI calculation methodologies

3. **Implement Option 1 - Focused Monitoring**
   - Start with pilot: top 50-100 flows for detailed tracking
   - Validate approach and refine before scaling

4. **Leverage Existing business_value_core Components**
   - Review existing value assessment features
   - Determine if they can be enhanced/repurposed for flow/app ROI
   - Integrate with new flow run statistics

### Short-Term (Weeks 5-12)

5. **Implement Phase 1.1 - Flow Run Statistics Collection**
   - Build flow to collect monthly run statistics for monitored flows
   - Implement throttling handling and error recovery
   - Test with progressively larger flow sets

6. **Implement Phase 1.3 - ROI Calculation Framework**
   - Create ROI metrics calculation flow
   - Build initial Power BI visualizations
   - Document ROI methodology

7. **Engage Microsoft Product Team**
   - Submit feature requests for enhanced APIs
   - Share this analysis and community needs
   - Monitor Power Platform roadmap

### Medium-Term (Months 3-6)

8. **Implement Phase 2.1 - Enhanced Audit Log Processing**
   - Improve app usage tracking
   - Add trend analysis
   - Refine ROI calculations based on initial data

9. **Create Comprehensive Documentation**
   - ROI calculation guide for CoE users
   - API limitations and workarounds
   - Best practices for business value tracking
   - Case studies/examples

10. **Community Feedback Loop**
    - Gather feedback from early adopters
    - Refine calculations and reports
    - Share lessons learned

### Long-Term (Months 6+)

11. **Monitor for API Enhancements**
    - Watch for new Power Platform analytics APIs
    - Implement integrations as they become available
    - Remove workarounds when better solutions exist

12. **Advanced Options (As Needed)**
    - Consider Phase 2.2 (Application Insights) for customers with Azure
    - Evaluate Option 4 (Log Analytics) for enterprise customers
    - Provide tooling for multiple ROI tracking approaches

## Implementation Risk Assessment

### Technical Risks

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| API throttling blocks data collection | High | High | Implement focused monitoring; add retry logic; batch operations |
| Data quality issues from manual entry | Medium | Medium | Validation rules; maker training; periodic audits |
| Platform API changes break integration | Medium | High | Regular testing; follow Microsoft roadmap; version handling |
| Power BI performance with large datasets | Medium | Medium | Data aggregation; archival strategy; incremental refresh |
| Incomplete adoption by makers | High | Medium | Communication plan; show quick wins; executive sponsorship |

### Business Risks

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| ROI calculations questioned/disputed | Medium | Medium | Document methodology; provide transparency; allow custom rates |
| Expectations exceed API capabilities | High | High | Clear documentation; set expectations early; show roadmap |
| Effort exceeds value for some orgs | Medium | Low | Phased approach; optional features; focus on high-value scenarios |

## Files to Be Created/Modified

### New Files (Phase 1)

**Dataverse Entities:**
1. `CenterofExcellenceCoreComponents/SolutionPackage/src/Entities/admin_FlowRunStatistics/Entity.xml`
2. `CenterofExcellenceCoreComponents/SolutionPackage/src/Entities/admin_ROIMetrics/Entity.xml`
3. `CenterofExcellenceCoreComponents/SolutionPackage/src/Entities/admin_AppUsageStatistics/Entity.xml` (Phase 2)

**Workflows:**
1. `CenterofExcellenceCoreComponents/SolutionPackage/src/Workflows/AdminCollectFlowRunStatistics-[GUID].json`
2. `CenterofExcellenceCoreComponents/SolutionPackage/src/Workflows/AdminCalculateROIMetrics-[GUID].json`

**Canvas Apps:**
1. `CenterofExcellenceCoreComponents/SolutionPackage/src/CanvasApps/admin_ROICaptureApp-[GUID]/` (or enhance existing business_value_core app)

**Documentation:**
1. `Documentation/ROI-Tracking-Guide.md`
2. `Documentation/ROI-Calculation-Methodology.md`
3. `Documentation/ROI-Limitations-and-Workarounds.md`
4. `Documentation/AppInsights-ROI-Integration.md` (Phase 2)

### Files to Modify

**Existing Entities (Add Fields):**
1. `CenterofExcellenceCoreComponents/SolutionPackage/src/Entities/admin_Flow/Entity.xml`
   - Add business context and ROI fields
2. `CenterofExcellenceCoreComponents/SolutionPackage/src/Entities/admin_App/Entity.xml`
   - Add business context and ROI fields

**Power BI Reports:**
1. `CenterofExcellenceResources/Release/Collateral/CoEStarterKit/Production_CoEDashboard_July2024.pbit`
   - Add ROI report pages
2. `CenterofExcellenceResources/Release/Collateral/CoEStarterKit/PowerPlatformGovernance_CoEDashboard_July2024.pbit`
   - Add ROI governance views

**Documentation Updates:**
1. Main README - Add ROI tracking section
2. Core Components README - Document new entities/flows
3. Known Limitations - Document API constraints for ROI

## Compliance & Licensing Considerations

### Licensing

- **CoE Starter Kit Requirements**: 
  - Power Automate per-user or per-flow license (existing requirement)
  - No additional licenses for basic ROI tracking
- **Optional Components**:
  - Azure subscription (for Application Insights or Log Analytics approach)
  - Power BI Pro (existing requirement for dashboard usage)

### Data Privacy

- Flow run statistics are aggregated (not individual user actions)
- App launch data from audit logs: follows existing audit log privacy policies
- Business context (cost/time data): internal business data, not user PII
- Ensure compliance with organizational data retention policies

### Security

- ROI data may be business-sensitive (cost, efficiency metrics)
- Ensure appropriate Dataverse security roles
- Consider restricting ROI report access to leadership/CoE team
- API access requires Power Platform admin permissions (existing requirement)

### API Usage Policies

- Must comply with Microsoft API throttling limits
- Must not violate Power Platform service agreements
- Recommend off-hours processing for large data collection
- Monitor API usage to avoid service disruptions

## Success Criteria

### Phase 1 Success Metrics

After Phase 1 implementation, users should be able to:
- ✅ Tag flows and apps with business context (business unit, ROI category)
- ✅ Capture estimated time/cost savings per execution
- ✅ View monthly run counts for monitored flows
- ✅ Calculate basic ROI metrics (time saved, cost avoided)
- ✅ Generate ROI reports in Power BI
- ✅ Track ROI trends over time (monthly/quarterly)

### Quality Gates

- Documentation clearly explains capabilities AND limitations
- API calls respect throttling limits (no service disruptions)
- Power BI reports load within acceptable time (<10 seconds for summary views)
- ROI calculations are transparent and auditable
- Maker feedback is positive on usability

## Conclusion

**Current Status**: ⚠️ **PARTIALLY FEASIBLE** - Core ROI tracking can be implemented with limitations

**Recommended Path Forward**:
1. **Implement Phase 1 (8-11 weeks)** - Provides valuable ROI tracking with current API capabilities
2. **Start with focused monitoring** - Avoid throttling by targeting high-value resources
3. **Leverage business_value_core** - Build on existing value assessment components
4. **Document limitations clearly** - Set realistic expectations about what can be tracked
5. **Engage Microsoft** - Submit feature requests for enhanced APIs
6. **Iterate based on feedback** - Refine approach as users adopt and provide input

**Key Message to User**:
> The CoE Starter Kit can be enhanced to support ROI computation for flows and apps, but with important limitations due to Power Platform API constraints. We recommend a phased approach starting with business context tagging and focused monitoring of high-value resources. This will provide meaningful ROI insights while avoiding API throttling issues. As Microsoft enhances their analytics APIs, we can expand capabilities to provide more comprehensive, automated ROI tracking.

**Value Proposition**:
- Even with limitations, this enhancement provides significant value
- Enables data-driven conversations about Power Platform ROI
- Combines available metrics with business context for compelling stories
- Creates foundation for future enhancements as APIs improve
- Positions organization to quickly adopt new capabilities when available

---

**Document Prepared By**: CoE Custom Agent  
**Date**: January 27, 2026  
**Next Steps**: 
1. Review with stakeholders
2. Prioritize phases based on organizational needs
3. Begin Phase 1 implementation
4. Submit Microsoft feature requests
