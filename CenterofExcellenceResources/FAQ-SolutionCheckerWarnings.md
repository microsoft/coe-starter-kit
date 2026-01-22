# FAQ: Solution Checker Warnings After Importing CoE Starter Kit

## Overview

This document addresses common questions about the Solution Checker warnings that appear after importing the Center of Excellence (CoE) Starter Kit solutions, particularly the Core Components.

---

## Common Questions

### Q: I see 1100-1200 medium solution checker warnings after importing. Is this normal?

**A: Yes, this is completely normal and expected behavior.**

The CoE Core Components solution is a large, enterprise-scale solution that contains:
- **60+ Canvas Apps** (Setup Wizards, Command Center pages, Admin tools)
- **110+ Flows** (Inventory, sync, cleanup, notification flows)
- **Extensive Dataverse customizations** (entities, dashboards, web resources)

With this scale, Solution Checker typically reports approximately **1100-1200 medium-severity warnings**. This is expected for a solution of this complexity.

---

### Q: What types of warnings should I expect?

**A:** The warnings are primarily accessibility-related and code quality suggestions:

| Warning Type | Typical Count | Description |
|--------------|---------------|-------------|
| `app-include-accessible-label` | 600-700 | Canvas app controls missing accessible labels |
| `app-include-tab-index` | 150-200 | Controls missing explicit tab index |
| `app-include-tab-order` | 100-150 | Controls without defined tab order |
| `app-make-focusborder-visible` | 100-150 | Focus borders not explicitly defined |
| `app-include-readable-screen-name` | 30-50 | Screens without descriptive names |
| `flow-avoid-recursive-loop` | 10-20 | Flow patterns that could potentially recurse |
| `app-reduce-screen-controls` | 5-15 | Screens with many controls |
| `app-formula-issues-medium` | 5-10 | Formula complexity suggestions |
| `web-use-strict-mode` | 3-5 | JavaScript strict mode recommendations |

These are **informational suggestions**, not errors or critical issues.

---

### Q: Will these warnings cause problems in production?

**A: No.** The CoE Starter Kit has been tested and deployed by thousands of organizations with these warnings present.

✅ **The solution works correctly** despite these warnings  
✅ **All flows and apps function as designed**  
✅ **No data loss or corruption will occur**  
✅ **Upgrades are not blocked by these warnings**  
✅ **No security vulnerabilities are introduced**

---

### Q: Should I fix these warnings before using the CoE Kit?

**A: No, you do not need to fix these warnings.**

**During initial setup, focus on:**
1. Configuring environment variables correctly
2. Setting up connections to Power Platform for Admins V2
3. Running the Setup Wizard to configure core components
4. Validating inventory sync is working
5. Testing user access to Command Center and other apps

The solution checker warnings do not need to be addressed for the CoE Kit to function properly.

---

### Q: Why do so many accessibility warnings exist?

**A:** Accessibility warnings accumulate for several reasons:

1. **Scale** - With 60+ canvas apps, even minor suggestions per app add up quickly
2. **Complex UI** - Command Center and Setup Wizards have rich, multi-screen interfaces
3. **Automated checks** - Solution Checker flags any control without explicit accessibility metadata
4. **Focus on functionality** - The CoE Kit prioritizes admin workflows over consumer-facing accessibility

These are **suggestions for improvement**, not requirements for functionality.

---

### Q: Are these warnings safe to ignore?

**A: Yes, for standard CoE Kit deployment, these warnings can be safely ignored.**

### When to Pay Attention to Warnings:

Consider addressing warnings only if:
- ✋ Your organization has **strict accessibility compliance requirements** (e.g., Section 508, WCAG)
- ✋ You are **heavily customizing** the solution for end-user consumption
- ✋ You are **extending the solution** with your own components
- ✋ Users report **specific accessibility issues** (keyboard navigation, screen reader problems)

### When to Ignore Warnings:

