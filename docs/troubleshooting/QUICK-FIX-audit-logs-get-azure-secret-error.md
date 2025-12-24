# Quick Fix: Office 365 Management API Subscription Flow - "Get_Azure_Secret" Error

## Problem
Flow fails with: `Action 'Get_Azure_Secret' failed. Error occurred while reading secret: Value cannot be null. Parameter name: input`

## Quick Checklist

- [ ] **Check environment variables exist** (Solutions > Center of Excellence - Core Components > Environment variables):
  - [ ] `admin_auditlogsclientid`
  - [ ] `admin_auditlogsclientazuresecret` OR `admin_auditlogsclientsecret`
  - [ ] `admin_TenantID`
  - [ ] `admin_AuditLogsAudience`
  - [ ] `admin_AuditLogsAuthority`

- [ ] **Verify environment variables have values** (not empty)

- [ ] **Azure AD App Registration** is configured:
  - [ ] App is registered in Azure AD
  - [ ] API Permissions added: `ActivityFeed.Read`, `ActivityFeed.ReadDlp`, `ServiceHealth.Read`
  - [ ] Admin consent granted
  - [ ] Client secret created and not expired

- [ ] **Environment variables configured** with correct values:
  - [ ] `admin_auditlogsclientid` = Application (Client) ID from Azure AD
  - [ ] `admin_auditlogsclientsecret` = Client Secret value (for text-based) OR
  - [ ] `admin_auditlogsclientazuresecret` = Azure Key Vault secret reference (for Key Vault-based)
  - [ ] `admin_TenantID` = Your Azure Tenant ID

- [ ] **Cloud-specific endpoints** are correct:
  - Commercial: `https://manage.office.com` / `https://login.windows.net`
  - GCC: `https://manage.office365.us` / `https://login.microsoftonline.us`

- [ ] **Prerequisites met**:
  - [ ] Unified Audit Log enabled in Microsoft Purview
  - [ ] Appropriate licenses (O365/M365 E3 or E5)
  - [ ] Required admin permissions

## Fastest Fix

If you need the flow working immediately:

1. Create a **client secret** in your Azure AD app (Azure Portal > App registrations > Your App > Certificates & secrets)
2. Set environment variable `admin_auditlogsclientsecret` to the secret value (text-based, simpler setup)
3. Set environment variable `admin_auditlogsclientid` to your Application (Client) ID
4. Set environment variable `admin_TenantID` to your Tenant ID
5. Rerun the flow

**Note**: For production, migrate to Azure Key Vault (`admin_auditlogsclientazuresecret`) for better security.

## Detailed Guide

For complete troubleshooting steps, see: [Full Troubleshooting Guide](audit-logs-office365-management-api-subscription-flow-errors.md)

## Common Mistake

The error "Value cannot be null" typically means the environment variable itself doesn't exist or is empty, not that the secret retrieval failed. Check the environment variable exists first before troubleshooting other areas.
