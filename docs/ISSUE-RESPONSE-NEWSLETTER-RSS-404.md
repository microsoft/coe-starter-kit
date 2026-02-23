# Issue Response: Newsletter Flow RSS Feed 404 Error

## Issue Pattern
Users report that the "Admin | Newsletter with Product Updates" flow is failing with a 404 error at the action "List PowerApps Community Blog RSS feed items" (or similar action name).

**Error Details**: 
- Action: `List PowerApps Community Blog RSS feed items` (or `List PowerApps Blog RSS feed items`)
- Error: HTTP 404 Not Found
- URL: `https://powerusers.microsoft.com/jgvjg48436/rss/board?board.id=PowerAppsBlog`

## Root Cause
The old Power Apps Community RSS feed URL (`powerusers.microsoft.com`) has been deprecated and now returns 404. Microsoft has consolidated all Power Platform blog RSS feeds under the official Microsoft blog domain.

The **latest version of the CoE Starter Kit already contains the corrected RSS feed URLs**. This issue indicates the user is running an outdated version of the Nurture Components solution or has unmanaged customizations.

## Standard Response Template

---

Thank you for reporting this issue! The RSS feed URL you're encountering is from a legacy Power Apps Community feed that has been deprecated by Microsoft.

### ✅ Solution: Upgrade to Latest Version

The good news is that **this has already been fixed in the current version of the CoE Starter Kit**. The flow now uses the official Microsoft Power Platform blog feeds:

- **Old (404)**: `https://powerusers.microsoft.com/jgvjg48436/rss/board?board.id=PowerAppsBlog`
- **New (Working)**: `https://www.microsoft.com/en-us/power-platform/blog/power-apps/feed/`

### Recommended Steps:

#### 1. Check Your Solution Version
Navigate to your CoE environment in the Power Platform admin center and check the version of **Center of Excellence - Nurture Components**. If it's not the latest version, please upgrade following our [upgrade guide](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup-upgrade).

#### 2. Remove Unmanaged Customizations
Before upgrading (or if you're already on the latest version):
1. Open [Power Automate](https://make.powerautomate.com) and select your CoE environment
2. Navigate to **Solutions** → **Center of Excellence - Nurture Components**
3. Find the flow **Admin | Newsletter with Product Updates**
4. If there's an option to **"Remove unmanaged layer"**, click it
5. This ensures you receive the latest updates

#### 3. Manual Fix (Temporary Workaround)
If you need an immediate fix and cannot upgrade right now:

1. Edit the flow **Admin | Newsletter with Product Updates**
2. Find the action failing with the 404 error
3. Update the **Feed URL** parameter to:
   ```
   https://www.microsoft.com/en-us/power-platform/blog/power-apps/feed/
   ```
4. Save and test the flow

⚠️ **Important**: Manual changes create an unmanaged layer that prevents receiving future updates. Please upgrade as soon as possible and remove the unmanaged layer afterward.

### All Current Working RSS Feeds

The Newsletter flow monitors these feeds (all working):

| Product | RSS Feed URL |
|---------|--------------|
| Power Apps | `https://www.microsoft.com/en-us/power-platform/blog/power-apps/feed/` |
| Power Automate | `https://www.microsoft.com/en-us/power-platform/blog/power-automate/feed/` |
| Power BI | `https://powerbi.microsoft.com/en-us/blog/feed/` |
| Microsoft Copilot | `https://www.microsoft.com/en-us/microsoft-copilot/blog/feed/` |

### Additional Resources
- [CoE Starter Kit Documentation](https://learn.microsoft.com/en-us/power-platform/guidance/coe/starter-kit)
- [Setup Nurture Components](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup-nurture-components)
- [Upgrade Guide](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup-upgrade)

Please let us know if you continue to experience issues after upgrading or if you need assistance with the upgrade process!

---

## Triage Notes

### Quick Identification
- Keywords: "Newsletter", "RSS", "404", "PowerApps Blog", "powerusers.microsoft.com"
- Affected Component: Nurture Components
- Affected Flow: Admin | Newsletter with Product Updates

### Common Follow-up Questions
1. What version of the Nurture Components solution are you running?
2. Have you made any customizations to the Newsletter flow?
3. Does the flow have an unmanaged layer? (Check in the solution)
4. When was the last time you upgraded the CoE Starter Kit?

### Related Issues
Search for similar issues using:
```
is:issue "Newsletter" "RSS" "404"
is:issue "powerusers.microsoft.com"
is:issue "Admin | Newsletter with Product Updates"
```

### Fix Priority
- **Severity**: Medium (flow fails completely, but not critical to core CoE functionality)
- **User Impact**: Admins don't receive weekly newsletter with product updates
- **Resolution**: Straightforward - upgrade or manual URL update
- **Prevention**: Ensure users upgrade regularly and remove unmanaged customizations

### Technical Details
- **Flow File**: `CenterofExcellenceNurtureComponents/SolutionPackage/src/Workflows/AdminNewsletterwithProductUpdates-E7A96786-C7E5-E911-A860-000D3A372932.json`
- **Actions Affected**: Lines 181-204 (List_PowerApps_Blog_RSS_feed_items)
- **Correct URL** (Line 199): `https://www.microsoft.com/en-us/power-platform/blog/power-apps/feed/`
- **Connection Reference**: `new_CoENurtureRSS` (RSS connector)

### Label Recommendations
- `nurture components`
- `flow error`
- `user error` or `version mismatch`
- `documentation needed` (if docs update required)
