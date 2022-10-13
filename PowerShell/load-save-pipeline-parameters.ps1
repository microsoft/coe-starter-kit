function Write-Export-Pipeline-Parameters {
    param (
        [Parameter(Mandatory)] [String]$filePath, 
        [Parameter()] [String]$gitAccessUrl, 
        [Parameter()] [String]$project,
        [Parameter()] [String]$repo, 
        [Parameter()] [String]$branch,
        [Parameter()] [String]$branchToCreate, 
        [Parameter()] [String]$commitMessage,
        [Parameter()] [String]$email, 
        [Parameter()] [String]$serviceConnectionName,
        [Parameter()] [String]$serviceConnectionUrl, 
        [Parameter()] [String]$solutionName,
        [Parameter()] [String]$userName
    )

    $configurationData = $env:DEPLOYMENT_SETTINGS | ConvertFrom-Json
    $pipelineParameterObject = [PSCustomObject]@{"gitAccessUrl"=$gitAccessUrl; "project"="$project"; "repo"="$repo"; "branch"="$branch"; "branchToCreate"="$branchToCreate"; "commitMessage"="$commitMessage"; "email"="$email"; "serviceConnectionName"="$serviceConnectionName"; "serviceConnectionUrl"="$serviceConnectionUrl"; "solutionName"="$solutionName"; "userName"="$userName"; "configurationData"=$configurationData }
    Write-Pipeline-Parameters $filePath $pipelineParameterObject
}

function Write-Deploy-Pipeline-Parameters {
    param (
        [Parameter(Mandatory)] [String]$filePath, 
        [Parameter()] [String]$serviceConnectionName, 
        [Parameter()] [String]$serviceConnectionUrl,
        [Parameter()] [String]$environmentName, 
        [Parameter()] [String]$solutionName,
        [Parameter()] [String]$importUnmanaged, 
        [Parameter()] [String]$overwriteUnmanagedCustomizations,
        [Parameter()] [String]$skipBuildToolsInstaller, 
        [Parameter()] [String]$cacheEnabled
    )
    $pipelineParameterObject = [PSCustomObject]@{"serviceConnectionName"="$serviceConnectionName"; "serviceConnectionUrl"="$serviceConnectionUrl"; "environmentName"="$environmentName"; "solutionName"="$solutionName"; "importUnmanaged"="$importUnmanaged"; "overwriteUnmanagedCustomizations"="$overwriteUnmanagedCustomizations"; "skipBuildToolsInstaller"="$skipBuildToolsInstaller"; "cacheEnabled"="$cacheEnabled" }
    Write-Pipeline-Parameters $filePath $pipelineParameterObject
}

function Write-Build-Pipeline-Parameters {
    param (
        [Parameter(Mandatory)] [String]$filePath, 
        [Parameter()] [String]$buildType, 
        [Parameter()] [String]$serviceConnectionName,
        [Parameter()] [String]$serviceConnectionUrl, 
        [Parameter()] [String]$solutionName
    )
    $pipelineParameterObject = [PSCustomObject]@{"buildType"=$buildType; "serviceConnectionName"="$serviceConnectionName"; "serviceConnectionUrl"="$serviceConnectionUrl"; "solutionName"="$solutionName" }
    Write-Pipeline-Parameters $filePath $pipelineParameterObject
}

function Write-Pipeline-Parameters {
    param (
        [Parameter(Mandatory)] [String]$filePath,
        [Parameter(Mandatory)] [PSCustomObject]$pipelineParameterObject
    )
    Write-Host "Saving Pipeline Parameters to $filePath"
    if (Test-Path $filePath) {
        Remove-Item $filePath
    }
    [string]$pipelineParameterJson = $pipelineParameterObject | ConvertTo-Json -depth 100
    if ($PSVersionTable.PSVersion.Major -gt 5) {
        $pipelineParameterJson | Out-File "$filePath" -Encoding utf8NoBOM
    }
    else {
        $utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $false
        [System.IO.File]::WriteAllText($filePath, $pipelineParameterJson, $utf8NoBomEncoding)
        # PowerShell < v6 does not support writing UTF8 without BOM using Out-File
        # $pipelineParameterJson | Out-File "$filePath"
    }
}
function Read-Pipeline-Parameters {
    param (
        [Parameter(Mandatory)] [String]$filePath
    )

    return Get-Content $filePath | ConvertFrom-Json
}