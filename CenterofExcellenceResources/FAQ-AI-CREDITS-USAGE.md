# FAQ: AI Credits Usage Data Collection

## Frequently Asked Questions

### Q1: Why is AI Credits usage data not showing in my Power BI reports?

**Quick Answer**: The CoE Starter Kit has no date limitations in its code. If data isn't appearing, the issue is typically:
1. The data collection flow isn't running
2. Microsoft's `msdyn_aievents` table isn't being populated (platform issue)
3. No AI Builder activity in your tenant

**Full Troubleshooting**: See [TROUBLESHOOTING-AI-CREDITS-DATA.md](./TROUBLESHOOTING-AI-CREDITS-DATA.md)

---

### Q2: My AI Credits data stopped at December 2025 (or another date). Why?

**Answer**: This is NOT due to hardcoded dates in the CoE Starter Kit. Our analysis confirmed:
- ✅ No hardcoded years (2025, 2026, etc.)
- ✅ No month-specific filters
- ✅ Flow uses dynamic date functions (`LastXDays`)

**Most Common Causes**:
1. **Flow stopped running** - Check if "Admin | Sync Template v4 (AI Usage)" is enabled and has run recently
2. **Source data missing** - Microsoft's AI Builder platform may not be writing to `msdyn_aievents` table
3. **No AI activity** - No models running = no data generated

**Action**: Follow troubleshooting steps in [TROUBLESHOOTING-AI-CREDITS-DATA.md](./TROUBLESHOOTING-AI-CREDITS-DATA.md)

---

### Q3: How often does AI Credits data refresh?

**Answer**: 
- **Flow Schedule**: Daily (by default)
- **Data Scope**: The flow queries yesterday's data (`LastXDays(1)`)
- **Power BI Refresh**: Manual or scheduled (configured in your Power BI workspace)

**Note**: If you make changes today, you'll see them in:
- Dataverse table: After the next flow run (next day)
- Power BI report: After the next Power BI dataset refresh

---

### Q4: Which table stores AI Credits usage data?

**Answer**: Two tables are involved:

| Table | Location | Purpose | Managed By |
|-------|----------|---------|------------|
| `msdyn_aievents` | Each environment | Source data (raw AI usage events) | Microsoft (system table) |
| `admin_AICreditsUsage` | CoE environment | Aggregated usage data | CoE Starter Kit |

**Data Flow**: 
```
msdyn_aievents (per environment) 
  → Admin | Sync Template v4 (AI Usage) flow 
    → admin_AICreditsUsage (CoE environment) 
      → Power BI reports
```

---

### Q5: What permissions are required to collect AI Credits data?

**Answer**: The flow connection must have:

✅ **Entra ID (Azure AD) Roles**:
- Power Platform Administrator (or)
- Dynamics 365 Administrator

✅ **Environment Roles**:
- System Administrator in each environment being scanned
- System Administrator in the CoE environment

✅ **Licenses**:
- Power Apps Per User or Premium license
- Access to environments where AI Builder is used

**See Also**: [FAQ-AdminRoleRequirements.md](./FAQ-AdminRoleRequirements.md)

---

### Q6: Can I manually trigger the AI Credits collection flow?

**Answer**: Yes!

1. Go to your **CoE environment**
2. Open **Power Automate** → **Cloud flows**
3. Find **Admin | Sync Template v4 (AI Usage)**
4. Click **Run** → **Run flow**

**Note**: The flow only collects yesterday's data by default. It won't retroactively fill in missing historical data.

---

### Q7: How can I collect historical AI Credits data?

**Answer**: The standard flow only collects yesterday's data. To collect historical data:

**Option 1: Modify the Flow (Advanced)**
1. Edit the flow
2. Find the OData filter: `LastXDays(PropertyName='msdyn_processingdate',PropertyValue=1)`
3. Change `PropertyValue=1` to a larger number (e.g., 30 for last 30 days)
4. Run the flow once
5. Revert back to `PropertyValue=1` after the historical collection

**Option 2: Contact Support**
- If `msdyn_aievents` table never had the data, it cannot be retroactively collected
- Historical data must exist in the source table first

---

### Q8: Does AI Credits data collection work for all AI Builder model types?

**Answer**: The flow collects data from the `msdyn_aievents` table, which should include:
- ✅ Document processing models
- ✅ Prediction models
- ✅ Text generation models (AI Builder)
- ✅ Form processing models
- ✅ Object detection models

**However**: 
- The data depends on Microsoft's AI Builder platform writing to `msdyn_aievents`
- If a new AI model type isn't logging data, that's a platform-level issue

---

### Q9: Why does my environment not have the `msdyn_aievents` table?

**Answer**: The `msdyn_aievents` table is a Microsoft system table that should exist if:
- ✅ AI Builder is enabled in the environment
- ✅ The environment has AI Builder capacity/credits
- ✅ The environment type supports AI Builder (Production, Sandbox)

