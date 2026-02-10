# Test Plan for Environment Variable Update Bug Fix

## Test Environment Setup

### Prerequisites
- [ ] Access to CoE Core environment
- [ ] Power Apps Studio access
- [ ] CoE Admin Command Center app installed
- [ ] Test environment variables configured with `admin_` prefix
- [ ] Browser DevTools ready (Network tab)
- [ ] Power Apps Monitor enabled (optional but recommended)

### Test Data Requirements
- At least one environment variable with an existing value
- At least one environment variable with only a default value (no current value)
- Security group ID for testing (e.g., a valid Azure AD security group GUID)

---

## Test Scenarios

### ✅ Scenario 1: Update Existing Environment Variable Value

**Objective**: Verify that updating an existing environment variable performs a PATCH, not a POST.

**Steps**:
1. Open CoE Admin Command Center
2. Navigate to Environment Variables page
3. Locate `admin_PowerPlatformMakeSecurityGroup` (or any variable with a current value - indicated by green checkmark)
4. Click to open the side panel
5. Note the current value
6. Modify the value (e.g., change security group GUID)
7. Open Browser DevTools → Network tab
8. Click "Save"

**Expected Results**:
- ✅ Success notification appears: "Environment variable saved successfully."
- ✅ Green notification color (success)
- ✅ Panel closes automatically
- ✅ Value updates in the list view
- ✅ Green checkmark remains visible
- ✅ Network tab shows PATCH request (not POST)
- ✅ HTTP status 200 or 204 (success)
- ✅ No 400 Bad Request errors

**Actual Results**:
- [ ] Pass / [ ] Fail
- Notes: _____________________

---

### ✅ Scenario 2: Create New Environment Variable Value

**Objective**: Verify that creating a new value performs a POST correctly.

**Steps**:
1. Open CoE Admin Command Center
2. Navigate to Environment Variables page
3. Locate a variable that has NO current value (no green checkmark, showing default value)
4. Click to open the side panel
5. Enter a new value
6. Open Browser DevTools → Network tab
7. Click "Save"

**Expected Results**:
- ✅ Success notification appears: "Environment variable saved successfully."
- ✅ Panel closes automatically
- ✅ Value appears in the list view
- ✅ Green checkmark now appears
- ✅ Network tab shows POST request to create new record
- ✅ HTTP status 201 (created) or 200
- ✅ No errors

**Actual Results**:
- [ ] Pass / [ ] Fail
- Notes: _____________________

---

### ✅ Scenario 3: Error Handling - Permission Denied

**Objective**: Verify that errors are properly surfaced to the user.

**Setup**:
- Temporarily remove user's "Create" or "Write" permission on Environment Variable Values table
- OR test with a user who doesn't have permissions

**Steps**:
1. Open CoE Admin Command Center as user without permissions
2. Navigate to Environment Variables page
3. Try to modify a value
4. Click "Save"

**Expected Results**:
- ✅ Error notification appears
- ✅ Red notification color (error)
- ✅ Error message includes useful information (e.g., "may lack permissions")
- ✅ Panel stays OPEN (does not close)
- ✅ User can retry or cancel
- ✅ No false "success" message

**Actual Results**:
- [ ] Pass / [ ] Fail
- Notes: _____________________

---

### ✅ Scenario 4: Update Value to Blank

**Objective**: Verify that clearing a value works correctly.

**Steps**:
1. Open CoE Admin Command Center
2. Navigate to Environment Variables page
3. Select a variable with a current value
4. Open the side panel
5. Clear the value (delete all text)
6. Click "Save"

**Expected Results**:
- ✅ Success notification appears
- ✅ Panel closes
- ✅ Value field is blank in list view (or shows default value if available)
- ✅ No errors
- ✅ Record updated in Dataverse (value set to blank/null)

**Actual Results**:
- [ ] Pass / [ ] Fail
- Notes: _____________________

---

### ✅ Scenario 5: Revert to Default Value

**Objective**: Verify that revert functionality still works.

**Steps**:
1. Open CoE Admin Command Center
2. Navigate to Environment Variables page
3. Select a variable that has BOTH a default value AND a current value
4. Click to open panel
5. Click "Revert" button

**Expected Results**:
- ✅ Current value is removed
- ✅ Display shows default value
- ✅ Green checkmark disappears (no longer customized)
- ✅ Panel closes
- ✅ Record deleted from Dataverse

**Actual Results**:
- [ ] Pass / [ ] Fail
- Notes: _____________________

---

### ✅ Scenario 6: Multiple Rapid Saves

**Objective**: Verify no race conditions or conflicts.

**Steps**:
1. Open CoE Admin Command Center
2. Navigate to Environment Variables page
3. Quickly modify and save Variable A
4. Immediately modify and save Variable B
5. Repeat for Variable C

