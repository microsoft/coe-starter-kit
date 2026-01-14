# ANSWER: Can we target maker notification email to specific environment?

## Original Question

> Hi Team, I want to restrict the maker notification email to specific environment. Kindly suggest do we have any configuration settings for the same or can we restrict the maker notification emails to specific set of users to do test pilot run

## Answer

**Yes, you can restrict maker notification emails to specific environments or specific users for pilot testing!**

While the CoE Starter Kit doesn't have out-of-the-box configuration settings for this, you can achieve it through flow customization. We've created comprehensive documentation to help you implement this.

## Quick Solutions

### Option 1: Restrict to Specific Environments ⚙️

**Best for**: Excluding production environments, targeting dev/test environments only

**How it works**:
1. Create an environment variable with allowed environment GUIDs
2. Modify notification flows to check if the maker's environment is in the allowed list
3. Only send emails if the environment matches

**Implementation time**: ~30 minutes  
**📖 Full Guide**: [How-To: Restrict Notifications to Specific Environments](./HowTo-RestrictNotificationsToEnvironment.md)

### Option 2: Restrict to Specific Users (Pilot Testing) 👥

**Best for**: Pilot runs, phased rollouts, testing with specific teams

**How it works**:
1. Create an environment variable with pilot user email addresses
2. Modify notification flows to check if the maker is in the pilot list
3. Only send emails to pilot users

**Implementation time**: ~20 minutes  
**📖 Full Guide**: [How-To: Restrict Notifications to Pilot Users](./HowTo-RestrictNotificationsToPilotUsers.md)

### Option 3: Combine Both 🎯

**Best for**: Maximum control - pilot users in specific environments only

**Implementation time**: ~45 minutes

## Available Documentation

We've created comprehensive documentation to help you implement these solutions:

1. **[Quick Reference Guide](./QuickReference-MakerNotificationFiltering.md)** 👈 **Start here for fast answers!**
   - Quick solutions and comparison
   - Common scenarios
   - Troubleshooting tips

2. **[Overview: Filtering Maker Notifications](./FilteringMakerNotifications.md)**
   - All available options
   - Best practices
   - Upgrade considerations

3. **[Step-by-Step: Environment Filtering](./HowTo-RestrictNotificationsToEnvironment.md)**
   - Detailed implementation steps
   - PowerShell commands to get environment IDs
   - Flow modification examples
   - Testing procedures

4. **[Step-by-Step: Pilot User Filtering](./HowTo-RestrictNotificationsToPilotUsers.md)**
   - Detailed implementation steps
   - Multiple approaches (environment variable vs. custom table)
   - User management procedures
   - Rollout planning

5. **[Resources README](./README.md)**
   - Complete index of all guides
   - Additional resources and support

## Affected Flows

These flows can be customized to restrict notifications:

- **Admin | Welcome Email v3** - Welcome email to first-time makers
- **Admin | Compliance Details Request eMail (Apps)** - App compliance requests
- **Admin | Compliance Details Request eMail (Flows)** - Flow compliance requests
- **Admin | Compliance Details Request eMail (Custom Connectors)** - Connector compliance
- **Admin | Compliance Details Request eMail (Chatbots)** - Chatbot compliance
- **Admin | Compliance Details Request eMail (Desktop Flows)** - Desktop flow compliance

## Key Benefits

✅ **Environment Filtering**:
- Exclude production environments
- Target only dev/test environments
- Control by environment type

✅ **Pilot User Filtering**:
- Test with small group first
- Gradual rollout
- Easy to add/remove users
- Department or team-based targeting

✅ **Flexible & Reversible**:
- No breaking changes
- Can disable filtering anytime
- Easy to expand to all users/environments

## Implementation Approach

### High-Level Steps:

1. **Choose your approach** (environment, users, or both)
2. **Create environment variable(s)** to store allowed environments/users
3. **Modify flows** to add filtering logic
4. **Test** with pilot environment/user
5. **Verify** non-pilot entities don't receive notifications
6. **Gradually expand** to more environments/users

### Example Configuration:

**Environment Variable for Environments**:
```
Name: admin_NotificationAllowedEnvironments
Value: guid1,guid2,guid3
```

**Environment Variable for Pilot Users**:
```
Name: admin_NotificationPilotUsers
Value: user1@contoso.com;user2@contoso.com;user3@contoso.com
```

## Important Considerations

⚠️ **Upgrade Impact**: 
- Flow modifications may be overwritten during CoE Starter Kit upgrades
- Export modified flows before upgrading
- Document your changes for reapplication

✅ **Best Practices**:
- Test in non-production environment first
- Start with small pilot group
- Monitor flow run history
- Document all changes
- Plan for gradual rollout

## Support & Resources

- **GitHub Repository**: [microsoft/coe-starter-kit](https://github.com/microsoft/coe-starter-kit)
- **Official Documentation**: [Microsoft Learn - CoE Starter Kit](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- **Community Forum**: [Power Platform Community](https://powerusers.microsoft.com/)
- **Report Issues**: [GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues)

## Next Steps

1. **Read the Quick Reference**: Start with [QuickReference-MakerNotificationFiltering.md](./QuickReference-MakerNotificationFiltering.md)
2. **Choose your approach**: Environment filtering, user filtering, or both
3. **Follow the detailed guide**: Implementation takes 20-45 minutes
4. **Test thoroughly**: Verify in non-production first
5. **Roll out gradually**: Start small and expand

## Questions?

If you have questions or need help:
- Review the detailed documentation linked above
- Check [GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues) for similar questions
- Ask in the [Power Platform Community](https://powerusers.microsoft.com/)
- File a new issue if you encounter problems

---

**Summary**: Yes, you can restrict maker notifications to specific environments or users! Follow our step-by-step guides to implement environment filtering, pilot user testing, or both. Implementation takes 20-45 minutes and is fully reversible.

**Recommended Starting Point**: [Quick Reference Guide](./QuickReference-MakerNotificationFiltering.md)

---

*Created: December 2024*  
*Applies to: CoE Starter Kit v3.x and later*  
*Documentation Source: [CenterofExcellenceResources](./)*
