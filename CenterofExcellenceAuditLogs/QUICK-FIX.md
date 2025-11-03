# Quick Fix: Azure Key Vault Permission Error

## ⚠️ Error You're Seeing

```
Error occurred while reading secret: Could not verify the user permission on 
'/subscriptions/.../resourceGroups/.../providers/Microsoft.KeyVault/vaults/.../secrets/...' 
resource. Make sure that Microsoft.PowerPlatform provider is registered in the Azure subscription.
```

## ✅ Solution (5 Minutes)

### Step 1: Register Microsoft.PowerPlatform Provider

**Via Azure Portal:**
1. Go to https://portal.azure.com
2. Navigate to **Subscriptions** → Select your subscription
3. Click **Resource providers** (left menu, under Settings)
4. Search for `Microsoft.PowerPlatform`
5. If status is "NotRegistered", select it and click **Register**
6. Wait 5-10 minutes for status to become **Registered**

**Via Azure CLI:**
```bash
az provider register --namespace Microsoft.PowerPlatform
```

**Via PowerShell:**
```powershell
Register-AzResourceProvider -ProviderNamespace Microsoft.PowerPlatform
```

### Step 2: Verify Key Vault Access

1. Go to your Key Vault in Azure Portal
2. Click **Access policies**
3. Verify `Microsoft.PowerPlatform` is listed with Get + List permissions
4. If not listed:
   - Click **Create**
   - Select Get + List under Secret permissions
   - Search for and select `Microsoft.PowerPlatform`
   - Click **Create**

### Step 3: Test the Fix

1. Wait 5-10 minutes after making changes
2. Go to your Power Automate flow
3. Click **Resubmit** on the failed run
4. Flow should now succeed ✅

## 📚 Full Documentation

For detailed troubleshooting and other issues, see:
- [Complete Troubleshooting Guide](./TROUBLESHOOTING.md)
- [Azure Key Vault Setup Guide](./AZURE-KEYVAULT-SETUP.md)

## 💡 Why This Happens

- The Microsoft.PowerPlatform resource provider must be registered in your Azure subscription
- This is a one-time setup per subscription
- Without it, Power Platform cannot access Key Vault resources
- This is independent of Key Vault access policies

## ⏱️ Timeline

- Provider registration: 5-10 minutes
- Changes to propagate: 5-10 minutes
- Total time: ~15-20 minutes

## ❓ Still Having Issues?

See [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) for:
- Invalid client secret errors
- Access denied errors
- Other Key Vault issues

---

**Related Issue**: #[issue-number]  
**Date**: 2025-11-03
