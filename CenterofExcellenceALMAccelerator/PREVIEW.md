# ALM Accelerator for Power Platform Preview

The ALM accelerator for Microsoft Power Platform is currently Generally Available. However, some features rely on preview features in other areas of the product and some may limit adoption in production environments as a result. 

This list is being maintained and will be updated as items come into or out of preview. This list may also be updated as we on-board new features, so please check back regularly for updates.

1. Canvas pack / unpack - <https://github.com/microsoft/PowerApps-Language-Tooling> - This feature can be enabled or disabled using the Project Setup Wizard.
1. Requirement for service principal to have App Management Permission. This permission <https://docs.microsoft.com/powershell/module/microsoft.powerapps.administration.powershell/new-powerappmanagementapp> gives the service principal Power Platform admin rights although it is only used in the pipelines in the following areas.
   - Sharing canvas apps in downstream environments.
   - Updating canvas app owner on import of an unmanaged solution.
   - Running canvas test automation, where applicable, to override connection consent.
