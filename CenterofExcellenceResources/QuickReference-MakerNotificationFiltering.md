# Quick Reference: Maker Notification Filtering

A concise reference for filtering maker notifications in the CoE Starter Kit Governance solution.

## Question Answered

**Can we restrict maker notification emails to specific environments or specific users for pilot testing?**

**Answer**: Yes! The CoE Starter Kit supports customization to filter notifications by environment and/or user.

## Quick Solutions

### Option 1: Filter by Environment ⚙️

**Use Case**: Only send notifications for specific environments (e.g., Dev, Test)

**Quick Setup**:
1. Create environment variable: `admin_NotificationAllowedEnvironments`
2. Set value: `env-guid-1,env-guid-2,env-guid-3`
3. Modify flows to check environment against this list
4. Result: Only makers in allowed environments receive notifications

**Time to Implement**: ~30 minutes  
**Complexity**: Medium  
📖 [Full Guide](./HowTo-RestrictNotificationsToEnvironment.md)

---

### Option 2: Filter by User (Pilot Testing) 👥

**Use Case**: Test with specific users before full rollout

**Quick Setup**:
1. Create environment variable: `admin_NotificationPilotUsers`
2. Set value: `user1@contoso.com;user2@contoso.com;user3@contoso.com`
3. Modify flows to check if maker is in pilot list
4. Result: Only pilot users receive notifications

**Time to Implement**: ~20 minutes  
**Complexity**: Simple  
📖 [Full Guide](./HowTo-RestrictNotificationsToPilotUsers.md)

---

### Option 3: Combine Both 🎯

**Use Case**: Pilot with specific users in specific environments

**Quick Setup**:
1. Implement both Option 1 and Option 2
2. Add conditions to check both criteria
3. Result: Only pilot users in allowed environments receive notifications

**Time to Implement**: ~45 minutes  
**Complexity**: Advanced  
📖 [Full Guide](./FilteringMakerNotifications.md)

---

### Option 4: Turn Off Flows ⏸️

**Use Case**: Simplest approach for testing

**Quick Setup**:
1. Turn off notification flows in production environments
2. Leave flows on only in pilot environment
3. Result: No code changes needed

**Time to Implement**: ~5 minutes  
**Complexity**: Very Simple  
⚠️ **Note**: Only works if pilot is in separate environment

---

## Affected Flows

These flows send maker notifications and can be modified:

| Flow Name | Purpose | Priority |
|-----------|---------|----------|
| Admin \| Welcome Email v3 | First-time maker welcome | ⭐ High |
| Admin \| Compliance Details Request eMail (Apps) | App compliance requests | ⭐ High |
| Admin \| Compliance Details Request eMail (Flows) | Flow compliance requests | ⭐ High |
| Admin \| Compliance Details Request eMail (Custom Connectors) | Connector compliance | Medium |
| Admin \| Compliance Details Request eMail (Chatbots) | Chatbot compliance | Medium |
| Admin \| Compliance Details Request eMail (Desktop Flows) | Desktop flow compliance | Medium |

## Implementation Checklist

- [ ] Decide filtering approach (environment, user, or both)
- [ ] Create environment variable(s) or custom table
- [ ] Get list of allowed environments/users
- [ ] Modify Welcome Email flow
- [ ] Modify Compliance Request flows
- [ ] Test with pilot user/environment
- [ ] Verify non-pilot users don't receive emails
- [ ] Document changes for future upgrades
- [ ] Monitor flow run history
- [ ] Plan rollout to all users/environments

## Common Scenarios

### Scenario 1: Exclude Production
```
Goal: Don't send notifications in Production
Solution: Environment filtering
Allowed Envs: Dev, Test, Sandbox (exclude Production)
```

### Scenario 2: Department Pilot
```
Goal: Test with IT department only
Solution: User filtering
Pilot Users: IT team email addresses
```

### Scenario 3: Phased Rollout
```
Goal: Gradual rollout across organization
Solution: User filtering with batches
Week 1: 10 users
Week 2: 50 users
Week 3: All users
```

### Scenario 4: Dev Environment Only
```
Goal: Only notify makers in Development environment
Solution: Environment filtering
Allowed Envs: Development environment GUID
```

## Key Concepts

### Environment Variable
- Store configuration values
- Easy to update without modifying flows
- Can be empty to disable filtering

### Condition Logic
```
If (AllowedList is empty) OR (Current Value is in AllowedList)
  Then: Send notification
  Else: Skip notification
```

### Maker Email
- Retrieved from maker/owner record
- Used to check against pilot user list
- Format: user@domain.com

### Environment ID
- GUID format: 00000000-0000-0000-0000-000000000000
- Found in Power Platform Admin Center
- Linked to resources (apps, flows, etc.)

## Troubleshooting Quick Tips

| Issue | Quick Fix |
|-------|-----------|
| No emails sent | Check if list is empty (should allow all) |
| All emails sent | Verify environment variable has correct value |
| Wrong format error | Use semicolon (;) for emails, comma (,) for GUIDs |
| Flow fails | Check if maker email field is available in trigger |

## Upgrade Considerations

⚠️ **Important**: Flow modifications may be overwritten during CoE Starter Kit upgrades

**Mitigation**:
- Export modified flows before upgrading
- Document all changes
- Consider using separate solution layer
- Reapply modifications after upgrade

## Getting Started

1. **Read**: [Overview Guide](./FilteringMakerNotifications.md) (10 min)
2. **Choose**: Pick environment or user filtering
3. **Follow**: [Environment Guide](./HowTo-RestrictNotificationsToEnvironment.md) OR [User Guide](./HowTo-RestrictNotificationsToPilotUsers.md)
4. **Test**: Verify with pilot user/environment
5. **Rollout**: Gradually expand to all users/environments

## Support Resources

- 📚 [Full Documentation](./README.md)
- 🐛 [Report Issues](https://github.com/microsoft/coe-starter-kit/issues)
- 💬 [Community Forum](https://powerusers.microsoft.com/)
- 📖 [Official Docs](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)

## Best Practices

✅ **Do**:
- Test in non-production first
- Document your changes
- Start with small pilot group
- Monitor flow run history
- Plan for upgrades

❌ **Don't**:
- Modify flows directly in production
- Skip testing phase
- Forget to document changes
- Ignore flow run errors
- Forget about upgrade impact

---

**Quick Answer Summary**

> **Yes, you can restrict maker notifications!**
> 
> - **By Environment**: Use environment variable with allowed environment GUIDs
> - **By User**: Use environment variable with pilot user emails  
> - **Both**: Combine both approaches
> - **Time Needed**: 20-45 minutes depending on approach
> - **Impact**: No breaking changes, reversible anytime

**Next Step**: Choose your approach and follow the detailed guide! 🚀

---

*Last Updated: December 2024 | CoE Starter Kit v3.x*
