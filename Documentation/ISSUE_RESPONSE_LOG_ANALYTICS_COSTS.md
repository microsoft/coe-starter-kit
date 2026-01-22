# Issue Response: High Amount of CoE Service Account Non-Interactive Login Logs

## Summary

Thank you for raising this important question about reducing Azure Log Analytics costs caused by CoE Starter Kit service account sign-in logs. This is a common concern for organizations running the CoE Starter Kit at scale.

## Root Cause

The high volume of non-interactive sign-in logs occurs because:

1. **Architecture Design**: CoE Starter Kit Core Components use Cloud Flows with user-based service account connections to perform inventory and telemetry collection
2. **Connector Limitations**: The Power Platform for Admins connector (primary connector for inventory) requires user-based authentication and does not currently support Service Principal authentication for most operations
3. **Frequency and Scale**: Regular inventory scans (daily or more frequent) combined with multiple API calls per flow and multiple environments create a high volume of authentication events
4. **Azure Logging**: Each API call generates a non-interactive sign-in event in Azure AD (Microsoft Entra ID), which is captured by Azure Log Analytics

## Answer to Your Questions

### Can you use Service Principals instead of user accounts?

**Short Answer**: Not currently for the majority of CoE Starter Kit operations.

**Detailed Explanation**:
- The Power Platform for Admins connector, which is the core connector for inventory collection, requires user-based authentication for most operations
- Some Dataverse operations can use Application Users (Service Principal equivalent), but this only addresses a subset of authentication events
- Using Service Principals would require creating custom connectors and modifying flows, which creates **unmanaged layers** that make updates cumbersome (as you correctly identified)

### What are your options?

Based on your requirements (maintain inventory frequency, avoid unmanaged layers), we recommend:

## Recommended Solution

### Primary Strategy: Exclude CoE Service Account Logs from Azure Log Analytics

This is the **optimal approach** that meets all your requirements:

✅ **Maintains inventory scan frequency** - No changes to CoE Starter Kit flows  
✅ **Avoids unmanaged layers** - No modifications to the managed solution  
✅ **Immediate cost reduction** - Can reduce costs by 100% for this log category  
✅ **Simple to implement** - Azure-side configuration only

**Implementation**:
1. Identify all CoE service account User Principal Names (UPNs)
2. Configure Azure Log Analytics data collection transformation rules to exclude these accounts
3. Alternatively, modify Azure AD diagnostic settings to filter logs before ingestion

**Example KQL transformation rule**:
```kql
SigninLogs
| where UserPrincipalName !in ("coe-service@contoso.com", "powerplatform-admin@contoso.com")
```

### Supplementary Strategy: Optimize Log Analytics Settings

Additionally consider:
- Adjust retention periods for sign-in log tables based on compliance requirements
- Implement sampling if you need to keep some visibility
- Archive older logs to cheaper storage tiers

## Alternative Options (Not Recommended for Your Scenario)

1. **Reduce inventory scan frequency** - You correctly identified this would make data less current and doesn't meet your requirements

2. **Use Application Users for Dataverse** - This is a partial solution that only affects Dataverse operations, not the primary Power Platform Admin connector operations that generate most logs

3. **Custom connectors with Service Principal** - This creates unmanaged layers and makes updates cumbersome, which you want to avoid

## Comprehensive Documentation

I've created detailed documentation covering all aspects of this issue, including:
- Technical background and root cause analysis
- All five options with pros/cons
- Step-by-step implementation guides
- Cost estimation examples
- FAQ and troubleshooting

**See**: [Documentation/ReducingAzureLogAnalyticsCosts.md](../Documentation/ReducingAzureLogAnalyticsCosts.md)

## Additional Resources

- [CoE Starter Kit Documentation](https://learn.microsoft.com/en-us/power-platform/guidance/coe/starter-kit)
- [Azure Monitor Data Transformation](https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/data-collection-transformations)
- [Azure Monitor Cost Optimization](https://learn.microsoft.com/en-us/azure/azure-monitor/best-practices-cost)
- [Application Users in Dataverse](https://learn.microsoft.com/en-us/power-platform/admin/manage-application-users)

## Future Improvements

As Power Platform expands Service Principal support for admin APIs, future versions of the CoE Starter Kit may offer more native options for Service Principal authentication. Monitor:
- [CoE Starter Kit Releases](https://github.com/microsoft/coe-starter-kit/releases)
- [Microsoft Power Platform Roadmap](https://powerplatform.microsoft.com/roadmap/)

## Next Steps

1. Review the comprehensive documentation linked above
2. Identify your CoE service accounts
3. Implement Log Analytics transformation rules or diagnostic setting changes
4. Monitor cost reduction over 1-2 weeks
5. Share your results with the community

Please let us know if you have any questions about the implementation or would like additional clarification on any of these options!

---

*This response is based on CoE Starter Kit architecture as of January 2026. Always refer to the latest official documentation at https://learn.microsoft.com/power-platform/guidance/coe/starter-kit*
