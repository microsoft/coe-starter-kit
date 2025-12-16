# Implementation Roadmap: Flow Error Message Enhancement

## Overview

This document provides a practical implementation guide for enhancing flow error messages across all CoE Starter Kit setup wizards.

---

## Quick Reference

### What's Being Changed
**File Type**: Canvas Apps (`.msapp` files)  
**Change Type**: Error message text in OnCheck event handlers  
**Impact**: User-facing error messages only  
**Risk Level**: Low  

---

## Implementation Matrix

| Priority | Setup Wizard | File Name | Status | Notes |
|----------|--------------|-----------|--------|-------|
| 🔴 High | Environment Request | `admin_environmentrequestsetupwizardpage_68a5b` | ⏳ Pending | User-reported issue |
| 🔴 High | Initial Setup | `admin_initialsetuppage_d45cf` | ⏳ Partial | Some controls already have specific messages |
| 🔴 High | Compliance | `admin_compliancesetupwizardpage_d7b4b` | ⏳ Pending | Core component |
| 🟡 Medium | Audit Log | `admin_auditlogsetupwizardpage_5b438` | ⏳ Pending | |
| 🟡 Medium | Other Core | `admin_othercoresetupwizardpage_1e3e9` | ⏳ Pending | |
| 🟡 Medium | Teams Environment Governance | `admin_teamsenvironmentgovernancesetupwizardpa85263` | ⏳ Pending | |
| 🟢 Standard | BVA | `admin_bvasetupwizardpage_f4958` | ⏳ Pending | |
| 🟢 Standard | Cleanup | `admin_cleanupfororphanedobjectssetupwizardcop04862` | ⏳ Pending | |
| 🟢 Standard | Inactivity Process | `admin_inactivityprocesssetupwizardpage_06a62` | ⏳ Pending | |
| 🟢 Standard | Maker Assessment | `admin_makerassessmentsetupwizardpage_f018f` | ⏳ Pending | |
| 🟢 Standard | Pulse Feedback | `admin_pulsefeedbacksetupwizardpage_4bf3f` | ⏳ Pending | |
| 🟢 Standard | Training in a Day | `admin_traininginadaysetupwizardpage_1cbde` | ⏳ Pending | |
| 🟢 Standard | Video Hub | `admin_videohubsetupwizardpage_3a340` | ⏳ Pending | |

---

## Code Change Pattern

### Before (Current)
```powerfx
IfError(
    Patch(
        Processes,
        LookUp(Processes, WorkflowIdUnique = ThisItem.theGUID), 
        {
            Status: 'Status (Processes)'.Activated
        }
    ),
    Notify(
        "Failed to turn on this flow. Open the Power Automate details page and turn on the flow there.", 
        NotificationType.Error
    )
);
```

### After (Enhanced)
```powerfx
IfError(
    Patch(
        Processes,
        LookUp(Processes, WorkflowIdUnique = ThisItem.theGUID), 
        {
            Status: 'Status (Processes)'.Activated
        }
    ),
    Notify(
        "Failed to turn on '" & Coalesce(ThisItem.theName, "Unknown Flow") & "'. Open the Power Automate details page and turn on the flow there.", 
        NotificationType.Error
    )
);
```

**Key Changes**:
1. ➕ Added flow name: `& Coalesce(ThisItem.theName, "Unknown Flow") &`
2. ➕ Added single quotes around flow name for clarity
3. ➕ Added null handling with `Coalesce()`

---

## User Experience Impact

### Current User Experience (❌ Poor)
```
⚠️ "Failed to turn on this flow. Open the Power Automate details page and turn on the flow there."

User Action Required:
1. Open Power Automate
2. Check each flow manually
3. Find the one with error state
4. Troubleshoot and fix
```

### Enhanced User Experience (✅ Good)
```
⚠️ "Failed to turn on 'Env Request | Create Approved Environment'. Open the Power Automate details page and turn on the flow there."

User Action Required:
1. Open Power Automate
2. Find "Env Request | Create Approved Environment" flow directly
3. Troubleshoot and fix
```

**Time Saved**: ~2-5 minutes per error (depending on number of flows)

---

## Technical Implementation Steps

