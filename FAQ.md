# CoE Starter Kit - Frequently Asked Questions (FAQ)

## Roadmap and Future of the CoE Starter Kit

### What does the roadmap look like until the deprecation of the CoE Starter Toolkit?

**There is currently no announced deprecation date for the CoE Starter Kit.** The CoE Starter Kit continues to be actively developed and maintained by Microsoft. You can track our ongoing development efforts through:

- **[Open Milestones](https://github.com/microsoft/coe-starter-kit/milestones?state=open)**: View planned features and upcoming releases
- **[Closed Milestones](https://github.com/microsoft/coe-starter-kit/milestones?state=closed)**: Review completed work and past releases
- **[Releases](https://github.com/microsoft/coe-starter-kit/releases)**: Download the latest versions of all managed solutions

We recommend subscribing to release notifications to stay informed about new features and improvements:
1. Select **Watch** on the GitHub repository
2. Select **Custom > Releases > Apply** to receive notifications about releases

### What is the exact date of the deprecation of the CoE Starter Toolkit?

**There is no deprecation date announced for the CoE Starter Kit.** The kit is an active project that continues to receive updates, bug fixes, and new features. 

If deprecation were to be planned in the future, Microsoft would provide advance notice through:
- Official announcements on the GitHub repository
- Updates to the [official documentation](https://docs.microsoft.com/power-platform/guidance/coe/starter-kit)
- Communications through the Power Platform admin community

### What impact will the deprecation have on existing components from the CoE Starter Toolkit that have been deployed?

While there is no current deprecation planned, it's important to understand the support model:

**Current Support Model:**
- The CoE Starter Kit is provided as a **template and sample implementation**
- The underlying Power Platform features (Dataverse, admin APIs, connectors) are **fully supported by Microsoft**
- The kit itself represents sample implementations that customers can customize and extend
- Issues should be reported through [GitHub Issues](https://aka.ms/coe-starter-kit-issues) rather than Microsoft Support

**If deprecation were announced in the future:**
- Existing deployed solutions would continue to function as the underlying Power Platform features remain supported
- You would retain full ownership of your deployed and customized solutions
- The Dataverse tables, flows, and apps you've deployed would remain in your environment
- Microsoft would likely provide guidance on migration paths or alternative solutions

### We have a lot of flows that are dependent on the CoE tables – what will be the impact on these newly created flows?

**Currently: No Impact**

Since there is no deprecation planned:
- Your custom flows that depend on CoE Starter Kit tables will continue to function normally
- The CoE Starter Kit tables are Dataverse tables in your environment that you control
- You can continue to build and extend solutions using these tables

**Best Practices for Long-term Sustainability:**
1. **Document your customizations**: Maintain clear documentation of flows and dependencies you've created
2. **Follow upgrade guidance**: When upgrading the CoE Starter Kit, follow the [official upgrade instructions](https://docs.microsoft.com/power-platform/guidance/coe/after-setup#installing-upgrades)
3. **Avoid modifying core components**: Build custom solutions alongside the CoE Starter Kit rather than modifying its core components
4. **Stay informed**: Subscribe to repository updates and review release notes for any breaking changes

**If deprecation were announced:**
- The Dataverse tables in your environment would remain intact
- Your custom flows would continue to operate as they interact with data in your own environment
- You would need to ensure data collection mechanisms continue (either through CoE Starter Kit flows or custom implementations)

### We have a Power App that has been built and is dependent on the CoE Dataverse tables – do we foresee any impact here?

**Currently: No Impact**

Your custom Power Apps that use CoE Starter Kit tables will continue to function:
- The apps interact with Dataverse tables in your environment
- You have full control over these tables and apps
- Updates to the CoE Starter Kit are designed to maintain backward compatibility where possible

**Best Practices:**
1. **Separate your customizations**: Create your custom apps in separate solutions from the CoE Starter Kit managed solutions
2. **Use proper dependency management**: Document which CoE tables and fields your apps depend on
3. **Test before upgrading**: When new versions of the CoE Starter Kit are released, test in a development environment first
4. **Review release notes**: Check for any schema changes or breaking changes before upgrading

**If deprecation were announced:**
- Your Power Apps would continue to function as they interact with data in your Dataverse environment
- The Dataverse tables would remain in your environment
- You might need to implement alternative data collection methods if you rely on CoE Starter Kit flows for data population

## Additional Resources

### How is the CoE Starter Kit supported?

From the [official documentation](https://docs.microsoft.com/power-platform/guidance/coe/starter-kit):

> Although the underlying features and components used to build the Center of Excellence (CoE) Starter Kit (such as Common Data Service, admin APIs, and connectors) are fully supported, the kit itself represents sample implementations of these features. Our customers and community can use and customize these features to implement admin and governance capabilities in their organizations.

**If you face issues with:**
- **Using the kit**: Report your issue at [aka.ms/coe-starter-kit-issues](https://aka.ms/coe-starter-kit-issues)
- **Core features in Power Platform**: Use your standard channel to contact Microsoft Support

### How do I stay informed about changes?

1. **Subscribe to releases**: Follow the instructions in the [README](README.md) to watch the repository and receive release notifications
2. **Review milestones**: Check [open milestones](https://github.com/microsoft/coe-starter-kit/milestones?state=open) for upcoming features
3. **Monitor discussions**: Participate in [GitHub Discussions](https://github.com/microsoft/coe-starter-kit/discussions)
4. **Check documentation**: Review the [official documentation](https://docs.microsoft.com/power-platform/guidance/coe/starter-kit) regularly for updates

### Where can I get help?

- **Questions**: Use the [question issue template](https://github.com/microsoft/coe-starter-kit/issues/new/choose)
- **Bugs**: Report bugs using the appropriate bug template
- **Feature requests**: Submit feature requests through GitHub Issues
- **Community**: Participate in [GitHub Discussions](https://github.com/microsoft/coe-starter-kit/discussions)
- **General Power Platform Governance**: Use the [Power Apps Community forum](https://powerusers.microsoft.com/t5/Power-Apps-Governance-and/bd-p/Admin_PowerApps)

## Summary

- ✅ **No deprecation is currently planned** for the CoE Starter Kit
- ✅ **Active development continues** with regular releases and updates
- ✅ **Your customizations are safe** as you own the deployed solutions and data
- ✅ **Underlying platform features are fully supported** by Microsoft
- ✅ **Stay informed** by subscribing to repository notifications and reviewing documentation

For the most current information, always refer to:
- Official documentation: https://docs.microsoft.com/power-platform/guidance/coe/starter-kit
- GitHub repository: https://github.com/microsoft/coe-starter-kit
- Release notes: https://github.com/microsoft/coe-starter-kit/releases
