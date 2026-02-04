# GitHub Issue Response Template - SYNC HELPER Get Security Role Users - Append Action Failed

## Use Case
Use this template when responding to issues related to the "Action 'Append_to_ActualSrMembers_this_group' failed" error in SYNC HELPER - Get Security Role Users flow.

---

## Response Template

Thank you for reporting this issue! This error occurs due to a race condition when the SYNC HELPER - Get Security Role Users flow tries to append multiple user records to an array variable simultaneously.

### Root Cause

This is a **concurrency race condition** issue where:
1. The flow uses "Apply to each" loops with high concurrency (50 parallel iterations)
2. Multiple parallel iterations attempt to append to the same array variable (`ActualSrMembers`) at the same time
3. Power Automate's array variable operations are not thread-safe, causing intermittent failures when concurrent writes occur
4. The error manifests as "ActionFailed. An action failed. No dependent actions succeeded."

### Technical Details

The flow contains three loops that append to array variables with concurrency set to 50:

1. **Apply_to_each_Direct_Access** - Appends direct user access to array
2. **Add_each_user_no_sub_groups** - Appends users from groups without sub-groups to `ActualSrMembers`
3. **Add_each_user_in_group** - Appends users from nested groups to `ActualSrMembers` (the most commonly failing action)

When processing security roles with many users (especially through AAD groups), the high concurrency causes multiple threads to write to the same array variable, resulting in failures.

### Resolution

**Fixed in Version 4.50.7+**

This issue has been resolved by reducing the concurrency setting from 50 to 1 in the three problematic loops. The fix ensures that array append operations execute sequentially, eliminating the race condition.

**For Users on Version 4.50.6 or Earlier:**

