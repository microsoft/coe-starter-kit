# Quick Start Guide for Contributors

## Contributing to Connection References and Environment Variables Enhancement

Want to help implement these features? This guide gets you started quickly!

## Prerequisites

### Required Knowledge
- ✅ Basic Power Platform development experience
- ✅ Familiarity with Dataverse or Model-Driven Apps (helpful, but not required)
- ✅ Git/GitHub basics

### Required Tools
- Power Platform admin account with CoE Starter Kit installed (or access to dev environment)
- Git installed locally
- Code editor (VS Code recommended)
- Power Platform CLI (optional, but helpful)

## Quick Setup (15 minutes)

### 1. Fork and Clone
```bash
# Fork the repository on GitHub first, then:
git clone https://github.com/YOUR-USERNAME/coe-starter-kit.git
cd coe-starter-kit
git checkout -b feature/connection-references-env-vars
```

### 2. Review Key Files
Navigate to the Core Components directory:
```bash
cd CenterofExcellenceCoreComponents/SolutionPackage/src
```

Key locations:
- **Entities**: `Entities/admin_ConnectionReference/`
- **Sitemap**: `AppModuleSiteMaps/admin_PowerPlatformAdminView/`
- **Views**: `Entities/admin_ConnectionReference/SavedQueries/`
- **Forms**: `Entities/admin_ConnectionReference/FormXml/`

## Choose Your Contribution Path

### Path A: Easy First Contribution (1-2 hours)
**Add Connection References Menu Item to Sitemap**

#### What You'll Do
Add a new menu item to make Connection References easily accessible.

#### Steps
1. Open `AppModuleSiteMaps/admin_PowerPlatformAdminView/AppModuleSiteMap.xml`
2. Find the "Connectors" SubArea (around line 25-29)
3. Add this code right after it:

```xml
<SubArea Id="NewSubArea_ConnectionReferences" 
         VectorIcon="/WebResources/admin_ConnectorIcon" 
         Icon="/WebResources/admin_ConnectorIcon" 
         Entity="admin_connectionreference" 
         Client="All,Outlook,OutlookLaptopClient,OutlookWorkstationClient,Web" 
         AvailableOffline="true" 
         PassParams="false" 
         Sku="All,OnPremise,Live,SPLA">
  <Titles>
    <Title LCID="1033" Title="Connection References" />
  </Titles>
</SubArea>
```

4. Save the file
5. Test by importing the solution to a dev environment
6. Commit and create a PR!

```bash
git add .
git commit -m "Add Connection References menu item to Power Platform Admin View"
git push origin feature/connection-references-env-vars
```

### Path B: Intermediate Contribution (2-4 hours)
**Create Enhanced View for Connection References**

#### What You'll Do
Create a better view that shows the right information about connection references.

#### Steps
1. Navigate to `Entities/admin_ConnectionReference/SavedQueries/`
2. Generate a new GUID for your view:
   - Online tool: https://www.uuidgenerator.net/
   - Or use: `New-Guid` in PowerShell
3. Create a new file: `{YOUR-NEW-GUID}.xml`
4. Copy this template:

```xml
<?xml version="1.0" encoding="utf-8"?>
<savedqueries xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <savedquery>
    <IsCustomizable>1</IsCustomizable>
    <CanBeDeleted>1</CanBeDeleted>
    <isquickfindquery>0</isquickfindquery>
    <isprivate>0</isprivate>
    <isdefault>1</isdefault>
    <savedqueryid>{YOUR-NEW-GUID}</savedqueryid>
    <layoutxml>
      <grid name="resultset" jump="admin_displayname" select="1" icon="1" preview="1">
        <row name="result" id="admin_connectionreferenceid">
          <cell name="admin_displayname" width="200" />
          <cell name="admin_connector" width="150" />
          <cell name="ownerid" width="150" />
          <cell name="createdon" width="125" />
        </row>
      </grid>
    </layoutxml>
    <querytype>0</querytype>
    <fetchxml>
      <fetch version="1.0" mapping="logical">
        <entity name="admin_connectionreference">
          <attribute name="admin_connectionreferenceid" />
          <attribute name="admin_displayname" />
          <attribute name="admin_connector" />
          <attribute name="ownerid" />
          <attribute name="createdon" />
          <order attribute="admin_displayname" descending="false" />
          <filter type="and">
            <condition attribute="statecode" operator="eq" value="0" />
          </filter>
        </entity>
      </fetch>
    </fetchxml>
    <IntroducedVersion>1.0</IntroducedVersion>
    <LocalizedNames>
      <LocalizedName description="Active Connection References" languagecode="1033" />
    </LocalizedNames>
  </savedquery>
</savedqueries>
```

5. Test by importing to dev environment
6. Commit and create PR!

### Path C: Advanced Contribution (1-2 days)
**Create Environment Variables Entity**

#### What You'll Do
Build the new entity for tracking environment variables.

#### Steps
1. Review the detailed entity structure in [Implementation Guide](./IMPLEMENTATION-GUIDE-CONNECTION-REFERENCES-ENV-VARS.md) - Step 2.1
2. Create directory: `Entities/admin_EnvironmentVariableDefinition/`
3. Create `Entity.xml` with the structure from the guide
4. Create sub-directories:
   - `FormXml/main/`
   - `FormXml/card/`
   - `FormXml/quick/`
   - `SavedQueries/`
5. Build forms and views following CoE patterns
6. Test thoroughly in dev environment
7. Document your changes
8. Create PR with screenshots!

## Testing Your Changes

