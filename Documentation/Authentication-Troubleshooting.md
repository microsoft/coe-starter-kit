# Authentication Troubleshooting Guide for CoE Starter Kit

This guide helps troubleshoot authentication issues with app registrations used in the CoE Starter Kit, whether using client secrets, certificates, or preparing for Workload Identity Federation.

## Common Issues and Solutions

### Issue 1: Flow Authentication Failures

**Symptoms:**
- Flows fail with "401 Unauthorized" errors
- Connection authentication errors in flow run history
- "The remote server returned an error: (401) Unauthorized" in HTTP actions

**Possible Causes:**
1. Expired client secret
2. Incorrect environment variable values
3. App registration permissions changed
4. Service principal disabled or deleted

**Troubleshooting Steps:**

```
Step 1: Check Secret Expiration
1. Go to Azure Portal → Azure Active Directory → App registrations
2. Select your app registration
3. Go to "Certificates & secrets"
4. Check "Client secrets" expiration dates
   ✅ Valid if "Expires" date is in the future
   ❌ Invalid if "Expired" or red warning icon

Step 2: Verify Environment Variables
1. Go to Power Platform Admin Center
2. Open your CoE environment
3. Go to Settings → Environment variables
4. Check these variables:
   - Audit Logs – Client Azure Secret (should reference Key Vault)
   - Audit Logs – Client ID (should match app registration)
   - Audit Logs – Tenant ID (should match your tenant)
   - Command Center variables (similar)
   ✅ Values should not be blank or "n/a"

Step 3: Test Azure Key Vault Access
1. Go to Azure Portal → Key Vault
2. Select your Key Vault
3. Go to "Secrets"
4. Find your client secret
5. Check:
   - Secret exists and is enabled
   - Expiration date (if set)
   - Access policies allow Power Platform to read
   ✅ Secret should be enabled and accessible

Step 4: Verify App Registration Permissions
1. Azure Portal → App registrations → Your app
2. Go to "API permissions"
3. Verify required permissions:
   
   For Office 365 Management API:
   - Office 365 Management APIs: ActivityFeed.Read
   
   For Microsoft Graph:
   - Microsoft Graph: User.Read.All
   - Microsoft Graph: Group.Read.All
   - Microsoft Graph: Directory.Read.All (if needed)
   
4. Check "Status" column shows "Granted for [tenant]"
   ❌ If not granted, admin consent is required

Step 5: Check Service Principal Status
1. Azure Portal → Azure Active Directory → Enterprise applications
2. Search for your app by name or Application ID
3. Go to "Properties"
4. Check "Enabled for users to sign-in?" is "Yes"
   ✅ Should be "Yes"
   ❌ If "No", enable it
```

**Solutions:**
- **Expired Secret**: Rotate the secret immediately (see Secret Rotation below)
- **Wrong Variables**: Update environment variables with correct values
- **Missing Permissions**: Request admin consent for required API permissions
- **Disabled Principal**: Re-enable in Enterprise Applications

---

### Issue 2: Secret Rotation Causes Downtime

**Symptoms:**
- Flows work before secret rotation but fail after
- Some flows work, others don't
- Intermittent authentication failures

**Possible Causes:**
1. Environment variables not updated
2. Multiple environments using different secrets
3. Cached connections not refreshed
4. Old secret deleted too quickly

**Troubleshooting Steps:**

```
Step 1: Verify All Environment Variables Updated
1. List all environments using CoE Starter Kit
2. For each environment:
   - Check environment variables reference correct Key Vault secret
   - Verify secret name hasn't changed
   - Confirm values are not cached

Step 2: Refresh Connections
1. Go to Power Automate → Data → Connections
2. Find connections related to app registrations:
   - HTTP with Azure AD
   - Custom connectors
3. Options:
   - Edit connection and re-authenticate
   - Or delete and recreate connection
   
Step 3: Check Flow Connection References
1. Open affected flow
2. Edit flow
3. Check each action using authentication
4. Verify connection is not showing error icon
5. Re-select connection if needed

Step 4: Verify Key Vault Secret
1. Azure Portal → Key Vault
2. Check secret versions
3. Ensure latest version is enabled
4. Verify old version is still available (for 24-48 hours)
```