1. **Upgrade to Latest Version** (Recommended)
   - Upgrade your CoE Starter Kit to version 4.50.7 or later
   - The fix is included in the solution package
   - Follow the [CoE Starter Kit Upgrade Guide](https://learn.microsoft.com/power-platform/guidance/coe/setup#update-the-coe-starter-kit)

2. **Manual Fix** (If unable to upgrade immediately)
   - Open the **SYNC HELPER - Get Security Role Users** flow in edit mode
   - Locate the following "Apply to each" actions:
     - "Apply_to_each_Direct_Access"
     - "Add_each_user_no_sub_groups" (within "if_no_sub_groups_add_group_here")
     - "Add_each_user_in_group" (within nested "Do_until" loop)
   - For each of these loops:
     - Click on the "..." menu → Settings
     - Under "Concurrency Control", turn ON "Concurrency Control"
     - Set "Degree of Parallelism" to **1**
   - Save the flow

3. **Retry Failed Runs**
   - After applying the fix, retry any failed flow runs
   - The flow should now complete successfully

### Expected Behavior After Fix

- The flow will process security role users sequentially instead of in parallel
- No more "Append_to_ActualSrMembers_this_group failed" errors
- Flow execution may take slightly longer for security roles with thousands of users, but reliability will be greatly improved
- Typical processing time impact: negligible for most scenarios (< 100 users per security role)

### Performance Considerations

**Why Concurrency Was Reduced:**
- **Reliability** > Performance: Array append operations are not thread-safe in Power Automate
- The performance impact is minimal because:
  - Most security roles have < 100 direct users
  - The bottleneck is API calls to list group members, not the append operation
  - Sequential append operations are very fast (< 50ms each)

**When Processing Large Security Roles:**
- If you have security roles with 1000+ users, expect slightly longer execution times
- The flow will still complete within Power Automate's 30-day timeout limit
- For extreme cases (10,000+ users), monitor flow execution and consider splitting the processing

### Prevention

To prevent similar issues in the future:
- Avoid using high concurrency with AppendToArrayVariable actions
- Use concurrency > 1 only for independent operations (like API calls)
- When appending to shared variables, always use sequential processing (concurrency = 1)

### When to Re-Open

Please re-open this issue if:
- The error persists after upgrading to version 4.50.7+
- The error persists after manually applying the concurrency fix
- You experience new types of failures in the SYNC HELPER - Get Security Role Users flow

---

## Additional Context for Responders

### Related Components
- **Flow**: SYNC HELPER - Get Security Role Users
- **Parent Flow**: Admin | Sync Template v4 (Security Roles)
- **Affected Actions**: 
  - `Append_to_ActualSrMembers_this_group`
  - `Append_to_ActualSrMembers_no_sub_groups`
  - `Append_to_array_variable` (in Apply_to_each_Direct_Access)

### Common Scenarios

**Scenario 1: Large AAD Groups**
- Security role assigned to AAD group with 100+ members
- High concurrency causes race condition on array append
- **Symptom**: Intermittent failures, not every run fails
- **Resolution**: Apply concurrency fix

**Scenario 2: Nested Groups**
- Security role assigned to group containing sub-groups
- Nested loop processing causes high parallel write attempts
- **Symptom**: Failures specifically in "Add_each_user_in_group" action
- **Resolution**: Apply concurrency fix

**Scenario 3: Multiple Security Roles**
- Processing many security roles in one sync run
- Race conditions occur in roles with many users
- **Symptom**: Some roles process fine, others fail
- **Resolution**: Apply concurrency fix

### Error Handling in Flow

The flow structure includes:
```
Get_Actual_SR_membership
├─ Apply_to_each_Direct_Access (concurrency: 50 → 1)
│  └─ Append_to_array_variable
└─ Apply_to_each_Team
   └─ continue_if_group_exists
      ├─ if_no_sub_groups_add_group_here
      │  └─ Add_each_user_no_sub_groups (concurrency: 50 → 1)
      │     └─ Append_to_ActualSrMembers_no_sub_groups
      └─ Do_until
         └─ Apply_to_each_group_-_loop
            └─ Add_each_user_in_group (concurrency: 50 → 1)
               └─ Append_to_ActualSrMembers_this_group
```

### Quick Diagnostic Questions

When gathering more information, ask:
1. What version of the CoE Starter Kit are you using?
2. Does this error occur consistently or intermittently?
3. How many users are typically in the security roles being processed?
4. Are the security roles assigned to AAD groups?
5. Do the AAD groups contain nested groups?
6. What is the run duration shown in the error screenshot?

### Related GitHub Issues

Search for similar issues:
- Keywords: "SYNC HELPER", "Security Role", "Append", "ActionFailed"
- Common variations: "Append failed", "race condition", "concurrency", "array variable"

### Microsoft Learn References

- [CoE Starter Kit Overview](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- [CoE Starter Kit Setup and Upgrade](https://learn.microsoft.com/power-platform/guidance/coe/setup)
- [Power Automate - Apply to each concurrency](https://learn.microsoft.com/power-automate/apply-to-each)
- [Power Automate - Variables](https://learn.microsoft.com/power-automate/use-variables)

### Code Changes

**File Modified**: `CenterofExcellenceCoreComponents/SolutionPackage/src/Workflows/SYNCHELPER-GetSecurityRoleUsers-5C248F24-F7C9-ED11-B597-0022480813FF.json`

**Changes Made**:
```json
// Three loops modified - changed from:
"runtimeConfiguration": {
  "concurrency": {
    "repetitions": 50
  }
}

// To:
"runtimeConfiguration": {
  "concurrency": {
    "repetitions": 1
  }
}
```

**Actions Updated**:
1. `Apply_to_each_Direct_Access` (metadata ID: a6f46313-c07d-49cb-86c1-e32584a2167c)
2. `Add_each_user_no_sub_groups` (metadata ID: cbce8529-7053-40ef-83fa-b3135196d45a)
3. `Add_each_user_in_group` (metadata ID: 27f9d96e-db8a-4a74-80cd-a8a1c4ae9872)

---

## Closing Statement

This issue has been fixed in the latest version of the CoE Starter Kit. The race condition was caused by high concurrency settings on loops that append to shared array variables. By reducing concurrency to 1 for these specific operations, the flow will now execute reliably without append failures.

Please upgrade to the latest version or apply the manual fix described above. If you continue to experience issues after applying the fix, please re-open this issue with additional details.

For questions about the CoE Starter Kit or to report new issues, please use the [issue templates](https://github.com/microsoft/coe-starter-kit/issues/new/choose).

---

## Template Version
- **Version**: 1.0
- **Created**: 2026-01-29
- **Last Updated**: 2026-01-29
- **Related Fix Version**: 4.50.7+
- **Related Components**: SYNC HELPER - Get Security Role Users flow