Safe to ignore if:
- ✅ Using the CoE Kit **as-is** for admin/governance purposes
- ✅ Users are **IT administrators** comfortable with the interface
- ✅ You are in **initial setup and testing** phase
- ✅ No accessibility compliance requirements for admin tools

---

### Q: Will Microsoft fix these warnings in future releases?

**A:** The product team continuously improves the CoE Starter Kit, and some accessibility improvements may be made over time.

However:
- 📊 **Scale** - With 60+ apps and 110+ flows, some level of solution checker warnings is expected
- 🎯 **Priorities** - The team focuses on functional improvements, bug fixes, and new features
- 🏗️ **Architecture** - The solution is designed for admin users, not public-facing consumption
- 📈 **Trade-offs** - Addressing every warning would delay feature development significantly

**Recommendation:** Don't wait for future releases to address warnings before using the CoE Kit. The solution is production-ready despite the warnings.

---

### Q: Do these warnings affect performance?

**A: No.** Solution Checker warnings are **static analysis recommendations** identified during solution import/analysis.

They do **not** impact:
- ❌ Runtime performance
- ❌ Flow execution speed
- ❌ Data query performance
- ❌ User experience (unless actual accessibility needs exist)

If you experience performance issues, they are unrelated to solution checker warnings and should be investigated separately.

---

### Q: Can I suppress these warnings?

**A:** Solution Checker warnings cannot be suppressed at the solution level.

**Options:**
- ✅ **Acknowledge and proceed** - The recommended approach for standard deployments
- ✅ **Focus on high-severity** - If Solution Checker shows any high-severity warnings, investigate those
- ✅ **Document as "Known"** - Add to your deployment notes that warnings are expected
- ❌ **Don't block imports** - Don't prevent solution import due to these warnings

---

### Q: What if I see HIGH-severity warnings or errors?

**A:** This would be unusual and should be investigated.

**Expected:** 1100-1200 **medium-severity** warnings  
**Unexpected:** High-severity warnings or actual import errors

If you see high-severity warnings:
1. Note the specific warning IDs and messages
2. Check if the solution imported successfully despite warnings
3. Validate that flows and apps function correctly
4. Report to [GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues) if functionality is impacted

---

### Q: What about import ERRORS (not warnings)?

**A:** Import errors are different from solution checker warnings.

| Issue Type | Severity | Action Required |
|------------|----------|-----------------|
| **Solution Checker Warnings** | Medium (informational) | ✅ Safe to ignore |
| **Import Errors** | Critical | ❌ Must be resolved |

**If solution import fails:**
- This is an actual issue, not just warnings
- Check prerequisites (license, permissions, environment version)
- Review import logs for specific error messages
- Report to [GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues) with:
  - Error messages
  - Environment details
  - Steps to reproduce

---

### Q: How do I know if the solution is working correctly despite warnings?

**A:** After import, validate core functionality:

✅ **Solution Import** - Solution shows as "Installed" in Power Platform Admin Center  
✅ **Connections** - Can create connections to Power Platform for Admins V2  
✅ **Setup Wizard** - Setup Wizard app opens and loads correctly  
✅ **Environment Variables** - Can configure environment variables  
✅ **Flows** - Core sync flows can be manually triggered without errors  
✅ **Dataverse** - CoE tables exist (admin_environment, admin_app, admin_flow, etc.)

If all of these work, the solution is functioning correctly regardless of warnings.

---

### Q: Should I run Solution Checker on the CoE Kit?

**A:** Solution Checker runs automatically during solution import in modern Power Platform environments.

**Recommendations:**
- ✅ **Review results** - Acknowledge that warnings exist
- ✅ **Document** - Note in your deployment documentation that warnings are expected
- ❌ **Don't re-run repeatedly** - Results will be the same each time
- ❌ **Don't block deployment** - Don't prevent go-live due to these warnings

---

## Understanding Solution Checker Severity Levels

Solution Checker reports three severity levels:

