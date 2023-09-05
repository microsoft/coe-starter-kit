<#
This function sets the canvas test Automation URLs.
Testable outside of agent.
#>
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

    Write-Host "CanvasAppsPath - $canvasAppsPath"
    if(Test-Path $canvasAppsPath) {
        $canvasApps = Get-ChildItem "$canvasAppsPath"  -File -Recurse | Where-Object { $_.Name -like "*$filter" }
        Write-Host "Printing matched $filter files"
        foreach ($file in $canvasApps) {
            Write-Host "File: $($file.Name)"
        }
        $asTestCase = "As TestCase"
        $hostUrl = Get-HostFromUrl $url       
        foreach ($app in $canvasApps) {
            Write-Host "App Name $($app.Name)"
            $appName = $app.Name.Replace($filter, "")
            $appDirectory = $app.Directory.ToString()
            $appSrcDirectory = "$appDirectory\src\$appName\Src\Tests"

            Write-Host "AppName - $appName"
            Write-Host "AppDirectory - $appDirectory"
            Write-Host "AppSrcDirectory - $appSrcDirectory"

            if(Test-Path $appSrcDirectory) {
                $testFiles = Get-ChildItem $appSrcDirectory
                $appId = $null

                foreach ($testFile in $testFiles) {
                    Write-Host "Fetching content of file - "$($testFile.FullName)
                    $lines = Get-Content $testFile.FullName

                    foreach ($line in $lines) {                
                        if ($line.Contains($asTestCase)) {
                            Write-Host "Test files contains $asTestCase"
                            $pipeDelimeter = "|"
                            $testCaseId = $line.Replace($asTestCase,$pipeDelimeter).Split($pipeDelimeter)[0].Replace("`"", "").Replace("'", "").Trim()
                            $canvasAppResponse = Get-CanvasAppData $token $hostUrl $appName
                            $testUrl = $canvasAppResponse.value[0].appopenuri
                            $canvasAppId = $canvasAppResponse.value[0].canvasappid
                            #TestURL format https://apps.powerapps.com/play/{appId}?tenantId={tenantId}&__PATestCaseId={testCaseId}
                            $tenantId = [regex]::Match($testUrl, "tenantId=([^&]+)").Groups[1].Value
                            $playHost = "https://apps.powerapps.com/play/"
                            $testUrl = "$($playHost)$($canvasAppId)?tenantId=$tenantId&__PATestCaseId=$testCaseId&source=testStudioLink"
                            Write-Host "Adding TestUrl - $testUrl"
                            $testUrls.Add($testUrl)
                            # We need to bypass consent.  Otherwise the test might fail.
                            if ($null -eq $appId) {
                                $appId = $canvasAppId
                                Write-Host "AppId - $appId"
                                try
                                {
                                    Set-AdminPowerAppApisToBypassConsent -EnvironmentName $environmentId -AppName $appId
                                    Write-Host "Bypassed consent for $appId"
                                }catch {
                                    Write-Host "Set-AdminPowerAppApisToBypassConsent execution failed - $($_.Exception.Message)"
                                }
                            }
                        }                        
                    }
                }
            }else{
                Write-Host "AppSrcDirectory - $appSrcDirectory is unavailable."
            }
        }
    }

    $json = ConvertTo-Json $testUrlsObject
    if ($PSVersionTable.PSVersion.Major -gt 5) {
        Set-Content -Path "CanvasTestAutomationURLs.json" -Value $json -Force -Encoding utf8NoBOM
    }
    else {
        $utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $false
        $jsonBytes = $utf8NoBomEncoding.GetBytes($json)
        Set-Content -Path "CanvasTestAutomationURLs.json" -Value $jsonBytes -Encoding Byte
    }

    $CanvasTestAutomationURLsContent =  Get-Content -Path "CanvasTestAutomationURLs.json"
    Write-Host "CanvasTestAutomationURLsContent - $CanvasTestAutomationURLsContent"
}

<#
This function gets the canvas app play url.
#>
function Get-CanvasAppData {
    param (
        [Parameter(Mandatory)] [String]$token,
        [Parameter(Mandatory)] [String]$hostUrl,
        [Parameter(Mandatory)] [String]$canvasName
    )
    $odataQuery = 'canvasapps?$filter=name eq ''' + $canvasName + '''&$select=appopenuri,canvasappid'
    $response = Invoke-DataverseHttpGet $token $hostUrl $odataQuery
    return $response
}