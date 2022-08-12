#Run in PowerShell Core
function Invoke-E2E-Pipeline-Tests-Test($solutionName)
{
    Set-Location -Path "..\"

    $testConfig = Get-Content ".\TestData\e2e-pipeline.tests-test.config.json" | ConvertFrom-Json
    $testData = Get-Content ".\TestData\e2e-pipeline.tests-test-data.json" | Out-String

    az login --allow-no-subscriptions
    $path = './e2e-pipeline.tests.ps1'
    $data = @{
        Org                   = $testConfig.orgUrl
        Project               = $testConfig.projectName
        BranchToTest          = $testConfig.githubHeadRef
        SourceBranch          = $solutionName
        BranchToCreate        = 'pr-loop-e2e-test-' + (New-Guid).Guid
        CommitMessage         = 'pr-loop-e2e-test'
        Data                  = $testData 
        Email                 = $testConfig.email
        Repo                  = $testConfig.repo
        ServiceConnection     = $testConfig.serviceConnection
        SolutionName          = $solutionName
        UserName              = $testConfig.user
    }    
    $container = New-PesterContainer -Path $path -Data $data
    Invoke-Pester -Container $container
}
Invoke-E2E-Pipeline-Tests-Test("ALMAcceleratorSampleSolution")