| Severity | Meaning | CoE Kit Status | Action Required |
|----------|---------|---------------|-----------------|
| **High** | Potential errors, security issues, or data loss risks | Not expected | ❌ Investigate immediately |
| **Medium** | Code quality suggestions, accessibility recommendations | 1100-1200 warnings | ✅ Safe to acknowledge |
| **Low** | Minor suggestions, style preferences | Variable | ✅ Informational only |

---

## Best Practices

### During Initial Setup

1. ✅ **Acknowledge warnings** but proceed with import
2. ✅ **Focus on configuration** - Environment variables, connections, flows
3. ✅ **Validate functionality** - Test core inventory and sync processes
4. ✅ **Document for stakeholders** - Note that warnings are expected and approved

### During Customization

If you customize the CoE Starter Kit:

1. ✅ **Add accessible labels** to new controls you create
2. ✅ **Test keyboard navigation** in modified apps
3. ✅ **Run Solution Checker** on your custom changes (separate from base solution)
4. ✅ **Compare baseline** - Are you introducing significantly more warnings?

### During Upgrades

1. ✅ **Expect similar warning counts** in each release
2. ✅ **Don't block upgrades** due to Solution Checker warnings
3. ✅ **Compare before/after** - Only investigate if warnings significantly increase
4. ✅ **Focus on errors** - Actual import errors should be investigated

---

## When to Report an Issue

### Report to GitHub if:

- ❌ Solution **import fails** (not just warnings)
- ❌ Flows don't run after successful import
- ❌ Apps show errors or blank screens
- ❌ Data doesn't sync to Dataverse tables
- ❌ **High-severity** warnings appear (unusual for CoE Kit)

### Do NOT report if:

- ✅ Only medium-severity warnings appear (expected)
- ✅ Warning count is around 1100-1200 (normal)
- ✅ Solution imported successfully and works correctly

---

## Additional Context

### Why These Warnings Matter (or Don't)

**For End-User Applications:**  
Accessibility warnings are important for apps used by:
- External customers
- General employees
- Users with accessibility needs
- Public-facing portals

**For Admin Tools (like CoE Kit):**  
Accessibility warnings are less critical for:
- Internal IT administrator tools
- Power Platform governance applications
- Technical configuration wizards
- Admin dashboards and reports

The CoE Starter Kit falls into the second category - it's designed for **IT administrators and Power Platform governance teams**, not general end users.

---

## Summary

### ✅ Expected Behavior:
- 1100-1200 medium-severity Solution Checker warnings
- Primarily accessibility and code quality suggestions
- Solution works correctly despite warnings
- No impact on functionality or performance

### ❌ Unexpected Behavior:
- High-severity warnings or errors
- Solution import failures
- Flows or apps not working after import
- Data not syncing correctly

### 🎯 Recommended Action:
- Acknowledge warnings as expected
- Proceed with CoE Kit setup and configuration
- Validate core functionality works correctly
- Document warnings for stakeholders
- Focus efforts on configuration, not warning remediation

---

## Additional Resources

- [Detailed Solution Checker Warnings Documentation](../Documentation/SolutionCheckerWarnings.md)
- [CoE Starter Kit Setup Documentation](https://learn.microsoft.com/power-platform/guidance/coe/setup)
- [Power Apps Solution Checker](https://learn.microsoft.com/power-apps/maker/data-platform/use-powerapps-checker)
- [Power Apps Accessibility Guidelines](https://learn.microsoft.com/power-apps/maker/canvas-apps/accessible-apps)
- [CoE Starter Kit GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues)

---

## Need Help?

If you have questions or concerns about solution checker warnings:

1. Review the [detailed documentation](../Documentation/SolutionCheckerWarnings.md)
2. Check [existing GitHub issues](https://github.com/microsoft/coe-starter-kit/issues?q=is%3Aissue+solution+checker)
3. Ask questions in [GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues) using the Question template
4. Engage with the community in [Power Apps Community forums](https://powerusers.microsoft.com/t5/Power-Apps-Governance-and/bd-p/Admin_PowerApps)

---

**Applies to:** CoE Starter Kit Core Components (All versions)  
**Last Updated:** January 2026