### Prerequisites
```bash
# Install PAC CLI (if not already installed)
pac install latest

# Or use standard tools
# - zip/unzip utilities
# - Text editor with JSON support
```

### Step-by-Step Process (Per App)

#### 1. Extract the App
```bash
cd /tmp
mkdir wizard-edit
cd wizard-edit

# Extract using unzip
unzip /path/to/admin_environmentrequestsetupwizardpage_68a5b_DocumentUri.msapp

# Expected structure:
# ├── Controls/
# │   ├── 1.json
# │   └── 36.json (main screen)
# ├── Components/
# ├── References/
# └── Properties.json
```

#### 2. Find the Error Message
```bash
# Search for the error message
grep -r "Failed to turn on this flow" Controls/

# Output example:
# Controls/36.json:..."Failed to turn on this flow. Open...
```

#### 3. Edit the Control File
```bash
# Open the file in a JSON-aware editor
nano Controls/36.json

# Or use sed for automated replacement
sed -i 's/Failed to turn on this flow\./Failed to turn on '\'' \& Coalesce(ThisItem.theName, "Unknown Flow") \& '\''\./g' Controls/36.json
```

**Manual Edit Pattern**:
- Find: `"Failed to turn on this flow.`
- Replace: `"Failed to turn on '" & Coalesce(ThisItem.theName, "Unknown Flow") & "'.`

#### 4. Verify the Change
```bash
# Check that the change was applied correctly
grep -A 2 -B 2 "Failed to turn on" Controls/36.json
```

#### 5. Repack the App
```bash
# Create new .msapp file
zip -r admin_environmentrequestsetupwizardpage_68a5b_DocumentUri_new.msapp .

# Verify the zip is valid
unzip -t admin_environmentrequestsetupwizardpage_68a5b_DocumentUri_new.msapp
```

#### 6. Replace Original
```bash
# Backup original
cp /path/to/original/admin_environmentrequestsetupwizardpage_68a5b_DocumentUri.msapp \
   /path/to/backup/

# Replace with new version
cp admin_environmentrequestsetupwizardpage_68a5b_DocumentUri_new.msapp \
   /path/to/CenterofExcellenceCoreComponents/SolutionPackage/src/CanvasApps/admin_environmentrequestsetupwizardpage_68a5b_DocumentUri.msapp
```

#### 7. Test in Environment
```bash
# Import solution to test environment
pac solution import --path CenterofExcellenceCoreComponents.zip

# Manual testing steps:
# 1. Open the setup wizard
# 2. Navigate to "Turn on flows"
# 3. Toggle a flow to cause an error (e.g., missing connection)
# 4. Verify error message shows flow name
```

---

## Testing Checklist (Per App)

### Functional Testing
- [ ] App opens without errors
- [ ] Navigate through all wizard steps
- [ ] "Turn on flows" step loads correctly
- [ ] Toggle a flow ON - should show success or specific error
- [ ] Toggle a flow OFF - should work correctly
- [ ] Multiple flows - errors show correct flow names
- [ ] Flow with null/empty name - shows "Unknown Flow"

### Regression Testing
- [ ] No console errors in browser
- [ ] No changes to other wizard functionality
- [ ] Navigation still works (Back/Next buttons)
- [ ] Connection references still work
- [ ] Environment variables still configure correctly

### User Experience Testing
- [ ] Error message is clear and readable
- [ ] Flow name is properly formatted
- [ ] Message provides actionable next steps
- [ ] No truncation of flow names

---

## Property Name Variations

Different wizards might use different property names. Check these in order:

| Property Name | Usage | Example |
|---------------|-------|---------|
| `ThisItem.theName` | Most common | Environment Request Wizard |
| `ThisItem.'Process Name'` | Some wizards | Initial Setup Wizard |
| `ThisItem.displayName` | Alternative | Various wizards |
| `ThisItem.name` | Rare | Legacy controls |

**Discovery Method**:
```bash
# Extract all ThisItem properties used in the app
grep -o "ThisItem\.[a-zA-Z_][a-zA-Z0-9_]*" Controls/*.json | sort -u
```

---

## Automation Script Template

