# CoE Starter Kit - Quick Reference: Large Tenant Inventory

## Problem: FullInventory Variable is Locked

**Quick Fix (PowerShell):**
```powershell
# Run this script
.\CenterofExcellenceCoreComponents\Scripts\Update-FullInventoryEnvVar.ps1 -EnvironmentId "YOUR_ENV_GUID" -Value "no"
```

## Problem: Flow Names Not Updating

**Recommended Solution:**
1. Set FullInventory to "no" (incremental mode)
2. Reduce lookback days to 3-5 days
3. Exclude non-critical environments from inventory

**PowerShell:**
```powershell
# Switch to incremental inventory
.\Scripts\Update-FullInventoryEnvVar.ps1 -EnvironmentId "YOUR_ENV_GUID" -Value "no"
```

## Problem: Inventory Takes 20+ Hours

**Performance Tuning Checklist:**
- [ ] Set `admin_FullInventory` = "no"
- [ ] Set `admin_InventoryFilter_DaysToLookBack` = 3-5 days
- [ ] Set `admin_DelayObjectInventory` = "yes"
- [ ] Mark non-critical environments with `admin_ExcuseFromInventory` = "yes"
- [ ] Verify service account has premium license (not trial)

## Environment Variables for Large Tenants

| Variable | Recommended Value | Purpose |
|----------|-------------------|---------|
| `admin_FullInventory` | **no** | Use incremental inventory |
| `admin_InventoryFilter_DaysToLookBack` | **3-5** | Reduce scope (default: 7) |
| `admin_DelayObjectInventory` | **yes** | Avoid throttling |

## Exclude Environments from Inventory

**Manual Method:**
1. Open your CoE environment in Power Apps
2. Navigate to **Advanced Find**
3. Look for **Environments** table
4. Find environments to exclude
5. Set `admin_ExcuseFromInventory` = Yes

**PowerShell Method:**
```powershell
# Coming soon - bulk exclude script
```

## Expected Inventory Times (Reference)

| Flows | Full Inventory | Incremental (7 days) |
|-------|---------------|---------------------|
| 1K    | 1-2 hours     | 15-30 min          |
| 5K    | 4-8 hours     | 30-60 min          |
| 10K   | 10-15 hours   | 1-2 hours          |
| 16K+  | 20-30 hours   | 2-4 hours          |

## More Help

📖 [Full Troubleshooting Guide](TROUBLESHOOTING-INVENTORY.md)
🔧 [PowerShell Scripts](CenterofExcellenceCoreComponents/Scripts/README.md)
📝 [Official Documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
🐛 [Report Issues](https://github.com/microsoft/coe-starter-kit/issues/new/choose)