**Best Practices for Secret Rotation:**
```
Day 1: Generate and Add New Secret
- Create new client secret in app registration
- Add to Key Vault with descriptive version/name
- Do NOT update environment variables yet
- Do NOT delete old secret

Day 2-3: Update and Test
- Update environment variables to reference new secret
- Test critical flows
- Monitor for failures
- Keep old secret active as fallback

Day 4-5: Cleanup
- Confirm all flows working with new secret
- Disable (but don't delete) old secret
- Monitor for 24 hours
- Only then delete old secret
```

---

### Issue 3: Azure Key Vault Access Denied

**Symptoms:**
- "Access denied" when flows try to read secrets
- "The specified secret was not found" errors
- KeyVault operation failed errors

**Possible Causes:**
1. Power Platform service principal lacks access policy
2. Key Vault firewall blocking access
3. Secret name mismatch
4. Key Vault soft-deleted

**Troubleshooting Steps:**

```
Step 1: Verify Access Policies
1. Azure Portal → Key Vault → Access policies
2. Check if Power Platform service principal has access:
   - Look for "Microsoft.PowerApps" or "Microsoft.PowerAutomate"
   - Or specific managed identity if using one
3. Required permissions:
   ✅ Secret permissions: Get, List
   ❌ Don't need: Set, Delete (unless for rotation automation)

Step 2: Check Network Settings
1. Key Vault → Networking
2. Verify:
   - "Allow trusted Microsoft services" is enabled
   - Or specific IP ranges include Power Platform IPs
   - Or "Allow all networks" (least secure, not recommended)

Step 3: Verify Secret Name
1. Key Vault → Secrets
2. Note exact secret name (case-sensitive)
3. In Power Platform environment variables:
   - Check secret URI is correct
   - Format: https://{vault-name}.vault.azure.net/secrets/{secret-name}
   - Or just secret name if using Key Vault reference

Step 4: Check Key Vault Status
1. Key Vault → Overview
2. Verify Status is "Available"
3. Check for any alerts or warnings
4. If Key Vault was deleted:
   - Go to Key Vault → Manage deleted vaults
   - Recover if within retention period
```

**Solutions:**
- **Missing Access**: Add Power Platform service principal to access policies
- **Network Blocked**: Configure network rules to allow Power Platform
- **Wrong Name**: Update environment variable with correct secret name/URI
- **Deleted Vault**: Recover from soft-delete or recreate

---

### Issue 4: App Registration Permissions Not Working

**Symptoms:**
- Flows fail with "Insufficient privileges" errors
- "Access is denied" when calling Microsoft Graph
- Office 365 Management API returns 403 Forbidden

**Possible Causes:**
1. Admin consent not granted
2. Permissions removed or changed
3. Conditional access policies blocking
4. API license requirements not met

**Troubleshooting Steps:**

```
Step 1: Verify Admin Consent
1. App registration → API permissions
2. Check "Status" column
   ✅ Should show: "Granted for [your tenant name]"
   ❌ If blank or "Not granted": Consent required

Step 2: Grant Admin Consent
1. Click "Grant admin consent for [tenant]" button
2. Confirm with Global Admin or Application Admin account
3. Wait 5-10 minutes for replication
4. Refresh page to verify status

Step 3: Check for Permission Changes
1. Review recent changes in Azure AD audit logs:
   - Azure Portal → Azure AD → Audit logs
   - Filter: Service = "Core Directory"
   - Activity = "Update application" or "Consent to application"
2. Verify no permissions were removed

Step 4: Test API Access Directly
Using PowerShell or Postman:
```powershell
# Get access token
$tenantId = "your-tenant-id"
$clientId = "your-client-id"
$clientSecret = "your-client-secret"