```bash
#!/bin/bash
# enhance-wizard-errors.sh
# Automates the enhancement of error messages in a setup wizard

WIZARD_NAME=$1
SOURCE_DIR="CenterofExcellenceCoreComponents/SolutionPackage/src/CanvasApps"
WORK_DIR="/tmp/wizard-enhancement-$$"

if [ -z "$WIZARD_NAME" ]; then
    echo "Usage: $0 <wizard_file_name>"
    exit 1
fi

echo "Enhancing $WIZARD_NAME..."

# 1. Create work directory
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

# 2. Extract app
unzip -q "$SOURCE_DIR/${WIZARD_NAME}.msapp"

# 3. Find and update error message
find Controls/ -name "*.json" -exec sed -i \
    's/Failed to turn on this flow\./Failed to turn on '\'' \& Coalesce(ThisItem.theName, "Unknown Flow") \& '\''\./g' \
    {} \;

# 4. Repack
zip -q -r "${WIZARD_NAME}_enhanced.msapp" .

# 5. Replace original
cp "${WIZARD_NAME}_enhanced.msapp" "$SOURCE_DIR/${WIZARD_NAME}.msapp"

echo "Enhancement complete for $WIZARD_NAME"
cd -
rm -rf "$WORK_DIR"
```

**Usage**:
```bash
chmod +x enhance-wizard-errors.sh
./enhance-wizard-errors.sh admin_environmentrequestsetupwizardpage_68a5b_DocumentUri
```

---

## Quality Gates

Before marking an app as complete:

### ✅ Code Quality
- [ ] JSON structure is valid
- [ ] No syntax errors in Power Fx formula
- [ ] Proper string concatenation
- [ ] Null handling in place

### ✅ Functional Quality
- [ ] App imports successfully
- [ ] All wizard steps work
- [ ] Error messages show flow names
- [ ] No regression in other features

### ✅ Documentation
- [ ] Update status in implementation matrix
- [ ] Note any deviations or issues
- [ ] Screenshot of improved error message
- [ ] Update release notes

---

## Rollback Plan

If issues are discovered after deployment:

### Quick Rollback
```bash
# Restore from backup
cp backup/admin_environmentrequestsetupwizardpage_68a5b_DocumentUri.msapp \
   CenterofExcellenceCoreComponents/SolutionPackage/src/CanvasApps/

# Rebuild solution
# Re-import to affected environments
```

### Partial Rollback
- Can roll back individual apps without affecting others
- Each app is independent
- No data migration needed

---

## Success Criteria

### Implementation Success
- ✅ All 13 wizards updated
- ✅ All tests passing
- ✅ Documentation updated
- ✅ No production issues

### User Success
- ✅ Users report improved troubleshooting experience
- ✅ Reduced support tickets for flow activation
- ✅ Positive feedback on error clarity

---

## Timeline

### Week 1: High Priority (Days 1-5)
- Day 1-2: Environment Request, Initial Setup
- Day 3-4: Compliance, Audit Log
- Day 5: Other Core, Teams Environment Governance

### Week 2: Standard Priority (Days 6-10)
- Day 6-8: BVA, Cleanup, Inactivity Process
- Day 9-10: Maker Assessment, Pulse Feedback

### Week 3: Completion (Days 11-15)
- Day 11-12: Training in a Day, Video Hub
- Day 13-14: Final testing and documentation
- Day 15: Release and monitoring

---

## Support and Troubleshooting

### Common Issues

#### Issue: "Invalid JSON after edit"
**Solution**: Use a JSON validator, ensure proper escaping of quotes and special characters

#### Issue: "App won't import"
**Solution**: Check .msapp file integrity, verify all files are included in zip

#### Issue: "Property 'theName' not found"
**Solution**: Check available properties using grep, use correct property name for that wizard

#### Issue: "Error message still generic"
**Solution**: Verify the correct control file was edited, check all occurrences of error message

---

## Contact and Resources

- **Repository**: microsoft/coe-starter-kit
- **Documentation**: CoE Starter Kit Setup Guide
- **Support**: GitHub Issues
- **Related Issue**: #10327

---

_Last Updated: [Date]_  
_Status: Implementation Ready_
