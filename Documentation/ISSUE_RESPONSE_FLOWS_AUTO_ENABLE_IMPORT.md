# GitHub Issue Response - Cloud flows automatically turn on during import

Use this response when customers report that CoE Core or Governance (Audit) cloud flows start running immediately while importing the solution package.

---

## Quick Answer

- The Governance v3.27.7 solution ships its flows in a **turned off (StateCode 0)** state. Examples: `Admin | Inactivity notifications v2 (Start Approval for Flows)` and `Admin | Inactivity notifications v2 (Start Approval for Apps)` are exported with `<StateCode>0</StateCode>` in the package metadata, meaning they are intentionally off by default ([source](../CenterofExcellenceAuditComponents/SolutionPackage/src/Workflows/AdminInactivitynotificationsv2StartApprovalforFlow-7E68D839-0556-EB11-A812-000D3A996ADC.json.data.xml#L14), [source](../CenterofExcellenceAuditComponents/SolutionPackage/src/Workflows/AdminInactivitynotificationsv2StartApprovalforApps-D740E841-7057-EB11-A812-000D3A9964A5.json.data.xml#L10-L16)).
- The Power Platform solution import wizard has an **Advanced setting called “Enable processes (workflows/flows/business rules)”** that is turned on by default. When left enabled, Dataverse activates all cloud flows after connections are supplied—even if the package ships them as off. This is platform behavior, not a CoE packaging bug.
- Upgrades also **retain the current run state** of existing flows. If flows were enabled before upgrading, the upgrade keeps them on.

## How to prevent flows turning on during import

1. When importing the solution (Maker portal or Power Platform Admin Center), expand **Advanced settings** on the review step.
2. **Clear/disable “Enable processes (such as business process flows, workflows, flows)”** before clicking **Import**. The solution will import with flows remaining off.
3. After import, run the **CoE Setup/Upgrade Wizard** to configure environment variables and then selectively turn on only the flows you need.

## If you already imported and flows started

- In the CoE environment, open the imported solution, switch to **Cloud flows**, multi-select the flows, and choose **Turn off**.
- Optionally re-import the solution with the Advanced setting disabled to ensure future upgrades keep them off until you explicitly enable them.
- After disabling, verify the connection references remain healthy, then re-enable only the flows you intend to run.

## Troubleshooting checklist

- ✅ Confirm whether the **Advanced import setting** was left enabled (most common cause of auto-activation).
- ✅ Verify the package state shows `<StateCode>0</StateCode>` for the affected flows to confirm they ship off by default (see sources above).
- ✅ If flows keep turning on after you disable them, check for automation (e.g., admin users or scripts) that might be reactivating flows during setup or post-deployment validation.
