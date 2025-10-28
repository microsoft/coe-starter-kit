# Center of Excellence Core Components

This directory contains the core components of the CoE Starter Kit, including flows, apps, and entities for tenant-wide inventory and monitoring.

## Key Components

### Audit Logs
The Audit Logs functionality tracks Power Platform usage and operations through the **Admin | Audit Logs | Sync Audit Logs (V2)** flow.

#### Important: Data Consumption Management

The Sync Audit Logs V2 flow retrieves audit data from Microsoft 365 and can consume significant amounts of data in high-activity environments. 

**If your flow was automatically turned off due to high data consumption**, please refer to the comprehensive troubleshooting guide:

📖 **[Audit Logs Troubleshooting Guide](./AUDIT_LOGS_TROUBLESHOOTING.md)**

This guide includes:
- Root cause analysis of data consumption issues
- Configuration recommendations and best practices
- Step-by-step troubleshooting procedures
- FAQ and monitoring strategies

#### Recent Optimizations (v4.50.5+)

The Sync Audit Logs V2 flow has been optimized to reduce data consumption:
- ✅ Reduced pagination limits (5000 → 50 iterations for Management API)
- ✅ Reduced page sizes ($top=500 → $top=100 for Graph API)
- ✅ Lowered concurrency (25 → 5 parallel operations)
- ✅ Shortened timeouts (10 hours → 1 hour)

These changes prevent excessive data transfer while maintaining complete audit log coverage.

### Environment Variables

Key environment variables for Audit Logs configuration:

| Variable | Default | Description |
|----------|---------|-------------|
| `admin_AuditLogsUseGraphAPI` | false | Set to `true` to use Graph API (recommended) |
| `admin_AuditLogsMinutestoLookBack` | 65 | Minutes of data to retrieve per run |
| `admin_AuditLogsEndTimeMinutesAgo` | 0 | Offset for data retrieval (2820 = 48 hours ago) |

See the [troubleshooting guide](./AUDIT_LOGS_TROUBLESHOOTING.md) for detailed configuration recommendations.

## Additional Resources

- [CoE Starter Kit Documentation](https://docs.microsoft.com/power-platform/guidance/coe/starter-kit)
- [Setup Instructions](https://docs.microsoft.com/power-platform/guidance/coe/setup)
- [Audit Logs Troubleshooting Guide](./AUDIT_LOGS_TROUBLESHOOTING.md)

## Support

For issues or questions:
1. Check the [troubleshooting guide](./AUDIT_LOGS_TROUBLESHOOTING.md)
2. Search [existing issues](https://github.com/microsoft/coe-starter-kit/issues)
3. Create a [new issue](https://github.com/microsoft/coe-starter-kit/issues/new/choose) if needed
