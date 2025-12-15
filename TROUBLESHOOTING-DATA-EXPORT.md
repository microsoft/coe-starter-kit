# Data Export Feature Greyed Out - Troubleshooting

## Quick Summary

**Issue**: The "Data Export" option is greyed out in the CoE Starter Kit Setup Wizard  
**Status**: This is **expected behavior**, NOT a bug  
**Solution**: Use the **Cloud Flows** inventory method (recommended)  

## What's Happening?

The Data Export option in the Initial Setup Wizard appears greyed out/disabled because it depends on **Data Export V2**, a Power Platform product feature that has not yet been released by Microsoft.

### Screenshot Location
The issue appears in: **Initial Setup Wizard > Choose Data Source step**

## Why Is This Happening?

1. **Product Dependency**: Data Export V2 must be released by the Microsoft Power Platform product team before it can be used
2. **Proactive Design**: The CoE Starter Kit team included this option in advance to enable quick adoption when the feature becomes available
3. **Timeline**: The original ~Fall 2024 estimate is subject to change based on Microsoft's product roadmap

## Solution: Use Cloud Flows Method

### Recommended Steps

1. **Open the Initial Setup Wizard**
2. **Navigate to "Choose Data Source"**
3. **Select "Cloud Flows"** (the first option)
4. **Click Next/Continue**
5. **Follow the setup guide**: https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup-core-components#choose-data-source

### Why Cloud Flows?

| Feature | Cloud Flows | BYODL | Data Export V2 |
|---------|------------|-------|----------------|
| **Recommended** | ✅ Yes | ❌ No | ⏳ Future |
| **Fully Supported** | ✅ Yes | ⚠️ Limited | ⏳ Future |
| **Easy Setup** | ✅ Yes | ❌ Complex | ⏳ Future |
| **No Azure Required** | ✅ Yes | ❌ Required | ⏳ Future |
| **Active Updates** | ✅ Yes | ❌ Minimal | ⏳ Future |

## Do NOT Use BYODL

The "BYODL - Bring Your Own Data Lake" option is still available but is **NOT RECOMMENDED** because:
- Legacy approach with limited support
- Complex Azure infrastructure requirements
- Higher maintenance overhead
- Microsoft moving to Fabric for data lake scenarios

## When Will Data Export V2 Be Available?

- **Current Status**: Not Yet Available
- **ETA**: To Be Announced by Microsoft
- **No specific date**: The product team controls the release timeline

### Stay Informed

1. **Subscribe to releases**: https://github.com/microsoft/coe-starter-kit/releases
2. **Watch Power Platform updates**: https://learn.microsoft.com/en-us/power-platform/release-plan/
3. **Check Microsoft 365 Roadmap**: https://www.microsoft.com/microsoft-365/roadmap

## FAQ

**Q: Can I enable Data Export somehow?**  
A: No. It requires a Power Platform product release from Microsoft.

**Q: Should I wait for Data Export V2?**  
A: No. Use Cloud Flows now. You can migrate later if desired.

**Q: Will my Cloud Flows setup work later?**  
A: Yes. Cloud Flows will remain supported even after Data Export V2 is released.

**Q: Is this a bug in the CoE Starter Kit?**  
A: No. The greyed-out option is intentional to show future capabilities.

**Q: Why does it say "~Fall 2024" if we're past that?**  
A: Product release timelines can shift. The estimate is subject to change by the Microsoft product team.

## More Information

- **Detailed Guide**: [docs/coe-knowledge/Data-Export-V2-Status.md](docs/coe-knowledge/Data-Export-V2-Status.md)
- **Common Responses**: [docs/coe-knowledge/COE-Kit-Common GitHub Responses.md](docs/coe-knowledge/COE-Kit-Common%20GitHub%20Responses.md)
- **Official Docs**: https://learn.microsoft.com/en-us/power-platform/guidance/coe/starter-kit

## Issue Resolution

If you've encountered this issue:
1. ✅ This is expected behavior
2. ✅ Select Cloud Flows method
3. ✅ Follow the official setup guide
4. ✅ Subscribe to release notifications for future updates

**Do NOT**:
- ❌ Try to "fix" or enable the greyed-out option
- ❌ Report this as a bug (it's intentional)
- ❌ Choose BYODL for new implementations
- ❌ Wait for Data Export V2 before setting up CoE

---

**Document Version**: 1.0  
**Last Updated**: December 2025  
**Applies To**: CoE Starter Kit v4.5.7 and later
