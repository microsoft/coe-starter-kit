# DLP Impact Analysis App - Copy Policy with Deleted Environments Issue

## Issue Summary
When copying a DLP policy using the DLP Impact Analysis application (part of Core Components), the copied policy may include references to deleted environments if those environments existed in the original policy but have since been removed from the Power Platform tenant.

## Root Cause
The DLP Impact Analysis app's copy functionality directly passes the selected policy's environment list to the Power Platform Admin connector's `CreatePolicyV2` API without filtering against the current list of active environments stored in the Dataverse `admin_environments` table.

### Technical Details
In the copy dialog's button handler (file: `admin_dlpimpactanalysis_4dfb8_DocumentUri.msapp`), the OnSelect action for the "Copy" button contains:

```powerFx
PowerPlatformforAdmins.CreatePolicyV2(
    {
        displayName: txtCopyPolicy.Value,
        connectorGroups: dlDLPPolicies.Selected.connectorGroups,
        defaultConnectorsClassification: dlDLPPolicies.Selected.defaultConnectorsClassification,
        environmentType: dlDLPPolicies.Selected.environmentType,
        environments: dlDLPPolicies.Selected.environments  // <-- Issue: This may contain deleted environments
    }
)
```

In contrast, the "edit" action properly filters environments:

```powerFx
ClearCollect(
    col_environmentsInPolicy,
    AddColumns(RenameColumns(ShowColumns(
        Filter(
            col_environments,  // <-- Filters against active environments
            (Name in col_tempEnvs[@name])
        ),
        'Display Name',
        Name,'Environment Sku'
    ), admin_displayname, displayName, admin_environmentname, name, admin_environmentsku, envSku), id, 
    "/providers/Microsoft.BusinessAppPlatform/scopes/admin/environments/" & name, 
    type, "Microsoft.BusinessAppPlatform/scopes/environments"))
```

## Impact
- Copied DLP policies may contain references to non-existent environments
- This can cause confusion for administrators managing DLP policies
- The policy may attempt to apply restrictions to environments that no longer exist

## Workaround for Users

### Short-term Solution
Until this issue is fixed, administrators should:

1. **Use the Edit function instead of Copy** for the original policy
2. Manually verify the environment list and remove any deleted environments
3. Save the policy as a draft
4. Create the new policy based on the cleaned draft

### Alternative Approach
Use the Power Platform Admin Center directly:
1. Navigate to the [Power Platform Admin Center](https://admin.powerplatform.microsoft.com)
2. Go to **Policies** > **Data policies**
3. Select the policy you want to copy
4. Manually create a new policy with the same settings
5. The Admin Center will automatically exclude deleted environments

## Recommended Fix

The copy button's OnSelect action should be modified to filter environments before creating the policy:

```powerFx
If(
    Self.SelectedButton.Label = "Copy",
    // Filter environments to only include those that currently exist
    ClearCollect(
        col_tempEnvsToCopy,
        Filter(
            dlDLPPolicies.Selected.environments,
            name in col_environments.Name
        )
    );
    PowerPlatformforAdmins.CreatePolicyV2(
        {
            displayName: txtCopyPolicy.Value,
            connectorGroups: dlDLPPolicies.Selected.connectorGroups,
            defaultConnectorsClassification: dlDLPPolicies.Selected.defaultConnectorsClassification,
            environmentType: dlDLPPolicies.Selected.environmentType,
            environments: col_tempEnvsToCopy  // Use filtered environment list
        }
    );
    ClearCollect(
        col_allDLP,
        AddColumns(
            PowerPlatformforAdmins.ListPoliciesV2().value,
            details,
            PowerPlatformforAdmins.GetPolicyV2(name)
        )
    );
    Notify(
        "Your new DLP policy has been created.",
        NotificationType.Success
    )
);
UpdateContext({showHideDialog: false})
```

## Implementation Steps

To implement this fix in the CoE Starter Kit:

1. Export the `admin_dlpimpactanalysis_4dfb8_DocumentUri.msapp` file
2. Unpack the .msapp file using the Power Platform CLI or a tool like [PAModelDrivenAppUnpacker](https://github.com/microsoft/PowerApps-Language-Tooling)
3. Locate the copy button's OnSelect property in `Controls/38.json`
4. Update the formula as shown above
5. Repack the .msapp file
6. Import it back into the solution
7. Test the functionality with a policy that references deleted environments

## Related Components
- **App:** DLP Impact Analysis (`admin_dlpimpactanalysis`)
- **Solution:** Center of Excellence - Core Components
- **Connector:** Power Platform for Admins
- **Data Source:** Dataverse table `admin_environments`

## Testing Validation

To validate the fix:

1. Create a test environment in your Power Platform tenant
2. Create a DLP policy that includes the test environment
3. Delete the test environment
4. Attempt to copy the DLP policy using the DLP Impact Analysis app
5. Verify that the copied policy does not include the deleted environment
6. Check that only active environments are included in the new policy

## Additional Notes

- This issue only affects the **copy** functionality, not the **edit** functionality
- The same filtering logic used in the edit action should be applied to the copy action for consistency
- Ensure that `col_environments` is properly loaded before attempting the copy operation
- Consider adding a notification to users if environments are excluded during the copy process

## References
- [CoE Starter Kit Documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- [Power Platform Admin Connector Reference](https://learn.microsoft.com/connectors/powerplatformforadmins/)
- [DLP Policy Management](https://learn.microsoft.com/power-platform/admin/wp-data-loss-prevention)
