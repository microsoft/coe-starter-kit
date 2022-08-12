#Run in PowerShell Core
function Write-Export-Pipeline-Parameters-Test()
{
    Set-Location -Path "..\"
    $testConfig = Get-Content ".\TestData\save-export-pipeline-parameter-test.config.json" | ConvertFrom-Json
    $testDeploymentConfig = Get-Content ".\TestData\update-deployment-settings-test-deployment.json"

    $path = './load-save-export-parameters.tests.ps1'
    $data = @{
        ConfigFileOutPath       = $testConfig.configFileOutPath #".\TestData\out-export-pipeline-parameters.json"
        GitAccessUrl            = $testConfig.gitAccessUrl 
        project                 = $testConfig.project
        Repo                    = $testConfig.repo 
        Branch                  = $testConfig.branch 
        branchToCreate          = $testConfig.branchToCreate 
        commitMessage           = $testConfig.commitMessage 
        Email                   = $testConfig.email 
        ServiceConnectionName   = $testConfig.serviceConnectionName 
        ServiceConnectionUrl    = $testConfig.serviceConnectionUrl 
        SolutionName            = $testConfig.solutionName
        UserName                = $testConfig.userName
        DeploymentSettingsData  = $testDeploymentConfig
    }
    $container = New-PesterContainer -Path $path -Data $data
    Invoke-Pester -Container $container
}

function Write-Build-Pipeline-Parameters-Test()
{
    $testConfig = Get-Content ".\TestData\save-build-pipeline-parameter-test.config.json" | ConvertFrom-Json

    $path = './load-save-build-parameters.tests.ps1'
    $data = @{
        ConfigFileOutPath           = $testConfig.configFileOutPath #".\TestData\out-build-pipeline-parameters.json"
        BuildType                   = $testConfig.buildType
        ServiceConnectionName       = $testconfig.serviceConnectionName
        ServiceConnectionUrl        = $testConfig.serviceConnectionUrl
        SolutionName                = $testConfig.solutionName
    }
    $container = New-PesterContainer -Path $path -Data $data
    Invoke-Pester -Container $container
}

function Write-Deploy-Pipeline-Parameters-Test()
{
    $testConfig = Get-Content ".\TestData\save-deploy-pipeline-parameter-test.config.json" | ConvertFrom-Json

    $path = './load-save-deploy-parameters.tests.ps1'
    $data = @{
        ConfigFileOutPath                   = $testConfig.configFileOutPath #".\TestData\out-deploy-pipeline-parameters.json"
        ServiceConnectionName               = $testConfig.serviceConnectionName 
        ServiceConnectionUrl                = $testConfig.serviceConnectionUrl 
        EnvironmentName                     = $testConfig.environmentName 
        SolutionName                        = $testConfig.solutionName 
        ImportUnmanaged                     = $testConfig.importUnmanaged 
        OverwriteUnmanagedCustomizations    = $testConfig.overwriteUnmanagedCustomizations 
        SkipBuildToolsInstaller             = $testConfig.skipBuildToolsInstaller 
        CacheEnabled                        = $testConfig.cacheEnabled
    }
    $container = New-PesterContainer -Path $path -Data $data
    Invoke-Pester -Container $container
}

Write-Export-Pipeline-Parameters-Test
Write-Build-Pipeline-Parameters-Test
Write-Deploy-Pipeline-Parameters-Test