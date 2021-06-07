Import-Module (Join-Path ( ([System.IO.Path]::GetDirectoryName($PSCommandPath))) "Microsoft.PowerApps.AuthModule.psm1") -Force

$local:ErrorActionPreference = "Stop"
function Get-AudienceForHostName
{
    [CmdletBinding()]
    Param(
        [string] $Uri
    )

    $hostMapping = @{
        "management.azure.com" = "https://management.azure.com/";
        "api.powerapps.com" = "https://service.powerapps.com/";
        "api.apps.appsplatform.us" = "https://service.apps.appsplatform.us/";
        "tip1.api.powerapps.com" = "https://service.powerapps.com/";
        "tip2.api.powerapps.com" = "https://service.powerapps.com/";
        "graph.windows.net" = "https://graph.windows.net/";
        "api.bap.microsoft.com" = "https://service.powerapps.com/";
        "tip1.api.bap.microsoft.com" = "https://service.powerapps.com/";
        "tip2.api.bap.microsoft.com" = "https://service.powerapps.com/";
        "api.flow.microsoft.com" = "https://service.flow.microsoft.com/";
        "api.flow.appsplatform.us" = "https://service.flow.appsplatform.us/";
        "tip1.api.flow.microsoft.com" = "https://service.flow.microsoft.com/";
        "tip2.api.flow.microsoft.com" = "https://service.flow.microsoft.com/";
        "gov.api.bap.microsoft.us" = "https://gov.service.powerapps.us/";
        "high.api.bap.microsoft.us" = "https://high.service.powerapps.us/";
        "api.bap.appsplatform.us" = "https://service.apps.appsplatform.us/";
        "gov.api.powerapps.us" = "https://gov.service.powerapps.us/";
        "high.api.powerapps.us" = "https://high.service.powerapps.us/";
        "gov.api.flow.microsoft.us" = "https://gov.service.flow.microsoft.us/";
        "high.api.flow.microsoft.us" = "https://high.service.flow.microsoft.us/";
    }

    $uriObject = New-Object System.Uri($Uri)
    $hostName = $uriObject.Host

    if ($null -ne $hostMapping[$hostName])
    {
        return $hostMapping[$hostName];
    }

    Write-Verbose "Unknown host $hostName. Using https://management.azure.com/ as a default";
    return "https://management.azure.com/";
}

function Invoke-Request(
    [CmdletBinding()]

    [Parameter(Mandatory=$True)]
    [string] $Uri,

    [Parameter(Mandatory=$True)]
    [string] $Method,

    [object] $Body = $null,

    [Hashtable] $Headers = @{},

    [switch] $ParseContent,

    [switch] $ThrowOnFailure
)
{
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    $audience = Get-AudienceForHostName -Uri $Uri
    $token = Get-JwtToken -Audience $audience
    $Headers["Authorization"] = "Bearer $token";
    $Headers["User-Agent"] = "PowerShell cmdlets 1.0";

    try {
        if ($null -eq $Body -or $Body -eq "")
        {
            $response = Invoke-WebRequest -Uri $Uri -Headers $Headers -Method $Method -UseBasicParsing
        }
        else
        {
            $jsonBody = ConvertTo-Json $Body -Depth 20
            $response = Invoke-WebRequest -Uri $Uri -Headers $Headers -Method $Method -ContentType "application/json; charset=utf-8" -Body $jsonBody -UseBasicParsing
        }

        if ($ParseContent)
        {
            if ($response.Content)
            {
                return ConvertFrom-JsonWithErrorHandling -JsonString $response.Content;
            }
        }

        return $response
    } catch {
        $response = $_.Exception.Response
        if ($_.ErrorDetails)
        {
            $errorResponse = ConvertFrom-JsonWithErrorHandling -JsonString $_.ErrorDetails;
            $code = $response.StatusCode.value__
            $message = $errorResponse.Error.Message
            Write-Verbose "Status Code: '$code'. Message: '$message'"

            $response = New-Object -TypeName PSObject `
                | Add-Member -PassThru -MemberType NoteProperty -Name StatusCode -Value $response.StatusCode.value__ `
                | Add-Member -PassThru -MemberType NoteProperty -Name StatusDescription -Value $response.StatusDescription `
                | Add-Member -PassThru -MemberType NoteProperty -Name Headers -Value $response.Headers `
                | Add-Member -PassThru -MemberType NoteProperty -Name Error -Value $errorResponse.Error `
                | Add-Member -PassThru -MemberType NoteProperty -Name Message -Value $message `
                | Add-Member -PassThru -MemberType NoteProperty -Name Internal -value $response;
        }

        if ($ThrowOnFailure)
        {
            throw;
        }
        else
        {
            return $response
        }
    }
}

