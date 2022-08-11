﻿if($args.count -eq 4 -and $null -ne $args[0] -and $args[0] -ne 'undefined' -and $null -ne $args[1] -and $args[1] -ne 'undefined' -and $null -ne $args[2] -and $args[2] -ne 'undefined' -and $null -ne $args[3] -and $args[3] -ne 'undefined' ) {
    if(Test-Path -Path "./coe-alm-accelerator-templates-latest") {
        Remove-Item "./coe-alm-accelerator-templates-latest" -Force -Recurse
    }
    New-Item -ItemType "directory" -Name "./coe-alm-accelerator-templates-latest"

    Set-Location "./coe-alm-accelerator-templates-latest"
    git clone https://github.com/microsoft/coe-alm-accelerator-templates.git
    Set-Location "./coe-alm-accelerator-templates"
    $tagArray = git tag --sort=-creatordate -l CenterofExcellenceALMAccelerator*
    $appVersion = $tagArray[0]

    git checkout tags/$appVersion -b $appVersion

    Set-Location "../../"

    if(Test-Path -Path "./coe-alm-accelerator-templates-local") {
        Remove-Item "./coe-alm-accelerator-templates-local" -Force -Recurse
    }
    New-Item -ItemType "directory" -Name "./coe-alm-accelerator-templates-local"

    $orgUrl = $args[0].TrimEnd('/')
    $project = [Uri]::EscapeUriString($args[1])
    $pipelineRepo = [Uri]::EscapeUriString($args[2].TrimEnd('/'))
    $accessToken = $args[3]

    Set-Location "./coe-alm-accelerator-templates-local"
    $azdoCloneUrl = "$orgUrl/$project/_git/$pipelineRepo"
    git -c http.extraHeader="AUTHORIZATION: bearer $accessToken" clone "$azdoCloneUrl"
    git -c http.extraHeader="AUTHORIZATION: bearer $accessToken" init

    if(!(Test-Path -Path "./$pipelineRepo/")) {
        New-Item -ItemType "directory" -Name "./$pipelineRepo/"
    }

    Set-Location "../"

    Copy-Item -Force -Recurse "./coe-alm-accelerator-templates-latest/coe-alm-accelerator-templates/*" "./coe-alm-accelerator-templates-local/$pipelineRepo/" -Exclude ".git"
    Set-Location "./coe-alm-accelerator-templates-local/$pipelineRepo/"
    git add --all
    git commit -m "Importing templates from $appVersion"

    git -c http.extraHeader="AUTHORIZATION: bearer $accessToken" push
    $mainExistsInRemote = git ls-remote --heads origin main
    $masterExistsInRemote = git ls-remote --heads origin master

    if($null -ne $masterExistsInRemote -and $null -eq $mainExistsInRemote) {
        Write-Host "Updating master branch to main"
        git -c http.extraHeader="AUTHORIZATION: bearer $accessToken" checkout -b main
        git -c http.extraHeader="AUTHORIZATION: bearer $accessToken" push --set-upstream origin main
        git -c http.extraHeader="AUTHORIZATION: bearer $accessToken" push origin -d master
    }
}