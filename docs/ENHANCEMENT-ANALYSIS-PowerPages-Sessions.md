# Enhancement Request Analysis: Power Pages Session Tracking

## Issue Reference
- **Issue Title**: [CoE Starter Kit - Feature]: Power BI Inventory Report - Include Number of Unique Sessions in a Power Pages site
- **Requested by**: @JanusAllenCapili
- **Status**: Under Analysis

## Understanding & Summary

### Enhancement Request
The user is requesting the addition of a new column/field in the Power BI CoE Inventory Report specifically for Power Pages sites that would display:
- **Number of unique sessions** for each Power Pages site
- **Time period**: Per month (with potential for real-time refresh)
- **Purpose**: To help identify and track usage/engagement metrics for Power Pages sites

### Core Problem
Currently, the CoE Starter Kit inventories Power Pages sites and captures basic metadata (name, owner, environment, configuration settings, etc.) but does **not capture usage or session analytics data**. This limits visibility into:
- Which Power Pages sites are actively being used
- Volume of user engagement per site
- ROI/value assessment for Power Pages implementations

## Feasibility Assessment

### Current Implementation Analysis

#### What the CoE Starter Kit Currently Collects for Power Pages:
Based on the analysis of `/CenterofExcellenceCoreComponents/SolutionPackage/src/`:

1. **Flow**: `AdminSyncTemplatev4Portals` (Power Pages Inventory Flow)
2. **Entity**: `admin_portal` (Power Pages Sites table)
3. **Data Collected** (via Dataverse tables):
   - Portal metadata: name, ID, creation/modification dates, unique name
   - Owner information
   - Environment details
   - Configuration settings: authentication methods, registration settings, table permissions
   - Website ID and domain name
   - Orphaned status and deletion tracking

4. **Data Source**: 
   - Queries `adx_websites` or `mspp_websites` tables in environment Dataverse
   - Queries `adx_sitesettings`, `adx_entitylists`, `adx_entityforms`, `adx_webforms` for configuration
   - No connection to analytics/telemetry APIs

#### What Is NOT Currently Collected:
- ❌ Session counts or analytics
- ❌ Page views
- ❌ User engagement metrics
- ❌ Performance data
- ❌ Any usage/telemetry data

### Technical Feasibility Analysis

#### API Availability Research

**Power Pages Analytics APIs - Current Status (as of January 2026):**

