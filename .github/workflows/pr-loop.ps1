function Invoke-EndToEndPipelineTest ($User, $Password, $Data) {
    $result = az login --allow-no-subscriptions -u $User -p $Password
    $path = './PowerShell/tests/e2e-pipeline.tests.ps1'    
    $container = New-PesterContainer -Path $path -Data $Data
    Invoke-Pester -Container $container
}