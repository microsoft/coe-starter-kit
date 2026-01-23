# Issue Response: Teams Connection Required During CoE Core Upgrade

## Ready-to-Use Response for GitHub Issue

---

Thank you for your question about the Microsoft Teams connection requirement during CoE Starter Kit upgrade!

### What's Happening

You're encountering a **new connection requirement** that was added to the CoE Core Components solution in versions released mid-2024 and later. The solution now requires a **Microsoft Teams connection** (`CoE Core - Teams`) to be configured during import.

### Good News: No Special Permissions Required! 

You **do not need** Teams admin permissions or any elevated API permissions. Standard Teams user access is all that's required.

### What Permissions Are Needed?

✅ **You only need:**
- Standard Microsoft Teams user access
- An M365 license that includes Teams
- Ability to send and receive Teams messages in your organization

❌ **You do NOT need:**
- Teams admin permissions
- Elevated API permissions  
- Azure AD admin consent
- Any special API registrations

### How to Set Up the Connection

**Step-by-Step:**

1. **During the solution import**, when you see the connection requirement screen:
   - Look for "CoE Core - Teams" in the connections list
   - It will show a red warning icon (as in your screenshot)

2. **Create the connection:**
   - Click on the "CoE Core - Teams" connection row
   - Click the **"+ New connection"** button
   - Sign in with your account (the one that will run the CoE flows)
   - Click **Allow** when prompted for Teams permissions
   - Wait for the green checkmark to appear

3. **Complete the import:**
   - Select the newly created connection from the dropdown
   - Ensure all connections show green checkmarks
   - Click **Next** to continue

### What is This Connection Used For?

The Teams connection enables these optional features:
- **Escalation notifications** when the inventory sync encounters critical errors
- **Approval workflows** for App Catalog access requests via Teams
- **DLP impact alerts** sent through Teams

**Note:** While the connection is required during import, you can choose not to use these Teams-based features if you prefer. The flows will still run; you just won't receive Teams notifications.

### Complete Setup Guide

We've created comprehensive documentation for this connection:

📖 **[Teams Connection Setup Guide](./TEAMS-CONNECTION-SETUP.md)** - Includes:
- Detailed setup instructions
- Troubleshooting for common issues
- What to do if Teams is blocked by DLP policies
- Which account should create the connection
- Complete FAQ section

### If You're Stuck

**Common issues and solutions:**

**Issue: "Teams connector is blocked by DLP policy"**
- Add Microsoft Teams connector to the same data group as Power Platform connectors
- Contact your Power Platform admin to update the DLP policy
- See [DLP troubleshooting](./TEAMS-CONNECTION-SETUP.md#what-if-teams-connector-is-blocked-by-dlp-policy)

**Issue: "I don't have Teams access"**
- Verify Microsoft Teams is enabled in your organization
- Check if your M365 license includes Teams
- Contact your M365 administrator

**Issue: "Which account should I use?"**
- Use the same service account that runs your CoE flows
- Ensure it has a Teams license
- Teams messages will be sent from this account's identity

### Additional Resources

- [Teams Connection Setup Guide](./TEAMS-CONNECTION-SETUP.md) - Complete guide
- [CoE Core Components Setup](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components) - Official docs
- [Upgrade Troubleshooting Guide](../TROUBLESHOOTING-UPGRADES.md) - General upgrade help

### Next Steps

1. Try creating the Teams connection using the steps above
2. If you encounter issues, check the [troubleshooting section](./TEAMS-CONNECTION-SETUP.md#troubleshooting) of the setup guide
3. Let us know if you have additional questions or encounter specific errors

We're here to help if you need further assistance! 🎉

---

## For Issue Responders

### Before Posting

- [ ] Customize the response if the user mentioned specific errors or constraints
- [ ] Check if their organization might have Teams blocked
- [ ] If in sovereign cloud (GCC/GCC High), mention that Teams connector should be available

### After Posting

- [ ] Label issue as "question"
- [ ] Add "documentation" label if appropriate
- [ ] Monitor for follow-up questions
- [ ] Close issue once resolved with reference to documentation

### Related Issues

- Search for similar issues: [Teams connection](https://github.com/microsoft/coe-starter-kit/issues?q=is%3Aissue+teams+connection)
- Link to related upgrade issues if applicable

---

**Response Version**: 1.0  
**Last Updated**: January 2026  
**For Issue**: Teams connection requirement questions
