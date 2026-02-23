# GitHub Issue Response Template - aka.ms/CoEStarterKitDownload serves outdated build

Use when users report that the "Download the latest solution file" link (`https://aka.ms/CoEStarterKitDownload`) delivers an old drop (for example, Core 4.50.6) instead of the current release.

---

## Root cause

- The `aka.ms/CoEStarterKitDownload` short link is owned outside this repo and **is not updated by any release automation**. The only in-repo reference is an informational link in the GitHub release pipeline definition (CenterofExcellenceResources/Release/Pipelines/CoEStarterKit/create-github-release.yml, issueClosingComment) and no task updates the short link target.
- The current Core solution version (check CenterofExcellenceCoreComponents/SolutionPackage/src/Other/Solution.xml) is newer than the version delivered by the short link. The redirect was never refreshed after the latest release, so it still serves the previous drop.

## How to fix the live link

1. **Update the short link target** for `aka.ms/CoEStarterKitDownload` to point to the latest CoE Starter Kit release payload (use the current release asset, or more future-proof, `https://github.com/microsoft/coe-starter-kit/releases/latest`).
2. After updating the short link, download it once to confirm the ZIP now contains the expected `CenterofExcellenceCoreComponents` version (verify in Solution.xml inside the package).

## Recommended durable fix

- Add a release checklist item (or automation) to refresh the `aka.ms/CoEStarterKitDownload` redirect every time a new CoE Starter Kit release is published.
- Where possible, reference the GitHub **Releases** page (`https://github.com/microsoft/coe-starter-kit/releases/latest`) instead of the short link in documentation to avoid future drift.

## Response template

Thanks for raising this. The `aka.ms/CoEStarterKitDownload` short link is currently pointing to an older drop. The latest release is newer than the one delivered by the short link, and the redirect needs to be refreshed.

**What we're doing now**
- Updating the short link to point at the current release.
- Verifying the download contains the latest Core solution version after the change.

**How you can get the latest build immediately**
- Download directly from the GitHub Releases page: https://github.com/microsoft/coe-starter-kit/releases/latest
- Use the latest assets from that page while we update the short link.

We'll reply back once the short link is updated. Let us know if you still see the old version after that.