**May NOT exist in**:
- ❌ Trial environments (some types)
- ❌ Developer environments
- ❌ Environments without AI Builder license

**Solution**: 
1. Check environment type in Power Platform Admin Center
2. Verify AI Builder capacity is allocated
3. Try creating a simple AI model to trigger table creation

---

### Q10: Can I use a service principal for AI Credits collection?

**Answer**: 
- **Theoretically**: Yes, if the service principal has proper roles
- **In Practice**: May encounter limitations with system tables

**Requirements for Service Principal**:
- Application ID registered in Entra ID
- Power Platform Administrator role
- System Administrator in environments
- Proper API permissions for Dataverse

**Recommendation**: Start with user-based authentication first. Only use service principals if required by your organization's security policies.

**See Also**: ServicePrincipalSupport.md (if available in repository)

---

### Q11: Does AI Credits data collection affect my AI Builder credit consumption?

**Answer**: **No**, the data collection flow does NOT consume AI Builder credits. It only:
- Reads existing usage records from `msdyn_aievents`
- Writes to CoE Starter Kit tables
- Does not invoke AI Builder models

**Credits are consumed by**:
- Running AI Builder models
- Processing documents/images
- Making predictions
- Using AI features in apps/flows

---

### Q12: How can I verify that AI Builder is actually being used in my tenant?

**Answer**: 

**Method 1: Power Platform Admin Center**
1. Go to **Power Platform Admin Center**
2. Navigate to **Analytics** → **AI Builder** (if available)
3. Check usage metrics

**Method 2: Per Environment Check**
1. Open an environment in Power Apps
2. Go to **AI Builder** section
3. Check **Models** → Look at **Last Run** dates
4. Verify models are **Published** and **Enabled**

**Method 3: Capacity Analytics**
1. Power Platform Admin Center → **Resources** → **Capacity**
2. Check **Add-ons** → **AI Builder** credits
3. Look at consumption trends

---

### Q13: What should I do if Microsoft Support confirms a platform issue with `msdyn_aievents`?

**Answer**: 

1. **Document the issue**:
   - Support ticket number
   - Environments affected
   - Time period of missing data

2. **Monitor for resolution**:
   - Check for platform updates
   - Test periodically if table starts populating

3. **Consider workarounds** (if needed):
   - Manual tracking via Power BI for AI model runs
   - Custom auditing solution (advanced)

4. **Communicate to stakeholders**:
   - Explain this is a platform limitation
   - Provide timeline for resolution (if known)

---

### Q14: How long is AI Credits usage data retained?

**Answer**: 

**In `admin_AICreditsUsage` table**:
- Retention is based on your CoE Starter Kit data retention policies
- By default: No automatic deletion (data grows indefinitely)
- See: [DataRetentionAndMaintenance.md](./DataRetentionAndMaintenance.md)

**In `msdyn_aievents` table** (source):
- Controlled by Microsoft's platform policies
- Typically: 30-90 days (varies by region/configuration)
- Not configurable by end users

**Best Practice**: 
- Keep CoE data long-term for trend analysis
- Back up Power BI reports regularly

---

### Q15: Can I customize what AI Credits data is collected?

**Answer**: 

**Currently Collected** (default):
- Credit consumed
- Processing date
- Environment
- User

**Customization Options**:
1. **Modify the Flow**: Add additional fields from `msdyn_aievents` table
2. **Extend the Entity**: Add custom fields to `admin_AICreditsUsage`
3. **Create Custom Reports**: Build additional Power BI visualizations

**Important**: 
- Changes to the flow may be overwritten during CoE Starter Kit upgrades
- Document customizations for easy re-application

---

## Related Resources

- **Troubleshooting Guide**: [TROUBLESHOOTING-AI-CREDITS-DATA.md](./TROUBLESHOOTING-AI-CREDITS-DATA.md)
- **Technical Deep Dive**: See repository root for `ANALYSIS-AI-CREDITS-2026-ISSUE.md`
- **CoE Documentation**: [Microsoft Learn - CoE Starter Kit](https://learn.microsoft.com/en-us/power-platform/guidance/coe/starter-kit)
- **AI Builder Credits**: [AI Builder Credit Management](https://learn.microsoft.com/en-us/ai-builder/credit-management)

---

## Still Have Questions?

1. **Check existing documentation**: Review README files in CenterofExcellenceCoreComponents
2. **Search GitHub Issues**: Check if your question has been asked before
3. **Open a new issue**: Use the "Question" template and provide:
   - Steps you've already tried
   - Screenshots of relevant errors
   - Your CoE Starter Kit version
   - Environment details

---

*Last Updated: February 2026*  
*Document Status: Comprehensive FAQ based on code analysis and common support questions*