function InvokeApi
{
    <#
    .SYNOPSIS
    Invoke an API.
    .DESCRIPTION
    The InvokeApi cmdlet invokes an API based on input parameters.
    Use Get-Help InvokeApi -Examples for more detail.
    .PARAMETER Method
    The http request method.
    .PARAMETER Route
    The http URL.
    .PARAMETER Body
    The http request body.
    .PARAMETER ThrowOnFailure
    Throw exception on failure if it is true.
    .PARAMETER ApiVersion
    The service API version.
    .EXAMPLE
    InvokeApi -Method GET -Route $uri -Body $body -ThrowOnFailure
    Call $uri API as GET method with $body input and throw exception on failure.
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$Method,

        [Parameter(Mandatory = $true)]
        [string]$Route,

        [Parameter(Mandatory = $false)]
        [object]$Body = $null,

        [Parameter(Mandatory = $false)]
        [switch]$ThrowOnFailure,

        [Parameter(Mandatory = $false)]
        [string]$ApiVersion = "2016-11-01"
    )

    Test-PowerAppsAccount;

    $uri = $Route `
        | ReplaceMacro -Macro "{apiVersion}"  -Value $ApiVersion `
        | ReplaceMacro -Macro "{flowEndpoint}" -Value $global:currentSession.flowEndpoint `
        | ReplaceMacro -Macro "{powerAppsEndpoint}" -Value $global:currentSession.powerAppsEndpoint `
        | ReplaceMacro -Macro "{bapEndpoint}" -Value $global:currentSession.bapEndpoint `
        | ReplaceMacro -Macro "{graphEndpoint}" -Value $global:currentSession.graphEndpoint `
        | ReplaceMacro -Macro "{cdsOneEndpoint}" -Value $global:currentSession.cdsOneEndpoint;

    Write-Verbose $uri

    If($ThrowOnFailure)
    {
        $result = Invoke-Request `
        -Uri $uri `
        -Method $Method `
        -Body $body `
        -ParseContent `
        -ThrowOnFailure `
        -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true);
    }
    else {
        $result = Invoke-Request `
        -Uri $uri `
        -Method $Method `
        -Body $body `
        -ParseContent `
        -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true);
    }

    if($result.nextLink)
    {
        $nextLink = $result.nextLink
        $resultValue = $result.value

        while($nextLink)
        {
            If($ThrowOnFailure)
            {
                $nextResult = Invoke-Request `
                -Uri $nextLinkuri `
                -Method $Method `
                -Body $body `
                -ParseContent `
                -ThrowOnFailure `
                -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true);
            }
            else {
                $nextResult = Invoke-Request `
                -Uri $nextLink `
                -Method $Method `
                -Body $body `
                -ParseContent `
                -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true);
            }

            $nextLink = $nextResult.nextLink
            $resultValue = $resultValue + $nextResult.value
        }

        return New-Object -TypeName PSObject `
            | Add-Member -PassThru -MemberType NoteProperty -Name value -Value $resultValue `
    }

    return $result;
}

function InvokeApiNoParseContent
{
    <#
    .SYNOPSIS
    Invoke an API without parsing return content.
    .DESCRIPTION
    The InvokeApiNoParseContent cmdlet invokes an API based on input parameters without parsing return content.
    Use Get-Help InvokeApiNoParseContent -Examples for more detail.
    .PARAMETER Method
    The http request method.
    .PARAMETER Route
    The http URL.
    .PARAMETER Body
    The http request body.
    .PARAMETER ThrowOnFailure
    Throw exception on failure if it is true.
    .PARAMETER ApiVersion
    The service API version.
    .EXAMPLE
    InvokeApiNoParseContent -Method PUT -Route $uri -Body $body -ThrowOnFailure
    Call $uri API as PUT method with $body input and throw exception on failure.
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$Method,

        [Parameter(Mandatory = $true)]
        [string]$Route,

        [Parameter(Mandatory = $false)]
        [object]$Body = $null,

        [Parameter(Mandatory = $false)]
        [switch]$ThrowOnFailure,

        [Parameter(Mandatory = $false)]
        [string]$ApiVersion = "2016-11-01"
    )

    Test-PowerAppsAccount;

    $uri = $Route `
        | ReplaceMacro -Macro "{apiVersion}"  -Value $ApiVersion `
        | ReplaceMacro -Macro "{flowEndpoint}" -Value $global:currentSession.flowEndpoint `
        | ReplaceMacro -Macro "{powerAppsEndpoint}" -Value $global:currentSession.powerAppsEndpoint `
        | ReplaceMacro -Macro "{bapEndpoint}" -Value $global:currentSession.bapEndpoint `
        | ReplaceMacro -Macro "{graphEndpoint}" -Value $global:currentSession.graphEndpoint `
        | ReplaceMacro -Macro "{cdsOneEndpoint}" -Value $global:currentSession.cdsOneEndpoint;

    Write-Verbose $uri

    If($ThrowOnFailure)
    {
        $result = Invoke-Request `
        -Uri $uri `
        -Method $Method `
        -Body $body `
        -ThrowOnFailure `
        -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true);
    }
    else {
        $result = Invoke-Request `
        -Uri $uri `
        -Method $Method `
        -Body $body `
        -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true);
    }

    if($result.nextLink)
    {
        $nextLink = $result.nextLink
        $resultValue = $result.value

        while($nextLink)
        {
            If($ThrowOnFailure)
            {
                $nextResult = Invoke-Request `
                -Uri $nextLinkuri `
                -Method $Method `
                -Body $body `
                -ThrowOnFailure `
                -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true);
            }
            else {
                $nextResult = Invoke-Request `
                -Uri $nextLink `
                -Method $Method `
                -Body $body `
                -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true);
            }

            $nextLink = $nextResult.nextLink
            $resultValue = $resultValue + $nextResult.value
        }

        return New-Object -TypeName PSObject `
            | Add-Member -PassThru -MemberType NoteProperty -Name value -Value $resultValue `
    }

    return $result;
}