1. **Power Pages Site Telemetry API**: ❌ **NOT PUBLICLY AVAILABLE**
   - Microsoft has internal telemetry for Power Pages
   - Currently NO public API endpoint for retrieving session data programmatically
   - Reference: [Microsoft Learn - Power Pages](https://learn.microsoft.com/en-us/power-pages/)

2. **Available Power Pages APIs**:
   - ✅ Power Pages Management API (for site configuration, metadata)
   - ✅ Dataverse API (for website configuration data)
   - ❌ Analytics/Telemetry API (not exposed)

3. **Existing Analytics Solutions**:
   - **Power Pages Admin Center**: Shows basic metrics in the portal UI
     - Site sessions (limited visibility)
     - Available only in the UI, not via API
   - **Application Insights**: Can be configured per Power Pages site
     - Requires manual configuration per site
     - Data stored in Azure Application Insights
     - Would require custom integration
   - **Microsoft Clarity**: Can be integrated for user behavior analytics
     - Third-party integration
     - Requires site-by-site setup

#### Comparison with Other Power Platform Components

The CoE Starter Kit successfully collects usage data for:
- **Power Virtual Agents**: Uses `conversationtranscripts` table (✅ Available in Dataverse)
- **AI Builder**: Uses AI Builder APIs for credit usage (✅ Available)
- **Canvas Apps**: Uses Office 365 audit logs for launch data (✅ Available)
- **Cloud Flows**: Uses flow run history APIs (✅ Available)

**Power Pages** is unique in that:
- Session data is NOT exposed in Dataverse tables
- No standard telemetry API exists
- Analytics are portal-specific and UI-only in Admin Center

### Feasibility Conclusion

**❌ NOT FEASIBLE with current Power Platform APIs**

**Reasons:**
1. **No Public API**: Microsoft does not expose a public API for Power Pages session analytics/telemetry
2. **No Dataverse Table**: Unlike PVA (which has `conversationtranscripts`), there's no equivalent session tracking table in Dataverse for Power Pages
3. **Architecture Limitation**: Power Pages sites are web applications; session tracking would require:
   - Server-side telemetry collection at the Power Pages infrastructure level
   - Microsoft would need to expose this via API (currently not available)

## Alternative Solutions & Workarounds

### Option 1: Application Insights Integration (Recommended)
**Description**: Configure Application Insights for each Power Pages site and aggregate data

**Implementation Approach**:
1. **Per-Site Setup**: Enable Application Insights for each Power Pages site
2. **Data Collection**: Application Insights automatically tracks:
   - Page views
   - Unique users/sessions
   - Performance metrics
3. **Aggregation**: 
   - Create Power Automate flow to query Application Insights API
   - Store aggregated metrics in Dataverse custom table
   - Include in Power BI report

**Pros**:
- ✅ Comprehensive analytics (more than just sessions)
- ✅ Microsoft-supported solution
- ✅ Works with current CoE architecture

**Cons**:
- ❌ Requires Application Insights setup for each site (not automatic)
- ❌ Additional Azure cost (Application Insights pricing)
- ❌ Requires Application Insights resource management
- ❌ Complex implementation (API authentication, query logic)

**Effort**: High (3-4 weeks development + setup guidance)

### Option 2: Custom Telemetry Implementation
**Description**: Implement custom JavaScript tracking in Power Pages sites

**Implementation Approach**:
1. Create standard JavaScript tracking code
2. Documentation for makers to add to Power Pages sites
3. Send events to Dataverse custom table or Azure Event Hub
4. Aggregate and report in Power BI

**Pros**:
- ✅ Flexible and customizable
- ✅ Can track specific events

**Cons**:
- ❌ Requires manual implementation per site
- ❌ Not standardized across all Power Pages
- ❌ Maintenance burden
- ❌ Makers must opt-in

**Effort**: Medium-High (2-3 weeks + documentation)

### Option 3: PowerShell/Admin Center Scraping (Not Recommended)
**Description**: Attempt to scrape data from Power Pages Admin Center UI

**Pros**:
- None significant

**Cons**:
- ❌ Unsupported approach
- ❌ Fragile (breaks with UI changes)
- ❌ Violates Microsoft terms of service
- ❌ No API-level data access

**Effort**: High with high risk

**Recommendation**: ❌ DO NOT PURSUE

### Option 4: Feature Request to Microsoft (Recommended Short-Term)
**Description**: Submit feature request to Power Pages product team

**Implementation Approach**:
1. Submit idea to [Power Pages Ideas Forum](https://ideas.powerpages.microsoft.com/)
2. Reference CoE use case
3. Request public API for session analytics
4. Vote/promote the idea in community

**Pros**:
- ✅ Addresses root cause
- ✅ Would benefit all CoE users
- ✅ Microsoft-supported when available

**Cons**:
- ❌ Uncertain timeline
- ❌ No guarantee of implementation
- ❌ Not immediate solution

**Effort**: Low (1-2 hours to submit)

## Recommendation

### Immediate Actions (Weeks 1-2)
1. **Document the limitation** in CoE Starter Kit documentation
   - Add note to Power BI Dashboard documentation explaining Power Pages session data is not available
   - Add to known limitations section

2. **Submit Feature Request to Microsoft**
   - File idea on Power Pages Ideas Forum
   - Reference this analysis and CoE Starter Kit use case
   - Engage Power Pages product team

3. **Provide guidance to users**
   - Document Alternative Option 1 (Application Insights) as recommended workaround
   - Create step-by-step guide for setting up Application Insights for Power Pages
   - Provide Power Automate flow template for AI data collection (if feasible)

### Future Consideration (If Microsoft Releases API)
When/if Microsoft releases a Power Pages Analytics API:
1. Create new entity field: `admin_portal.admin_uniquesessionsmonthly` (Integer)
2. Update `AdminSyncTemplatev4Portals` flow to call new API
3. Add field to Power BI report
4. Estimated effort: 2-3 days

### Respond to Issue
Respond to @JanusAllenCapili with:
- Appreciation for the feature request
- Explanation of current technical limitation (no API)
- Recommended alternatives (Application Insights approach)
- Commitment to implement if Microsoft reserves API
- Link to this analysis document

## Technical Impact Assessment

### If Implemented (Future State When API Available)

#### Files to Modify:
1. **Dataverse Entity**: `/CenterofExcellenceCoreComponents/SolutionPackage/src/Entities/admin_portal/Entity.xml`
   - Add new attribute: `admin_UniqueSessionsMonthly` (Integer)
   - Add attribute: `admin_SessionsLastRefreshed` (DateTime)

2. **Power Automate Flow**: `/CenterofExcellenceCoreComponents/SolutionPackage/src/Workflows/AdminSyncTemplatev4Portals-CEAD57C0-A080-EE11-8179-000D3A341FFF.json`
   - Add API call to Power Pages Analytics endpoint
   - Add logic to update session fields
   - Handle errors/permissions

3. **Power BI Reports**: 
   - `Production_CoEDashboard_July2024.pbit`
   - `PowerPlatformGovernance_CoEDashboard_July2024.pbit`
   - Add column to Power Pages pages/visuals
   - Add measure for session trending

4. **Documentation**:
   - Update setup guide with new field
   - Add permissions requirements
   - Add troubleshooting for session data collection

#### Potential Risks:
- **API Throttling**: Analytics APIs may have rate limits
- **Permissions**: May require additional admin permissions
- **Data Volume**: Session data could be large for high-traffic sites
- **Licensing**: Analytics data access may require specific licenses

## Compliance & Licensing Considerations

### Licensing
- Power Pages analytics may require specific licensing tiers
- CoE Starter Kit requires Power Automate per-user or per-flow license
- Application Insights approach requires Azure subscription

### Data Privacy
- Session data may contain PII depending on tracking implementation
- Must comply with organizational data retention policies
- GDPR/privacy considerations for tracking user sessions

### Security
- API access requires appropriate admin permissions
- Must secure any custom telemetry endpoints
- Application Insights data needs proper access controls

## Conclusion

**Current Status**: ❌ **NOT FEASIBLE** - No public API available for Power Pages session analytics

**Path Forward**:
1. Document limitation and provide workarounds
2. Engage Microsoft product team via Ideas Forum
3. Monitor for API availability
4. Implement when technically feasible

**Estimated Timeline if API Released**: 1-2 sprints (2-4 weeks) to implement

---

**Document Prepared By**: CoE Custom Agent  
**Date**: January 13, 2026  
**Next Review**: When Power Pages Analytics API becomes available
