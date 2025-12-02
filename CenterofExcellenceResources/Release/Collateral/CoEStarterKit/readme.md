# Center of Excellence Starter Kit
The Microsoft Power Platform CoE Starter Kit is a collection of components and tools that are designed to help you get started with developing a strategy for adopting and supporting Microsoft Power Platform, with a focus on Power Apps, Power Automate, and Power Virtual Agents.

## Documentation
Learn more about the CoE Starter Kit: https://docs.microsoft.com/power-platform/guidance/coe/starter-kit

## First Time Setup Instructions
- Get started with the CoE Starter Kit Setup: https://docs.microsoft.com/en-us/power-platform/guidance/coe/setup
- Get started with the ALM Accelerator for Power Platform Setup: https://docs.microsoft.com/en-us/power-platform/guidance/coe/setup-almacceleratorpowerplatform-cli

## Upgrade Instructions
- Upgrading from the latest version of the CoE Starter Kit: https://docs.microsoft.com/power-platform/guidance/coe/after-setup#installing-upgrades

## Customizing the CoE Starter Kit
- Best practices on customizing and extending the CoE Starter Kit: https://docs.microsoft.com/en-us/power-platform/guidance/coe/modify-components
- See also: [Customization and Extension Guide](CUSTOMIZATION-AND-EXTENSION-GUIDE.md) for detailed guidance on environment strategy, flow customization, and extension patterns

## Files in this download

The content package contains various files that support different features of the CoE Starter Kit. The setup instructions will walk you through when to use each file, and below table will give you an overview of the purpose of each file:

| File Name | Description |
| --- | --- |
| ALMAcceleratorForMakers_x.x.yyyymmdd.x_managed.zip | [ALM Accelerator for Makers](almaccelerator-components.md) solution file. Required during [setup of the ALM Accelerator for Makers](setup-almaccelerator.md) components. |
| CenterofExcellenceALMAccelerator_x.x.yyyymmdd.x_managed.zip  | [ALM Accelerator for Power Platform](almacceleratorpowerplatform-components.md) solution file. Required during [setup of the ALM Accelerator for Power Platform](setup-almacceleratorpowerplatform-cli.md) components. |
| CenterofExcellenceAuditComponents_x.xx_managed.zip  | [Governance components](governance-components.md) solution file. Required during [setup of the Governance](before-setup-gov.md) components. Has a dependency on [Core components](core-components.md) being installed first. |
| CenterofExcellenceAuditLogs_x.xx_managed.zip  |  Audit Log components solution file. Required during [setup of the Audit Log](setup-auditlog.md) components. Has a dependency on [Core components](core-components.md) being installed first.|
| CenterofExcellenceCoreComponents_x.xx_managed.zip  | [Core components](core-components.md) solution file. Required during [setup of the Core](setup-core-components.md) components in a Production environment. |
| CenterofExcellenceCoreComponentsTeams_x.xx_managed.zip  | [Core components](core-components.md) solution file. Required during [setup of the Core](setup-core-components.md) components in a Dataverse for Teams environment. |
| CenterofExcellenceInnovationBacklog_x.xx_managed.zip  | [Innovation Backlog components](innovationbacklog-components.md) solution file. Required during [setup of the Innovation Backlog](setup-innovationbacklog.md) components. |
| CenterofExcellenceNurtureComponents_x.xx_managed.zip  |  [Nurture components](nurture-components.md) solution file. Required during [setup of the Nurture](setup-nurture-components.md) components. Has a dependency on [Core components](core-components.md) being installed first. |
| MakerAssessmentStarterData.xlsx | Provides a set of starter questions and answers for the [Maker assessment](nurture-components.md#maker-assessment-components) app. Required during [configuration of the Maker Assessment](setup-nurture-components.md#set-up-maker-assessment-components) app. |
| Production_CoEDashboard_MMM2022.pbit  | [CoE Dashboard Power BI template file](power-bi.md) used when the CoE solutions are installed in a Production environment. Required during [configuration of the Power BI dashboard](setup-powerbi.md) |
| Pulse_CoEDashboard.pbit | [Pulse survey Power BI template file](nurture-components.md#pulse-survey-components). Required during [configuration of Pulse survey](setup-nurture-components.md#set-up-pulse-feedback-survey) components. |
| Teams_CoEDashboard_MMM2022.pbit | [CoE Dashboard Power BI template file](power-bi.md) used when the CoE solutions are installed in a Dataverse for Teams environment. Required during [configuration of the Power BI dashboard](setup-powerbi.md) |
| Theming_x.xx_managed.zip | [Theming components](theming-components.md) solution file. Required during [setup of the Theming](setup-theming.md) components. | 
| ToolIcons.zip | Provides a set of starter icons for the [Innovation Backlog](innovationbacklog-components.md). Required during [configuration of the Innovation Backlog](setup-innovationbacklog.md#turn-on-the-flows) |

## Disclaimer
Although the underlying features and components used to build the Center of Excellence (CoE) Starter Kit (such as Common Data Service, admin APIs, and connectors) are fully supported, the kit itself represents sample implementations of these features. Our customers and community can use and customize these features to implement admin and governance capabilities in their organizations.

If you face issues with:

- **Using the kit**: Report your issue here: [aka.ms/coe-starter-kit-issues](https://aka.ms/coe-starter-kit-issues). (Microsoft Support won't help you with issues related to this kit, but they will help with related, underlying platform and feature issues.)
- The **core features in Power Platform**: Use your standard channel to contact Support.
