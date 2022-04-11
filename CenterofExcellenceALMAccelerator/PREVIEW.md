# ALM Accelerator for Power Platform Preview

The ALM accelerator for Microsoft Power Platform is currently in public preview.
The ALM Accelerator for Power Platform has the "preview" designation because we currently use features of the platform that are marked as "preview". The following list is being maintained and will be updated as items come into or out of preview.

This list may be updated as we move toward general availability so please check back regularly for updates.

1. Canvas Pack / Unpack - <https://github.com/microsoft/PowerApps-Language-Tooling>
1. Impersonation for activating Flows - There is work being done to make sharing of connections possible with service principals to remove this blocker to GA. - <https://github.com/microsoft/coe-starter-kit/issues/2415>
1. Requirement for service principal to have App Management Permission. This permission <https://docs.microsoft.com/powershell/module/microsoft.powerapps.administration.powershell/new-powerappmanagementapp> gives the service principal Power Platform admin rights although it is only used in the pipelines in the following areas.
   - Sharing Canvas Apps in downstream environments.
   - Updating Canvas App Owners on import of an unmanaged solution.
   - Activating Flows where an activation user is not specified in the deployment configuration. This issue would be resolved by #2 above when connection can be shared and impersonation is no longer required.
   - Running Test Automation, where applicable, to override connection consent.
