# CoE Starter Kit Customization and Extension Guide

This guide provides best practices for customizing and extending the CoE Starter Kit based on the official Microsoft documentation and recommended patterns.

> **Important**: The CoE Starter Kit is provided as-is and represents sample implementations. See [Modify components](https://learn.microsoft.com/power-platform/guidance/coe/modify-components) for official guidance.

## Table of Contents

- [Environment Strategy](#environment-strategy)
- [Customizing Cloud Flows](#customizing-cloud-flows)
- [Customizing Choice Fields (Option Sets)](#customizing-choice-fields-option-sets)
- [Flow Customization Approach](#flow-customization-approach)
- [Recommended Best Practices](#recommended-best-practices)
- [Upgrade Considerations](#upgrade-considerations)

---

## Environment Strategy

### Is DEV/UAT/PROD the Correct Approach?

**The CoE Starter Kit team does not recommend a traditional DEV/UAT/PROD approach for the CoE Starter Kit itself.** Here's why:

#### Why a Single Production Environment is Recommended

1. **The CoE Kit is Data-Dependent**: The CoE Starter Kit solutions rely heavily on tenant-wide inventory data (environments, apps, flows, makers). A DEV environment will not have accurate data to test against unless you run the full inventory sync (which would duplicate API calls and potentially cause throttling).

2. **Environment Variables**: Many environment variables are environment-specific (URLs, App IDs generated during setup). These cannot be easily transported between environments.

3. **Managed Solutions**: Microsoft provides **managed solutions only** for the CoE Starter Kit. Importing unmanaged solutions is not officially supported and will create complications when upgrading.

4. **Frequent Updates**: The CoE Kit receives monthly updates. Managing customizations across multiple environments adds significant overhead.

#### Recommended Environment Strategy

| Environment | Purpose | Solution Type |
|-------------|---------|---------------|
| **Production** | Primary CoE environment | Managed CoE solutions + Managed extension solution |
| **Test/Sandbox** | Testing major version upgrades | Managed CoE solutions (temporary) |

**Best Practice**: 
- Use a **single production environment** for the CoE Starter Kit
- Create a **separate custom solution** (unmanaged in development, then export as managed) for your customizations
- Use a **test/sandbox environment** only for validating major CoE upgrades before applying to production

> **Reference**: [Set up a Production Environment](https://learn.microsoft.com/power-platform/guidance/coe/setup)

---

## Customizing Cloud Flows

### Understanding the HELPER - Send Email Flow

The `HELPER - Send Email` flow is a child flow that centralizes email sending across the CoE Kit. Parent flows call it using a **workflow reference** (GUID: `5625768c-bd3d-ec11-8c63-00224829720b`).

**Flows that call HELPER - Send Email include:**
- Admin | Compliance Details Request eMail (Apps)
- Admin | Compliance Details Request eMail (Flows)
- Admin | Compliance Details Request eMail (Chatbots)
- Admin | Compliance Details Request eMail (Custom Connectors)
- Admin | Compliance Details Request eMail (Desktop Flows)
- Admin | Welcome Email v3
- And others...

### Understanding How Flow References Work

When a parent flow calls a child flow in Power Automate, it uses a **hardcoded workflow reference GUID**. This means:

> ⚠️ **CRITICAL**: If you create a copy of `HELPER - Send Email` using "Save As", parent flows **will NOT automatically call your customized version**. They will continue to call the original flow using its GUID.

### Options for Customizing Email Flows

#### Option 1: Customize Email Templates (Recommended)

The CoE Kit uses **Customized Emails** stored in Dataverse. You can customize email content without modifying flows:

1. Open the **Power Platform Admin View** model-driven app
2. Navigate to **Customized Emails**
3. Modify the email body, subject, CC, Reply-To, and Send On Behalf fields
4. Add translations for different languages

**Benefits**: 
- No flow modifications required
- Survives CoE Kit upgrades
- Supports localization

#### Option 2: Customize Email Environment Variables

Modify the email styling using environment variables:
- `eMail Header Style` (admin_eMailHeaderStyle) - CSS styling
- `eMail Body Start` (admin_eMailBodyStart) - HTML header
- `eMail Body Stop` (admin_eMailBodyStop) - HTML footer

**Benefits**:
- Simple CSS/HTML changes
- No flow modifications
- Survives upgrades

#### Option 3: Create Extension Flows (For Advanced Scenarios)

If you need to fundamentally change how emails are sent (e.g., use a different connector, add attachments, integrate with other systems):

1. **Turn off** the original `HELPER - Send Email` flow
2. **Create a new flow** with the **exact same trigger signature** (same input parameters)
3. Give it the **exact same display name**: `HELPER - Send Email`
4. Add to your **custom extension solution**

> **Important**: Power Automate uses workflow GUIDs, not display names, for child flow references. However, if you disable the original and create one with the same signature, new connections may route correctly. Always test thoroughly.

**Alternative approach for complete control**:
1. Create copies of ALL parent flows that call HELPER - Send Email
2. Update each copy to call your new helper flow
3. Disable all original parent flows
4. Place all customized flows in your extension solution

**This is significant work and makes upgrades complex. Only use if absolutely necessary.**

---

## Customizing Choice Fields (Option Sets)

### Customizing App Category

The **App Category** field is a choice (option set) on the Power Apps inventory table. To customize it:

#### Method 1: Add Values via Solution (Recommended)

1. Create a new unmanaged solution for your customizations
2. Add the `App Category` choice to your solution
3. Add your custom values
4. Export as managed for deployment

**Steps**:
1. Go to **make.powerapps.com** > **Solutions**
2. Create new solution (e.g., "CoE Extensions")
3. Add existing > Choice > Search for "App Category" (`admin_appcategory`)
4. Edit the choice and add your values
5. Publish

#### Method 2: Edit in Admin Model-Driven App

1. Open **Power Platform Admin View**
2. Navigate to **Apps** and edit a record
3. Click on the App Category field
4. Select "Edit choice" to add values

### Important Considerations

- **Do NOT remove existing values** - they may be referenced by existing data
- **Use values above 100,000,000** for custom options to avoid conflicts with future CoE updates
- **Document your customizations** for upgrade planning

---

## Flow Customization Approach

### Will "Save As" Work?

Here's the assessment of the proposed approach:

| Step | Assessment | Notes |
|------|------------|-------|
| Create copy using "Save As" | ✅ Works | Creates a new flow with a new GUID |
| Save in separate unmanaged solution | ✅ Works | Best practice for extension solutions |
| Disable original flow | ✅ Works | Prevents duplicate execution |
| Parent flows automatically call new version | ❌ **Does NOT work** | Parent flows have hardcoded GUID references |

### The GUID Reference Problem

When examining the `Admin | Compliance Details Request eMail (Apps)` flow, we can see:

```json
"Send_Audit_Mail_to_Owner_Apps": {
  "type": "Workflow",
  "inputs": {
    "host": {
      "workflowReferenceName": "5625768c-bd3d-ec11-8c63-00224829720b"
    }
  }
}
```

This GUID (`5625768c-bd3d-ec11-8c63-00224829720b`) is a direct reference to the original `HELPER - Send Email` flow. **This does not change when you create a copy with "Save As".**

### Correct Approach for Flow Customization

#### Scenario A: Customizing Email Content Only

**Do NOT copy the flows.** Instead:
1. Customize Dataverse email templates
2. Customize environment variables for styling
3. Both survive upgrades without modification

#### Scenario B: Customizing Email Sending Logic

If you must change how emails are sent:

**Option 1: Replace the Helper Flow (Simplest)**
1. Turn OFF `HELPER - Send Email`
2. Create a new flow named `HELPER - Send Email` (same name)
3. Match the EXACT trigger signature (same parameters)
4. The new flow gets a new GUID
5. Test if the parent flows work (may need to update connections)

> ⚠️ **Note**: This may not work in all cases due to GUID references. Test thoroughly.

**Option 2: Copy All Parent Flows (Complete Control)**
1. Copy `HELPER - Send Email` → Save to extension solution
2. Copy ALL parent flows that call it:
   - Admin | Compliance Details Request eMail (Apps)
   - Admin | Compliance Details Request eMail (Flows)
   - Admin | Compliance Details Request eMail (Chatbots)
   - Admin | Compliance Details Request eMail (Custom Connectors)
   - Admin | Compliance Details Request eMail (Desktop Flows)
3. Edit each parent flow copy to reference your new helper flow GUID
4. Turn OFF all original flows
5. Turn ON all copied flows
6. Save everything to your extension solution

**Upgrade Impact**: When CoE Kit updates these flows, you must:
- Review release notes for changes
- Manually apply changes to your copies
- Test thoroughly before production

---

## Recommended Best Practices

### Extension Solution Architecture

```
┌─────────────────────────────────────────┐
│        Production Environment           │
├─────────────────────────────────────────┤
│  ┌─────────────────────────────────┐   │
│  │    CoE Core Components          │   │
│  │    (Managed - from Microsoft)   │   │
│  └─────────────────────────────────┘   │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │    CoE Audit Components         │   │
│  │    (Managed - from Microsoft)   │   │
│  └─────────────────────────────────┘   │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │    Your Extension Solution      │   │
│  │    (Managed - from your repo)   │   │
│  │    - Custom flows               │   │
│  │    - Custom choice values       │   │
│  │    - Custom apps                │   │
│  │    - Environment variable       │   │
│  │      overrides                  │   │
│  └─────────────────────────────────┘   │
└─────────────────────────────────────────┘
```

### Best Practices Checklist

- [ ] **Use managed solutions** for production CoE deployment
- [ ] **Create a separate extension solution** for all customizations
- [ ] **Prefer configuration over code** - use environment variables and Dataverse email templates
- [ ] **Document all customizations** in a changelog
- [ ] **Test upgrades** in a sandbox before production
- [ ] **Review release notes** before each upgrade
- [ ] **Remove unmanaged layers** before upgrades using the Setup Wizard

### When NOT to Customize

Avoid customizing if:
- The change can be achieved through environment variables
- The change can be achieved through Customized Email templates
- The customization will require copying many dependent flows
- You don't have resources to maintain customizations through monthly updates

---

## Upgrade Considerations

### Before Upgrading

1. **Review release notes** on GitHub: [CoE Starter Kit Releases](https://github.com/microsoft/coe-starter-kit/releases)
2. **Backup your customizations** - export your extension solution
3. **Test in sandbox** if making major version jumps
4. **Run Setup Wizard** to identify unmanaged layers

### Handling Unmanaged Layers

If you've created unmanaged customizations directly on CoE components:

```
The Setup Wizard will help identify unmanaged layers that 
need to be removed before the upgrade can proceed.
```

Reference: [After Setup - Removing Unmanaged Layers](https://learn.microsoft.com/power-platform/guidance/coe/after-setup#installing-upgrades)

### Upgrade Steps with Customizations

1. Export your extension solution as a backup
2. Remove any unmanaged layers on CoE components
3. Import the new CoE managed solutions
4. Test core functionality
5. Re-import/update your extension solution if needed
6. Test customizations
7. Update any copied flows with new logic from release notes

---

## Summary

| Question | Answer |
|----------|--------|
| Is DEV/UAT/PROD correct? | **Not recommended** for CoE Kit. Use single production + extension solution |
| Will "Save As" flow approach work? | **Partially** - parent flows won't automatically call copied child flows |
| Will parent flows call customized HELPER - Send Email? | **No** - they use hardcoded GUIDs |
| Best approach for customizations? | Create extension solution + prefer configuration over code |
| How to customize App Category? | Add to extension solution and add new values |

---

## Additional Resources

- [Modify CoE Components - Official Documentation](https://learn.microsoft.com/power-platform/guidance/coe/modify-components)
- [CoE Setup Documentation](https://learn.microsoft.com/power-platform/guidance/coe/setup)
- [After Setup & Upgrades](https://learn.microsoft.com/power-platform/guidance/coe/after-setup)
- [GitHub Issues for CoE Starter Kit](https://github.com/microsoft/coe-starter-kit/issues)
- [Power Platform Community Forums](https://powerusers.microsoft.com/t5/Power-Apps-Governance-and/bd-p/Admin_PowerApps)

---

*Last updated: December 2024*