### Local Testing (Before PR)
1. **Export the solution** from your CoE environment
2. **Apply your changes** to the exported solution files
3. **Re-import** to a test environment
4. **Verify**:
   - Menu items appear correctly
   - Views display expected data
   - Forms load without errors
   - No impact on existing functionality

### What to Test
- [ ] Menu navigation works
- [ ] Views load and display data
- [ ] Forms open and save correctly
- [ ] Existing features still work
- [ ] No console errors
- [ ] Performance is acceptable

## Creating Your Pull Request

### PR Checklist
Before submitting, ensure:
- [ ] Code follows existing patterns in the repo
- [ ] XML is well-formed and indented consistently
- [ ] You've tested in a dev environment
- [ ] You've documented what you changed
- [ ] You've included screenshots if UI changes
- [ ] You've linked to the original issue

### PR Template
```markdown
## Description
Brief description of what you implemented.

## Changes Made
- Added Connection References menu item to sitemap
- Created new view showing [specific fields]
- Updated form to include [specific changes]

## Testing Done
- Tested in dev environment with [X] connection references
- Verified menu navigation
- Confirmed no impact to existing features

## Screenshots
[Add screenshots showing your changes]

## Related Issue
Closes #[issue-number]

## Checklist
- [ ] Code follows repository patterns
- [ ] Tested in dev environment
- [ ] Documentation updated (if needed)
- [ ] Screenshots included (if UI changes)
```

## Getting Help

### Stuck? Here's What to Do

**1. Check the Documentation**
- [Implementation Guide](./IMPLEMENTATION-GUIDE-CONNECTION-REFERENCES-ENV-VARS.md) - Detailed technical steps
- [Feature Summary](./FEATURE-ENHANCEMENT-SUMMARY.md) - High-level overview

**2. Look at Similar Code**
- Browse `Entities/admin_Flow/` for entity examples
- Check `Entities/admin_Connector/` for similar patterns
- Review existing views in any `SavedQueries/` folder

**3. Ask Questions**
- Comment on the GitHub issue
- Post in Power Platform Community forums
- Tag @coe-starter-kit maintainers

**4. Start Small**
- Begin with the sitemap menu item (easiest)
- Move to views (medium)
- Then tackle entity creation (advanced)

## Common Patterns in CoE Starter Kit

### Entity Naming
- Use `admin_` prefix for all custom entities
- Use PascalCase for entity names
- Example: `admin_ConnectionReference`, `admin_EnvironmentVariableDefinition`

### Field Naming
- Use `admin_` prefix for custom fields
- Use lowercase for logical names
- Example: `admin_displayname`, `admin_schemaname`

### GUID Generation
Always generate new GUIDs for:
- New entities
- New forms
- New views
- New fields

Never reuse existing GUIDs!

### XML Formatting
- Use 2 spaces for indentation (consistent with existing files)
- Close all tags properly
- Include XML declaration: `<?xml version="1.0" encoding="utf-8"?>`

## Pro Tips

### 1. Use a Dev Environment
Always test in a non-production environment first!

### 2. Small PRs Are Better
Consider submitting multiple small PRs instead of one large one:
- PR 1: Sitemap changes
- PR 2: View updates
- PR 3: Entity creation

This makes review easier and faster.

### 3. Follow Existing Patterns
The CoE Starter Kit has established patterns. Copy existing code structure and modify rather than starting from scratch.

### 4. Document Your Work
Add comments in your PR explaining:
- What you changed
- Why you made that choice
- Any trade-offs or limitations

### 5. Screenshots Are Valuable
Include screenshots showing:
- Menu navigation
- View layout
- Form design
- Error messages (if debugging)

## Contribution Timeline

| Phase | What | When | Who |
|-------|------|------|-----|
| ✅ Analysis | Requirements & design | Complete | @copilot |
| 📝 Phase 1 | Connection References | Ready to start | You? |
| 📝 Phase 2 | Environment Variables | After Phase 1 | You? |
| ⏳ Testing | Validation & feedback | After implementation | Community |
| ⏳ Release | Include in CoE Kit | After testing | Maintainers |

## Quick Reference Links

### Documentation
- [Implementation Guide](./IMPLEMENTATION-GUIDE-CONNECTION-REFERENCES-ENV-VARS.md)
- [Feature Summary](./FEATURE-ENHANCEMENT-SUMMARY.md)
- [GitHub Issue Response](./GITHUB-ISSUE-RESPONSE.md)

### External Resources
- [CoE Starter Kit Docs](https://learn.microsoft.com/en-us/power-platform/guidance/coe/starter-kit)
- [Connection References Docs](https://learn.microsoft.com/en-us/power-apps/maker/data-platform/create-connection-reference)
- [Environment Variables Docs](https://learn.microsoft.com/en-us/power-apps/maker/data-platform/environmentvariables)
- [Dataverse Web API](https://learn.microsoft.com/en-us/power-apps/developer/data-platform/webapi/overview)

### Tools
- [GUID Generator](https://www.uuidgenerator.net/)
- [XML Formatter](https://www.freeformatter.com/xml-formatter.html)
- [Power Platform CLI](https://learn.microsoft.com/en-us/power-platform/developer/cli/introduction)

## Ready to Start?

1. Pick your contribution path (A, B, or C)
2. Set up your environment
3. Make your changes
4. Test thoroughly
5. Submit your PR
6. Celebrate! 🎉

Thank you for contributing to the CoE Starter Kit! Every contribution, no matter how small, helps the entire Power Platform community.

---

**Questions?** Open an issue or comment on the feature request!
**Stuck?** Check the documentation or ask for help!
**Excited?** Let's build this together! 🚀
