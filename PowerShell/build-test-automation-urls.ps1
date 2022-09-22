# Testable outside of agent
function Set-CanvasTestAutomationURLs {
    param (
        [Parameter(Mandatory)] [String]$token,
        [Parameter(Mandatory)] [String]$url,
        [Parameter(Mandatory)] [String]$solutionName,
        [Parameter(Mandatory)] [String]$canvasAppsPath,
        [Parameter(Mandatory)] [String]$environmentId
    )
    $filter = ".meta.xml"
    [System.Collections.ArrayList]$testUrls = @()
    $testUrlsObject = New-Object -TypeName PSObject
    $testUrlsObject | Add-Member -MemberType NoteProperty -Name TestURLs -Value $testUrls

    if(Test-Path $canvasAppsPath) {
        $canvasApps = Get-ChildItem "$canvasAppsPath\src\" -Filter "*$filter"
        $asTestCase = "As TestCase"
        $hostUrl = Get-HostFromUrl $url        
        foreach ($app in $canvasApps) {
            $appName = $app.Name.Replace($filter, "")
            $appDirectory = $app.Directory.ToString()
            $appSrcDirectory = "$appDirectory\src\$appName\Src\Tests"

            if(Test-Path $appSrcDirectory) {
                $testFiles = Get-ChildItem $appSrcDirectory
                $appId = $null

                foreach ($testFile in $testFiles) {
                    $lines = Get-Content $testFile.FullName

                    foreach ($line in $lines) {                
                        if ($line.Contains($asTestCase)) {
                            $pipeDelimeter = "|"
                            $testCaseId = $line.Replace($asTestCase,$pipeDelimeter).Split($pipeDelimeter)[0].Replace("`"", "").Replace("'", "").Trim()
                            $testUrl = Get-CanvasAppPlayUrl $token $hostUrl $appName
                            $testUrl = "$testUrl&__PATestCaseId=$testCaseId&source=testStudioLink"
                            $testUrls.Add($testUrl)
                            # We need to bypass consent.  Otherwise the test might fail.
                            if ($null -eq $appId) {
                                $appId = $testUrl.Replace('play/',$pipeDelimeter).Replace('?',$pipeDelimeter).Split($pipeDelimeter)[1]                            
                                Set-AdminPowerAppApisToBypassConsent -EnvironmentName $environmentId -AppName $appId
                                Write-Host "Bypassed consent for $appId"
                            }
                        }
                    }
                }
            }
        }
    }
    $json = ConvertTo-Json $testUrlsObject
    Set-Content -Path "CanvasTestAutomationURLs.json" -Value $json -Force
    Get-Content -Path "CanvasTestAutomationURLs.json"
}

function Get-CanvasAppPlayUrl {
    param (
        [Parameter(Mandatory)] [String]$token,
        [Parameter(Mandatory)] [String]$hostUrl,
        [Parameter(Mandatory)] [String]$canvasName
    )
    $odataQuery = 'canvasapps?$filter=name eq ''' + $canvasName + '''&$select=appopenuri'
    $response = Invoke-DataverseHttpGet $token $hostUrl $odataQuery
    return $response.value[0].appopenuri
}