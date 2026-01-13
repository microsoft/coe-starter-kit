# Issue Response Templates - Quick Reference

This directory contains response templates for common CoE Starter Kit issues. Use these templates when responding to GitHub issues to provide consistent, helpful guidance.

## Available Templates

### Power BI and Data Issues

1. **[Environment Capacity Incomplete Data](environment-capacity-incomplete-data.md)**
   - **Use when**: Environment Capacity report shows fewer environments than expected
   - **Common cause**: Service account licensing limitations
   - **Key fix**: Verify and upgrade service account license

## How to Use These Templates

1. Identify the issue type from the user's GitHub issue
2. Find the matching template in this directory
3. Copy the relevant sections to your response
4. Customize with specific details from the user's issue
5. Add any additional context or questions as needed

## General Response Guidelines

When responding to CoE Starter Kit issues:

### Always Include
- ✅ Summary of the issue in your own words
- ✅ Most likely root cause(s)
- ✅ Immediate troubleshooting steps
- ✅ Links to detailed documentation
- ✅ Request for additional information if needed
- ✅ Official resource links

### Best Practices
- Be empathetic and understanding
- Provide actionable steps, not just explanations
- Link to official Microsoft documentation when available
- Reference similar resolved issues if applicable
- Set expectations about support level (best-effort, community-driven)

### Avoid
- ❌ Assuming the user's environment or setup
- ❌ Providing only high-level guidance without specifics
- ❌ Ignoring the user's specific symptoms
- ❌ Over-promising support or SLAs

## Common CoE Starter Kit Issues (Quick Ref)

| Issue | Template | Key Troubleshooting |
|-------|----------|---------------------|
| Power BI shows incomplete environment data | [environment-capacity-incomplete-data.md](environment-capacity-incomplete-data.md) | Check service account license, verify sync flows |
| Apps/Flows missing from reports | (Same as above) | Check child sync flows, verify inventory settings |
| Flow timeouts | TBD | Review tenant size, consider batching |
| Connection errors | TBD | Recreate connections, verify permissions |
| Setup wizard issues | TBD | Follow setup documentation step-by-step |

## Contributing

If you frequently respond to a specific type of issue, consider:
1. Creating a new template in this directory
2. Documenting the common causes and solutions
3. Linking to existing troubleshooting guides
4. Submitting a PR to add the template

## Related Documentation

- [TROUBLESHOOTING-POWERBI-INCOMPLETE-DATA.md](../../TROUBLESHOOTING-POWERBI-INCOMPLETE-DATA.md)
- [TROUBLESHOOTING-ENVIRONMENT-CAPACITY-POWERBI.md](../../TROUBLESHOOTING-ENVIRONMENT-CAPACITY-POWERBI.md)
- [Official CoE Starter Kit Documentation](https://learn.microsoft.com/en-us/power-platform/guidance/coe/starter-kit)
