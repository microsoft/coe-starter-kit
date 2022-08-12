
#Run in PowerShell Core
function Invoke-CanvasUnpackPack-Test()
{
    Set-Location -Path "..\"
    $testConfig = Get-Content ".\TestData\canvas-unpack-pack-test.config.json" | ConvertFrom-Json

    $RepackedMsAppPath = $testConfig.repackedMsAppPath
    $MsAppPath = $testConfig.msAppPath
    $MsAppSourcePath = $testConfig.msAppSourcePath

    $path = './canvas-unpack-pack.tests.ps1'
    $data = @{
        RepackedMsAppPath       = $RepackedMsAppPath
        MsAppPath               = $MsAppPath
        MsAppSourcePath         = $MsAppSourcePath
    }
    $container = New-PesterContainer -Path $path -Data $data
    Invoke-Pester -Container $container
}
Invoke-CanvasUnpackPack-Test
