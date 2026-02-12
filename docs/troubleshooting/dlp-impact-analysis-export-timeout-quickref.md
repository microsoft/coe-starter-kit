# DLP Impact Analysis Export Timeout - Quick Reference

**Problem**: Cannot export DLP Impact Analysis results due to timeouts when analyzing strict DLP policies

**Reason**: Large number of impacted records exceeds platform limitations (Canvas app delegation, browser timeouts, export limits)

## Quick Solutions

### 1. 📊 Power Automate Flow (Best for Large Datasets)
- **Best for**: > 2,000 records
- **Time**: 30-60 min to setup
- **Complexity**: Medium
- **Steps**: Create flow → List rows in batches → Export to SharePoint/Email
- **Details**: [Full instructions](dlp-impact-analysis-export-timeout.md#solution-1-power-automate-flow-export-recommended-for-large-datasets)

### 2. 💻 PowerShell Script (For Technical Users)
- **Best for**: Any size dataset
- **Time**: 5 min to setup + run time
- **Complexity**: High (requires PowerShell knowledge)
- **Script**: [Export-DLPImpactAnalysis.ps1](../scripts/Export-DLPImpactAnalysis.ps1)
- **Usage**:
  ```powershell
  Install-Module Microsoft.Xrm.Data.PowerShell
  .\Export-DLPImpactAnalysis.ps1 -EnvironmentUrl "https://yourorg.crm.dynamics.com"
  ```

### 3. 🔍 Filter and Export Subsets (Quick Workaround)
- **Best for**: < 2,000 records per export
- **Time**: 5 min
- **Complexity**: Low
- **Steps**: 
  1. Open Impact Analysis app
  2. Apply filters (Environment, Date, Status)
  3. Export filtered subset
  4. Repeat with different filters

### 4. 📈 Power BI (No Export Needed)
- **Best for**: Analysis without export
- **Time**: 15-30 min
- **Complexity**: Low-Medium
- **Steps**: Connect Power BI Desktop → Select admin_dlpimpactanalysis table → Create reports

### 5. 📝 FetchXML with Pagination (For Developers)
- **Best for**: Custom integrations
- **Time**: 60+ min
- **Complexity**: High
- **Details**: [FetchXML instructions](dlp-impact-analysis-export-timeout.md#solution-2-fetchxml-with-pagination-for-developers)

## Decision Matrix

| Record Count | Recommended Solution | Alternative |
|--------------|---------------------|-------------|
| < 2,000 | Filter in Canvas App (Solution 3) | Power BI (Solution 4) |
| 2,000 - 10,000 | Power Automate (Solution 1) | Filtered exports (Solution 3) |
| 10,000 - 50,000 | Power Automate (Solution 1) | PowerShell (Solution 2) |
| > 50,000 | PowerShell (Solution 2) | Power Automate (Solution 1) |

## Need More Help?

- **Full Documentation**: [dlp-impact-analysis-export-timeout.md](dlp-impact-analysis-export-timeout.md)
- **PowerShell Script**: [Export-DLPImpactAnalysis.ps1](../scripts/Export-DLPImpactAnalysis.ps1)
- **Issue Response Template**: [ISSUE-RESPONSE-dlp-impact-analysis-export-timeout.md](../ISSUE-RESPONSE-dlp-impact-analysis-export-timeout.md)
- **GitHub Issues**: [Report a problem](https://github.com/microsoft/coe-starter-kit/issues)

## Prevention Tips

✅ Run targeted analyses (by environment, not tenant-wide)  
✅ Clean up old analysis records regularly (90-day retention)  
✅ Use Power BI for ongoing monitoring instead of repeated exports  
✅ Test strict policies on subset of environments first  

---
**Last Updated**: February 2024  
**Related**: CoE Starter Kit Core Components v4.50.8+
