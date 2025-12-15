# Issue Response: Data Export Feature Greyed Out

## For GitHub Issue Comment

Use this template to respond to issues where users report the Data Export option being greyed out:

---

Thank you for reporting this issue. I can confirm that **the Data Export option appearing greyed out is expected behavior**, not a bug.

## Current Status

**Data Export V2 is not yet available.** It is a Power Platform product feature that has not been released by Microsoft. The CoE Starter Kit has prepared the Setup Wizard to support this feature once it becomes available, but it cannot be enabled until the product team releases Data Export V2.

## Recommended Action

Please use the **Cloud Flows** inventory method, which is the current recommended approach:

### Steps:
1. In the Setup Wizard "Choose Data Source" step, select **"Cloud Flows"**
2. Complete the setup following the official documentation: [Setup Core Components - Choose Data Source](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup-core-components#choose-data-source)
3. Configure environment variables and turn on the inventory flows

### Why Cloud Flows?
- ✅ Fully supported and actively maintained
- ✅ No additional Azure infrastructure required
- ✅ Provides complete inventory and telemetry capabilities
- ✅ Receives regular updates and improvements

## About BYODL

While the "BYODL - Bring Your Own Data Lake" option is also available, it is **not recommended** for new implementations. BYODL is a legacy approach with limited ongoing support. Microsoft is moving towards Fabric for data lake scenarios.

## When Will Data Export V2 Be Available?

There is currently no announced ETA for Data Export V2 general availability. The "~Fall 2024" message shown in the wizard was an estimated timeframe that is subject to change by the Microsoft product team.

### How to Stay Informed:
1. Subscribe to [CoE Starter Kit Release Notifications](https://github.com/microsoft/coe-starter-kit/releases)
2. Monitor [Power Platform Release Plans](https://learn.microsoft.com/en-us/power-platform/release-plan/)
3. Check the [Microsoft 365 Roadmap](https://www.microsoft.com/microsoft-365/roadmap)

## Additional Resources

For more detailed information, please see:
- [Data Export V2 Status and Troubleshooting Guide](../docs/coe-knowledge/Data-Export-V2-Status.md)
- [CoE Kit Common Responses](../docs/coe-knowledge/COE-Kit-Common%20GitHub%20Responses.md)

## Summary

- ✅ **Use Cloud Flows** - This is the current recommended approach
- ⏳ **Data Export V2 is not available yet** - The greyed-out option is intentional
- ❌ **Do not use BYODL** - Not recommended for new implementations
- 🚀 **Don't wait** - Set up CoE Starter Kit with Cloud Flows today

Please let us know if you have any questions about setting up the Cloud Flows inventory method.

---

## Closing the Issue

If the user confirms they understand and will use Cloud Flows, close the issue with:

---

Closing this issue as this is expected behavior. Data Export V2 is not yet available from the Microsoft product team. Please use the Cloud Flows inventory method as documented.

If you encounter issues with the Cloud Flows setup, please open a new issue with specific details about the problem you're experiencing.

---