$body = @{
    grant_type    = "client_credentials"
    client_id     = $clientId
    client_secret = $clientSecret
    scope         = "https://graph.microsoft.com/.default"
}

$token = Invoke-RestMethod -Method Post -Uri "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token" -Body $body
$token.access_token

# Test API call
$headers = @{
    Authorization = "Bearer $($token.access_token)"
}
Invoke-RestMethod -Method Get -Uri "https://graph.microsoft.com/v1.0/users" -Headers $headers
```

```
Step 5: Check Conditional Access
1. Azure Portal → Azure AD → Security → Conditional Access
2. Review policies
3. Check if any policies block:
   - Service principals
   - Specific applications
   - API access from Power Platform IPs
```

**Solutions:**
- **No Consent**: Grant admin consent with appropriate admin role
- **Removed Permissions**: Re-add required API permissions and grant consent
- **Conditional Access**: Adjust policies or add exceptions for service principals
- **License Issues**: Ensure tenant has required licenses for APIs being accessed

---

### Issue 5: Preparing for Workload Identity Federation

**Symptoms:**
- Organization mandating WIF migration
- Need to test WIF compatibility
- Planning migration timeline

**Preparation Steps:**

```
Step 1: Inventory Current Setup
Document:
- All app registrations used by CoE Kit
- Environment variables referencing secrets
- Flows using each app registration
- Key Vault secrets and their locations
- Permissions granted to each app

Step 2: Check Platform Readiness
1. Review Microsoft documentation for WIF support:
   - Power Platform connector capabilities
   - Managed Identity support status
2. Test in development environment if preview available
3. Document any limitations found

Step 3: Plan Migration Approach
Choose strategy:
1. Wait for GA (recommended for most)
2. Hybrid with Azure Functions (for early adopters)
3. Certificate-based auth (alternative)

Step 4: Set Up Monitoring
Before migration:
- Enable Azure AD sign-in logs
- Set up Application Insights for flows
- Document baseline performance
- Create rollback procedures

Step 5: Create Test Environment
1. Duplicate production setup in test
2. Use separate app registrations
3. Test WIF configuration
4. Document results and issues
5. Update procedures
```

---

## Quick Diagnostic Checklist

Use this checklist to quickly identify authentication issues:

```
[ ] Secret Expiration
    - Azure Portal → App registrations → Certificates & secrets
    - Check all secrets for expiration dates
    
[ ] Environment Variables
    - Power Platform → Environment → Settings → Environment variables
    - Verify all authentication variables have values
    
[ ] Key Vault Access
    - Azure Portal → Key Vault → Access policies
    - Confirm Power Platform has Get/List secret permissions
    
[ ] API Permissions
    - Azure Portal → App registrations → API permissions
    - Status should show "Granted for [tenant]"
    
[ ] Service Principal Status
    - Azure Portal → Enterprise applications
    - "Enabled for users to sign-in?" should be "Yes"
    
[ ] Connection Status
    - Power Automate → Data → Connections
    - All connections should show green checkmark
    
[ ] Flow Run History
    - Open failed flow
    - Check run history for specific error messages
    - Review failed action details
```

## Error Message Reference

| Error Message | Likely Cause | Quick Fix |
|--------------|--------------|-----------|
| "401 Unauthorized" | Expired secret or wrong credentials | Rotate secret, verify environment variables |
| "403 Forbidden" | Missing permissions or no admin consent | Grant admin consent, check API permissions |
| "404 Not Found" | Wrong API endpoint or resource deleted | Verify endpoints, check app registration exists |
| "KeyVault operation failed" | Key Vault access issue | Check access policies and network rules |
| "Invalid client secret" | Secret doesn't match or expired | Generate new secret, update Key Vault |
| "AADSTS700016: Application not found" | App registration deleted or wrong tenant | Verify Application ID and tenant ID |
| "Insufficient privileges" | Missing API permissions | Add required permissions and grant consent |
| "ConsentNotGranted" | Admin consent not provided | Grant admin consent in Azure Portal |

## PowerShell Diagnostic Script

Use this script to quickly check app registration health:

```powershell
# CoE Kit App Registration Health Check
# Requires Azure AD PowerShell module: Install-Module AzureAD

