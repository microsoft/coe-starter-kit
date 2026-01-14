# CoE Starter Kit Release Process

This document outlines the steps required to complete a CoE Starter Kit release.

## Prerequisites

- Access to Azure DevOps pipeline for CoE Starter Kit
- GitHub repository access with release permissions
- Access to Microsoft's aka.ms link management system
- Access to Microsoft Learn documentation (if updates are needed)

## Release Steps

### 1. Execute Release Pipeline

Run the `create-github-release.yml` pipeline in Azure DevOps with the appropriate parameters:
- Set `ReleaseMonthNumber` and `ReleaseYearNumber`
- Configure `DraftRelease` (typically `true` for initial creation)
- Set other parameters as needed

The pipeline will:
- Download latest solution artifacts from production environments
- Package solutions into release assets
- Create a GitHub release draft
- Generate release notes from closed milestone issues

### 2. Review and Publish GitHub Release

1. Navigate to [GitHub Releases](https://github.com/microsoft/coe-starter-kit/releases)
2. Review the draft release created by the pipeline
3. Verify all solution files are attached with correct versions
4. Review and edit release notes if necessary
5. Publish the release

### 3. **Update aka.ms Redirect Link** ⚠️ CRITICAL STEP

After publishing the GitHub release, the `aka.ms/CoeStarterKitDownload` link MUST be updated to point to the new release.

#### Steps to Update aka.ms Link:

1. Navigate to the Microsoft aka.ms link management system (requires Microsoft internal access)
2. Locate the redirect for `aka.ms/CoeStarterKitDownload`
3. Update the target URL to point to the latest release's CoEStarterKit.zip file:
   ```
   https://github.com/microsoft/coe-starter-kit/releases/download/CoEStarterKit-[MonthYear]/CoEStarterKit.zip
   ```
   Example for December 2025:
   ```
   https://github.com/microsoft/coe-starter-kit/releases/download/CoEStarterKit-December2025/CoEStarterKit.zip
   ```
4. Test the aka.ms link to verify it redirects to the correct file
5. Verify the downloaded file contains the expected solution versions

### 4. Verify Documentation Links

Ensure the Microsoft Learn documentation references are accurate:
- [After Setup - Download Latest Solution](https://learn.microsoft.com/en-us/power-platform/guidance/coe/after-setup#download-the-latest-solution-file)
- [Setup Instructions](https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup)

The documentation should reference `aka.ms/CoeStarterKitDownload` which now points to the latest release.

### 5. Communicate Release

- Announce the release on appropriate channels (Power Platform Community, etc.)
- Update any internal documentation or wikis
- Notify stakeholders

## Post-Release Verification Checklist

- [ ] GitHub release is published and visible
- [ ] All solution files are attached to the release with correct versions
- [ ] Release notes are accurate and complete
- [ ] **aka.ms/CoeStarterKitDownload redirects to the latest release** ⚠️
- [ ] Downloaded zip file contains correct solution versions
- [ ] Microsoft Learn documentation links are working
- [ ] Release announcement has been made

## Troubleshooting

### aka.ms Link Not Updated

**Symptom**: Users report downloading old versions from aka.ms/CoeStarterKitDownload

**Root Cause**: The aka.ms redirect was not updated after the GitHub release was published

**Resolution**:
1. Follow step 3 above to update the aka.ms redirect
2. Test the link to verify it works
3. Respond to affected users with the direct GitHub release link as a workaround

### Direct Download Link (Workaround)

If the aka.ms link is not yet updated, users can download directly from:
```
https://github.com/microsoft/coe-starter-kit/releases/latest
```

Or from a specific release page:
```
https://github.com/microsoft/coe-starter-kit/releases
```

## Historical Context

The `aka.ms/CoeStarterKitDownload` link is referenced in:
- Microsoft Learn documentation
- GitHub release pipeline (issue closing comments)
- Community support responses
- Various setup guides

This makes it critical to update after each release to ensure users always get the latest version.

## Related Files

- Release Pipeline: `/CenterofExcellenceResources/Release/Pipelines/CoEStarterKit/create-github-release.yml`
- Release Collateral: `/CenterofExcellenceResources/Release/Collateral/CoEStarterKit/`
- Release Notes: `/CenterofExcellenceResources/Release/Notes/CoEStarterKit/RELEASENOTES.md`
