---
name: Setup Wizard Diagnostic Checklist
about: Use this checklist to diagnose Setup Wizard loading issues
title: '[Setup Wizard Issue] '
labels: 'bug, needs-triage, setup-wizard'
assignees: ''
---

## Setup Wizard Diagnostic Checklist

Before reporting an issue with the Setup Wizard not loading, please complete this diagnostic checklist. This will help us quickly identify and resolve your issue.

### 1. Environment Information

- [ ] **CoE Starter Kit Version**: (e.g., 4.50.6)
- [ ] **Environment Type**: (Production / Sandbox / Trial)
- [ ] **Browser**: (Name and version, e.g., Edge 120.0)
- [ ] **Operating System**: (e.g., Windows 11, macOS 14)

### 2. Component Installation Check

- [ ] **Power Platform Creator Kit (PowerCAT) is installed**
  - Go to Solutions in Power Platform Admin Center
  - Search for "Creator Kit" or "PowerCAT"
  - If not found: See [Solution 1 in Troubleshooting Guide](../../TROUBLESHOOTING-SETUP-WIZARD.md#solution-1-verify-powercat-component-library-installation)

- [ ] **CoE Core Components solution is fully imported**
  - Check Solutions for "Center of Excellence - Core Components"
  - Verify it shows as "Installed" with no warnings

- [ ] **All solution dependencies are satisfied**
  - Open CoE Core Components solution
  - Click "Show dependencies"
  - Verify all dependencies are green/satisfied

### 3. Browser Console Check

- [ ] **Opened browser Developer Tools (F12)**
- [ ] **Checked Console tab for errors**

**Error messages found** (if any):
```
Paste any error messages here
```

- [ ] **Checked Network tab for failed requests**

**Failed requests** (if any):
```
List failed resource URLs here
```

### 4. Browser Cache Check

- [ ] **Cleared browser cache completely** (Ctrl+Shift+Del)
- [ ] **Tried in InPrivate/Incognito mode**
- [ ] **Tested in a different browser** (specify which): ___________

Result after trying different browser: (Works / Doesn't work)

### 5. Network/Firewall Check

- [ ] **No firewall/proxy blocking Microsoft CDN domains**
- [ ] **Corporate network allows access to:**
  - *.azureedge.net
  - *.powerapps.com
  - *.dynamics.com
  - *.microsoft.com

- [ ] **Console shows no CORS or network security errors**

### 6. Visual Symptoms

Which of the following describes what you see? (Check all that apply)

- [ ] Completely blank white page
- [ ] Page header loads but content area is blank
- [ ] Navigation/buttons visible but content missing
- [ ] Spinner/loading indicator stuck
- [ ] Error message displayed (specify): ___________
- [ ] Other (describe): ___________

### 7. Screenshot

Please attach a screenshot showing:
- The full browser window with the issue
- Browser Developer Tools console (F12) showing any errors

### 8. Actions Already Tried

Which solutions from the [Troubleshooting Guide](../../TROUBLESHOOTING-SETUP-WIZARD.md) have you already tried?

- [ ] Solution 1: Verified PowerCAT installation
- [ ] Solution 2: Checked solution dependencies
- [ ] Solution 3: Cleared browser cache
- [ ] Solution 4: Tried different browser
- [ ] Solution 5: Checked network/firewall
- [ ] Solution 6: Verified component control registration
- [ ] Solution 7: Re-imported CoE solution

**Results**: (Which, if any, solutions helped?)

### 9. When Did This Start?

- [ ] Fresh installation (never worked)
- [ ] After an update (specify from which version): ___________
- [ ] Was working before, suddenly stopped (specify when): ___________
- [ ] Other: ___________

### 10. Additional Context

Any other information that might be relevant:

```
Add any additional context here
```

---

## For CoE Team Use Only

**Diagnosis**:
- [ ] Missing PowerCAT components
- [ ] Version mismatch
- [ ] Browser compatibility
- [ ] Network/firewall issue
- [ ] Cache corruption
- [ ] Other: ___________

**Recommended Solution**: ___________