**Expected Results**:
- ✅ All three saves succeed
- ✅ No errors
- ✅ All values persist correctly
- ✅ No conflicts or overwrites

**Actual Results**:
- [ ] Pass / [ ] Fail
- Notes: _____________________

---

### ✅ Scenario 7: Page Refresh Persistence

**Objective**: Verify that saved values persist after page refresh.

**Steps**:
1. Open CoE Admin Command Center
2. Navigate to Environment Variables page
3. Modify a value and save
4. Note the new value
5. Refresh the page (F5)
6. Check the value again

**Expected Results**:
- ✅ Value persists after refresh
- ✅ Green checkmark still present (if customized)
- ✅ hasCurrent flag is correct
- ✅ CurrentID is properly populated

**Actual Results**:
- [ ] Pass / [ ] Fail
- Notes: _____________________

---

### ✅ Scenario 8: Network Trace Validation

**Objective**: Verify the correct API calls are made.

**Steps**:
1. Open Browser DevTools → Network tab
2. Filter for: `environmentvariablevalues`
3. Perform an UPDATE (Scenario 1)
4. Perform a CREATE (Scenario 2)

**Expected Results for UPDATE**:
- ✅ Method: PATCH
- ✅ URL: `https://[org].crm.dynamics.com/api/data/v9.2/environmentvariablevalues([guid])`
- ✅ Status: 204 No Content or 200 OK
- ✅ Request body contains only `{"Value": "new-value"}`

**Expected Results for CREATE**:
- ✅ Method: POST
- ✅ URL: `https://[org].crm.dynamics.com/api/data/v9.2/environmentvariablevalues`
- ✅ Status: 201 Created or 200 OK
- ✅ Request body contains `{"environmentvariabledefinitionid@odata.bind": "...", "value": "..."}`

**Actual Results**:
- [ ] Pass / [ ] Fail
- Notes: _____________________

---

### ✅ Scenario 9: Secret Type Variables

**Objective**: Verify that secret-type environment variables work correctly.

**Steps**:
1. Identify a secret-type environment variable (if available)
2. Try to update its value
3. Verify the value is masked in the UI

**Expected Results**:
- ✅ Value is masked/obscured in UI (shows `••••••••` or similar)
- ✅ Save operation works correctly
- ✅ Security is maintained
- ✅ No plaintext secrets visible

**Actual Results**:
- [ ] Pass / [ ] Fail / [ ] N/A (no secret variables)
- Notes: _____________________

---

### ✅ Scenario 10: Revert with No Default Value

**Objective**: Verify correct message when revert is not possible.

**Steps**:
1. Open CoE Admin Command Center
2. Navigate to Environment Variables page
3. Select a variable that has NO default value OR has no current value
4. Click to open panel
5. Click "Revert" button

**Expected Results**:
- ✅ Notification: "Nothing to revert, no alternate reset value exists."
- ✅ Panel stays open
- ✅ No errors

**Actual Results**:
- [ ] Pass / [ ] Fail
- Notes: _____________________

---

## Regression Tests

### ✅ Other App Functionality

**Objective**: Verify the fix didn't break other parts of the app.

**Test Areas**:
- [ ] Navigation between pages works
- [ ] Other pages load correctly
- [ ] App doesn't crash or hang
- [ ] No console errors unrelated to environment variables
- [ ] Performance is acceptable

---

## Power Apps Monitor Validation (Optional)

If using Power Apps Monitor:

### Steps:
1. Enable Monitor (Alt+Shift+M or Tools → Monitor)
2. Perform UPDATE and CREATE operations
3. Review the trace

### Expected in Monitor:
- ✅ Fresh LookUp call before save (to check if record exists)
- ✅ Patch call with correct parameters
- ✅ IsError check after save
- ✅ Notify call with appropriate message
- ✅ No errors in formula execution

---

## Test Summary

### Test Results
- Total Scenarios: 10
- Passed: ___
- Failed: ___
- Blocked/N/A: ___

### Critical Issues Found
- [ ] None
- [ ] Issue 1: _____________________
- [ ] Issue 2: _____________________

### Recommendation
- [ ] ✅ Approve for production
- [ ] ⚠️ Approve with minor issues
- [ ] ❌ Do not approve - critical issues found

---

## Sign-Off

**Tester Name**: _____________________  
**Test Date**: _____________________  
**Environment**: _____________________  
**App Version**: _____________________  
**Signature**: _____________________

---

## Notes

### Known Limitations
- This fix requires the user to have appropriate permissions on Environment Variable Values table
- Delegation limits apply if environment has more than 500 environment variables with `admin_` prefix
- Browser must support modern JavaScript for Power Apps to function

### Support
- If issues are found, refer to: [ENVIRONMENT-VARIABLE-BUG-FIX-SUMMARY.md](./ENVIRONMENT-VARIABLE-BUG-FIX-SUMMARY.md)
- For rollback: Restore previous version from git history or Power Apps version history
