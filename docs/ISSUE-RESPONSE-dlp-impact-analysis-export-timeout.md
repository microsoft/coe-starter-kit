# GitHub Issue Response Template - DLP Impact Analysis Export Timeout

This template can be used when responding to issues related to export timeouts when exporting DLP Impact Analysis data.

---

## Template: DLP Impact Analysis Export Timeout

**Use when:** Users report that they cannot export DLP Impact Analysis results due to timeouts or large dataset sizes

**Response:**

Thank you for reporting this issue with exporting DLP Impact Analysis data!

### Issue Summary

This is a **known limitation** when analyzing DLP policies with broad scope (such as "Strict" policies that block many connectors). The large number of impacted apps and flows creates too many records to export through the standard Canvas app or model-driven app export functions.

### Root Cause

The export timeouts are caused by platform limitations:
- **Canvas Apps**: 2,000 record delegation limit
- **Dataverse Excel Export**: 50,000 row limit  
- **Browser Timeouts**: 30-120 seconds (varies by browser)
- **API Throttling**: Service protection limits for large queries

When your DLP policy analysis generates more records than these limits, exports will timeout or fail.

### Solutions Available

We've created comprehensive troubleshooting documentation with **5 different solutions** to handle large DLP Impact Analysis exports:

🔗 **[DLP Impact Analysis Export Timeout Troubleshooting Guide](../docs/troubleshooting/dlp-impact-analysis-export-timeout.md)**

#### Quick Reference - Choose Your Approach:

| Your Scenario | Recommended Solution | Complexity |
|--------------|---------------------|------------|
| < 2,000 records | Filter in Canvas App and export | ✅ Low |
| 2,000 - 50,000 records | Use filtered views in model-driven app | ✅ Low |
| > 50,000 records | **Power Automate batch export** | ⚠️ Medium |
| Technical users | PowerShell with FetchXML pagination | 🔧 High |
| Analysis only (no export needed) | Power BI integration | ✅ Low-Medium |

### Recommended Solution: Power Automate Flow Export

For most users with large datasets, we recommend **Solution 1** from the troubleshooting guide:

**Create a Power Automate flow** that:
1. Retrieves data in batches of 5,000 records
2. Exports to SharePoint/OneDrive or sends via email
3. Handles any dataset size without timeouts
4. Runs automatically in the background

👉 [Step-by-step instructions for Power Automate export](../docs/troubleshooting/dlp-impact-analysis-export-timeout.md#solution-1-power-automate-flow-export-recommended-for-large-datasets)

### For Technical Users: PowerShell Script

We've also created a **ready-to-use PowerShell script** that automates the export:

📥 **[Export-DLPImpactAnalysis.ps1](../docs/scripts/Export-DLPImpactAnalysis.ps1)**

```powershell
# Install the required module
Install-Module Microsoft.Xrm.Data.PowerShell -Scope CurrentUser

# Run the export
.\Export-DLPImpactAnalysis.ps1 -EnvironmentUrl "https://yourorg.crm.dynamics.com"
```

The script handles pagination automatically and exports to CSV.

### Quick Workaround: Export Filtered Subsets

If you need data immediately:

1. Open the **Impact Analysis** app
2. Apply filters to reduce dataset size:
   - Filter by **Environment** 
   - Filter by **Decision Status** (e.g., "Needs Review")
   - Filter by **Date Range** (last 30 days)
3. Export the filtered subset (should be < 2,000 records)
4. Repeat for other filters to get complete dataset in parts

### Next Steps

1. Review the [complete troubleshooting guide](../docs/troubleshooting/dlp-impact-analysis-export-timeout.md)
2. Choose the solution that fits your scenario and technical skills
3. If you continue experiencing issues after trying these solutions, please provide:
   - Approximate number of records in your DLP Impact Analysis
   - Which solution you tried
   - Any error messages or screenshots
   - Your CoE Starter Kit version

### Related Documentation

- [CoE Starter Kit Documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- [Dataverse Service Protection Limits](https://learn.microsoft.com/power-platform/admin/api-request-limits-allocations)
- [Power Apps Delegation Limits](https://learn.microsoft.com/power-apps/maker/canvas-apps/delegation-overview)

### Prevention: Managing Large Datasets

To prevent this issue in the future:

✅ **Run targeted analyses**: Analyze by environment rather than tenant-wide  
✅ **Clean up old data**: Delete completed analyses after 90 days  
✅ **Use Power BI**: Analyze directly without exporting  

Let us know if you have any questions or need additional guidance!

---

## Template: Follow-up Questions

**Use when:** The user provides more details or asks specific questions

**Response:**

Thank you for the additional information!

[Address specific questions based on their scenario]

### For Your Specific Situation

**Dataset Size**: ~[X] records  
**Recommended Approach**: [Choose from the solutions above]

**Why this approach:**
- [Explain why it fits their needs]
- [Mention any considerations]

**Estimated Time**: 
- Setup: [X] minutes
- Execution: [X] minutes
- Total: [X] minutes

### Additional Tips for Your Scenario

[Provide scenario-specific guidance]

Let me know if you need help with any of these steps!

---

## Template: Issue Resolution

**Use when:** Confirming the issue is resolved or providing final guidance

**Response:**

Great to hear [the solution worked / you're making progress]!

### Summary

✅ **Issue**: Export timeout with large DLP Impact Analysis dataset  
✅ **Solution**: [The approach they used]  
✅ **Outcome**: Successfully exported [X] records

### Documentation Updated

This is a common issue, so we've added comprehensive troubleshooting documentation:
- [DLP Impact Analysis Export Timeout Guide](../docs/troubleshooting/dlp-impact-analysis-export-timeout.md)

This should help other users encountering the same issue.

### Feedback Welcome

If you have suggestions for improving the documentation or additional solutions that worked for you, please share them! We're always looking to improve the CoE Starter Kit experience.

Thank you for your patience and for helping improve the CoE Starter Kit! 🎉

---

## Notes for Maintainers

- This issue typically occurs with "Strict" DLP policies that affect 10,000+ apps/flows
- The most common successful solution is Power Automate flow export (Solution 1)
- Technical users prefer the PowerShell script
- Some users may need guidance on how to estimate their record count first
- Consider adding telemetry to track how many records are in typical analyses
- Future enhancement: Add built-in batch export functionality to the Impact Analysis app
