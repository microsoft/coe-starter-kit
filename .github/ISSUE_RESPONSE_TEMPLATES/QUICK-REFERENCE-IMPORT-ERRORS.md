# Quick Reference: Solution Import Error Resolution

## Error 80097376 - BadGateway

**Meaning**: Temporary connectivity issue with Flow service  
**Solution**: Wait 5-10 minutes and retry the import

**Steps**:
1. Wait 5-10 minutes
2. Delete partially imported solution (if exists)
3. Re-import the solution
4. If persists: Check [Service Health](https://admin.microsoft.com/servicehealth)
5. If persists: Import during off-peak hours

---

## Error 80072031 - Operation Status Unknown

**Meaning**: Import may have succeeded but status not reported  
**Solution**: Check if solution imported, then retry if needed

**Steps**:
1. Check if solution appears in Solutions list
2. Verify version number is correct
3. If not present: Wait 5-10 minutes and retry
4. If partial import: Delete and retry
5. As message says: "You can safely retry the operation"

---

## General Import Troubleshooting

### Pre-Import Checklist
- [ ] English language pack enabled
- [ ] Premium license (not trial)
- [ ] System Administrator role
- [ ] Sufficient storage capacity
- [ ] Prerequisites installed

### During Import
- ⏸️ Don't navigate away
- 🚫 Don't interrupt the process
- 📸 Screenshot any errors
- ⏱️ Allow 30-60 minutes for large solutions

### If Import Fails
1. **Wait**: 5-10 minutes minimum
2. **Check**: Service health dashboard
3. **Clean**: Delete partial import
4. **Retry**: Re-import the solution
5. **Timing**: Try off-peak hours if needed

---

## PowerShell Alternative

If UI import fails repeatedly:

```powershell
# Authenticate
pac auth create --url https://yourorg.crm.dynamics.com

# Import
pac solution import --path "SolutionName_managed.zip" --async
```

---

## Production Upgrade Best Practices

✅ Test in non-production first  
✅ Schedule maintenance window  
✅ Disable flows before upgrade  
✅ Backup environment variables  
✅ Allow 2-4 hours  
✅ Import during off-peak hours  

---

## When to Get Help

**Retry if**: First or second import failure  
**Check service health if**: Multiple retries fail  
**Contact Microsoft Support if**: Errors persist 24+ hours  
**Post on GitHub if**: Potential code bug  

---

## Links

📖 [Full Troubleshooting Guide](../../CenterofExcellenceResources/Release/Notes/CoEStarterKit/TROUBLESHOOTING-IMPORT-ERRORS.md)  
📋 [Known Issues](../../CenterofExcellenceResources/Release/Notes/CoEStarterKit/KNOWN-ISSUES.md)  
🏥 [Service Health](https://admin.microsoft.com/servicehealth)  
📚 [Setup Docs](https://docs.microsoft.com/power-platform/guidance/coe/setup)  
🐛 [GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues)  

---

**Remember**: Most import errors are transient. Wait and retry is the #1 solution.