function ReplaceMacro
{
    <#
    .SYNOPSIS
    Replace macro to the specified value.
    .DESCRIPTION
    The ReplaceMacro cmdlet replace macro in input string with the specified value.
    Use Get-Help ReplaceMacro -Examples for more detail.
    .PARAMETER Input
    The input string.
    .PARAMETER Macro
    The macro to be replaced.
    .PARAMETER Value
    The value for the replacement.
    .EXAMPLE
    ReplaceMacro -Macro "{apiVersion}"  -Value $ApiVersion
    Replace {apiVersion} to $ApiVersion.
    #>
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$Input,

        [Parameter(Mandatory = $true)]
        [string]$Macro,

        [Parameter(Mandatory = $false)]
        [string]$Value
    )

    return $Input.Replace($Macro, $Value)
}


function BuildFilterPattern
{
    param
    (
        [Parameter(Mandatory = $false)]
        [object]$Filter
    )

    if ($null -eq $Filter -or $Filter.Length -eq 0)
    {
        return New-Object System.Management.Automation.WildcardPattern "*"
    }
    else
    {
        return New-Object System.Management.Automation.WildcardPattern @($Filter,"IgnoreCase")
    }
}

function ConvertFrom-JsonWithErrorHandling
{
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$JsonString
    )

    try {
        return ConvertFrom-Json $JsonString
    } catch {
        Write-Verbose "Invalid JSON string: '$JsonString', falling back to .NET deserialization."

        # try to de-serialize the json string by using .Net json serializer
        [void][System.Reflection.Assembly]::LoadWithPartialName("System.Web.Extensions")
        return (New-Object -TypeName System.Web.Script.Serialization.JavaScriptSerializer -Property @{MaxJsonLength=67108864}).DeserializeObject($JsonString)
    }
}

function ResolveEnvironment
{
    param
    (
        [Parameter(Mandatory = $false)]
        [string]$OverrideId
    )

    if (-not [string]::IsNullOrWhiteSpace($OverrideId))
    {
        return $OverrideId;
    }
    elseif ($global:currentSession.selectedEnvironment)
    {
        return $global:currentSession.selectedEnvironment;
    }

    return "~default";
}


function Select-CurrentEnvironment
{
 <#
 .SYNOPSIS
 Sets the current environment for listing powerapps, flows, and other environment resources
 .DESCRIPTION
 The Select-CurrentEnvironment cmdlet sets the current environment in which commands will
 execute when an environment is not specified. Use Get-Help Select-CurrentEnvironment -Examples
 for more detail.
 .PARAMETER EnvironmentName
 Environment identifier (not display name).
 .PARAMETER Default
 Shortcut to specify the default tenant environment
 .EXAMPLE
 Select-CurrentEnvironment -EnvironmentName 3c2f7648-ad60-4871-91cb-b77d7ef3c239
 Select environment 3c2f7648-ad60-4871-91cb-b77d7ef3c239 as the current environment. Cmdlets invoked
 after running this command will operate against this environment.
 .EXAMPLE
 Select-CurrentEnvironment ~default
 Select the default environment. Cmdlets invoked after running this will operate against the default
 environment.
 #>
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName=$true, ParameterSetName = "Name")]
        [String]$EnvironmentName,

        [Parameter(Mandatory = $true, ParameterSetName = "Default")]
        [Switch]$Default
    )

    Test-PowerAppsAccount;

    if ($Default)
    {
        $global:currentSession.selectedEnvironment = "~default";
    }
    else
    {
        $global:currentSession.selectedEnvironment = $EnvironmentName;
    }
}