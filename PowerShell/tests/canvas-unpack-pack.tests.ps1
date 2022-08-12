param(
    $RepackedMsAppPath, $MsAppPath, $MsAppSourcePath 
)

Describe 'Canvas-Unpack-Pack-Test' {
    It 'UnpackAndPackCanvasApp' -Tag 'UnpackAndPackCanvasApp' {
        . ..\canvas-unpack-pack.ps1
        Write-Host (Get-Location)
        Set-Location -Path "..\"
        Write-Host (Get-Location)
        if(Test-Path -Path $RepackedMsAppPath) {
            Remove-Item -Path $RepackedMsAppPath -Force
        }
        if(Test-Path -Path $MsAppSourcePath) {
            Remove-Item -Path $MsAppSourcePath -Force -Recurse
        }
        Invoke-CanvasUnpackPack "unpack" $MsAppPath $MsAppSourcePath
        Invoke-CanvasUnpackPack "pack" $MsAppSourcePath $RepackedMsAppPath
    }
}