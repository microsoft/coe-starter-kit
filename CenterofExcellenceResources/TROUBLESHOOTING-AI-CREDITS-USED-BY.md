# AI Credits usage report shows **unknown** in **Credits Used By**

## Why this happens
- The **Credits Used By** value shown in the Power BI report comes from the calculated column `admin_creditusersname` on **AI Credits Usage**. The formula is `If(Len(admin_CreditsUser.admin_displayname) = 0, "unknown", admin_CreditsUser.admin_displayname)` so any record where the related user has no display name is rendered as `unknown` (CenterofExcellenceCoreComponents/SolutionPackage/src/Entities/admin_AICreditsUsage/Formulas/admin_aicreditsusage-FormulaDefinitions.yaml:1).
- The AI usage sync flow links each usage record to `admin_powerplatformusers` and also stores the raw user GUID in `admin_userid`. When the user does not already exist, the flow only inserts a stub user (type and group size) without a display name, which causes the calculated field to fall back to `unknown` (CenterofExcellenceCoreComponents/SolutionPackage/src/Workflows/AdminSyncTemplatev4AIUsage-9BBE33D2-BCE6-EE11-904D-000D3A341FFF.json:478-486,548-565).
- The flow derives the user GUID from `msdyn_aievents.createdby/azureactivedirectoryobjectid` and falls back to the **CoE System User ID** environment variable if the audit event does not contain a user. Rows created with that fallback also resolve to `unknown` because they point to the system placeholder (same flow: 724-726).

## How to fix and backfill names
1. **Verify data contains a user GUID**  
   In Dataverse, open `msdyn_aievents` for recent days and confirm `createdby.azureactivedirectoryobjectid` is populated. If it is empty, the platform is not emitting user identity for those events; those rows will remain un-attributable.
2. **Populate display names for `admin_powerplatformusers`**  
   Make sure the inventory flows that write user display names are turned on and succeeding—especially **Admin | Sync Template v4 (Connection Identities)**, which calls **Get user profile (V2)** and updates `admin_displayname` for each referenced user (CenterofExcellenceCoreComponents/SolutionPackage/src/Workflows/AdminSyncTemplatev4ConnectionIdentities-919D34D1-A8AC-EE11-A569-000D3A3411D9.json:491-565). The AI usage flow will already have created stub users; this flow fills in their names.
3. **Refresh data**  
   After display names are populated, the calculated column recalculates automatically. Refresh the AI Credits usage Power BI dataset to pull the updated `admin_creditusersname` values. No manual edits to existing usage rows are required.
4. **Prevent future gaps**  
   Keep the AI usage sync flow and the connection identities (or other user inventory) flows running on schedule and ensure their connections are authenticated so new user GUIDs always receive a display name.

## Quick diagnostic query
Use Advanced Find (or a Dataverse query) to list AI Credits usage rows where `admin_creditusersname = "unknown"`. Cross-check the related `admin_powerplatformusers` record; if `admin_displayname` is empty, rerun the connection identities/user inventory flows until it is populated, then refresh the report.
