# Pipeline Performance Optimization

[https://github.com/microsoft/coe-alm-accelerator-templates/tree/jeschro-1540](https://github.com/microsoft/coe-alm-accelerator-templates/tree/jeschro-1540)

Branch includes performance optimizations by leveraging the [Cache DevOps task](https://docs.microsoft.com/azure/devops/pipelines/release/caching?view=azure-devops).

## Caching of Power Platform Build Tools - Tools Installer

The Power Platform Build Tools - Tools Installer tasks installed several PowerShell Modules to a PP_BT specific folder on the agent. The tasks checks to see if the modules already exist in the PP_BT folder and skips download of the modules that are available (folder will never be available when running on Azure Hosted Agents). By caching this folder the downloaded PS modules can be restored directly from the cache rather than have to download them.
The PP_BT Tools Installer task sets several Pipeline Variables that are required for subsequent use of PP_BT tasks so the tasks must always be executed even if there is a cache hit and PS modules are restored.  

### Cache task for PP_BT

```
- task: Cache@2
  displayName: Cache Build Tools
  inputs:
    key:  restoreTools | "$(buildToolsSubPath)" | $(BuildToolsCacheKey)
    path: $(buildToolsPath)
    cacheHitVar: buildToolsPath_IsCached
```

- $(buildToolsSubPath) see [Introducing set-tools-paths.yml](#introducing-set-tools-pathsyml)
- $(buildToolsCacheKey) this is a **required** variable and can be set in the **alm-accelerator-variable-group** or as a pipeline variable
- $(buildToolsPath) see [Introducting set-tools-paths.yml](#introducing-set-tools-pathsyml)

### Invalidating the PP_BT cache

To invalidate the cache for PP_BT users can update the value of the $(BuildToolsCacheKey).

## Caching of Install-PowerShell-Modules.yml

The Install-PowerShell-Modules.yml template downloads and installs PowerShell modules required in subsequent pipeline templates. This branch include changes to the install-powershell-module.yml that implements the same logic as PP_BT Tools Installer to save PS Modules to a AA4PP specific folder on the agent. By caching this folder the downloaded PS modules can be restored directly from cache rather than have to download them.
The Install-PowerShell-Module.yml has also been modified to download the Microsoft.Xrm.Tooling.ConfigurationMigration which is used by the import-configuration-migration-data.yml.

### Cache task for install-powershell-modules.yml
```
- task: Cache@2
  displayName: Cache Powershell Modules
  inputs:
    key:  restoremodules | "$(powerPlatformToolsSubPath)" | $(Pipeline.Workspace)/PipelineUtils/Pipelines/Templates/install-powershell-modules.yml
    path: $(powerPlatformToolsPath)
    cacheHitVar: powerPlatformToolsPath_IsCached
```

- $(powerPlatformToolsSubPath) see [Introducing set-tools-paths.yml](#introducing-set-tools-pathsyml)
- $(Pipeline.Workspace)/PipelineUtils/Pipelines/Templates/install-powershell-modules.yml - this is reference to the template file. The cache task will calculate a dynamic cache key based on the hash of the template file
- $(powerPlatformToolsPath) see [Introducting set-tools-paths.yml](#introducing-set-tools-pathsyml)

### Invalidating the install-powershell-module.yml cache

To invalidate the cache for install-powershell-modules.yml users can update the content of the install-powershell-modules.yml file. I.e. if the required version for a powershell module is updated in the template the cache will be invalid and all the ps modules will be downloaded.

## Introducing set-tools-paths.yml

This new template file will set Pipeline Variables to be used in the cache tasks and the install-powershell-modules.yml template

Following pipeline vars are set

- buildToolsSubPath: _t\PA_BT (this path is used by the PP_BT Tools Installer task)
- buildToolsPath: will map depending on pipeline agent (usually maps to the pipeline workspace)
  - Example: C:\agent\_work\1\$buildToolsSubPath
- powerPlatformToolsSubPath: _coe\ALM_ACC
- powerPlatformToolsPath: will map depending on pipeline agent (usually maps to the pipeline workspace)
  - Example: C:\agent\_work\1\$powerPlatformToolsSubPath
