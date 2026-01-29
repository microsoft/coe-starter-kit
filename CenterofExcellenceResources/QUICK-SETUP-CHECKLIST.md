# CoE Starter Kit - Quick Setup Checklist

## Before You Begin

**⚠️ Critical Prerequisites**

1. **Install Creator Kit First**
   - Download from: https://aka.ms/creatorkitdownload
   - The CoE Setup Wizard requires Creator Kit PCF controls
   - Install Creator Kit **before** importing CoE Core Components

2. **Service Account Requirements**
   - Must be a **user account** (not service principal/app registration)
   - Requires **Power Apps Per User** or **Power Apps Premium** license
   - Needs **Power Platform Admin** role (Entra ID)
   - Must have **System Administrator** role in CoE environment

3. **Environment Setup**
   - Enable **English (1033)** language pack
   - Verify environment has Dataverse database
   - Ensure no DLP policies block required connectors

## Common Installation Issues

### "Error loading control" in Setup Wizard
**Cause:** Missing Creator Kit or browser cache
**Fix:**
1. Install Creator Kit if not present
2. Clear browser cache completely
3. Try InPrivate/Incognito window
4. Verify English language pack is enabled

See [TROUBLESHOOTING-SETUP-WIZARD.md](./TROUBLESHOOTING-SETUP-WIZARD.md) for detailed steps.

### Cannot Add Service Account as System Administrator
**Cause:** Insufficient license or wrong account type
**Fix:**
1. Verify account is a **user account**
2. Assign **Power Apps Per User** or **Premium** license
3. Wait 15-30 minutes for license sync
4. Try assignment again

See [TROUBLESHOOTING-SETUP-WIZARD.md](./TROUBLESHOOTING-SETUP-WIZARD.md) for detailed steps.

## Quick Links

- **Creator Kit:** https://aka.ms/creatorkitdownload
- **Setup Documentation:** https://learn.microsoft.com/power-platform/guidance/coe/setup
- **Full Troubleshooting Guide:** [TROUBLESHOOTING-SETUP-WIZARD.md](./TROUBLESHOOTING-SETUP-WIZARD.md)
- **FAQ:** https://learn.microsoft.com/power-platform/guidance/coe/faq
- **Report Issues:** https://github.com/microsoft/coe-starter-kit/issues

## Installation Order

1. ✅ Install Creator Kit
2. ✅ Assign licenses to service account
3. ✅ Add service account as System Admin to CoE environment
4. ✅ Import CoE Core Components
5. ✅ Run Setup Wizard
6. ✅ Configure environment variables
7. ✅ Turn on flows

## Need Help?

- **GitHub Issues:** https://github.com/microsoft/coe-starter-kit/issues
- **Community Forum:** https://powerusers.microsoft.com/t5/Power-Apps-Governance-and/bd-p/Admin_PowerApps
- **Microsoft Support:** Open a ticket via Power Platform Admin Center

---

**Version:** 4.50.7+  
**Last Updated:** January 2026
