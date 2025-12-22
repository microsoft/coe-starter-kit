# Troubleshooting: aka.ms/CoeStarterKitDownload Link Issues

## Problem Description

Users may experience issues where the `aka.ms/CoeStarterKitDownload` link downloads outdated solution versions that don't match the latest release announced on GitHub.

## Symptoms

- Downloaded solution files show older version numbers than expected
- Solution import shows no updates available despite a new release being announced
- File names in the downloaded zip show previous release dates
- Release notes mention newer versions but installed versions remain unchanged

## Root Cause

The `aka.ms/CoeStarterKitDownload` redirect link is managed separately from the GitHub release process and requires manual updating. If this step is missed during the release process, users will continue to download the previous version.

## Immediate Workaround for Users

If you suspect the aka.ms link is pointing to an outdated version, use one of these alternatives:

### Option 1: Download from GitHub Releases (Recommended)

1. Go to the [CoE Starter Kit Releases page](https://github.com/microsoft/coe-starter-kit/releases)
2. Select the latest release (it will be marked as "Latest")
3. Download the `CoEStarterKit.zip` file from the Assets section
4. Proceed with your installation/upgrade

### Option 2: Use Direct GitHub Download URL

You can construct the direct download URL using this pattern:
```
https://github.com/microsoft/coe-starter-kit/releases/download/CoEStarterKit-[MonthYear]/CoEStarterKit.zip
```

Example for December 2025:
```
https://github.com/microsoft/coe-starter-kit/releases/download/CoEStarterKit-December2025/CoEStarterKit.zip
```

### Option 3: Download Individual Solution Files

If you only need specific solutions, you can download them individually from the release assets:
- `CenterofExcellenceCoreComponents_[version]_managed.zip`
- `CenterofExcellenceAuditComponents_[version]_managed.zip`
- `CenterofExcellenceNurtureComponents_[version]_managed.zip`
- And others...

## Verification Steps

To verify you have the correct version after download:

1. Extract the downloaded zip file
2. Check the solution file names - they should match the version numbers listed in the release notes
3. If importing via the Power Platform admin center, check the solution history after import to confirm the new version number

## Expected Solution Versions by Release

Refer to the [Release Notes](https://github.com/microsoft/coe-starter-kit/releases) for the expected version numbers of each component in a release.

### Example: December 2025 Release

According to the December 2025 release notes:
- Core Components: 4.50.7
- Audit Components: 3.27.6
- Nurture Components: 3.20.3 (unchanged)
- Innovation Backlog: 3.1 (unchanged)

## Reporting This Issue

If you encounter this issue:

1. File a bug report using the [CoE Starter Kit Bug template](https://github.com/microsoft/coe-starter-kit/issues/new/choose)
2. Include:
   - The date you downloaded from aka.ms/CoeStarterKitDownload
   - The version numbers you received
   - The release you expected to get
   - Screenshots of the downloaded files or solution history

## For CoE Starter Kit Maintainers

If this issue is reported:

1. Verify the aka.ms redirect is pointing to the correct release
2. Update the redirect if needed following the [Release Process](RELEASE_PROCESS.md)
3. Test the link after updating
4. Respond to the issue with confirmation the link is now fixed
5. Consider adding automated testing for aka.ms link validation in the future

## Prevention

This issue can be prevented by:

1. Following the complete [Release Process](RELEASE_PROCESS.md) checklist
2. Including aka.ms link update as a required step before marking a release as complete
3. Adding automated testing or alerts for link validation
4. Documenting the aka.ms account owner and backup contacts

## Related Documentation

- [Release Process](RELEASE_PROCESS.md) - Complete release process with aka.ms update steps
- [GitHub Releases](https://github.com/microsoft/coe-starter-kit/releases) - All official releases
- [Microsoft Learn Documentation](https://learn.microsoft.com/en-us/power-platform/guidance/coe/after-setup) - Setup and upgrade documentation
