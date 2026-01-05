# AI Credits Collection in CoE Starter Kit

## Overview

The CoE Starter Kit collects AI credit consumption data through the **Admin - Sync Template v4 (AI Usage)** flow, which is part of the Core Components solution.

## What Credits Are Collected?

The AI Usage flow collects **all AI credit consumption** data stored in the `msdyn_aievents` table in Dataverse. This includes:

### 1. AI Builder Credits
- Custom AI models (prediction, form processing, object detection, etc.)
- Prebuilt AI models (business card reader, receipt processing, text recognition, etc.)
- AI Builder prompts (GPT-based prompt builder)

### 2. Copilot Credits
- Copilot Studio conversations and actions
- Embedded copilots in Power Apps and Power Pages
- Copilot in Power Automate (AI-powered automation)
- Any other copilot features that consume AI credits

### 3. Other AI Services
- Any Power Platform AI service that logs credit consumption to the `msdyn_aievents` table

## How It Works

The AI Usage flow:

1. **Triggers**: When an environment record is added or modified in the CoE inventory
2. **Queries**: Connects to each environment and queries the `msdyn_aievents` table
3. **Filters**: Retrieves records where `msdyn_creditconsumed > 0` from the last day
4. **Stores**: Aggregates and stores the data in the `admin_aicreditsusages` table in the CoE environment

## Data Collected

For each AI credit consumption event, the flow collects:
- **Credits Consumed**: Number of AI credits used (`msdyn_creditconsumed`)
- **Processing Date**: When the AI operation occurred (`msdyn_processingdate`)
- **User**: The user who triggered the AI operation
- **Environment**: The environment where the operation occurred
- **AI Event ID**: Unique identifier for the event

## Viewing AI Credits Data

You can view AI credits consumption data in the CoE Starter Kit through:

1. **Power Platform Admin View app**: Navigate to the AI Credits Usage section
2. **Power BI Reports**: If you have configured the CoE Power BI dashboard, AI credits data will be included
3. **Direct Dataverse Access**: Query the `admin_aicreditsusages` table

## Important Notes

### Credit Types
The `msdyn_aievents` table does **not** differentiate between AI Builder credits and Copilot credits in separate fields. Both types of credits are logged with the same structure, identified by the operation that consumed them.

### Data Retention
- The AI Usage flow runs daily and collects data from the previous day
- Historical data is retained in the `admin_aicreditsusages` table according to your Dataverse retention policies
- The source `msdyn_aievents` table follows Microsoft's standard retention policies

### Prerequisites
For the AI Usage flow to collect data:
1. The environment must be in your CoE inventory
2. The CoE service account must have permissions to read the `msdyn_aievents` table in each environment
3. The environment must have AI features enabled and in use

### Troubleshooting

If you're not seeing Copilot credits:
1. **Verify Copilot is being used**: Ensure users are actively using Copilot features that consume credits
2. **Check environment inventory**: Confirm the environments with Copilot usage are being inventoried by the CoE Kit
3. **Review flow history**: Check the AI Usage flow run history for errors
4. **Validate permissions**: Ensure the CoE service account has read access to `msdyn_aievents` in target environments
5. **Check data freshness**: The flow collects data daily; recent usage may not appear immediately

## Frequently Asked Questions

### Q: Are Copilot credits collected separately from AI Builder credits?
**A**: No. Both AI Builder and Copilot credits are stored in the same `msdyn_aievents` table and collected by the same flow. They are logged as separate events but stored in the same data structure.

### Q: How can I differentiate between AI Builder and Copilot credit consumption?
**A**: While the `msdyn_aievents` table includes fields that can help identify the source of credit consumption, the CoE Starter Kit currently aggregates all AI credits together. For detailed breakdown by service type, you may need to enhance the reporting with custom queries against the `msdyn_aievents` table.

### Q: What version of CoE Starter Kit supports Copilot credit collection?
**A**: The AI Usage flow was introduced to collect data from the `msdyn_aievents` table. As long as your CoE Starter Kit version includes the AI Usage flow (version 4.x and later), it will automatically collect Copilot credits as they are logged to the same table.

### Q: Do I need to make any changes to collect Copilot credits?
**A**: No. If you already have the AI Usage flow enabled and collecting AI Builder credits, it is automatically collecting Copilot credits as well. No configuration changes are needed.

## Related Resources

- [CoE Starter Kit Documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- [Set up core components](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components)
- [Microsoft AI Builder documentation](https://learn.microsoft.com/ai-builder/)
- [Microsoft Copilot Studio documentation](https://learn.microsoft.com/microsoft-copilot-studio/)
- [AI credit consumption in Power Platform](https://learn.microsoft.com/power-platform/admin/power-automate-licensing/types#ai-builder-credits)

## Version Information

- **Solution**: Core Components
- **Flow**: Admin - Sync Template v4 (AI Usage)
- **Entity**: admin_aicreditsusages
- **Source Table**: msdyn_aievents (Dataverse system table)
