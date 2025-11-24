# Frequently Asked Questions - CoE Admin Environment Request App

## Overview
This FAQ addresses common questions and issues related to the CoE Admin Environment Request app, particularly focusing on missing buttons, permissions, and access issues.

---

## General Questions

### Q: What is the CoE Admin Environment Request app?
**A:** The CoE Admin Environment Request app is part of the CoE Starter Kit that allows:
- **Makers** to submit requests for new environments
- **Admins** to review, approve, or reject environment creation requests
- Automated environment provisioning based on organization policies

### Q: What's the difference between the Admin and Maker apps?
**A:** 
- **Maker App** (`CoE Maker - Environment Request`): Used by makers to submit new environment requests
- **Admin App** (`CoE Admin - Environment Request`): Used by administrators to review and approve/reject requests

### Q: Who should have access to the Admin app?
**A:** Only users with administrative responsibilities for Power Platform governance should have access. They must have the **Power Platform Admin SR** security role.

---

## Missing Buttons and Functionality

### Q: Why can't I see the "View" and "Approve Request" buttons?
**A:** This is the most common issue and is caused by insufficient permissions. The buttons only appear if:
1. You have the **Power Platform Admin SR** role (not just Maker SR)
2. The app is shared with you using the Admin SR role
3. You have Global-level privileges on the `coe_EnvironmentCreationRequest` table

**Solution:** See the [troubleshooting guide](../../.github/ISSUE_TEMPLATE/troubleshooting-environment-request-admin-app.md) for detailed steps.

### Q: I have admin rights in my tenant. Why am I still not seeing the buttons?
**A:** Tenant-level admin rights (e.g., Global Admin, Power Platform Admin) are separate from Dataverse security roles. You need:
1. **Both** tenant admin rights AND
2. The **Power Platform Admin SR** security role in the CoE environment

### Q: The buttons were visible before, but now they're gone. What happened?
**A:** This can happen due to:
- Solution upgrade that reset app sharing
- Security role reassignment
- Cached permissions in the browser

**Solution:**
1. Verify your security role is still assigned
2. Clear your browser cache completely
3. Close all Power Apps tabs and reopen

---

## Security and Permissions

### Q: What's the difference between "Basic" and "Global" privilege levels?
**A:**
- **Basic**: User can only access records they own
- **Global**: User can access all records in the organization

The Maker role has Basic privileges (can only see their own requests), while the Admin role has Global privileges (can see and act on all requests).

### Q: I'm assigned the Power Platform Admin SR role but still can't approve requests. Why?
**A:** Check the following:

1. **App Sharing**: The app must be explicitly shared with you
   ```
   make.powerapps.com > Apps > CoE Admin - Environment Request > Share
   ```

2. **Cache**: Clear your browser cache and close all Power Apps tabs

3. **Table Permissions**: Verify the security role has Global-level privileges:
   ```
   Settings > Security > Security Roles > Power Platform Admin SR > Custom Entities
   ```

4. **Connection**: Ensure you're connected to the correct environment

### Q: Can I assign both Maker and Admin roles to the same user?
**A:** Yes, this is a common scenario. Users with both roles can:
- Create environment requests (Maker capability)
- Approve their own and others' requests (Admin capability)

However, approval workflows typically prevent self-approval.

### Q: What tables does the Admin role need access to?
**A:** The key table is `coe_EnvironmentCreationRequest`. The Admin role needs:
- Read: Global
- Write: Global
- Create: Global
- Delete: Global
- Assign: Global
- Append: Global
- Append To: Global

---

## App Behavior and Features

### Q: Can I approve my own environment requests?
**A:** This depends on your organization's configuration. The default business process flow may prevent self-approval to maintain separation of duties.

### Q: What happens after I approve a request?
**A:** The approval typically triggers:
1. A flow to create the environment in Power Platform
2. Notification to the requester
3. Configuration based on environment policies
4. Assignment of security groups/roles

The exact behavior depends on your CoE Starter Kit configuration.

### Q: Why do some requests show buttons and others don't?
**A:** If you see buttons for some requests but not others, this is likely due to:
- **Row-level security**: You may only have access to certain records
- **Business unit permissions**: Your security role may be scoped to specific business units
- **Record ownership**: Basic-level privileges only show buttons for records you own

**Solution:** Ensure your Admin SR role has **Organization-level** access, not just Business Unit.

### Q: The app is slow or doesn't load properly. What should I do?
**A:** Common performance issues:

1. **Large data volume**: If you have many requests, the gallery may be slow
   - Use filters to limit displayed records
   - Consider archiving old requests

2. **Connection issues**: 
   - Verify all connections are active (Settings > Connections)
   - Reconnect if any show errors

3. **Browser issues**:
   - Use Microsoft Edge or Chrome (recommended)
   - Clear cache and cookies
   - Disable browser extensions that might interfere

---

## Installation and Upgrade

### Q: I just installed CoE Starter Kit 4.50.6. Do I need to configure anything for the Admin app?
**A:** Yes, after installation:

