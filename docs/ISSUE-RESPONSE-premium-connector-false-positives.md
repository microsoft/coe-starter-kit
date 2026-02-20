# Premium Connector False Positives

## Issue Summary
Flows with only standard connectors (SharePoint, Excel Online, Office 365, etc.) are being incorrectly flagged as having premium connectors in the CoE Starter Kit inventory.

## Root Cause
The `SYNCHELPER-CloudFlows` flow determines whether a flow has premium connectors by:

1. Extracting the tier from each connector using the path `@item()?['apiDefinition/properties/tier']`
2. Filtering for connectors where tier equals 'Premium'
3. Also checking if the flow contains HTTP, HttpWebhook, or Request triggers/actions

The issue is that the `apiDefinition/properties/tier` path may not always exist or may return unexpected values in the Power Platform API response, causing the tier detection to fail.

## Impact
- Flows are incorrectly flagged as using premium features
- This can cause confusion for admins trying to understand licensing requirements
- May lead to incorrect compliance and governance decisions

## Investigation Steps

To investigate this issue in your environment:

1. **Check the actual connector tier data:**
   - Open the Admin Command Center
   - Navigate to Flows
   - Check flows that are incorrectly flagged
   - Look at the Connector Reference table to see what tiers are stored

2. **Review the flow definition:**
   - Open the Power Automate maker portal
   - Review the connectors used in the flagged flow
   - Verify that they are indeed standard connectors

3. **Check the Power Platform API response:**
   - Use the Power Platform Admin API to get flow details
   - Check the structure of `connectionReferences` in the response
   - Verify the path to access the tier information

## Workaround
Until this is fixed, you can:

1. Manually review flows flagged as premium to verify actual connector usage
2. Filter out false positives in your reports by cross-referencing with the Connector entity
3. Use the Power Platform Admin Center to verify actual premium connector usage

## Known Issues

This is a known limitation where the API structure for accessing connector tier information may vary or change over time.

## Related Information

- Power Platform Admin API documentation: https://learn.microsoft.com/power-platform/admin/api/introduction
- Flow connector reference: https://learn.microsoft.com/connectors/connector-reference/
- Premium connector list: https://learn.microsoft.com/power-platform/admin/powerapps-flow-licensing-faq#what-connectors-are-premium

## Version Information
This issue has been observed in CoE Starter Kit version 4.50.8 and may affect other versions.