param(
    [Parameter(Mandatory=$true)]
    [string]$ApplicationId,
    
    [Parameter(Mandatory=$true)]
    [string]$TenantId
)

# Connect to Azure AD
Connect-AzureAD -TenantId $TenantId

# Get application
$app = Get-AzureADApplication -Filter "AppId eq '$ApplicationId'"

if ($null -eq $app) {
    Write-Host "❌ Application not found!" -ForegroundColor Red
    exit
}

Write-Host "✅ Application found: $($app.DisplayName)" -ForegroundColor Green

# Check service principal
$sp = Get-AzureADServicePrincipal -Filter "AppId eq '$ApplicationId'"

if ($null -eq $sp) {
    Write-Host "❌ Service Principal not found!" -ForegroundColor Red
} else {
    Write-Host "✅ Service Principal exists" -ForegroundColor Green
    Write-Host "   Enabled: $($sp.AccountEnabled)" -ForegroundColor $(if($sp.AccountEnabled){"Green"}else{"Red"})
}

# Check secrets
$secrets = Get-AzureADApplicationPasswordCredential -ObjectId $app.ObjectId

Write-Host "`nClient Secrets:" -ForegroundColor Cyan
if ($secrets.Count -eq 0) {
    Write-Host "⚠️  No client secrets found" -ForegroundColor Yellow
} else {
    foreach ($secret in $secrets) {
        $daysUntilExpiry = ($secret.EndDate - (Get-Date)).Days
        if ($daysUntilExpiry -lt 0) {
            Write-Host "❌ Secret expired $(-$daysUntilExpiry) days ago" -ForegroundColor Red
        } elseif ($daysUntilExpiry -lt 30) {
            Write-Host "⚠️  Secret expires in $daysUntilExpiry days" -ForegroundColor Yellow
        } else {
            Write-Host "✅ Secret valid for $daysUntilExpiry days" -ForegroundColor Green
        }
    }
}

# Check permissions
$permissions = Get-AzureADApplicationServiceEndpointOwner -ObjectId $app.ObjectId

Write-Host "`nRequired Permissions:" -ForegroundColor Cyan
$requiredResources = $app.RequiredResourceAccess
foreach ($resource in $requiredResources) {
    $resourceApp = Get-AzureADServicePrincipal -Filter "AppId eq '$($resource.ResourceAppId)'"
    Write-Host "  Resource: $($resourceApp.DisplayName)" -ForegroundColor White
    Write-Host "  Permissions: $($resource.ResourceAccess.Count)" -ForegroundColor White
}

Write-Host "`n✅ Health check complete" -ForegroundColor Green
```

## Additional Resources

- [Workload Identity Federation Quick Reference](WIF-Quick-Reference.md)
- [Workload Identity Federation Migration Guide](WorkloadIdentityFederationMigration.md)
- [CoE Starter Kit Setup Guide](https://learn.microsoft.com/power-platform/guidance/coe/setup)
- [Azure AD Authentication Troubleshooting](https://learn.microsoft.com/azure/active-directory/develop/troubleshoot-authentication)

## Getting Help

If you're still experiencing issues after following this guide:

1. **Check existing issues**: [CoE Starter Kit GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues)
2. **Create new issue**: Use the appropriate issue template
3. **Include diagnostics**: Provide error messages, flow run IDs, and troubleshooting steps attempted
4. **Contact support**: For platform issues, contact Microsoft Support through Azure Portal

---

**Last Updated**: December 2024  
**Maintainer**: CoE Starter Kit Team