1. Assign the **Power Platform Admin SR** role to admin users
2. Share the admin app with those users
3. Configure environment variables for environment request settings
4. Set up approval workflows if customization is needed

See: [Setup Core Components](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components)

### Q: I upgraded from an earlier version. Why are buttons missing?
**A:** Upgrades can sometimes reset:
- App sharing settings
- Security role assignments (if roles were customized)
- Connection references

**Solution:**
1. Re-share the apps with admin users
2. Verify security role assignments
3. Update connection references if needed
4. Clear cache for all users

### Q: Can I customize the Admin app to add more fields or buttons?
**A:** Yes, but with caution:
- The CoE Starter Kit is a **managed solution**
- Direct modifications will create an unmanaged layer
- Unmanaged layers can prevent solution updates

**Best practice:**
- Create a separate unmanaged solution for customizations
- Extend the app rather than modifying it directly
- Document all customizations

See: [Modify Components](https://learn.microsoft.com/power-platform/guidance/coe/modify-components)

---

## Troubleshooting

### Q: How do I debug permission issues?
**A:** Use this checklist:

```
☐ User has Power Platform Admin SR role assigned
☐ App is shared with user (with Admin SR role)
☐ User can see the app in their app list
☐ Security role has Global-level privileges on coe_EnvironmentCreationRequest
☐ User is in the correct business unit (if BU-scoped)
☐ Browser cache has been cleared
☐ User has logged out and back in
☐ No DLP policies blocking required connectors
☐ All connections are active and working
```

### Q: Where can I find error logs?
**A:** Check these locations:

1. **Power Automate Flow Run History**:
   - make.powerautomate.com > My flows
   - Find flows related to environment requests
   - Check run history for errors

2. **Browser Developer Console**:
   - Press F12 in browser
   - Go to Console tab
   - Look for JavaScript errors

3. **Monitor**:
   - In Power Apps Studio, use Monitor to debug app behavior
   - Run the app while monitoring is active

### Q: The app shows "You don't have permissions" error. What does this mean?
**A:** This specific error means:
- You can access the app
- BUT you don't have sufficient Dataverse table permissions

**Solution:** Verify your security role has the required privileges on the `coe_EnvironmentCreationRequest` table.

### Q: Buttons appear but don't do anything when clicked. Why?
**A:** Check:

1. **Connections**: Ensure all connections are valid
2. **Flow errors**: Check if approval flows are failing
3. **JavaScript errors**: Open browser console (F12) to see errors
4. **DLP policies**: Verify required connectors aren't blocked

---

## Advanced Scenarios

### Q: Can I integrate environment requests with external approval systems?
**A:** Yes, the CoE Starter Kit is extensible. You can:
- Modify the approval flows to call external APIs
- Integrate with Azure Logic Apps or other systems
- Use custom connectors for your approval system

**Note:** Customizations should be done in a separate solution.

### Q: How do I set up automated environment creation?
**A:** This requires:
1. Completing the Environment Request setup wizard
2. Configuring environment templates
3. Setting up automatic approval rules (if desired)
4. Configuring security groups for new environments

See: [Environment Management](https://learn.microsoft.com/power-platform/guidance/coe/setup-environment-components)

### Q: Can I restrict who can request certain types of environments?
**A:** Yes, this can be configured through:
- Custom business rules in the request form
- Approval flow logic
- Environment policies in your CoE configuration

---

## Getting Help

### Q: Where can I get more help?
**A:** Resources:

1. **Official Documentation**: [CoE Starter Kit Docs](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
2. **GitHub Issues**: [Report bugs or ask questions](https://github.com/microsoft/coe-starter-kit/issues)
3. **Community Forums**: [Power Apps Admin & Governance](https://powerusers.microsoft.com/t5/Power-Apps-Governance-and/bd-p/Admin_PowerApps)

### Q: Is there Microsoft Support for the CoE Starter Kit?
**A:** The CoE Starter Kit is provided as a **best-effort, unsupported** solution:
- ✅ Community support via GitHub
- ✅ Documentation and guidance provided
- ❌ No SLA or guaranteed response time
- ❌ Not covered by Microsoft support contracts

For **Power Platform product issues** (not CoE Kit specific), contact Microsoft Support.

### Q: Can I contribute to improving the CoE Starter Kit?
**A:** Yes! Contributions are welcome:
- Report bugs via GitHub Issues
- Suggest features
- Submit pull requests
- Share your experiences and workarounds

See: [How to Contribute](../../HOW_TO_CONTRIBUTE.md)

---

## Related Documents

- [Troubleshooting Guide](../../.github/ISSUE_TEMPLATE/troubleshooting-environment-request-admin-app.md)
- [Common GitHub Responses](./COE-Kit-Common-GitHub-Responses.md)
- [Issue Response Template](./issue-response-missing-environment-request-options.md)

---

*Last Updated: November 2025*
*For the latest information, always refer to the official [CoE Starter Kit documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit).*
