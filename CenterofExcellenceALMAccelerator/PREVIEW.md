# ALM Accelerator for Power Platform Preview
The ALM accelerator for Microsoft Power Platform is currently in public preview.
The ALM Accelerator for Power Platform has the "preview" designation because we currently use features of the platform that are marked as "preview". The following list is being maintained and will be updated as items come into or out of preview.

This list may be updated as we move toward general availability so please check back regularly for updates.

- Canvas Pack / Unpack - https://github.com/microsoft/PowerApps-Language-Tooling
- Impersonation for activating Flows - There is work being done to make sharing of connections possible with service principals to remove this blocker to GA. - https://github.com/microsoft/coe-starter-kit/issues/2415
- Requirement for service principal to have App Management Permission. This permission gives the service principal Power Platform admin rights although it is only used in the pipelines in a limited fashion. As such it's not following a pattern of zero trust we'd like to achieve in the CoE Starter Kit - https://docs.microsoft.com/powershell/module/microsoft.powerapps.administration.powershell/new-powerappmanagementapp