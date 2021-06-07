Import-Module (Join-Path ( ([System.IO.Path]::GetDirectoryName($PSCommandPath))) "Microsoft.PowerApps.RestClientModule.psm1") -Force
Import-Module (Join-Path ( ([System.IO.Path]::GetDirectoryName($PSCommandPath))) "Microsoft.PowerApps.AuthModule.psm1") -Force



function Get-PowerAppEnvironment
{
 <#
 .SYNOPSIS
 Returns information about one or more PowerApps environments that the user has access to.
 .DESCRIPTION
 The Get-PowerAppEnvironment cmdlet looks up information about =one or more environments depending on parameters.
 Use Get-Help Get-PowerAppEnvironment -Examples for more detail.
 .PARAMETER Filter
 Finds environments matching the specified filter (wildcards supported).
 .PARAMETER EnvironmentName
 Finds a specific environment.
 .PARAMETER Default
 Finds the default environment.
 .PARAMETER CreatedByMe
 Finds environments created by the calling user
 .EXAMPLE
 Get-PowerAppEnvironment
 Finds all environments within the tenant.
 .EXAMPLE
 Get-PowerAppEnvironment -EnvironmentName 3c2f7648-ad60-4871-91cb-b77d7ef3c239
 Finds environment 3c2f7648-ad60-4871-91cb-b77d7ef3c239
 .EXAMPLE
 Get-PowerAppEnvironment *Test*
 Finds all environments that contain the string "Test" in their display name.
  .EXAMPLE
 Get-PowerAppEnvironment -CreatedByMe
 Finds all environments that were created by the calling user
 #>
    [CmdletBinding(DefaultParameterSetName="Filter")]
    param
    (
        [Parameter(Mandatory = $false, Position = 0, ParameterSetName = "Filter")]
        [Parameter(Mandatory = $false, Position = 0, ParameterSetName = "Owner")]
        [string[]]$Filter,

        [Parameter(Mandatory = $false, ParameterSetName = "Name")]
        [string]$EnvironmentName,

        [Parameter(Mandatory = $false, ParameterSetName = "Default")]
        [Switch]$Default,

        [Parameter(Mandatory = $false, ParameterSetName = "Filter")]
        [Parameter(Mandatory = $false, ParameterSetName = "Owner")]
        [Switch]$CreatedByMe,

        [Parameter(Mandatory = $false, ParameterSetName = "Filter")]
        [Parameter(Mandatory = $false, ParameterSetName = "Name")]
        [Parameter(Mandatory = $false, ParameterSetName = "Default")]
        [Parameter(Mandatory = $false, ParameterSetName = "Owner")]
        [string]$ApiVersion = "2016-11-01"
    )

    if ($Default)
    {
        $getEnvironmentUri = "https://{bapEndpoint}/providers/Microsoft.BusinessAppPlatform/environments/~default?`$expand=permissions&api-version={apiVersion}"

        $environmentResult = InvokeApi -Method GET -Route $getEnvironmentUri -ApiVersion $ApiVersion -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)

        CreateEnvironmentObject -EnvObject $environmentResult
    }
    else
    {
        $createdByUserId = ""

        If($CreatedByMe)
        {
            $createdByUserId = $Global:currentSession.userId
        }

        $filterString = $Filter

        if (-not [string]::IsNullOrWhiteSpace($EnvironmentName))
        {
            $filterString = $EnvironmentName
        }

        $getAllEnvironmentsUri = "https://{powerAppsEndpoint}/providers/Microsoft.PowerApps/environments?`$expand=permissions&api-version={apiVersion}"

        $environmentsResult = InvokeApi -Method GET -Route $getAllEnvironmentsUri -ApiVersion $ApiVersion -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)

        Get-FilteredEnvironments -Filter $filterString -CreatedBy $createdByUserId -EnvironmentResult $environmentsResult
    }
}


function Get-PowerAppConnection(
)
{
    <#
    .SYNOPSIS
    Returns connections for the calling user.
    .DESCRIPTION
    The Get-PowerAppConnection returns the connections for a calling user.  The connections can be filtered by a specified environment or api.
    Use Get-Help Get-PowerAppConnection -Examples for more detail.
    .PARAMETER ConnectorNameFilter
    Finds connections created against a specific connector (wildcards supported), for example *twitter* will returns connections for the twitter connector.
    .PARAMETER ReturnFlowConnections
    Every flow that is created also has an associated connection created with it.  Those connections will only be returned if this flag is specified.
    .PARAMETER EnvironmentName
    Limit connections returned to those in a specified environment.
    .EXAMPLE
    Get-PowerAppConnection
    Finds all connections for which the user has access.
    .EXAMPLE
    Get-PowerAppConnection -ReturnFlowConnections
    Finds all connections for which the user has access., including the connection created for each flow that the user has access to.
    .EXAMPLE
    Get-PowerAppConnection -EnvironmentName 3c2f7648-ad60-4871-91cb-b77d7ef3c239
    Finds connections within the 3c2f7648-ad60-4871-91cb-b77d7ef3c239 environment for this user.
    .EXAMPLE
    Get-PowerAppConnection -ConnectorNameFilter *twitter*
    Finds all connections for this user created against the Twitter connector.
    .EXAMPLE
    Get-PowerAppConnection -EnvironmentName 3c2f7648-ad60-4871-91cb-b77d7ef3c239
    Finds connectinos for the current user within the 3c2f7648-ad60-4871-91cb-b77d7ef3c239 environment.
    .EXAMPLE
    Get-PowerAppConnection -ConnectionName a2956cf95ba441119d16dc2ef0ca1ff9 -EnvironmentName 87d7e1a3-6104-4889-a225-54a681b5532b
    Returns the connection details for the connectino with name a2956cf95ba441119d16dc2ef0ca1ff9.
    #>
    [CmdletBinding(DefaultParameterSetName="Connection")]
    param
    (
        [Parameter(Mandatory = $false,  Position = 0, ParameterSetName = "Connection", ValueFromPipelineByPropertyName = $true)]
        [string]$ConnectionName,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [string]$EnvironmentName,

        [Parameter(Mandatory = $false)]
        [string]$ConnectorNameFilter,

        [Parameter(Mandatory = $false)]
        [switch]$ReturnFlowConnections,

        [Parameter(Mandatory = $false)]
        [string]$ApiVersion = "2016-11-01"
    )
    process
    {
        $environments = @();

        if (-not [string]::IsNullOrWhiteSpace($EnvironmentName))
        {
            $environments += @{
                EnvironmentName = $EnvironmentName
            }
        }
        else {
            $environments = Get-PowerAppEnvironment
        }

        $flowFilter = "/providers/Microsoft.PowerApps/apis/shared_logicflows"
        $patternFlow = BuildFilterPattern -Filter $flowFilter

        $patternApi = BuildFilterPattern -Filter $ConnectorNameFilter

        $patternConnection = BuildFilterPattern -Filter $ConnectionName

        foreach($environment in $environments)
        {
            $route = "https://{powerAppsEndpoint}/providers/Microsoft.PowerApps/connections`?api-version={apiVersion}&`$filter=environment%20eq%20%27{environment}%27" `
            | ReplaceMacro -Macro "{environment}" -Value $environment.EnvironmentName;

            $getConnectionsResponse = InvokeApi -Method GET -Route $route -ApiVersion $ApiVersion -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)

            foreach($connection in $getConnectionsResponse.value)
            {
                if (-not [string]::IsNullOrWhiteSpace($ConnectionName))
                {
                    if ($patternConnection.IsMatch($connection.name))
                    {
                        CreateConnectionObject -ConnectionObj $connection
                    }
                }
                elseif($patternFlow.IsMatch($connection.properties.apiId))
                {
                    If($ReturnFlowConnections)
                    {
                        CreateConnectionObject -ConnectionObj $connection
                    }
                }
                elseif ($patternApi.IsMatch($connection.properties.apiId))
                {
                    CreateConnectionObject -ConnectionObj $connection
                }
            }
        }
    }
}

function Remove-PowerAppConnection
{
 <#
 .SYNOPSIS
 Deletes the connection.
 .DESCRIPTION
 The Remove-PowerAppConnection permanently deletes the connection.
 Use Get-Help Remove-PowerAppConnection -Examples for more detail.
 .PARAMETER ConnectionName
 The connection identifier.
 .PARAMETER ConnectorName
 The connection's connector name.
 .PARAMETER EnvironmentName
 The connection's environment.
 .EXAMPLE
 Remove-PowerAppConnection -ConnectionName 3c2f7648-ad60-4871-91cb-b77d7ef3c239 -ConnectorName shared_twitter -EnvironmentName Default-efecdc9a-c859-42fd-b215-dc9c314594dd
 Deletes the connection with name 3c2f7648-ad60-4871-91cb-b77d7ef3c239
 #>
    [CmdletBinding(DefaultParameterSetName="Name")]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "Name")]
        [string]$ConnectionName,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "Name")]
        [string]$ConnectorName,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "Name")]
        [string]$EnvironmentName,

        [Parameter(Mandatory = $false, ParameterSetName = "Name")]
        [string]$ApiVersion = "2017-06-01"
    )

    process
    {
        $route = "https://{powerAppsEndpoint}/providers/Microsoft.PowerApps/apis/{connector}/connections/{connection}`?api-version={apiVersion}&`$filter=environment%20eq%20%27{environment}%27" `
        | ReplaceMacro -Macro "{connector}" -Value $ConnectorName `
        | ReplaceMacro -Macro "{connection}" -Value $ConnectionName `
        | ReplaceMacro -Macro "{environment}" -Value $EnvironmentName;

        $removeResult = InvokeApi -Method DELETE -Route $route -ApiVersion $ApiVersion -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)

        If($removeResult -eq $null)
        {
            return $null
        }

        CreateHttpResponse($removeResult)
    }
}

function Get-PowerAppConnectionRoleAssignment
{
 <#
 .SYNOPSIS
 Returns the connection role assignments for a user or a connection. Owner role assignments cannot be deleted without deleting the connection resource.
 .DESCRIPTION
 The Get-PowerAppConnectionRoleAssignment functions returns all roles assignments for an connection or all connection roles assignments for a user (across all of their connections).  A connection's role assignments determine which users have access to the connection for using or building apps and flows and with which permission level (CanUse, CanUseAndShare) .
 Use Get-Help Get-PowerAppConnectionRoleAssignment -Examples for more detail.
 .PARAMETER ConnectionName
 The connection identifier.
 .PARAMETER EnvironmentName
 The connections's environment.
 .PARAMETER ConnectorName
 The connection's connector identifier.
 .PARAMETER PrincipalObjectId
 The objectId of a user or group, if specified, this function will only return role assignments for that user or group.
 .EXAMPLE
 Get-PowerAppConnectionRoleAssignment
 Returns all connection role assignments for the calling user.
 .EXAMPLE
 Get-PowerAppConnectionRoleAssignment -ConnectionName 3b4b9592607147258a4f2fb33517e97a -ConnectorName shared_sharepointonline -EnvironmentName ee1eef10-ba55-440b-a009-ce379f86e20c
 Returns all role assignments for the connection with name 3b4b9592607147258a4f2fb33517e97ain environment with name ee1eef10-ba55-440b-a009-ce379f86e20c for the connector named shared_sharepointonline
 .EXAMPLE
 Get-PowerAppConnectionRoleAssignment -ConnectionName 3b4b9592607147258a4f2fb33517e97a -ConnectorName shared_sharepointonline -EnvironmentName ee1eef10-ba55-440b-a009-ce379f86e20c -PrincipalObjectId 3c2f7648-ad60-4871-91cb-b77d7ef3c239
 Returns all role assignments for the user, or group with an object of 3c2f7648-ad60-4871-91cb-b77d7ef3c239 for the connection with name 3b4b9592607147258a4f2fb33517e97ain environment with name ee1eef10-ba55-440b-a009-ce379f86e20c for the connector named shared_sharepointonline
 #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $false, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]$ConnectionName,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [string]$ConnectorName,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [string]$EnvironmentName,

        [Parameter(Mandatory = $false)]
        [string]$PrincipalObjectId,

        [Parameter(Mandatory = $false)]
        [string]$ApiVersion = "2017-06-01"
    )

    process
    {
        $selectedObjectId = $global:currentSession.UserId

        if (-not [string]::IsNullOrWhiteSpace($ConnectionName))
        {
            if (-not [string]::IsNullOrWhiteSpace($PrincipalObjectId))
            {
                $selectedObjectId = $PrincipalObjectId;
            }
            else
            {
                $selectedObjectId = $null
            }
        }

        $pattern = BuildFilterPattern -Filter $selectedObjectId

        if (-not [string]::IsNullOrWhiteSpace($ConnectionName))
        {

            $route = "https://{powerAppsEndpoint}/providers/Microsoft.PowerApps/apis/{connector}/connections/{connection}/permissions?api-version={apiVersion}&`$filter=environment eq '{environment}'" `
            | ReplaceMacro -Macro "{connector}" -Value $ConnectorName `
            | ReplaceMacro -Macro "{connection}" -Value $ConnectionName `
            | ReplaceMacro -Macro "{environment}" -Value $EnvironmentName;

            $connectionRoleResult = InvokeApi -Method GET -Route $route -ApiVersion $ApiVersion -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)

            foreach ($connectionRole in $connectionRoleResult.Value)
            {
                if (-not [string]::IsNullOrWhiteSpace($PrincipalObjectId))
                {
                    if ($pattern.IsMatch($connectionRole.properties.principal.id ) -or
                        $pattern.IsMatch($connectionRole.properties.principal.email) -or
                        $pattern.IsMatch($connectionRole.properties.principal.tenantId))
                    {
                        CreateConnectionRoleAssignmentObject -ConnectionRoleAssignmentObj $connectionRole -EnvironmentName $EnvironmentName
                    }
                }
                else
                {
                    CreateConnectionRoleAssignmentObject -ConnectionRoleAssignmentObj $connectionRole -EnvironmentName $EnvironmentName
                }
            }
        }
        else
        {
            $connections = Get-PowerAppConnection

            foreach($connection in $connections)
            {
                Get-PowerAppConnectionRoleAssignment `
                    -ConnectionName $connection.ConnectionName `
                    -ConnectorName $connection.ConnectorName `
                    -EnvironmentName $connection.EnvironmentName `
                    -PrincipalObjectId $selectedObjectId `
                    -ApiVersion $ApiVersion `
					-Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
            }
        }
    }
}

function Set-PowerAppConnectionRoleAssignment
{
    <#
    .SYNOPSIS
    Sets permissions to the connection.
    .DESCRIPTION
    The Set-PowerAppConnectionRoleAssignment set up permission to connection depending on parameters.
    Use Get-Help Set-PowerAppConnectionRoleAssignment -Examples for more detail.
    .PARAMETER ConnectionName
    The connection identifier.
    .PARAMETER EnvironmentName
    The connections's environment.
    .PARAMETER ConnectorName
    The connection's connector identifier.
    .PARAMETER RoleName
    Specifies the permission level given to the connection: CanView, CanViewWithShare, CanEdit. Sharing with the entire tenant is only supported for CanView.
    .PARAMETER PrincipalType
    Specifies the type of principal this connection is being shared with; a user, a security group, the entire tenant.
    .PARAMETER PrincipalObjectId
    If this connection is being shared with a user or security group principal, this field specified the ObjectId for that principal. You can use the Get-UsersOrGroupsFromGraph API to look-up the ObjectId for a user or group in Azure Active Directory.
    .EXAMPLE
    Set-PowerAppConnectionRoleAssignment -PrincipalType Group -PrincipalObjectId b049bf12-d56d-4b50-8176-c6560cbd35aa -RoleName CanEdit -ConnectionName 3b4b9592607147258a4f2fb33517e97a -ConnectorName shared_vsts -EnvironmentName Default-55abc7e5-2812-4d73-9d2f-8d9017f8c877
    Give the specified security group CanEdit permissions to the connection with name 3b4b9592607147258a4f2fb33517e97a
    #>
    [CmdletBinding(DefaultParameterSetName="User")]
    param
    (
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = "Tenant", ValueFromPipelineByPropertyName = $true)]
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = "User", ValueFromPipelineByPropertyName = $true)]
        [string]$ConnectionName,

        [Parameter(Mandatory = $true, ParameterSetName = "Tenant", ValueFromPipelineByPropertyName = $true)]
        [Parameter(Mandatory = $true, ParameterSetName = "User", ValueFromPipelineByPropertyName = $true)]
        [string]$ConnectorName,

        [Parameter(Mandatory = $true, ParameterSetName = "Tenant", ValueFromPipelineByPropertyName = $true)]
        [Parameter(Mandatory = $true, ParameterSetName = "User", ValueFromPipelineByPropertyName = $true)]
        [string]$EnvironmentName,

        [Parameter(Mandatory = $true, ParameterSetName = "Tenant", ValueFromPipelineByPropertyName = $true)]
        [Parameter(Mandatory = $true, ParameterSetName = "User", ValueFromPipelineByPropertyName = $true)]
        [ValidateSet("CanView", "CanViewWithShare", "CanEdit")]
        [string]$RoleName,

        [Parameter(Mandatory = $true, ParameterSetName = "Tenant", ValueFromPipelineByPropertyName = $true)]
        [Parameter(Mandatory = $true, ParameterSetName = "User", ValueFromPipelineByPropertyName = $true)]
        [ValidateSet("User", "Group", "Tenant")]
        [string]$PrincipalType,

        [Parameter(Mandatory = $false, ParameterSetName = "Tenant")]
        [Parameter(Mandatory = $true, ParameterSetName = "User")]
        [string]$PrincipalObjectId = $null,

        [Parameter(Mandatory = $false, ParameterSetName = "User")]
        [Parameter(Mandatory = $false, ParameterSetName = "Tenant")]
        [string]$ApiVersion = "2017-06-01"
    )

    process
    {
        $TenantId = $Global:currentSession.tenantId

        if($PrincipalType -ne "Tenant")
        {
            $userOrGroup = Get-UsersOrGroupsFromGraph -ObjectId $PrincipalObjectId
            $PrincipalEmail = $userOrGroup.Mail
        }

        $route = "https://{powerAppsEndpoint}/providers/Microsoft.PowerApps/apis/{connector}/connections/{connection}/modifyPermissions?api-version={apiVersion}&`$filter=environment eq '{environment}'" `
        | ReplaceMacro -Macro "{connector}" -Value $ConnectorName `
        | ReplaceMacro -Macro "{connection}" -Value $ConnectionName `
        | ReplaceMacro -Macro "{environment}" -Value $EnvironmentName;

        #Construct the body
        $requestbody = $null

        If ($PrincipalType -eq "Tenant")
        {
            $requestbody = @{
                delete = @()
                put = @(
                    @{
                        properties = @{
                            roleName = $RoleName
                            capabilities = @()
                            NotifyShareTargetOption = "Notify"
                            principal = @{
                                email = ""
                                id = $TenantId
                                type = $PrincipalType
                                tenantId = $TenantId
                            }
                        }
                    }
                )
            }
        }
        else
        {
            $requestbody = @{
                delete = @()
                put = @(
                    @{
                        properties = @{
                            roleName = $RoleName
                            capabilities = @()
                            NotifyShareTargetOption = "Notify"
                            principal = @{
                                email = $PrincipalEmail
                                id = $PrincipalObjectId
                                type = $PrincipalType
                                tenantId = $TenantId
                            }
                        }
                    }
                )
            }
        }

        $setConnectionRoleResult = InvokeApi -Method POST -Body $requestbody -Route $route -ApiVersion $ApiVersion -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)

        CreateHttpResponse($setConnectionRoleResult)
    }
}

function Remove-PowerAppConnectionRoleAssignment
{
 <#
 .SYNOPSIS
 Deletes a connection role assignment record.
 .DESCRIPTION
 The Remove-PowerAppConnectionRoleAssignment deletes the specific connection role assignment
 Use Get-Help Remove-PowerAppConnectionRoleAssignment -Examples for more detail.
 .PARAMETER RoleId
 The id of the role assignment to be deleted.
 .PARAMETER ConnectionName
 The app identifier.
 .PARAMETER ConnectorName
 The connection's associated connector name
 .PARAMETER EnvironmentName
 The connection's environment.
 .EXAMPLE
 Remove-PowerAppConnectionRoleAssignment -ConnectionName a2956cf95ba441119d16dc2ef0ca1ff9 -EnvironmentName 08b4e32a-4e0d-4a69-97da-e1640f0eb7b9 -ConnectorName shared_twitter -RoleId /providers/Microsoft.PowerApps/apis/shared_twitter/connections/a2956cf95ba441119d16dc2ef0ca1ff9/permissions/7557f390-5f70-4c93-8bc4-8c2faabd2ca0
 Deletes the app role assignment with an id of /providers/Microsoft.PowerApps/apps/f8d7a19d-f8f9-4e10-8e62-eb8c518a2eb4/permissions/tenant-efecdc9a-c859-42fd-b215-dc9c314594dd
 #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $false, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]$ConnectionName,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [string]$ConnectorName,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [string]$EnvironmentName,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [string]$RoleId,

        [Parameter(Mandatory = $false)]
        [string]$ApiVersion = "2017-06-01"
    )

    process
    {
        $route = "https://{powerAppsEndpoint}/providers/Microsoft.PowerApps/apis/{connector}/connections/{connection}/modifyPermissions`?api-version={apiVersion}&`$filter=environment%20eq%20%27{environment}%27" `
        | ReplaceMacro -Macro "{connector}" -Value $ConnectorName `
        | ReplaceMacro -Macro "{connection}" -Value $ConnectionName `
        | ReplaceMacro -Macro "{environment}" -Value $EnvironmentName;

        #Construct the body
        $requestbody = $null

        $requestbody = @{
            delete = @(
                @{
                    id = $RoleId
                }
            )
        }

        $removeResult = InvokeApi -Method POST -Body $requestbody -Route $route -ApiVersion $ApiVersion -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)

        If($removeResult -eq $null)
        {
            return $null
        }

        CreateHttpResponse($removeResult)
    }
}

function Get-PowerAppConnector(
)
{
    <#
    .SYNOPSIS
    Returns connectors for the calling user.
    .DESCRIPTION
    The Get-PowerAppConnector returns the Connector for a calling user.  The Connector can be filtered by a specified environment or to only return custom connectors created by users.
    Use Get-Help Get-PowerAppConnector -Examples for more detail.
    .PARAMETER Filter
    Finds connectors matching the specified filter (wildcards supported), searches against the Connector's Name and DisplayName
    .PARAMETER FilterNonCustomConnectors
    Setting this flag will filter out all of the shared connectors built by microsfot such as Twitter, SharePoint, OneDrive, etc.
    .PARAMETER EnvironmentName
    Limit connectors returned to those in a specified environment.
    .PARAMETER ConnectorName
    Limits the details returned to only a certain specific connector
    .PARAMETER ReturnConnectorSwagger
    This parameter can only be set if the ConnectorName is populated, and, when set, will return additional metdata for the connector such as the Swagger and runtime Urls.
    .EXAMPLE
    Get-PowerAppConnector
    Finds all connectors that a user has access to across all environments (shared connectors will be duplicated in the response).
    .EXAMPLE
    Get-PowerAppConnector -FilterNonCustomConnectors
    Finds all custom connectors for which the user has access.
    .EXAMPLE
    Get-PowerAppConnector -EnvironmentName 3c2f7648-ad60-4871-91cb-b77d7ef3c239
    Finds connectors within the 3c2f7648-ad60-4871-91cb-b77d7ef3c239 environment for this user.
    .EXAMPLE
    Get-PowerAppConnector -Filter *twitter*
    Finds all connectors (both shared and custom) with the name Twitter.
    .EXAMPLE
    Get-PowerAppConnector -ConnectorName shared_sharepointonline -EnvironmentName 87d7e1a3-6104-4889-a225-54a681b5532b -ReturnConnectorSwagger
    Returns the connector details (including the swagger) for the connector named shared_sharepointonline in environment 87d7e1a3-6104-4889-a225-54a681b5532b
    #>
    [CmdletBinding(DefaultParameterSetName="Filter")]
    param
    (
        [Parameter(Mandatory = $false, Position = 0, ParameterSetName = "Filter")]
        [string[]]$Filter,

        [Parameter(Mandatory = $false, ParameterSetName = "Filter")]
        [switch]$FilterNonCustomConnectors,

        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = "Connector", ValueFromPipelineByPropertyName = $true)]
        [string]$ConnectorName,

        [Parameter(Mandatory = $true, ParameterSetName = "Connector", ValueFromPipelineByPropertyName = $true)]
        [Parameter(Mandatory = $false, ParameterSetName = "Filter", ValueFromPipelineByPropertyName = $true)]
        [string]$EnvironmentName,

        [Parameter(Mandatory = $false, ParameterSetName = "Connector")]
        [switch]$ReturnConnectorSwagger,

        [Parameter(Mandatory = $false, ParameterSetName = "Connector")]
        [Parameter(Mandatory = $false, ParameterSetName = "Filter")]
        [string]$ApiVersion = "2016-11-01"

    )
    process
    {
        $environments = @();

        if (-not [string]::IsNullOrWhiteSpace($EnvironmentName))
        {
            $environments += @{
                EnvironmentName = $EnvironmentName
            }
        }
        else {
            $environments = Get-PowerAppEnvironment
        }

        $userId = $Global:currentSession.userId
        $expandPermissions = "permissions(`$filter=maxAssignedTo(`'$userId`'))"

        $patternConnector = BuildFilterPattern -Filter $ConnectorName
        $patternFilter = BuildFilterPattern -Filter $Filter
        $patternSharedConnector =  BuildFilterPattern -Filter "Microsoft"

        foreach($environment in $environments)
        {
            if($ReturnConnectorSwagger)
            {
                $route = "https://{powerAppsEndpoint}/providers/Microsoft.PowerApps/apis/{connector}?`$expand={expandPermissions}&`$filter=environment%20eq%20%27{environment}%27&api-version={apiVersion}" `
                | ReplaceMacro -Macro "{expandPermissions}" -Value $expandPermissions `
                | ReplaceMacro -Macro "{connector}" -Value $ConnectorName `
                | ReplaceMacro -Macro "{environment}" -Value $environment.EnvironmentName;

                $getConnectorsResponse = InvokeApi -Method GET -Route $route -ApiVersion $ApiVersion -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)

                $connectors = $getConnectorsResponse
            }
            else
            {
                $route = "https://{powerAppsEndpoint}/providers/Microsoft.PowerApps/apis?showApisWithToS=true&`$expand={expandPermissions}&`$filter=environment%20eq%20%27{environment}%27&api-version={apiVersion}" `
                | ReplaceMacro -Macro "{expandPermissions}" -Value $expandPermissions `
                | ReplaceMacro -Macro "{environment}" -Value $environment.EnvironmentName;

                $getConnectorsResponse = InvokeApi -Method GET -Route $route -ApiVersion $ApiVersion -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)

                $connectors = $getConnectorsResponse.value
            }

            foreach($connector in $connectors)
            {
                if (-not [string]::IsNullOrWhiteSpace($ConnectorName))
                {
                    if ($patternConnector.IsMatch($connector.name))
                    {
                        CreateConnectorObject -ConnectorObj $connector -EnvironmentName $environment.EnvironmentName
                    }
                }
                elseif($patternFilter.IsMatch($connector.name) -or
                    $patternFilter.IsMatch($ConnectorObj.properties.displayName))
                {
                    #If(-not($FilterNonCustomConnectors -and $patternSharedConnector.IsMatch($connector.properties.metadata.source)))
                    If(-not($FilterNonCustomConnectors -and $patternSharedConnector.IsMatch($connector.properties.publisher)))
                    {
                        CreateConnectorObject -ConnectorObj $connector -EnvironmentName $environment.EnvironmentName
                    }
                }
            }
        }
    }
}

function Remove-PowerAppConnector
{
 <#
 .SYNOPSIS
 Deletes the custom connector.
 .DESCRIPTION
 The Remove-PowerAppConnector permanently deletes the custom connector.
 Use Get-Help Remove-PowerAppConnector -Examples for more detail.
 .PARAMETER ConnectorName
 The custom connector name.
 .PARAMETER EnvironmentName
 The connector's environment.
 .EXAMPLE
 Remove-PowerAppConnector -ConnectorName shared_api.5fb47d90c037a0f41d.5fa9f4751f014dccc8 -EnvironmentName Default-efecdc9a-c859-42fd-b215-dc9c314594dd
 Deletes the connection with name shared_api.5fb47d90c037a0f41d.5fa9f4751f014dccc8
 #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$ConnectorName,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$EnvironmentName,

        [Parameter(Mandatory = $false)]
        [string]$ApiVersion = "2017-06-01"
    )

    process
    {
        $route = "https://{powerAppsEndpoint}/providers/Microsoft.PowerApps/apis/{connector}`?api-version={apiVersion}&`$filter=environment%20eq%20%27{environment}%27" `
        | ReplaceMacro -Macro "{connector}" -Value $ConnectorName `
        | ReplaceMacro -Macro "{environment}" -Value $EnvironmentName;

        $removeResult = InvokeApi -Method DELETE -Route $route -ApiVersion $ApiVersion -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)

        If($removeResult -eq $null)
        {
            return $null
        }

        CreateHttpResponse($removeResult)
    }
}

function Get-PowerAppConnectorRoleAssignment
{
 <#
 .SYNOPSIS
 Returns the connector role assignments for a user or a connector.
 .DESCRIPTION
 The Get-PowerAppConnectorRoleAssignment functions returns all roles assignments for an connector or all connector roles assignments for a user (across all of their connectors).  A connector's role assignments determine which users have access to the connector for using or building apps and flows and with which permission level (CanEdit, CanView) .
 Use Get-Help Get-PowerAppConnectorRoleAssignment -Examples for more detail.
 .PARAMETER EnvironmentName
 The connections's environment.
 .PARAMETER ConnectorName
 The connection's connector identifier.
 .PARAMETER PrincipalObjectId
 The objectId of a user or group, if specified, this function will only return role assignments for that user or group.
 .EXAMPLE
 Get-PowerAppConnectionRoleAssignment
 Returns all connection role assignments for the calling user.
 .EXAMPLE
 Get-PowerAppConnectionRoleAssignment  -ConnectorName shared_sharepointonline -EnvironmentName ee1eef10-ba55-440b-a009-ce379f86e20c
 Returns all role assignments for the connector named shared_sharepointonline in the environment with name ee1eef10-ba55-440b-a009-ce379f86e20c
 .EXAMPLE
 Get-PowerAppConnectionRoleAssignment -ConnectorName shared_sharepointonline -EnvironmentName ee1eef10-ba55-440b-a009-ce379f86e20c -PrincipalObjectId 3c2f7648-ad60-4871-91cb-b77d7ef3c239
 Returns all role assignments for the user, or group with an object of 3c2f7648-ad60-4871-91cb-b77d7ef3c239 for the connector named shared_sharepointonline in the environment with name ee1eef10-ba55-440b-a009-ce379f86e20c
 #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [string]$ConnectorName,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [string]$EnvironmentName,

        [Parameter(Mandatory = $false)]
        [string]$PrincipalObjectId,

        [Parameter(Mandatory = $false)]
        [string]$ApiVersion = "2017-06-01"
    )

    process
    {
        $selectedObjectId = $global:currentSession.UserId

        if (-not [string]::IsNullOrWhiteSpace($ConnectorName))
        {
            if (-not [string]::IsNullOrWhiteSpace($PrincipalObjectId))
            {
                $selectedObjectId = $PrincipalObjectId;
            }
            else
            {
                $selectedObjectId = $null
            }
        }

        $pattern = BuildFilterPattern -Filter $selectedObjectId

        if (-not [string]::IsNullOrWhiteSpace($ConnectorName))
        {

            $route = "https://{powerAppsEndpoint}/providers/Microsoft.PowerApps/apis/{connector}/permissions?api-version={apiVersion}&`$filter=environment eq '{environment}'" `
            | ReplaceMacro -Macro "{connector}" -Value $ConnectorName `
            | ReplaceMacro -Macro "{environment}" -Value $EnvironmentName;

            $connectorRoleResult = InvokeApi -Method GET -Route $route -ApiVersion $ApiVersion -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)

            foreach ($connectorRole in $connectorRoleResult.Value)
            {
                if (-not [string]::IsNullOrWhiteSpace($PrincipalObjectId))
                {
                    if ($pattern.IsMatch($connectorRole.properties.principal.id ) -or
                        $pattern.IsMatch($connectorRole.properties.principal.email) -or
                        $pattern.IsMatch($connectorRole.properties.principal.tenantId))
                    {
                        CreateConnectorRoleAssignmentObject -ConnectorRoleAssignmentObj $connectorRole -EnvironmentName $EnvironmentName
                    }
                }
                else
                {
                    CreateConnectorRoleAssignmentObject -ConnectorRoleAssignmentObj $connectorRole -EnvironmentName $EnvironmentName
                }
            }
        }
        else
        {
            $connectors = Get-PowerAppConnector -FilterNonCustomConnectors

            foreach($connector in $connectors)
            {
                Get-PowerAppConnectorRoleAssignment `
                    -ConnectorName $connector.ConnectorName `
                    -EnvironmentName $connector.EnvironmentName `
                    -PrincipalObjectId $selectedObjectId `
                    -ApiVersion $ApiVersion `
					-Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
            }
        }
    }
}

function Remove-PowerAppConnectorRoleAssignment
{
 <#
 .SYNOPSIS
 Deletes a connector role assignment record.
 .DESCRIPTION
 The Remove-PowerAppConnectorRoleAssignment deletes the specific connector role assignment
 Use Get-Help Remove-PowerAppConnectorRoleAssignment -Examples for more detail.
 .PARAMETER RoleId
 The id of the role assignment to be deleted.
 .PARAMETER ConnectorName
 The connector name
 .PARAMETER EnvironmentName
 The connector's environment.
 .EXAMPLE
 Remove-PowerAppConnectorRoleAssignment -EnvironmentName 08b4e32a-4e0d-4a69-97da-e1640f0eb7b9 -ConnectorName shared_twitter -RoleId /providers/Microsoft.PowerApps/apis/shared_twitter/connections/a2956cf95ba441119d16dc2ef0ca1ff9/permissions/7557f390-5f70-4c93-8bc4-8c2faabd2ca0
 Deletes the app role assignment with an id of /providers/Microsoft.PowerApps/apps/f8d7a19d-f8f9-4e10-8e62-eb8c518a2eb4/permissions/tenant-efecdc9a-c859-42fd-b215-dc9c314594dd
 #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $false,  Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]$ConnectorName,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [string]$EnvironmentName,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [string]$RoleId,

        [Parameter(Mandatory = $false)]
        [string]$ApiVersion = "2017-06-01"
    )

    process
    {
        $route = "https://{powerAppsEndpoint}/providers/Microsoft.PowerApps/apis/{connector}/modifyPermissions`?api-version={apiVersion}&`$filter=environment%20eq%20%27{environment}%27" `
        | ReplaceMacro -Macro "{connector}" -Value $ConnectorName `
        | ReplaceMacro -Macro "{environment}" -Value $EnvironmentName;

        #Construct the body
        $requestbody = $null

        $requestbody = @{
            delete = @(
                @{
                    id = $RoleId
                }
            )
        }

        $removeResult = InvokeApi -Method POST -Body $requestbody -Route $route -ApiVersion $ApiVersion -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)

        If($removeResult -eq $null)
        {
            return $null
        }

        CreateHttpResponse($removeResult)
    }
}

function Set-PowerAppConnectorRoleAssignment
{
    <#
    .SYNOPSIS
    Sets permissions to the connector.
    .DESCRIPTION
    The Set-PowerAppConnectorRoleAssignment set up permission to connector depending on parameters.
    Use Get-Help Set-PowerAppConnectorRoleAssignment -Examples for more detail.
    .PARAMETER ConnectorName
    The connector identifier.
    .PARAMETER EnvironmentName
    The connector's environment.
    .PARAMETER RoleName
    Specifies the permission level given to the connector: CanView, CanViewWithShare, CanEdit. Sharing with the entire tenant is only supported for CanView.
    .PARAMETER PrincipalType
    Specifies the type of principal this connector is being shared with; a user, a security group, the entire tenant.
    .PARAMETER PrincipalObjectId
    If this connector is being shared with a user or security group principal, this field specified the ObjectId for that principal. You can use the Get-UsersOrGroupsFromGraph API to look-up the ObjectId for a user or group in Azure Active Directory.
    .EXAMPLE
    Set-PowerAppConnectorRoleAssignment -PrincipalType Group -PrincipalObjectId b049bf12-d56d-4b50-8176-c6560cbd35aa -RoleName CanEdit -ConnectorName shared_vsts -EnvironmentName Default-55abc7e5-2812-4d73-9d2f-8d9017f8c877
    Give the specified security group CanEdit permissions to the connector with name shared_vsts
    #>
    [CmdletBinding(DefaultParameterSetName="User")]
    param
    (
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = "Tenant", ValueFromPipelineByPropertyName = $true)]
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = "User", ValueFromPipelineByPropertyName = $true)]
        [string]$ConnectorName,

        [Parameter(Mandatory = $true, ParameterSetName = "Tenant", ValueFromPipelineByPropertyName = $true)]
        [Parameter(Mandatory = $true, ParameterSetName = "User", ValueFromPipelineByPropertyName = $true)]
        [string]$EnvironmentName,

        [Parameter(Mandatory = $true, ParameterSetName = "Tenant", ValueFromPipelineByPropertyName = $true)]
        [Parameter(Mandatory = $true, ParameterSetName = "User", ValueFromPipelineByPropertyName = $true)]
        [ValidateSet("CanView", "CanViewWithShare", "CanEdit")]
        [string]$RoleName,

        [Parameter(Mandatory = $true, ParameterSetName = "Tenant", ValueFromPipelineByPropertyName = $true)]
        [Parameter(Mandatory = $true, ParameterSetName = "User", ValueFromPipelineByPropertyName = $true)]
        [ValidateSet("User", "Group", "Tenant")]
        [string]$PrincipalType,

        [Parameter(Mandatory = $false, ParameterSetName = "Tenant")]
        [Parameter(Mandatory = $true, ParameterSetName = "User")]
        [string]$PrincipalObjectId = $null,

        [Parameter(Mandatory = $false, ParameterSetName = "User")]
        [Parameter(Mandatory = $false, ParameterSetName = "Tenant")]
        [string]$ApiVersion = "2017-06-01"
    )

    process
    {
        $TenantId = $Global:currentSession.tenantId

        if($PrincipalType -ne "Tenant")
        {
            $userOrGroup = Get-UsersOrGroupsFromGraph -ObjectId $PrincipalObjectId
            $PrincipalEmail = $userOrGroup.Mail
        }

        $route = "https://{powerAppsEndpoint}/providers/Microsoft.PowerApps/apis/{connector}/modifyPermissions?api-version={apiVersion}&`$filter=environment eq '{environment}'" `
        | ReplaceMacro -Macro "{connector}" -Value $ConnectorName `
        | ReplaceMacro -Macro "{connection}" -Value $ConnectionName `
        | ReplaceMacro -Macro "{environment}" -Value $EnvironmentName;

        #Construct the body
        $requestbody = $null

        If ($PrincipalType -eq "Tenant")
        {
            $requestbody = @{
                put = @(
                    @{
                        properties = @{
                            roleName = $RoleName
                            principal = @{
                                email = " "
                                id = $TenantId
                                type = $PrincipalType
                                tenantId = $TenantId
                            }
                        }
                    }
                )
            }
        }
        else
        {
            $requestbody = @{
                delete = @()
                put = @(
                    @{
                        properties = @{
                            roleName = $RoleName
                            capabilities = @()
                            NotifyShareTargetOption = "Notify"
                            principal = @{
                                email = $PrincipalEmail
                                id = $PrincipalObjectId
                                type = $PrincipalType
                                tenantId = $TenantId
                            }
                        }
                    }
                )
            }
        }

        $setConnectorRoleResult = InvokeApi -Method POST -Body $requestbody -Route $route -ApiVersion $ApiVersion -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)

        CreateHttpResponse($setConnectorRoleResult)
    }
}

function Get-PowerApp
{
 <#
 .SYNOPSIS
 Returns information about one or more apps.
 .DESCRIPTION
 The Get-PowerApp looks up information about one or more apps depending on parameters.
 Use Get-Help Get-PowerApp -Examples for more detail.
 .PARAMETER Filter
 Finds apps matching the specified filter (wildcards supported).
 .PARAMETER AppName
 Finds a specific id.
 .PARAMETER MyEditable
 Limits the query to only apps that are owned or where the user has CanEdit access, this filter is applicable only if the EnvironmentName parameter is populated.
 .PARAMETER EnvironmentName
 Limit apps returned to those in a specified environment.
 .EXAMPLE
 Get-PowerApp
 Finds all apps for which the user has access.
 .EXAMPLE
 Get-PowerApp -EnvironmentName 3c2f7648-ad60-4871-91cb-b77d7ef3c239
 Finds apps within the 3c2f7648-ad60-4871-91cb-b77d7ef3c239 environment
 .EXAMPLE
 Get-PowerApp *PowerApps*
 Finds all app in the current environment that contain the string "PowerApps" in their display name.
 .EXAMPLE
 Get-PowerApp -AppName 3c2f7648-ad60-4871-91cb-b77d7ef3c239
 Returns the details for the app named 3c2f7648-ad60-4871-91cb-b77d7ef3c239.
 .EXAMPLE
 Get-PowerApp -MyEditable -EnvironmentName 3c2f7648-ad60-4871-91cb-b77d7ef3c239
 Shows apps owned or editable by the current user within the 3c2f7648-ad60-4871-91cb-b77d7ef3c239 environment.
 #>
    [CmdletBinding(DefaultParameterSetName="Filter")]
    param
    (
        [Parameter(Mandatory = $false, Position = 0, ParameterSetName = "Filter")]
        [string[]]$Filter,

        [Parameter(Mandatory = $false, Position = 0, ParameterSetName = "Name", ValueFromPipelineByPropertyName = $true)]
        [string]$AppName,

        [Parameter(Mandatory = $false, ParameterSetName = "Filter")]
        [Switch]$MyEditable,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [string]$EnvironmentName,

        [Parameter(Mandatory = $false, ParameterSetName = "Filter")]
        [Parameter(Mandatory = $false, ParameterSetName = "Name")]
        [string]$ApiVersion = "2016-11-01"
    )

    process
    {
        if (-not [string]::IsNullOrWhiteSpace($AppName))
        {
            $route = "https://{powerAppsEndpoint}/providers/Microsoft.PowerApps/apps/{appName}?api-version={apiVersion}&`$expand=unpublishedAppDefinition" `
            | ReplaceMacro -Macro "{appName}" -Value $AppName;

            $appResult = InvokeApi -Method GET -Route $route -ApiVersion $ApiVersion -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)

            CreateAppObject -AppObj $appResult;
        }
        else
        {
            $userId = $Global:currentSession.userId
            $expandPermissions = "permissions(`$filter=maxAssignedTo(`'$userId`'))"

            if(-not [string]::IsNullOrWhiteSpace($EnvironmentName))
            {
                If($MyEditable)
                {
                    $queryFilter = "environment eq '{environment}'"
                }
                else
                {
                    $queryFilter = "classification eq 'EditableApps' and environment eq '{environment}'"
                }

                $route = "https://{powerAppsEndpoint}/providers/Microsoft.PowerApps/apps?api-version={apiVersion}&`$expand={expandPermissions}&`$filter={queryFilter}&`$top=250" `
                | ReplaceMacro -Macro "{expandPermissions}" -Value $expandPermissions `
                | ReplaceMacro -Macro "{queryFilter}" -Value $queryFilter `
                | ReplaceMacro -Macro "{environment}" -Value (ResolveEnvironment -OverrideId $EnvironmentName);
            }
            else
            {
                $route = "https://{powerAppsEndpoint}/providers/Microsoft.PowerApps/apps?api-version={apiVersion}&`$expand={expandPermissions}&`$top=250" `
                    | ReplaceMacro -Macro "{expandPermissions}" -Value $expandPermissions;
            }
            $appResult = InvokeApi -Method GET -Route $route -ApiVersion $ApiVersion -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)

            $pattern = BuildFilterPattern -Filter $Filter

            foreach ($app in $appResult.Value)
            {
                if ($pattern.IsMatch($app.name) -or
                    $pattern.IsMatch($app.properties.displayName))
                {
                    CreateAppObject -AppObj $app
                }
            }
        }
    }
}

function Remove-PowerApp
{
 <#
 .SYNOPSIS
 Deletes the app.
 .DESCRIPTION
 The Remove-PowerApp permanently deletes the app.
 Use Get-Help Remove-PowerApp -Examples for more detail.
 .PARAMETER AppName
 The app identifier.
 .EXAMPLE
 Remove-PowerApp -AppName 3c2f7648-ad60-4871-91cb-b77d7ef3c239
 Deletes the app with name 3c2f7648-ad60-4871-91cb-b77d7ef3c239
 #>
    [CmdletBinding(DefaultParameterSetName="Name")]
    param
    (
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = "Name", ValueFromPipelineByPropertyName = $true)]
        [string]$AppName,

        [Parameter(Mandatory = $false, ParameterSetName = "Name")]
        [string]$ApiVersion = "2017-06-01"
    )

    process
    {
        $route = "https://{powerAppsEndpoint}/providers/Microsoft.PowerApps/apps/{appName}?api-version={apiVersion}" `
        | ReplaceMacro -Macro "{appName}" -Value $AppName;

        $removeResult = InvokeApi -Method DELETE -Route $route -ApiVersion $ApiVersion -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)

        CreateHttpResponse -ResponseObject $removeResult
    }
}

function Publish-PowerApp
{
 <#
 .SYNOPSIS
 Publishes the current 'draft' version of the app to be the 'live' version of the app.  All users of the app will be able to see the new version post-publishing.
 .DESCRIPTION
 The Publish-PowerApp publishes the draft version of the specified app to all users.
 Use Get-Help Publish-PowerApp -Examples for more detail.
 .PARAMETER AppName
 The app identifier.
 .EXAMPLE
 Publish-PowerApp -AppName 3c2f7648-ad60-4871-91cb-b77d7ef3c239
 Publishes the draft vesrion of the app with name 3c2f7648-ad60-4871-91cb-b77d7ef3c239
 #>
    [CmdletBinding(DefaultParameterSetName="Name")]
    param
    (
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = "Name", ValueFromPipelineByPropertyName = $true)]
        [string]$AppName,

        [Parameter(Mandatory = $false, ParameterSetName = "Name")]
        [string]$ApiVersion = "2017-06-01"
    )

    process
    {
        $route = "https://{powerAppsEndpoint}/providers/Microsoft.PowerApps/apps/{appName}/publish?api-version={apiVersion}" `
        | ReplaceMacro -Macro "{appName}" -Value $AppName;

        $publishResult = InvokeApi -Method POST -Body @{} -Route $route -ApiVersion $ApiVersion -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)

        CreateHttpResponse -ResponseObject $publishResult
    }
}

function Set-PowerAppDisplayName
{
 <#
 .SYNOPSIS
 Sets the app display name.
 .DESCRIPTION
 The Set-PowerAppDisplayName changes the display name of the app to the specified string.
 Use Get-Help Set-PowerAppDisplayName -Examples for more detail.
 .PARAMETER AppName
 The app identifier.
 .PARAMETER AppDisplayName
 The new display name fo the app.
 .EXAMPLE
 Set-PowerAppDisplayName -AppName 3c2f7648-ad60-4871-91cb-b77d7ef3c239 -AppDisplayName "New App Display Name"
 Set the display name of the app with id 3c2f7648-ad60-4871-91cb-b77d7ef3c239 to "New App Display Name"
 #>
    [CmdletBinding(DefaultParameterSetName="Name")]
    param
    (
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = "Name", ValueFromPipelineByPropertyName = $true)]
        [string]$AppName,

        [Parameter(Mandatory = $true, ParameterSetName = "Name")]
        [string]$AppDisplayName,

        [Parameter(Mandatory = $false, ParameterSetName = "Name")]
        [string]$ApiVersion = "2017-06-01"
    )

    process
    {
        $route = "https://{powerAppsEndpoint}/providers/Microsoft.PowerApps/apps/{appName}/displayName?api-version={apiVersion}" `
        | ReplaceMacro -Macro "{appName}" -Value $AppName;

        $body = @{
            displayName = $AppDisplayName
        }

        $publishResult = InvokeApi -Method PUT -Body $body -Route $route -ApiVersion $ApiVersion -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
    }
}

function Get-PowerAppVersion
{
 <#
 .SYNOPSIS
 Returns all of versions of an app.  Whenever an PowerApps Studio ends, the changes made during the session are saved to the app's single draft version (i.e. the version with lifeCycleId=Draft). The most recent version with a lifeCycleId=Published is the version that is live to all users of the app.
 .DESCRIPTION
 The Get-PowerAppVersion returns all previous published versions of an app and the draft version if it exists.
 Use Get-Help Get-PowerAppVersion -Examples for more detail.
 .PARAMETER AppName
 The app identifier.
 .PARAMETER LatestDraft
 Limits the query to only return the latest draft version of the app, if it exists.
 .PARAMETER LatestPublished
 Limits the query to only return the latest published version of the app.
 .EXAMPLE
 Get-PowerAppVersion -AppName 3c2f7648-ad60-4871-91cb-b77d7ef3c239
 Returns all versions of the app with name 3c2f7648-ad60-4871-91cb-b77d7ef3c239
 .EXAMPLE
 Get-PowerAppVersion -AppName 3c2f7648-ad60-4871-91cb-b77d7ef3c239 -LatestDraft
 Returns the draft version (if exists) of the app  with name 3c2f7648-ad60-4871-91cb-b77d7ef3c239
 .EXAMPLE
 Get-PowerAppVersion -AppName 3c2f7648-ad60-4871-91cb-b77d7ef3c239 -LatestPublished
 Returns the latest published version of the app with name 3c2f7648-ad60-4871-91cb-b77d7ef3c239
 #>
    [CmdletBinding(DefaultParameterSetName="Name")]
    param
    (
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = "Name", ValueFromPipelineByPropertyName = $true)]
        [string]$AppName,

        [Parameter(Mandatory = $false, ParameterSetName = "Name")]
        [Switch]$LatestDraft,

        [Parameter(Mandatory = $false, ParameterSetName = "Name")]
        [Switch]$LatestPublished,

        [Parameter(Mandatory = $false, ParameterSetName = "Name")]
        [string]$ApiVersion = "2017-06-01"
    )

    process
    {
        $route = "https://{powerAppsEndpoint}/providers/Microsoft.PowerApps/apps/{appName}/versions?api-version={apiVersion}" `
        | ReplaceMacro -Macro "{appName}" -Value $AppName;

        $versionsResult = InvokeApi -Method GET -Route $route -ApiVersion $ApiVersion -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)

        $latestPublishedDate = $null
        $latestPublishedAppVersion = $null

        $publishedFound = $false
        $draftFound = $false

        foreach ($appVersion in $versionsResult.Value)
        {
            if ($LatestDraft)
            {
                if ($appVersion.properties.lifeCycleId -eq "Draft")
                {
                    $draftFound = $true
                    CreateAppVersionObject -AppVersionObj $appVersion
                    break
                }
            }
            elseif ($LatestPublished)
            {
                if ($appVersion.properties.lifeCycleId -eq "Published")
                {
                    #if first time through seed the latest version
                    if ($publishedFound)
                    {
                        $publishedFound = $true
                        $latestPublishedDate = [DateTime] $appVersion.properties.AppVersion
                        $latestPublishedAppVersion = $appVersion
                    }
                    else
                    {
                        $nextPublishedDate = [DateTime] $appVersion.properties.AppVersion

                        #if there is a more recent published version replace it
                        if ($nextPublishedDate -gt $latestPublishedDate)
                        {
                            $latestPublishedDate = $nextPublishedDate
                            $latestPublishedAppVersion = $appVersion
                        }
                    }
                }
            }
            #if the caller just wants all versions return them
            else
            {
                CreateAppVersionObject -AppVersionObj $appVersion
            }
        }

        #if the caller was asking for the latest published version, return it
        if($latestPublishedAppVersion)
        {
            CreateAppVersionObject -AppVersionObj $latestPublishedAppVersion
        }

        #if the caller was asking for a draft and there was none, return null
        if ($LatestDraft -and (-not $draftFound))
        {
            return $null
        }
    }
}

function Restore-PowerAppVersion
{
 <#
 .SYNOPSIS
 Restores the current 'draft' version of the app to be the specified App Version.
 .DESCRIPTION
 The Restore-PowerAppVersion publishes the draft version of the specified app to all users.
 Use Get-Help Restore-PowerAppVersion -Examples for more detail.
 .PARAMETER AppName
 The app identifier.
 .PARAMETER AppVersionName
 The app version identifier (retrieved by calling Get-PowerAppVersion).
 .PARAMETER ImmediatelyPublish
 If this parameter is specified, the specific App Version will immediately be published to be the 'live' version of the app available to all users.
 .EXAMPLE
 Restore -AppVersion -AppName 08b4e32a-4e0d-4a69-97da-e1640f0eb7b9 -AppVersionName 20180220T065310Z
 Restores the draft version of the app with name 08b4e32a-4e0d-4a69-97da-e1640f0eb7b9 to the state that was previously stored as app version 20180220T065310Z
 .EXAMPLE
 Restore -AppVersion -AppName 08b4e32a-4e0d-4a69-97da-e1640f0eb7b9 -AppVersionName 20180220T065310Z -ImmediatelyPublish
 Restores the 'live' version of the app with name 08b4e32a-4e0d-4a69-97da-e1640f0eb7b9 to the state that was previously stored as app version 20180220T065310Z
 #>
    [CmdletBinding(DefaultParameterSetName="Name")]
    param
    (
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = "Name", ValueFromPipelineByPropertyName = $true)]
        [string]$AppName,

        [Parameter(Mandatory = $true, ParameterSetName = "Name", ValueFromPipelineByPropertyName = $true)]
        [string]$AppVersionName,

        [Parameter(Mandatory = $false, ParameterSetName = "Name")]
        [Switch]$ImmediatelyPublish,

        [Parameter(Mandatory = $false, ParameterSetName = "Name")]
        [string]$ApiVersion = "2017-06-01"
    )

    process
    {
        $route = "https://{powerAppsEndpoint}/providers/Microsoft.PowerApps/apps/{appName}/versions/{appVersionName}/promote?api-version={apiVersion}" `
        | ReplaceMacro -Macro "{appName}" -Value $AppName `
        | ReplaceMacro -Macro "{appVersionName}" -Value $AppVersionName;

        $restoreResult = InvokeApi -Method POST -Body @{} -Route $route -ApiVersion $ApiVersion -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)

        If($ImmediatelyPublish)
        {
            $pulishResult = Publish-PowerApp -AppName $AppName -ApiVersion $ApiVersion -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
        }
    }
}

function Get-PowerAppRoleAssignment
{
 <#
 .SYNOPSIS
 Returns the app roles assignments for a user or an app.
 .DESCRIPTION
 The Get-PowerAppRolesAssignment functions returns all roles assignments for an app or all roles assignments for a user (across all of their apps).  An app's role assignemnts  determine which users have access to an app and with which permission level (Owner, CanEdit, CanView) .
 Use Get-Help Get-PowerAppRolesAssignment -Examples for more detail.
 .PARAMETER AppName
 The app identifier.
 .PARAMETER EnvironmentName
 The app's environment.
 .PARAMETER PrincipalObjectId
 The objectId of a user or group, if specified, this function will only return role assignments for that user or group.
 .EXAMPLE
 Get-PowerAppRolesAssignment
 Returns all app role assignments for the calling user.
 .EXAMPLE
 Get-PowerAppRoleAssignment -AppName 3c2f7648-ad60-4871-91cb-b77d7ef3c239 -EnvironmentName 08b4e32a-4e0d-4a69-97da-e1640f0eb7b9
 Returns all role assignments for the app with name 3c2f7648-ad60-4871-91cb-b77d7ef3c239 in environment with name 08b4e32a-4e0d-4a69-97da-e1640f0eb7b9
 .EXAMPLE
 Get-PowerAppRoleAssignment -AppName 3c2f7648-ad60-4871-91cb-b77d7ef3c239 -EnvironmentName 08b4e32a-4e0d-4a69-97da-e1640f0eb7b9 -PrincipalObjectId 3c2f7648-ad60-4871-91cb-b77d7ef3c239
 Returns all role assignments for the user or group with an object of 3c2f7648-ad60-4871-91cb-b77d7ef3c239 for the app with name 3c2f7648-ad60-4871-91cb-b77d7ef3c239 in environment with name 08b4e32a-4e0d-4a69-97da-e1640f0eb7b9
 #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $false, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]$AppName,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [string]$EnvironmentName,

        [Parameter(Mandatory = $false)]
        [string]$PrincipalObjectId,

        [Parameter(Mandatory = $false)]
        [string]$ApiVersion = "2017-06-01"
    )

    process
    {
        $selectedObjectId = $global:currentSession.UserId

        if (-not [string]::IsNullOrWhiteSpace($AppName))
        {
            if (-not [string]::IsNullOrWhiteSpace($PrincipalObjectId))
            {
                $selectedObjectId = $PrincipalObjectId;
            }
            else
            {
                $selectedObjectId = $null
            }
        }

        $pattern = BuildFilterPattern -Filter $selectedObjectId

        if (-not [string]::IsNullOrWhiteSpace($AppName))
        {
            $route = "https://{powerAppsEndpoint}/providers/Microsoft.PowerApps/apps/{appName}/permissions?api-version={apiVersion}&`$filter=environment eq '{environment}'" `
            | ReplaceMacro -Macro "{appName}" -Value $AppName `
            | ReplaceMacro -Macro "{environment}" -Value $EnvironmentName;

            $appRoleResult = InvokeApi -Method GET -Route $route -ApiVersion $ApiVersion -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)

            foreach ($appRole in $appRoleResult.Value)
            {
                if (-not [string]::IsNullOrWhiteSpace($PrincipalObjectId))
                {
                    if ($pattern.IsMatch($appRole.properties.principal.id ) -or
                        $pattern.IsMatch($appRole.properties.principal.email) -or
                        $pattern.IsMatch($appRole.properties.principal.tenantId))
                    {
                        CreateAppRoleAssignmentObject -AppRoleAssignmentObj $appRole
                    }
                }
                else
                {
                    CreateAppRoleAssignmentObject -AppRoleAssignmentObj $appRole
                }
            }
        }
        else
        {
            $apps = Get-PowerApp

            foreach($app in $apps)
            {
                Get-PowerAppRoleAssignment `
                    -AppName $app.AppName `
                    -EnvironmentName $app.EnvironmentName `
                    -PrincipalObjectId $selectedObjectId `
                    -ApiVersion $ApiVersion `
					-Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
            }
        }
    }
}

function Remove-PowerAppRoleAssignment
{
 <#
 .SYNOPSIS
 Deletes an app roles assignment.
 .DESCRIPTION
 The Remove-PowerAppRoleAssignment deletes the specific app role assignment
 Use Get-Help Remove-PowerAppRolesAssignment -Examples for more detail.
 .PARAMETER RoleId
 The id of the role assignment to be deleted.
 .PARAMETER AppName
 The app identifier.
 .PARAMETER EnvironmentName
 The app's environment.
 .EXAMPLE
 Remove-PowerAppRoleAssignment -AppName 3c2f7648-ad60-4871-91cb-b77d7ef3c239 -EnvironmentName 08b4e32a-4e0d-4a69-97da-e1640f0eb7b9 -RoleId /providers/Microsoft.PowerApps/apps/f8d7a19d-f8f9-4e10-8e62-eb8c518a2eb4/permissions/tenant-efecdc9a-c859-42fd-b215-dc9c314594dd
 Deletes the app role assignment with an id of /providers/Microsoft.PowerApps/apps/f8d7a19d-f8f9-4e10-8e62-eb8c518a2eb4/permissions/tenant-efecdc9a-c859-42fd-b215-dc9c314594dd
 #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $false, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]$AppName,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [string]$EnvironmentName,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [string]$RoleId,

        [Parameter(Mandatory = $false)]
        [string]$ApiVersion = "2017-06-01"
    )

    process
    {
        $route = "https://{powerAppsEndpoint}/providers/Microsoft.PowerApps/apps/{appName}/modifyPermissions`?api-version={apiVersion}&`$filter=environment%20eq%20%27{environment}%27" `
        | ReplaceMacro -Macro "{appName}" -Value $AppName `
        | ReplaceMacro -Macro "{environment}" -Value $EnvironmentName;

        #Construct the body
        $requestbody = $null

        $requestbody = @{
            delete = @(
                @{
                    id = $RoleId
                }
            )
        }


        $removeResult = InvokeApi -Method POST -Body $requestbody -Route $route -ApiVersion $ApiVersion -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)

        If($removeResult -eq $null)
        {
            return $null
        }

        CreateHttpResponse($removeResult)
    }
}

function Set-PowerAppRoleAssignment
{
    <#
    .SYNOPSIS
    sets permissions to the app.
    .DESCRIPTION
    The Set-PowerAppRoleAssignments set up permission to app depending on parameters.
    Use Get-Help Set-PowerAppRoleAssignment -Examples for more detail.
    .PARAMETER AppName
    App name for the one which you want to set permission.
    .PARAMETER EnvironmentName
    Limit app returned to those in a specified environment.
    .PARAMETER RoleName
    Specifies the permission level given to the app: CanView, CanViewWithShare, CanEdit. Sharing with the entire tenant is only supported for CanView.
    .PARAMETER PrincipalType
    Specifies the type of principal this app is being shared with; a user, a security group, the entire tenant.
    .PARAMETER PrincipalObjectId
    If this app is being shared with a user or security group principal, this field specified the ObjectId for that principal. You can use the Get-UsersOrGroupsFromGraph API to look-up the ObjectId for a user or group in Azure Active Directory.
    .EXAMPLE
    Set-PowerAppRoleAssignment -PrincipalType Group -PrincipalObjectId b049bf12-d56d-4b50-8176-c6560cbd35aa -RoleName CanEdit -AppName 1ec3c80c-c2c0-4ea6-97a8-31d8c8c3d488 -EnvironmentName Default-55abc7e5-2812-4d73-9d2f-8d9017f8c877
    Give the specified security group CanEdit permissions to the app with name 1ec3c80c-c2c0-4ea6-97a8-31d8c8c3d488
    #>
    [CmdletBinding(DefaultParameterSetName="User")]
    param
    (
        [Parameter(Mandatory = $true, ParameterSetName = "Tenant", ValueFromPipelineByPropertyName = $true)]
        [Parameter(Mandatory = $true, ParameterSetName = "User", ValueFromPipelineByPropertyName = $true)]
        [string]$AppName,

        [Parameter(Mandatory = $true, ParameterSetName = "Tenant", ValueFromPipelineByPropertyName = $true)]
        [Parameter(Mandatory = $true, ParameterSetName = "User", ValueFromPipelineByPropertyName = $true)]
        [string]$EnvironmentName,

        [Parameter(Mandatory = $true, ParameterSetName = "Tenant", ValueFromPipelineByPropertyName = $true)]
        [Parameter(Mandatory = $true, ParameterSetName = "User", ValueFromPipelineByPropertyName = $true)]
        [ValidateSet("CanView", "CanViewWithShare", "CanEdit")]
        [string]$RoleName,

        [Parameter(Mandatory = $true, ParameterSetName = "Tenant", ValueFromPipelineByPropertyName = $true)]
        [Parameter(Mandatory = $true, ParameterSetName = "User", ValueFromPipelineByPropertyName = $true)]
        [ValidateSet("User", "Group", "Tenant")]
        [string]$PrincipalType,

        [Parameter(Mandatory = $false, ParameterSetName = "Tenant")]
        [Parameter(Mandatory = $true, ParameterSetName = "User")]
        [string]$PrincipalObjectId = $null,

        [Parameter(Mandatory = $false, ParameterSetName = "User")]
        [Parameter(Mandatory = $false, ParameterSetName = "Tenant")]
        [string]$ApiVersion = "2016-11-01"
    )

    process
    {
        $TenantId = $Global:currentSession.tenantId

        if($PrincipalType -ne "Tenant")
        {
            $userOrGroup = Get-UsersOrGroupsFromGraph -ObjectId $PrincipalObjectId
            $PrincipalEmail = $userOrGroup.Mail
        }

        $route = "https://{powerAppsEndpoint}/providers/Microsoft.PowerApps/apps/{appName}/modifyPermissions`?api-version={apiVersion}&`$filter=environment eq '{environment}'" `
        | ReplaceMacro -Macro "{appName}" -Value $AppName `
        | ReplaceMacro -Macro "{environment}" -Value (ResolveEnvironment -OverrideId $EnvironmentName);

        #Construct the body
        $requestbody = $null

        If ($PrincipalType -eq "Tenant")
        {
            $requestbody = @{
                delete = @()
                put = @(
                    @{
                        properties = @{
                            roleName = $RoleName
                            capabilities = @()
                            NotifyShareTargetOption = "Notify"
                            principal = @{
                                email = ""
                                id = "null"
                                type = $PrincipalType
                                tenantId = $TenantId
                            }
                        }
                    }
                )
            }
        }
        else
        {
            $requestbody = @{
                delete = @()
                put = @(
                    @{
                        properties = @{
                            roleName = $RoleName
                            capabilities = @()
                            NotifyShareTargetOption = "Notify"
                            principal = @{
                                email = $PrincipalEmail
                                id = $PrincipalObjectId
                                type = $PrincipalType
                                tenantId = "null"
                            }
                        }
                    }
                )
            }
        }

        $setAppRoleResult = InvokeApi -Method POST -Body $requestbody -Route $route -ApiVersion $ApiVersion -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)

        CreateHttpResponse($setAppRoleResult)
    }
}

function Get-PowerAppsNotification
{
 <#
 .SYNOPSIS
 Returns the PowerApps notifications for the calling users.
 .DESCRIPTION
 The Get-PowerAppsNotification functions returns all PowerApps notifications for t calling user, which inclues all records of cds data files they have exported and apps that have beens shared with them .
 Use Get-Help Get-PowerAppsNotification -Examples for more detail.
 .EXAMPLE
 Get-PowerAppsNotification
 Returns all the PowerApps notifications for the calling user.
 #>
    [CmdletBinding(DefaultParameterSetName="User")]
    param
    (
        [Parameter(Mandatory = $false, Position = 0, ParameterSetName = "User", ValueFromPipelineByPropertyName = $true)]
        [string]$UserId,

        [Parameter(Mandatory = $false, ParameterSetName = "User")]
        [string]$ApiVersion = "2017-06-01"
    )

    process
    {
        $selectedUserId = $global:currentSession.UserId

        $route = "https://{powerAppsEndpoint}/providers/Microsoft.PowerApps/objectIds/{objectId}/notifications?api-version={apiVersion}"`
            | ReplaceMacro -Macro "{objectId}" -Value $selectedUserId;

        $notificationResult = InvokeApi -Method GET -Route $route -ApiVersion $ApiVersion -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)

        foreach ($notification in $notificationResult.Value)
        {
            CreatePowerAppsNotificationObject -PowerAppsNotificationObj $notification
        }
    }
}

function Set-PowerAppAsSolutionAware
{
    <#
    .SYNOPSIS
    Sets the powerapp as solution aware.
    .DESCRIPTION
    The Set-PowerAppAsSolutionAware function will add a canvas app to a solution for the first time.
    Use Get-Help Set-PowerAppAsSolutionAware -Examples for more detail.
    .PARAMETER EnvironmentName
    The environment name of the environment where the app resides.
    .PARAMETER AppName
    App name for the powerapp which should be made solution aware.
    .PARAMETER SolutionId
    The identifier for the solution to which the app should be added.
    .PARAMETER ForceLeaseFlag
    A value indicating whether or not the acquisition of the app lease should be forced by the client. Using this option could disrupt other ongoing app editing sessions.
    .EXAMPLE
    Set-PowerAppAsSolutionAware -EnvironmentName 839eace6-59ab-4243-97ec-a5b8fcc104e4 -AppName 0e075c48-a792-4705-8f99-82eec3b1cd8e -SolutionId 090928a6-d541-4e00-ad1d-e06c3ac26d62
    Add the specified app with name 0e075c48-a792-4705-8f99-82eec3b1cd8e in environment 839eace6-59ab-4243-97ec-a5b8fcc104e4 to the solution with identifier 090928a6-d541-4e00-ad1d-e06c3ac26d62
    #>

    [CmdletBinding(DefaultParameterSetName="User")]
    param
    (
        [Parameter(Mandatory = $true, ParameterSetName = "Tenant", ValueFromPipelineByPropertyName = $true)]
        [Parameter(Mandatory = $true, ParameterSetName = "User", ValueFromPipelineByPropertyName = $true)]
        [string]$EnvironmentName,

        [Parameter(Mandatory = $true, ParameterSetName = "Tenant", ValueFromPipelineByPropertyName = $true)]
        [Parameter(Mandatory = $true, ParameterSetName = "User", ValueFromPipelineByPropertyName = $true)]
        [string]$AppName,

        [Parameter(Mandatory = $true, ParameterSetName = "Tenant")]
        [Parameter(Mandatory = $true, ParameterSetName = "User")]
        [string]$SolutionId,

        [Parameter(Mandatory = $false, ParameterSetName = "User")]
        [Parameter(Mandatory = $false, ParameterSetName = "Tenant")]
        [string]$ApiVersion = "2018-10-01"
    )

    $powerApp = Get-PowerApp -appName $AppName -ApiVersion $ApiVersion -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
    $makeSolutionAwareUri = "https://{powerAppsEndpoint}/providers/Microsoft.PowerApps/environments/{environmentName}/apps/{appName}/makeSolutionAware?api-version={apiVersion}"`
        | ReplaceMacro -Macro "{appName}" -Value $AppName `
        | ReplaceMacro -Macro "{environmentName}" -Value $EnvironmentName;

    $solutionIdRequest = @{
        solutionId = $SolutionId
    }

    $response = InvokeApi -Method POST -Route $makeSolutionAwareUri -ApiVersion $ApiVersion -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true) -Body $solutionIdRequest

    CreateHttpResponse($response)
}

function Set-FlowAsSolutionAware
{
    <#
    .SYNOPSIS
    Sets the flow as solution aware.
    .DESCRIPTION
    The Set-FlowAsSolutionAware function will add a flow to a solution for the first time.
    Use Get-Help Set-FlowAsSolutionAware -Examples for more detail.
    .PARAMETER EnvironmentName
    The environment name of the environment where the flow resides.
    .PARAMETER FlowName
    Flow name for the flow which should be made solution aware.
    .PARAMETER SolutionId
    The identifier for the solution to which the app should be added.
    .PARAMETER ApiVersion
    The api version.
    .EXAMPLE
    Set-FlowAsSolutionAware -EnvironmentName 839eace6-59ab-4243-97ec-a5b8fcc104e4 -FlowName 0e075c48-a792-4705-8f99-82eec3b1cd8e -SolutionId 090928a6-d541-4e00-ad1d-e06c3ac26d62
    Add the specified flow with name 0e075c48-a792-4705-8f99-82eec3b1cd8e in environment 839eace6-59ab-4243-97ec-a5b8fcc104e4 to the solution with identifier 090928a6-d541-4e00-ad1d-e06c3ac26d62
    #>

    [CmdletBinding(DefaultParameterSetName="User")]
    param
    (
        [Parameter(Mandatory = $true, ParameterSetName = "Tenant", ValueFromPipelineByPropertyName = $true)]
        [Parameter(Mandatory = $true, ParameterSetName = "User", ValueFromPipelineByPropertyName = $true)]
        [string]$EnvironmentName,

        [Parameter(Mandatory = $true, ParameterSetName = "Tenant", ValueFromPipelineByPropertyName = $true)]
        [Parameter(Mandatory = $true, ParameterSetName = "User", ValueFromPipelineByPropertyName = $true)]
        [string]$FlowName,

        [Parameter(Mandatory = $true, ParameterSetName = "Tenant")]
        [Parameter(Mandatory = $true, ParameterSetName = "User")]
        [string]$SolutionId,

        [Parameter(Mandatory = $false, ParameterSetName = "User")]
        [Parameter(Mandatory = $false, ParameterSetName = "Tenant")]
        [string]$ApiVersion = "2016-11-01"
    )

    $flow = Get-Flow -flowName $AppName -ApiVersion $ApiVersion -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)

    $makeSolutionAwareUri = "https://{flowEndpoint}/providers/Microsoft.Flow/environments/{environmentName}/solutions/{solutionId}/migrateFlows?api-version={apiVersion}"`
        | ReplaceMacro -Macro "{solutionId}" -Value $SolutionId `
        | ReplaceMacro -Macro "{environmentName}" -Value $EnvironmentName `
        | ReplaceMacro -Macro "{apiVersion}" -Value $ApiVersion;

    $solutionIdRequest = @{
        flowsToMigrate = @($flowName)
    }

    $response = InvokeApi -Method POST -Route $makeSolutionAwareUri -ApiVersion $ApiVersion -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true) -Body $solutionIdRequest

    CreateHttpResponse($response)
}

function Get-FlowEnvironment
{
 <#
 .SYNOPSIS
 Returns information about one or more Flow environments that the user has access to.
 .DESCRIPTION
 The Get-FlowEnvironment cmdlet looks up information about one or more environments depending on parameters.
 Use Get-Help Get-FlowEnvironment -Examples for more detail.
 .PARAMETER Filter
 Finds environments matching the specified filter (wildcards supported).
 .PARAMETER EnvironmentName
 Finds a specific environment.
 .PARAMETER Default
 Finds the default environment.
 .EXAMPLE
 Get-FlowEnvironment
 Finds all environments within the tenant.
 .EXAMPLE
 Get-FlowEnvironment -EnvironmentName 3c2f7648-ad60-4871-91cb-b77d7ef3c239
 Finds environment 3c2f7648-ad60-4871-91cb-b77d7ef3c239
 .EXAMPLE
 Get-FlowEnvironment *Test*
 Finds all environments that contain the string "Test" in their display name.
 #>
    [CmdletBinding(DefaultParameterSetName="Filter")]
    param
    (
        [Parameter(Mandatory = $false, Position = 0, ParameterSetName = "Filter")]
        [string[]]$Filter,

        [Parameter(Mandatory = $false, Position = 0, ParameterSetName = "Name")]
        [string]$EnvironmentName,

        [Parameter(Mandatory = $false, Position = 0, ParameterSetName = "Default")]
        [Switch]$Default,

        [Parameter(Mandatory = $false, ParameterSetName = "Filter")]
        [Parameter(Mandatory = $false, ParameterSetName = "Name")]
        [string]$ApiVersion = "2016-11-01"
    )

    if ($Default)
    {
        $getEnvironmentUri = "https://{flowEndpoint}/providers/Microsoft.ProcessSimple/environments/~default?`$expand=permissions&api-version={apiVersion}"

        $environmentResult = InvokeApi -Method GET -Route $getEnvironmentUri -ApiVersion $ApiVersion -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)

        CreateEnvironmentObject -EnvObject $environmentResult
    }
    elseif (-not [string]::IsNullOrWhiteSpace($EnvironmentName))
    {
        $getEnvironmentUri = "https://{flowEndpoint}/providers/Microsoft.ProcessSimple/environments/{environmentName}?`$expand=permissions&api-version={apiVersion}" `
            | ReplaceMacro -Macro "{environmentName}" -Value $EnvironmentName;

        $environmentResult = InvokeApi -Method GET -Route $getEnvironmentUri -ApiVersion $ApiVersion -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)

        CreateEnvironmentObject -EnvObject $environmentResult
    }
    else
    {
        $getAllEnvironmentsUri = "https://{flowEndpoint}/providers/Microsoft.ProcessSimple/environments?`$expand=permissions&api-version={apiVersion}"

        $environmentsResult = InvokeApi -Method GET -Route $getAllEnvironmentsUri -ApiVersion $ApiVersion -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)

        $pattern = BuildFilterPattern -Filter $Filter;

        foreach ($environment in $environmentsResult.Value)
        {
            if ($pattern.IsMatch($environment.name) -or
                $pattern.IsMatch($environment.properties.displayName))
            {
                CreateEnvironmentObject -EnvObject $environment;
            }
        }
    }
}

function Get-Flow
{
 <#
 .SYNOPSIS
 Returns information about one or more flows.
 .DESCRIPTION
 The Get-Flow looks up information about one or more flows depending on parameters.
 Use Get-Help Get-Flow -Examples for more detail.
 .PARAMETER Filter
 Finds flows matching the specified filter (wildcards supported).
 .PARAMETER Flow
 Finds a specific id.
 .PARAMETER My
 Limits the query to only flows owned ONLY by the currently authenticated user.
 .PARAMETER Team
 Limits the query to flows owned by the currently authenticated user but shared with other users.
 .PARAMETER EnvironmentName
 Limit flows returned to those in a specified environment.
 .PARAMETER Top
 Limits the result size of the query. Defaults to 50.
 .EXAMPLE
 Get-Flow
 Finds all flows for which the user has access.
 .EXAMPLE
 Get-Flow -EnvironmentName 3c2f7648-ad60-4871-91cb-b77d7ef3c239
 Finds flows within the 3c2f7648-ad60-4871-91cb-b77d7ef3c239 environment
 .EXAMPLE
 Get-Flow *PowerApps*
 Finds all flows in the current environment that contain the string "PowerApps" in their display name.
 .EXAMPLE
 Get-Flow -My
 Shows flows owned only by the current user.
 #>
    [CmdletBinding(DefaultParameterSetName="Filter")]
    param
    (
        [Parameter(Mandatory = $false, Position = 0, ParameterSetName = "Filter")]
        [string[]]$Filter,

        [Parameter(Mandatory = $false, Position = 0, ParameterSetName = "Name")]
        [string]$FlowName,

        [Parameter(Mandatory = $false, ParameterSetName = "Filter")]
        [Switch]$My,

        [Parameter(Mandatory = $false, ParameterSetName = "Filter")]
        [Switch]$Team,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [string]$EnvironmentName,

        [Parameter(Mandatory = $false, ParameterSetName = "Filter")]
        [int]$Top = 50,

        [Parameter(Mandatory = $false, ParameterSetName = "Filter")]
        [Parameter(Mandatory = $false, ParameterSetName = "Name")]
        [string]$ApiVersion = "2016-11-01"
    )

    process
    {
        if (-not [string]::IsNullOrWhiteSpace($FlowName))
        {
            $route = "https://{flowEndpoint}/providers/Microsoft.ProcessSimple/environments/{environment}/flows/{flowName}?api-version={apiVersion}" `
                | ReplaceMacro -Macro "{flowName}" -Value $FlowName `
                | ReplaceMacro -Macro "{environment}" -Value (ResolveEnvironment -OverrideId $EnvironmentName);

            $flowResult = InvokeApi -Method GET -Route $route -ApiVersion $ApiVersion -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)

            CreateFlowObject -FlowObj $flowResult;
        }
        else
        {
            $flowFilter = "`$filter=all&";

            if ($My)
            {
                $flowFilter = "`$filter=search('personal')&";
            }
            elseif ($Team)
            {
                $flowFilter = "`$filter=search('team')&";
            }

            $route = "https://{flowEndpoint}/providers/Microsoft.ProcessSimple/environments/{environment}/flows?api-version={apiVersion}" `
                | ReplaceMacro -Macro "{flowFilter}" -Value $flowFilter `
                | ReplaceMacro -Macro "{environment}" -Value (ResolveEnvironment -OverrideId $EnvironmentName) `
                | ReplaceMacro -Macro "{topValue}" -Value $Top.ToString();

            $flowResult = InvokeApi -Method GET -Route $route -ApiVersion $ApiVersion -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)

            $pattern = BuildFilterPattern -Filter $Filter;

            foreach ($flow in $flowResult.Value)
            {
                if ($pattern.IsMatch($flow.name) -or
                    $pattern.IsMatch($flow.properties.displayName))
                {
                    CreateFlowObject -FlowObj $flow
                }
            }
        }
    }
}


function Get-FlowOwnerRole
{
 <#
    .SYNOPSIS
    Gets owner permissions to the flow.
    .DESCRIPTION
    The Get-FlowOwnerRole
    Use Get-Help Get-FlowOwnerRole -Examples for more detail.
    .PARAMETER EnvironmentName
    The environment of the flow.
    .PARAMETER FlowName
    Specifies the flow id.
    .PARAMETER Owner
    A objectId of the user you want to filter by.
    .EXAMPLE
    Get-FlowOwnerRole -Owner 53c0a918-ce7c-401e-98f9-1c60b3a723b3
    Returns all flow permissions across all environments for the user with an object id of 53c0a918-ce7c-401e-98f9-1c60b3a723b3
    .EXAMPLE
    Get-FlowOwnerRole -EnvironmentName 3c2f7648-ad60-4871-91cb-b77d7ef3c239 -Owner 53c0a918-ce7c-401e-98f9-1c60b3a723b3
    Returns all flow permissions within environment with id 3c2f7648-ad60-4871-91cb-b77d7ef3c239 for the user with an object id of 53c0a918-ce7c-401e-98f9-1c60b3a723b3
    .EXAMPLE
    Get-FlowOwnerRole -FlowName 4d1f7648-ad60-4871-91cb-b77d7ef3c239 -EnvironmentName 3c2f7648-ad60-4871-91cb-b77d7ef3c239 -Owner 53c0a918-ce7c-401e-98f9-1c60b3a723b3
    Returns all flow permissions for the flow with id 4d1f7648-ad60-4871-91cb-b77d7ef3c239 in environment 3c2f7648-ad60-4871-91cb-b77d7ef3c239 for the user with an object id of 53c0a918-ce7c-401e-98f9-1c60b3a723b3
    .EXAMPLE
    Get-FlowOwnerRole -FlowName 4d1f7648-ad60-4871-91cb-b77d7ef3c239 -EnvironmentName 3c2f7648-ad60-4871-91cb-b77d7ef3c239
    Returns all permissions for the flow with id 4d1f7648-ad60-4871-91cb-b77d7ef3c239 in environment 3c2f7648-ad60-4871-91cb-b77d7ef3c239
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $false, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]$FlowName,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [string]$EnvironmentName,

        [Parameter(Mandatory = $false)]
        [string]$PrincipalObjectId,

        [Parameter(Mandatory = $false)]
        [string]$ApiVersion = "2017-06-01"
    )

    process
    {
        $selectedObjectId = $global:currentSession.UserId

        if (-not [string]::IsNullOrWhiteSpace($FlowName))
        {
            if (-not [string]::IsNullOrWhiteSpace($PrincipalObjectId))
            {
                $selectedObjectId = $PrincipalObjectId;
            }
            else
            {
                $selectedObjectId = $null
            }
        }

        $pattern = BuildFilterPattern -Filter $selectedObjectId

        if (-not [string]::IsNullOrWhiteSpace($FlowName))
        {
            $route = "https://{flowEndpoint}/providers/Microsoft.ProcessSimple/environments/{environment}/flows/{flowName}/owners?api-version={apiVersion}'" `
            | ReplaceMacro -Macro "{flowName}" -Value $FlowName `
            | ReplaceMacro -Macro "{environment}" -Value $EnvironmentName;

            $flowRoleResult = InvokeApi -Method GET -Route $route -ApiVersion $ApiVersion -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)

            foreach ($flowRole in $flowRoleResult.Value)
            {
                if (-not [string]::IsNullOrWhiteSpace($PrincipalObjectId))
                {
                    if ($pattern.IsMatch($flowRole.properties.principal.id))
                    {
                        CreateFlowRoleAssignmentObject -FlowRoleAssignmentObj $flowRole
                    }
                }
                else
                {
                    CreateFlowRoleAssignmentObject -FlowRoleAssignmentObj $flowRole
                }
            }
        }
        else
        {
            $flows = Get-Flow

            foreach($flow in $flows)
            {
                Get-FlowOwnerRole `
                    -FlowName $flow.FlowName `
                    -EnvironmentName $flow.EnvironmentName `
                    -PrincipalObjectId $selectedObjectId `
                    -ApiVersion $ApiVersion `
					-Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
            }
        }
    }
}

function Set-FlowOwnerRole
{
<#
 .SYNOPSIS
 sets owner permissions to the flow.
 .DESCRIPTION
 The Set-FlowOwnerRole set up permission to flow depending on parameters.
 Use Get-Help Set-FlowOwnerRole -Examples for more detail.
 .PARAMETER EnvironmentName
 Limit app returned to those in a specified environment.
 .PARAMETER FlowName
 Specifies the flow id.
 .PARAMETER PrincipalType
 Specifies the type of principal that is being added as an owner; User or Group (security group)
 .PARAMETER PrincipalObjectId
 Specifies the principal object Id of the user or security group.
 .EXAMPLE
 Set-FlowOwnerRole -PrincipalType Group -PrincipalObjectId b049bf12-d56d-4b50-8176-c6560cbd35aa -FlowName 1ec3c80c-c2c0-4ea6-97a8-31d8c8c3d488 -EnvironmentName Default-55abc7e5-2812-4d73-9d2f-8d9017f8c877
 Add the specified security as an owner fo the flow with name 1ec3c80c-c2c0-4ea6-97a8-31d8c8c3d488
 #>
    [CmdletBinding(DefaultParameterSetName="User")]
    param
    (
        [Parameter(Mandatory = $true, ParameterSetName = "User", ValueFromPipelineByPropertyName = $true)]
        [string]$FlowName,

        [Parameter(Mandatory = $true, ParameterSetName = "User", ValueFromPipelineByPropertyName = $true)]
        [string]$EnvironmentName,

        [Parameter(Mandatory = $true)]
        [ValidateSet("User", "Group")]
        [string]$PrincipalType,

        [Parameter(Mandatory = $true, ParameterSetName = "User")]
        [string]$PrincipalObjectId = $null,

        [Parameter(Mandatory = $false, ParameterSetName = "User")]
        [string]$ApiVersion = "2016-11-01"
    )

    process
    {
        $userOrGroup = Get-UsersOrGroupsFromGraph -ObjectId $PrincipalObjectId
        $PrincipalDisplayName = $userOrGroup.DisplayName
        $PrincipalEmail = $userOrGroup.Mail


        $route = "https://{flowEndpoint}/providers/Microsoft.ProcessSimple/scopes/admin/environments/{environment}/flows/{flowName}/modifyowners?api-version={apiVersion}" `
        | ReplaceMacro -Macro "{flowName}" -Value $FlowName `
        | ReplaceMacro -Macro "{environment}" -Value (ResolveEnvironment -OverrideId $EnvironmentName);

        #Construct the body
        $requestbody = $null

        $requestbody = @{
            put = @(
                @{
                    properties = @{
                        principal = @{
                            email = $PrincipalEmail
                            id = $PrincipalObjectId
                            type = $PrincipalType
                            displayName = $PrincipalDisplayName
                        }
                    }
                }
            )
        }

        $result = InvokeApi -Method POST -Route $route -Body $requestbody -ApiVersion $ApiVersion -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)

        CreateHttpResponse($result)
    }
}

function Remove-FlowOwnerRole
{
<#
 .SYNOPSIS
 Removes owner permissions to the flow.
 .DESCRIPTION
 The Remove-FlowOwnerRole sets up permission to flow depending on parameters.
 Use Get-Help Remove-FlowOwnerRole -Examples for more detail.
 .PARAMETER EnvironmentName
 The environment of the flow.
 .PARAMETER FlowName
 Specifies the flow id.
 .PARAMETER RoleId
 Specifies the role id of user or group or tenant.
 .EXAMPLE
 Remove-FlowOwnerRole -EnvironmentName "Default-55abc7e5-2812-4d73-9d2f-8d9017f8c877" -FlowName $flow.FlowName -RoleId "/providers/Microsoft.ProcessSimple/environments/Default-55abc7e5-2812-4d73-9d2f-8d9017f8c877/flows/791fc889-b9cc-4a76-9795-ae45f75d3e48/permissions/1ec3c80c-c2c0-4ea6-97a8-31d8c8c3d488"
 deletes flow permision for the given RoleId, FlowName and Environment name.
 #>
    [CmdletBinding(DefaultParameterSetName="Owner")]
    param
    (
        [Parameter(Mandatory = $false, ParameterSetName = "Owner")]
        [string]$ApiVersion = "2016-11-01",

        [Parameter(Mandatory = $true, ParameterSetName = "Owner", ValueFromPipelineByPropertyName = $true)]
        [string]$FlowName,

        [Parameter(Mandatory = $true, ParameterSetName = "Owner", ValueFromPipelineByPropertyName = $true)]
        [string]$EnvironmentName,

        [Parameter(Mandatory = $true, ParameterSetName = "Owner", ValueFromPipelineByPropertyName = $true)]
        [string]$RoleId
    )

    process
    {
        $route = "https://{flowEndpoint}/providers/Microsoft.ProcessSimple/environments/{environment}/flows/{flowName}/modifyPermissions?api-version={apiVersion}" `
            | ReplaceMacro -Macro "{flowName}" -Value $FlowName `
            | ReplaceMacro -Macro "{environment}" -Value (ResolveEnvironment -OverrideId $EnvironmentName);

        $requestbody = $null

        $requestbody = @{
            delete = @(
                @{
                    id = $RoleId
                    }
                )
                }

        $result = InvokeApi -Method POST -Route $route -Body $requestbody -ApiVersion $ApiVersion -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)

        CreateHttpResponse($result)
    }
}

function Get-FlowRun
{
 <#
 .SYNOPSIS
 Gets flow run details for a specified flow.
 .DESCRIPTION
 The Get-FlowRun cmdlet retrieves flow execution history for a flow.
 .PARAMETER FlowName
 FlowName identifier (not display name).
  .PARAMETER EnvironmentName
 Limit flows returned to those in a specified environment.
 .EXAMPLE
 Get-FlowRun -FlowName cbb38ddd-c6a9-4ecd-8a70-aaaf448615df
 Retrieves flow run history for flow cbb38ddd-c6a9-4ecd-8a70-aaaf448615df
 #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]$FlowName,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [string]$EnvironmentName,

        [Parameter(Mandatory = $false)]
        [string]$ApiVersion = "2016-11-01"
    )

    process
    {
        $route = "https://{flowEndpoint}/providers/Microsoft.ProcessSimple/environments/{environmentName}/flows/{flowName}/runs?api-version={apiVersion}" `
            | ReplaceMacro -Macro "{flowName}" -Value $FlowName `
            | ReplaceMacro -Macro "{environmentName}" -Value (ResolveEnvironment -OverrideId $EnvironmentName);

        $runResult = InvokeApi -Method GET -Route $route -ApiVersion $ApiVersion -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
        foreach ($run in $runResult.Value)
        {
            CreateFlowRunObject -RunObj $run
        }
    }
}

function Enable-Flow
{
 <#
 .SYNOPSIS
 Enables a flow
 .DESCRIPTION
 The Enable-Flow cmdlet enables a flow for execution. Use Get-Help Enable-Flow -Examples
 for more detail.
 .PARAMETER FlowName
  FlowName identifier (not display name).
  .PARAMETER EnvironmentName
 Used to specify the environment of the Flow (if not the currently selected environment.)
 .EXAMPLE
 Enable-Flow -FlowName cbb38ddd-c6a9-4ecd-8a70-aaaf448615df
 Enables flow cbb38ddd-c6a9-4ecd-8a70-aaaf448615df for execution.
 #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]$FlowName,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [string]$EnvironmentName,

        [Parameter(Mandatory = $false)]
        [string]$ApiVersion = "2016-11-01"
    )

    process
    {
        $route = "https://{flowEndpoint}/providers/Microsoft.ProcessSimple/environments/{environmentName}/flows/{flowName}/start?api-version={apiVersion}" `
            | ReplaceMacro -Macro "{flowName}" -Value $FlowName `
            | ReplaceMacro -Macro "{environmentName}" -Value (ResolveEnvironment -OverrideId $EnvironmentName);

        InvokeApi -Method POST -Route $route -ApiVersion $ApiVersion -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
    }
}

function Disable-Flow
{
 <#
 .SYNOPSIS
 Disables a flow
 .DESCRIPTION
 The Disable-Flow cmdlet disables a flow. Use Get-Help Disable-Flow -Examples
 for more detail.
 .PARAMETER FlowId
 FlowId identifier (not display name).
 .PARAMETER EnvironmentName
 Used to specify the environment of the Flow (if not the currently selected environment.)
 .EXAMPLE
 Disable-Flow -FlowId cbb38ddd-c6a9-4ecd-8a70-aaaf448615df
 Disables flow cbb38ddd-c6a9-4ecd-8a70-aaaf448615df.
 #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]$FlowName,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [string]$EnvironmentName,

        [Parameter(Mandatory = $false)]
        [string]$ApiVersion = "2016-11-01"
    )

    process
    {
        $route = "https://{flowEndpoint}/providers/Microsoft.ProcessSimple/environments/{environmentName}/flows/{flowName}/stop?api-version={apiVersion}" `
            | ReplaceMacro -Macro "{flowName}" -Value $FlowName `
            | ReplaceMacro -Macro "{environmentName}" -Value (ResolveEnvironment -OverrideId $EnvironmentName);

        InvokeApi -Method POST -Route $route -ApiVersion $ApiVersion -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
    }
}

function Remove-Flow
{
 <#
 .SYNOPSIS
 Removes a flow
 .DESCRIPTION
 The Remove-Flow cmdlet disables a flow. Use Get-Help Remove-Flow -Examples
 for more detail.
 .PARAMETER FlowId
 FlowId identifier (not display name).
 .PARAMETER EnvironmentName
 Used to specify the environment of the Flow (if not the currently selected environment.)
 .EXAMPLE
 Remove-Flow -FlowId cbb38ddd-c6a9-4ecd-8a70-aaaf448615df
 Deletes flow cbb38ddd-c6a9-4ecd-8a70-aaaf448615df.
 #>
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact="High")]
    param
    (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]$FlowName,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [string]$EnvironmentName,

        [Parameter(Mandatory = $false)]
        [string]$ApiVersion = "2016-11-01"
    )

    process
    {
        $route = "https://{flowEndpoint}/providers/Microsoft.ProcessSimple/environments/{environmentName}/flows/{flowName}?api-version={apiVersion}" `
            | ReplaceMacro -Macro "{flowName}" -Value $FlowName `
            | ReplaceMacro -Macro "{environmentName}" -Value (ResolveEnvironment -OverrideId $EnvironmentName);

        if ($PSCmdlet.ShouldProcess($FlowName, "Delete"))
        {
            InvokeApi -Method DELETE -Route $route -ApiVersion $ApiVersion -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
        }
    }
}

function Get-FlowApprovalRequest
{
 <#
 .SYNOPSIS
 Returns information about approval requests assigned to the current user
 .DESCRIPTION
 The Get-ApprovalRequest finds any pending received approval requests.
 Use Get-Help Get-ApprovalRequest -Examples for more detail.
 .PARAMETER Filter
 Finds approvals matching the specified filter (wildcards supported).
 .PARAMETER Environment
 Limits approvals returned to the specified environment
 .PARAMETER Top
 Limits the result size of the query. Defaults to 50.
 .EXAMPLE
 Get-ApprovalRequest
 Finds all approvals assigned to the user in the current environment.
 .EXAMPLE
 Get-ApprovalRequest -EnvironmentName 3c2f7648-ad60-4871-91cb-b77d7ef3c239
 Finds approval requests within the 3c2f7648-ad60-4871-91cb-b77d7ef3c239 environment
 .EXAMPLE
 Get-ApprovalRequest *Please review*
 Finds all approval requests that contain "Please review"
 #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $false, Position = 0)]
        [string[]]$Filter,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [string]$EnvironmentName,

        [Parameter(Mandatory = $false)]
        [int]$Top = 50,

        [Parameter(Mandatory = $false)]
        [string]$ApiVersion = "2016-11-01"
    )

    process
    {
        $currentEnvironment = ResolveEnvironment -OverrideId $EnvironmentName;

        $route = "https://{flowEndpoint}/providers/Microsoft.ProcessSimple/environments/{environmentName}/approvalRequests?api-version={apiVersion}&`$filter=properties/assignedTo/id eq '{currentUserId}'&`$expand=properties/approval" `
            | ReplaceMacro -Macro "{environmentName}" -Value $currentEnvironment `
            | ReplaceMacro -Macro "{currentUserId}" -Value $global:currentSession.UserId `
            | ReplaceMacro -Macro "{topValue}" -Value $Top.ToString();

        $approvalRequests = InvokeApi -Method GET -Route $route -ApiVersion $ApiVersion -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
        $pattern = BuildFilterPattern -Filter $Filter;

        foreach ($approval in $approvalRequests.Value)
        {
            if ($pattern.IsMatch($approval.name) -or
                $pattern.IsMatch($approval.properties.approval.title))
            {
                CreateApprovalRequestObject -ApprovalRequest $approval -Environment $currentEnvironment
            }
        }
    }
}

function Get-FlowApproval
{
 <#
 .SYNOPSIS
 Returns information about approval requests created by the current user
 .DESCRIPTION
 The Get-Approval finds any pending sent approval requests.
 Use Get-Help Get-Approval -Examples for more detail.
 .PARAMETER Filter
 Finds approvals matching the specified filter (wildcards supported).
 .PARAMETER EnvironmentName
 Limits approvals returned to the specified environment
 .PARAMETER Top
 Limits the result size of the query. Defaults to 50.
 .EXAMPLE
 Get-Approval
 Finds all approvals created by the current user in the current environment.
 .EXAMPLE
 Get-Approval -EnvironmentName 3c2f7648-ad60-4871-91cb-b77d7ef3c239
 Finds approval within the 3c2f7648-ad60-4871-91cb-b77d7ef3c239 environment
 .EXAMPLE
 Get-Approval *Please review*
 Finds all approval requests that contain "Please review"
 #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $false, Position = 0)]
        [string[]]$Filter,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [string]$EnvironmentName,

        [Parameter(Mandatory = $false)]
        [int]$Top = 50,

        [Parameter(Mandatory = $false)]
        [string]$ApiVersion = "2016-11-01"
    )

    process
    {
        $currentEnvironment = ResolveEnvironment -OverrideId $EnvironmentName;

        $route = "https://{flowEndpoint}/providers/Microsoft.ProcessSimple/environments/{environmentName}/approvals?api-version={apiVersion}&`$filter=properties/owner/id eq '{currentUserId}' and properties/status eq 'Pending'&`$expand=properties/requestSummary" `
            | ReplaceMacro -Macro "{environmentName}" -Value $currentEnvironment `
            | ReplaceMacro -Macro "{currentUserId}" -Value $global:currentSession.UserId `
            | ReplaceMacro -Macro "{topValue}" -Value $Top.ToString();

        $approvals = InvokeApi -Method GET -Route $route -ApiVersion $ApiVersion -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
        $pattern = BuildFilterPattern -Filter $Filter;

        foreach ($approval in $approvals.Value)
        {
            if ($pattern.IsMatch($approval.name) -or
                $pattern.IsMatch($approval.properties.approval.title))
            {
                CreateApprovalObject -Approval $approval -Environment $currentEnvironment
            }
        }
    }
}

function Approve-FlowApprovalRequest
{
 <#
 .SYNOPSIS
 Approve or reject an approval response
 .DESCRIPTION
 The RespondTo-FlowApprovalRequest cmdlet to approval or reject a request
 Use Get-Help RespondTo-FlowApprovalRequest -Examples for more detail.
 .PARAMETER ApprovalId
 Id of the approval for which the user is responding.
 .PARAMETER ApprovalRequestId
 Id of the user's request for the approval.
 .PARAMETER EnvironmentName
 Environment containing the specified approval
 .PARAMETER Comments
 Comments to attach to the response.
 .EXAMPLE
 RespondTo-FlowApprovalRequest -EnvironmentName 3c2f7648-ad60-4871-91cb-b77d7ef3c239 -ApprovalId d5f65cd7-7c10-41b6-aa93-68a145bb64e7 -ApprovalRequestId 94be632a-83d1-499e-8e65-d6e0e7c2cb1a -Response "Reject" -Comments "no response"
 Rejects a specific approval within the 3c2f7648-ad60-4871-91cb-b77d7ef3c239 environment
 .EXAMPLE
 Get-FlowApprovalRequest | ? { $_.Owner -eq 'joe@contoso.com' } | RespondTo-ApprovalRequest -Response "Approve" -Comments "looks good"
 Finds all approval requests that contain "Please review" and approves them
 #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$ApprovalId,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$ApprovalRequestId,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$EnvironmentName,

        [Parameter(Mandatory = $true)]
        [string]$Comments,

        [Parameter(Mandatory = $false)]
        [string]$ApiVersion = "2016-11-01"
    )

    process
    {
		$Response = "Approve"
        $currentEnvironment = ResolveEnvironment -OverrideId $EnvironmentName

        $approvalResponse = BuildApprovalResponse `
            -EnvironmentName $currentEnvironment `
            -ApprovalId $ApprovalId `
            -ApprovalRequestId $ApprovalRequestId `
            -Response $Response `
            -Comments $Comments

        $route = "https://{flowEndpoint}/providers/Microsoft.ProcessSimple/environments/{environmentName}/approvals/{approvalId}/approvalResponses?api-version={apiVersion}" `
            | ReplaceMacro -Macro "{environmentName}" -Value $currentEnvironment `
            | ReplaceMacro -Macro "{approvalId}" -Value $ApprovalId;

        $ignored = InvokeApi -Method POST -Route $route -Body $approvalResponse -ApiVersion $ApiVersion -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
    }
}

function Deny-FlowApprovalRequest
{
 <#
 .SYNOPSIS
 Approve or reject an approval response
 .DESCRIPTION
 The RespondTo-FlowApprovalRequest cmdlet to approval or reject a request
 Use Get-Help RespondTo-FlowApprovalRequest -Examples for more detail.
 .PARAMETER ApprovalId
 Id of the approval for which the user is responding.
 .PARAMETER ApprovalRequestId
 Id of the user's request for the approval.
 .PARAMETER EnvironmentName
 Environment containing the specified approval
 .PARAMETER Comments
 Comments to attach to the response.
 .EXAMPLE
 RespondTo-FlowApprovalRequest -EnvironmentName 3c2f7648-ad60-4871-91cb-b77d7ef3c239 -ApprovalId d5f65cd7-7c10-41b6-aa93-68a145bb64e7 -ApprovalRequestId 94be632a-83d1-499e-8e65-d6e0e7c2cb1a -Response "Reject" -Comments "no response"
 Rejects a specific approval within the 3c2f7648-ad60-4871-91cb-b77d7ef3c239 environment
 .EXAMPLE
 Get-FlowApprovalRequest | ? { $_.Owner -eq 'joe@contoso.com' } | RespondTo-ApprovalRequest -Response "Approve" -Comments "looks good"
 Finds all approval requests that contain "Please review" and approves them
 #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$ApprovalId,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$ApprovalRequestId,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$EnvironmentName,

        [Parameter(Mandatory = $true)]
        [string]$Comments,

        [Parameter(Mandatory = $false)]
        [string]$ApiVersion = "2016-11-01"
    )

    process
    {
		$Response = "Reject"
        $currentEnvironment = ResolveEnvironment -OverrideId $EnvironmentName

        $approvalResponse = BuildApprovalResponse `
            -EnvironmentName $currentEnvironment `
            -ApprovalId $ApprovalId `
            -ApprovalRequestId $ApprovalRequestId `
            -Response $Response `
            -Comments $Comments

        $route = "https://{flowEndpoint}/providers/Microsoft.ProcessSimple/environments/{environmentName}/approvals/{approvalId}/approvalResponses?api-version={apiVersion}" `
            | ReplaceMacro -Macro "{environmentName}" -Value $currentEnvironment `
            | ReplaceMacro -Macro "{approvalId}" -Value $ApprovalId;

        $ignored = InvokeApi -Method POST -Route $route -Body $approvalResponse -ApiVersion $ApiVersion -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
    }
}

#internal, helper function
function Get-FilteredEnvironments(
)
{
     param
    (
        [Parameter(Mandatory = $false)]
        [object]$Filter,

        [Parameter(Mandatory = $false)]
        [object]$CreatedBy,

        [Parameter(Mandatory = $false)]
        [object]$EnvironmentResult
    )

    $patternOwner = BuildFilterPattern -Filter $CreatedBy
    $patternFilter = BuildFilterPattern -Filter $Filter

    foreach ($env in $EnvironmentResult.Value)
    {
        if ($patternOwner.IsMatch($env.properties.createdBy.displayName) -or
            $patternOwner.IsMatch($env.properties.createdBy.email) -or
            $patternOwner.IsMatch($env.properties.createdBy.id) -or
            $patternOwner.IsMatch($env.properties.createdBy.userPrincipalName))
        {
            if ($patternFilter.IsMatch($env.name) -or
                $patternFilter.IsMatch($env.properties.displayName))
            {
                CreateEnvironmentObject -EnvObject $env
            }
        }
    }
}

#internal, helper function
function CreateAppObject
{
    param
    (
        [Parameter(Mandatory = $true)]
        [object]$AppObj
    )

    return New-Object -TypeName PSObject `
        | Add-Member -PassThru -MemberType NoteProperty -Name AppName -Value $AppObj.name `
        | Add-Member -PassThru -MemberType NoteProperty -Name DisplayName -Value $AppObj.properties.displayName `
        | Add-Member -PassThru -MemberType NoteProperty -Name CreatedTime -Value $AppObj.properties.createdTime `
        | Add-Member -PassThru -MemberType NoteProperty -Name LastModifiedTime -Value $AppObj.properties.lastModifiedTime `
        | Add-Member -PassThru -MemberType NoteProperty -Name EnvironmentName -Value $AppObj.properties.environment.name `
        | Add-Member -PassThru -MemberType NoteProperty -Name UnpublishedAppDefinition -Value $AppObj.properties.unpublishedAppDefinition `
        | Add-Member -PassThru -MemberType NoteProperty -Name Internal -Value $AppObj;
}

#internal, helper function
function CreateConnectionObject
{
    param
    (
        [Parameter(Mandatory = $true)]
        [object]$ConnectionObj
    )

    return New-Object -TypeName PSObject `
        | Add-Member -PassThru -MemberType NoteProperty -Name ConnectionName -Value $ConnectionObj.name `
        | Add-Member -PassThru -MemberType NoteProperty -Name ConnectionId -Value $ConnectionObj.id `
        | Add-Member -PassThru -MemberType NoteProperty -Name FullConnectorName -Value $ConnectionObj.properties.apiId `
        | Add-Member -PassThru -MemberType NoteProperty -Name ConnectorName -Value ((($ConnectionObj.properties.apiId -split "/apis/")[1]) -split "/")[0] `
        | Add-Member -PassThru -MemberType NoteProperty -Name DisplayName -Value $ConnectionObj.properties.displayName `
        | Add-Member -PassThru -MemberType NoteProperty -Name CreatedTime -Value $ConnectionObj.properties.createdTime `
        | Add-Member -PassThru -MemberType NoteProperty -Name CreatedBy -Value $ConnectionObj.properties.createdBy `
        | Add-Member -PassThru -MemberType NoteProperty -Name LastModifiedTime -Value $ConnectionObj.properties.lastModifiedTime `
        | Add-Member -PassThru -MemberType NoteProperty -Name EnvironmentName -Value $ConnectionObj.properties.environment.name `
        | Add-Member -PassThru -MemberType NoteProperty -Name Statuses -Value $ConnectionObj.properties.statuses `
        | Add-Member -PassThru -MemberType NoteProperty -Name Internal -Value $ConnectionObj;
}

#internal, helper function
function CreateConnectionRoleAssignmentObject
{
    param
    (
        [Parameter(Mandatory = $true)]
        [object]$ConnectionRoleAssignmentObj,

        [Parameter(Mandatory = $false)]
        [string]$EnvironmentName
    )

    If($ConnectionRoleAssignmentObj.properties.principal.type -eq "Tenant")
    {
        return New-Object -TypeName PSObject `
            | Add-Member -PassThru -MemberType NoteProperty -Name RoleId -Value $ConnectionRoleAssignmentObj.id `
            | Add-Member -PassThru -MemberType NoteProperty -Name RoleName -Value $ConnectionRoleAssignmentObj.name `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalDisplayName -Value $null `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalEmail -Value $null `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalObjectId -Value $ConnectionRoleAssignmentObj.properties.principal.tenantId `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalType -Value $ConnectionRoleAssignmentObj.properties.principal.type `
            | Add-Member -PassThru -MemberType NoteProperty -Name RoleType -Value $ConnectionRoleAssignmentObj.properties.roleName `
            | Add-Member -PassThru -MemberType NoteProperty -Name ConnectionName -Value ((($ConnectionRoleAssignmentObj.id -split "/connections/")[1]) -split "/")[0] `
            | Add-Member -PassThru -MemberType NoteProperty -Name ConnectorName -Value ((($ConnectionRoleAssignmentObj.id -split "/apis/")[1]) -split "/")[0] `
            | Add-Member -PassThru -MemberType NoteProperty -Name EnvironmentName -Value $EnvironmentName `
            | Add-Member -PassThru -MemberType NoteProperty -Name Internal -Value $ConnectionRoleAssignmentObj;
    }
    elseif($ConnectionRoleAssignmentObj.properties.principal.type -eq "User")
    {
        return New-Object -TypeName PSObject `
            | Add-Member -PassThru -MemberType NoteProperty -Name RoleId -Value $ConnectionRoleAssignmentObj.id `
            | Add-Member -PassThru -MemberType NoteProperty -Name RoleName -Value $ConnectionRoleAssignmentObj.name `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalDisplayName -Value $ConnectionRoleAssignmentObj.properties.principal.displayName `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalEmail -Value $ConnectionRoleAssignmentObj.properties.principal.email `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalObjectId -Value $ConnectionRoleAssignmentObj.properties.principal.id `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalType -Value $ConnectionRoleAssignmentObj.properties.principal.type `
            | Add-Member -PassThru -MemberType NoteProperty -Name RoleType -Value $ConnectionRoleAssignmentObj.properties.roleName `
            | Add-Member -PassThru -MemberType NoteProperty -Name ConnectionName -Value ((($ConnectionRoleAssignmentObj.id -split "/connections/")[1]) -split "/")[0] `
            | Add-Member -PassThru -MemberType NoteProperty -Name ConnectorName -Value ((($ConnectionRoleAssignmentObj.id -split "/apis/")[1]) -split "/")[0] `
            | Add-Member -PassThru -MemberType NoteProperty -Name EnvironmentName -Value $EnvironmentName `
            | Add-Member -PassThru -MemberType NoteProperty -Name Internal -Value $ConnectionRoleAssignmentObj;
    }
    elseif($ConnectionRoleAssignmentObj.properties.principal.type -eq "Group")
    {
        return New-Object -TypeName PSObject `
            | Add-Member -PassThru -MemberType NoteProperty -Name RoleId -Value $ConnectionRoleAssignmentObj.id `
            | Add-Member -PassThru -MemberType NoteProperty -Name RoleName -Value $ConnectionRoleAssignmentObj.name `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalDisplayName -Value $ConnectionRoleAssignmentObj.properties.principal.displayName `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalEmail -Value $null `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalObjectId -Value $ConnectionRoleAssignmentObj.properties.principal.id `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalType -Value $ConnectionRoleAssignmentObj.properties.principal.type `
            | Add-Member -PassThru -MemberType NoteProperty -Name RoleType -Value $ConnectionRoleAssignmentObj.properties.roleName `
            | Add-Member -PassThru -MemberType NoteProperty -Name ConnectionName -Value ((($ConnectionRoleAssignmentObj.id -split "/permission/")[1]) -split "/")[0] `
            | Add-Member -PassThru -MemberType NoteProperty -Name ConnectorName -Value ((($ConnectionRoleAssignmentObj.id -split "/apis/")[1]) -split "/")[0] `
            | Add-Member -PassThru -MemberType NoteProperty -Name EnvironmentName -Value $EnvironmentName `
            | Add-Member -PassThru -MemberType NoteProperty -Name Internal -Value $ConnectionRoleAssignmentObj;
    }
    else {
        return $null
    }
}

#internal, helper function
function CreateConnectorObject
{
    param
    (
        [Parameter(Mandatory = $true)]
        [object]$ConnectorObj,

        [Parameter(Mandatory = $false)]
        [string]$EnvironmentName
    )

    return New-Object -TypeName PSObject `
        | Add-Member -PassThru -MemberType NoteProperty -Name ConnectorName -Value $ConnectorObj.name `
        | Add-Member -PassThru -MemberType NoteProperty -Name ConnectorId -Value $ConnectorObj.id `
        | Add-Member -PassThru -MemberType NoteProperty -Name EnvironmentName -Value $EnvironmentName `
        | Add-Member -PassThru -MemberType NoteProperty -Name CreatedTime -Value $ConnectorObj.properties.createdTime `
        | Add-Member -PassThru -MemberType NoteProperty -Name ChangedTime -Value $ConnectorObj.properties.changedtime `
        | Add-Member -PassThru -MemberType NoteProperty -Name DisplayName -Value $ConnectorObj.properties.displayName `
        | Add-Member -PassThru -MemberType NoteProperty -Name Description -Value $ConnectorObj.properties.description `
        | Add-Member -PassThru -MemberType NoteProperty -Name Publisher -Value $ConnectorObj.properties.publisher `
        | Add-Member -PassThru -MemberType NoteProperty -Name Source -Value $ConnectorObj.properties.metadata.source `
        | Add-Member -PassThru -MemberType NoteProperty -Name Tier -Value $ConnectorObj.properties.tier `
        | Add-Member -PassThru -MemberType NoteProperty -Name Url -Value $ConnectorObj.properties.primaryRuntimeUrl `
        | Add-Member -PassThru -MemberType NoteProperty -Name ConnectionParameters -Value $ConnectorObj.properties.connectionParameters `
        | Add-Member -PassThru -MemberType NoteProperty -Name Swagger -Value $ConnectorObj.properties.swagger `
        | Add-Member -PassThru -MemberType NoteProperty -Name WadlUrl -Value $ConnectorObj.properties.wadlUrl `
        | Add-Member -PassThru -MemberType NoteProperty -Name Internal -Value $ConnectorObj;
}

#internal, helper function
function CreateConnectorRoleAssignmentObject
{
    param
    (
        [Parameter(Mandatory = $true)]
        [object]$ConnectorRoleAssignmentObj,

        [Parameter(Mandatory = $false)]
        [string]$EnvironmentName
    )

    If($ConnectorRoleAssignmentObj.properties.principal.type -eq "Tenant")
    {
        return New-Object -TypeName PSObject `
            | Add-Member -PassThru -MemberType NoteProperty -Name RoleId -Value $ConnectorRoleAssignmentObj.id `
            | Add-Member -PassThru -MemberType NoteProperty -Name RoleName -Value $ConnectorRoleAssignmentObj.name `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalDisplayName -Value $null `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalEmail -Value $null `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalObjectId -Value $ConnectorRoleAssignmentObj.properties.principal.tenantId `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalType -Value $ConnectorRoleAssignmentObj.properties.principal.type `
            | Add-Member -PassThru -MemberType NoteProperty -Name RoleType -Value $ConnectorRoleAssignmentObj.properties.roleName `
            | Add-Member -PassThru -MemberType NoteProperty -Name ConnectorName -Value ((($ConnectorRoleAssignmentObj.id -split "/apis/")[1]) -split "/")[0] `
            | Add-Member -PassThru -MemberType NoteProperty -Name EnvironmentName -Value $EnvironmentName `
            | Add-Member -PassThru -MemberType NoteProperty -Name Internal -Value $ConnectorRoleAssignmentObj;
    }
    elseif($ConnectorRoleAssignmentObj.properties.principal.type -eq "User")
    {
        return New-Object -TypeName PSObject `
            | Add-Member -PassThru -MemberType NoteProperty -Name RoleId -Value $ConnectorRoleAssignmentObj.id `
            | Add-Member -PassThru -MemberType NoteProperty -Name RoleName -Value $ConnectorRoleAssignmentObj.name `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalDisplayName -Value $ConnectorRoleAssignmentObj.properties.principal.displayName `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalEmail -Value $ConnectorRoleAssignmentObj.properties.principal.email `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalObjectId -Value $ConnectorRoleAssignmentObj.properties.principal.id `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalType -Value $ConnectorRoleAssignmentObj.properties.principal.type `
            | Add-Member -PassThru -MemberType NoteProperty -Name RoleType -Value $ConnectorRoleAssignmentObj.properties.roleName `
            | Add-Member -PassThru -MemberType NoteProperty -Name ConnectorName -Value ((($ConnectorRoleAssignmentObj.id -split "/apis/")[1]) -split "/")[0] `
            | Add-Member -PassThru -MemberType NoteProperty -Name EnvironmentName -Value $EnvironmentName `
            | Add-Member -PassThru -MemberType NoteProperty -Name Internal -Value $ConnectorRoleAssignmentObj;
    }
    elseif($ConnectorRoleAssignmentObj.properties.principal.type -eq "Group")
    {
        return New-Object -TypeName PSObject `
            | Add-Member -PassThru -MemberType NoteProperty -Name RoleId -Value $ConnectorRoleAssignmentObj.id `
            | Add-Member -PassThru -MemberType NoteProperty -Name RoleName -Value $ConnectorRoleAssignmentObj.name `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalDisplayName -Value $ConnectorRoleAssignmentObj.properties.principal.displayName `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalEmail -Value $null `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalObjectId -Value $ConnectorRoleAssignmentObj.properties.principal.id `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalType -Value $ConnectorRoleAssignmentObj.properties.principal.type `
            | Add-Member -PassThru -MemberType NoteProperty -Name RoleType -Value $ConnectorRoleAssignmentObj.properties.roleName `
            | Add-Member -PassThru -MemberType NoteProperty -Name ConnectorName -Value ((($ConnectorRoleAssignmentObj.id -split "/apis/")[1]) -split "/")[0] `
            | Add-Member -PassThru -MemberType NoteProperty -Name EnvironmentName -Value $EnvironmentName `
            | Add-Member -PassThru -MemberType NoteProperty -Name Internal -Value $ConnectorRoleAssignmentObj;
    }
    else {
        return $null
    }
}

#internal, helper function
function CreateAppVersionObject
{
    param
    (
        [Parameter(Mandatory = $true)]
        [object]$AppVersionObj
    )

    return New-Object -TypeName PSObject `
        | Add-Member -PassThru -MemberType NoteProperty -Name AppVersionName -Value $AppVersionObj.name `
        | Add-Member -PassThru -MemberType NoteProperty -Name CreatedTime -Value $AppVersionObj.properties.appVersion `
        | Add-Member -PassThru -MemberType NoteProperty -Name LifecycleId -Value $AppVersionObj.properties.lifeCycleId `
        | Add-Member -PassThru -MemberType NoteProperty -Name PowerAppsRelease -Value (($AppVersionObj.properties.createdByClientVersion.major).ToString() + "." + ($AppVersionObj.properties.createdByClientVersion.minor).ToString() + "." + ($AppVersionObj.properties.createdByClientVersion.build).ToString())`
        | Add-Member -PassThru -MemberType NoteProperty -Name AppName -Value $AppVersionObj.properties.appName `
        | Add-Member -PassThru -MemberType NoteProperty -Name Internal -Value $AppVersionObj;
}

#internal, helper function
function CreateAppRoleAssignmentObject
{
    param
    (
        [Parameter(Mandatory = $true)]
        [object]$AppRoleAssignmentObj
    )

    If($AppRoleAssignmentObj.properties.principal.type -eq "Tenant")
    {
        return New-Object -TypeName PSObject `
            | Add-Member -PassThru -MemberType NoteProperty -Name RoleId -Value $AppRoleAssignmentObj.id `
            | Add-Member -PassThru -MemberType NoteProperty -Name RoleName -Value $AppRoleAssignmentObj.name `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalDisplayName -Value $null `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalEmail -Value $null `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalObjectId -Value $AppRoleAssignmentObj.properties.principal.tenantId `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalType -Value $AppRoleAssignmentObj.properties.principal.type `
            | Add-Member -PassThru -MemberType NoteProperty -Name RoleType -Value $AppRoleAssignmentObj.properties.roleName `
            | Add-Member -PassThru -MemberType NoteProperty -Name AppName -Value ((($AppRoleAssignmentObj.properties.scope -split "/apps/")[1]) -split "/")[0] `
            | Add-Member -PassThru -MemberType NoteProperty -Name EnvironmentName -Value ((($AppRoleAssignmentObj.properties.scope -split "/environments/")[1]) -split "/")[0] `
            | Add-Member -PassThru -MemberType NoteProperty -Name Internal -Value $AppRoleAssignmentObj;
    }
    elseif($AppRoleAssignmentObj.properties.principal.type -eq "User")
    {
        return New-Object -TypeName PSObject `
            | Add-Member -PassThru -MemberType NoteProperty -Name RoleId -Value $AppRoleAssignmentObj.id `
            | Add-Member -PassThru -MemberType NoteProperty -Name RoleName -Value $AppRoleAssignmentObj.name `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalDisplayName -Value $AppRoleAssignmentObj.properties.principal.displayName `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalEmail -Value $AppRoleAssignmentObj.properties.principal.email `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalObjectId -Value $AppRoleAssignmentObj.properties.principal.id `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalType -Value $AppRoleAssignmentObj.properties.principal.type `
            | Add-Member -PassThru -MemberType NoteProperty -Name RoleType -Value $AppRoleAssignmentObj.properties.roleName `
            | Add-Member -PassThru -MemberType NoteProperty -Name AppName -Value ((($AppRoleAssignmentObj.properties.scope -split "/apps/")[1]) -split "/")[0] `
            | Add-Member -PassThru -MemberType NoteProperty -Name EnvironmentName -Value ((($AppRoleAssignmentObj.properties.scope -split "/environments/")[1]) -split "/")[0] `
            | Add-Member -PassThru -MemberType NoteProperty -Name Internal -Value $AppRoleAssignmentObj;
    }
    elseif($AppRoleAssignmentObj.properties.principal.type -eq "Group")
    {
        return New-Object -TypeName PSObject `
            | Add-Member -PassThru -MemberType NoteProperty -Name RoleId -Value $AppRoleAssignmentObj.id `
            | Add-Member -PassThru -MemberType NoteProperty -Name RoleName -Value $AppRoleAssignmentObj.name `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalDisplayName -Value $AppRoleAssignmentObj.properties.principal.displayName `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalEmail -Value $null `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalObjectId -Value $AppRoleAssignmentObj.properties.principal.id `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalType -Value $AppRoleAssignmentObj.properties.principal.type `
            | Add-Member -PassThru -MemberType NoteProperty -Name RoleType -Value $AppRoleAssignmentObj.properties.roleName `
            | Add-Member -PassThru -MemberType NoteProperty -Name AppName -Value ((($AppRoleAssignmentObj.properties.scope -split "/apps/")[1]) -split "/")[0] `
            | Add-Member -PassThru -MemberType NoteProperty -Name EnvironmentName -Value ((($AppRoleAssignmentObj.properties.scope -split "/environments/")[1]) -split "/")[0] `
            | Add-Member -PassThru -MemberType NoteProperty -Name Internal -Value $AppRoleAssignmentObj;
    }
    else {
        return $null
    }
}

#internal, helper function
function CreatePowerAppsNotificationObject
{
    param
    (
        [Parameter(Mandatory = $true)]
        [object]$PowerAppsNotificationObj
    )

    return New-Object -TypeName PSObject `
        | Add-Member -PassThru -MemberType NoteProperty -Name AppVersionName -Value $PowerAppsNotificationObj.name `
        | Add-Member -PassThru -MemberType NoteProperty -Name PowerAppsNotificationId -Value $PowerAppsNotificationObj.id `
        | Add-Member -PassThru -MemberType NoteProperty -Name PowerAppsNotificationName -Value $PowerAppsNotificationObj.name `
        | Add-Member -PassThru -MemberType NoteProperty -Name Category -Value $PowerAppsNotificationObj.properties.category `
        | Add-Member -PassThru -MemberType NoteProperty -Name Content -Value $PowerAppsNotificationObj.properties.content `
        | Add-Member -PassThru -MemberType NoteProperty -Name CreatedTime -Value $PowerAppsNotificationObj.properties.createdTime `
        | Add-Member -PassThru -MemberType NoteProperty -Name Internal -Value $PowerAppsNotificationObj;
}

#internal, helper function
function CreateFlowObject
{
    param
    (
        [Parameter(Mandatory = $true)]
        [object]$FlowObj
    )

    return New-Object -TypeName PSObject `
        | Add-Member -PassThru -MemberType NoteProperty -Name FlowName -Value $FlowObj.name `
        | Add-Member -PassThru -MemberType NoteProperty -Name Enabled -Value ($FlowObj.properties.state -eq 'Started') `
        | Add-Member -PassThru -MemberType NoteProperty -Name DisplayName -Value $FlowObj.properties.displayName `
        | Add-Member -PassThru -MemberType NoteProperty -Name UserType -Value $FlowObj.properties.userType `
        | Add-Member -PassThru -MemberType NoteProperty -Name CreatedTime -Value $FlowObj.properties.createdTime `
        | Add-Member -PassThru -MemberType NoteProperty -Name LastModifiedTime -Value $FlowObj.properties.lastModifiedTime `
        | Add-Member -PassThru -MemberType NoteProperty -Name EnvironmentName -Value $FlowObj.properties.environment.name `
        | Add-Member -PassThru -MemberType NoteProperty -Name Internal -Value $FlowObj;
}
#internal, helper function
function CreateFlowRoleAssignmentObject
{
    param
    (
        [Parameter(Mandatory = $true)]
        [object]$FlowRoleAssignmentObj
    )

    if($FlowRoleAssignmentObj.properties.principal.type -eq "User")
    {
        return New-Object -TypeName PSObject `
            | Add-Member -PassThru -MemberType NoteProperty -Name RoleId -Value $FlowRoleAssignmentObj.id `
            | Add-Member -PassThru -MemberType NoteProperty -Name RoleName -Value $FlowRoleAssignmentObj.name `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalObjectId -Value $FlowRoleAssignmentObj.properties.principal.id `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalType -Value $FlowRoleAssignmentObj.properties.principal.type `
            | Add-Member -PassThru -MemberType NoteProperty -Name RoleType -Value $FlowRoleAssignmentObj.properties.roleName `
            | Add-Member -PassThru -MemberType NoteProperty -Name FlowName -Value ((($FlowRoleAssignmentObj.id -split "/flows/")[1]) -split "/")[0] `
            | Add-Member -PassThru -MemberType NoteProperty -Name EnvironmentName -Value ((($FlowRoleAssignmentObj.id -split "/environments/")[1]) -split "/")[0] `
            | Add-Member -PassThru -MemberType NoteProperty -Name Internal -Value $FlowRoleAssignmentObj;
    }
    elseif($FlowRoleAssignmentObj.properties.principal.type -eq "Group")
    {
        return New-Object -TypeName PSObject `
        | Add-Member -PassThru -MemberType NoteProperty -Name RoleId -Value $FlowRoleAssignmentObj.id `
        | Add-Member -PassThru -MemberType NoteProperty -Name RoleName -Value $FlowRoleAssignmentObj.name `
        | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalObjectId -Value $FlowRoleAssignmentObj.properties.principal.id `
        | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalType -Value $FlowRoleAssignmentObj.properties.principal.type `
        | Add-Member -PassThru -MemberType NoteProperty -Name RoleType -Value $FlowRoleAssignmentObj.properties.roleName `
        | Add-Member -PassThru -MemberType NoteProperty -Name FlowName -Value ((($FlowRoleAssignmentObj.id -split "/flows/")[1]) -split "/")[0] `
        | Add-Member -PassThru -MemberType NoteProperty -Name EnvironmentName -Value ((($FlowRoleAssignmentObj.id -split "/environments/")[1]) -split "/")[0] `
        | Add-Member -PassThru -MemberType NoteProperty -Name Internal -Value $FlowRoleAssignmentObj;
    }
    else {
        return $null
    }
}

#internal, helper function
function CreateFlowRunObject
{
    param
    (
        [Parameter(Mandatory = $true)]
        [object]$RunObj
    )

    return New-Object -TypeName PSObject `
        | Add-Member -PassThru -MemberType NoteProperty -Name FlowRunName -Value $RunObj.name `
        | Add-Member -PassThru -MemberType NoteProperty -Name Status -Value $RunObj.properties.status `
        | Add-Member -PassThru -MemberType NoteProperty -Name StartTime -Value $RunObj.properties.startTime `
        | Add-Member -PassThru -MemberType NoteProperty -Name Internal -Value $RunObj;
}

#internal, helper function
function CreateEnvironmentObject
{
    param
    (
        [Parameter(Mandatory = $true)]
        [object]$EnvObject
    )

    return New-Object -TypeName PSObject `
        | Add-Member -PassThru -MemberType NoteProperty -Name EnvironmentName -Value $EnvObject.name `
        | Add-Member -PassThru -MemberType NoteProperty -Name DisplayName -Value $EnvObject.properties.displayName `
        | Add-Member -PassThru -MemberType NoteProperty -Name IsDefault -Value $EnvObject.properties.isDefault `
        | Add-Member -PassThru -MemberType NoteProperty -Name Location -Value $EnvObject.location `
        | Add-Member -PassThru -MemberType NoteProperty -Name CreatedTime -Value $EnvObject.properties.createdTime `
        | Add-Member -PassThru -MemberType NoteProperty -Name CreatedBy -value $EnvObject.properties.createdBy.userPrincipalName `
        | Add-Member -PassThru -MemberType NoteProperty -Name LastModifiedTime -Value $EnvObject.properties.lastModifiedTime `
        | Add-Member -PassThru -MemberType NoteProperty -Name LastModifiedBy -value $EnvObject.properties.lastModifiedBy.userPrincipalName `
        | Add-Member -PassThru -MemberType NoteProperty -Name Internal -value $EnvObject;
}

#internal, helper function
function CreateApprovalRequestObject
{
    param
    (
        [Parameter(Mandatory = $true)]
        [object]$ApprovalRequest,

        [Parameter(Mandatory = $true)]
        [string]$EnvironmentName
    )

    return New-Object -TypeName PSObject `
        | Add-Member -PassThru -MemberType NoteProperty -Name ApprovalRequestId -Value $ApprovalRequest.name `
        | Add-Member -PassThru -MemberType NoteProperty -Name Title -Value $ApprovalRequest.properties.approval.properties.title `
        | Add-Member -PassThru -MemberType NoteProperty -Name Details -Value $ApprovalRequest.properties.approval.properties.details `
        | Add-Member -PassThru -MemberType NoteProperty -Name ApprovalId -Value $ApprovalRequest.properties.approval.name `
        | Add-Member -PassThru -MemberType NoteProperty -Name Owner -Value $ApprovalRequest.properties.approval.properties.owner.userPrincipalName `
        | Add-Member -PassThru -MemberType NoteProperty -Name EnvironmentName -Value $EnvironmentName `
        | Add-Member -PassThru -MemberType NoteProperty -Name CreationDate -Value $ApprovalRequest.properties.approval.properties.creationDate `
        | Add-Member -PassThru -MemberType NoteProperty -Name Internal -Value $ApprovalRequest
}

#internal, helper function
function CreateApprovalObject
{
    param
    (
        [Parameter(Mandatory = $true)]
        [object]$Approval,

        [Parameter(Mandatory = $true)]
        [string]$EnvironmentName
    )

    return New-Object -TypeName PSObject `
        | Add-Member -PassThru -MemberType NoteProperty -Name ApprovalId -Value $Approval.name `
        | Add-Member -PassThru -MemberType NoteProperty -Name Title -Value $Approval.properties.title `
        | Add-Member -PassThru -MemberType NoteProperty -Name Details -Value $Approval.properties.details `
        | Add-member -PassThru -MemberType NoteProperty -Name AssignedTo -Value ($Approval.properties.requestSummary.approvers | select userPrincipalName) `
        | Add-Member -PassThru -MemberType NoteProperty -Name CreationDate -Value $Approval.properties.creationDate `
        | Add-Member -PassThru -MemberType NoteProperty -Name EnvironmentName -Value $EnvironmentName `
        | Add-Member -PassThru -MemberType NoteProperty -Name Internal -Value $Approval
}

#internal, helper function
function BuildApprovalResponse
{
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$EnvironmentName,

        [Parameter(Mandatory = $true)]
        [string]$ApprovalId,

        [Parameter(Mandatory = $true)]
        [string]$ApprovalRequestId,

        [Parameter(Mandatory = $true)]
        [ValidateSet("Approve", "Reject")]
        [string]$Response,

        [Parameter(Mandatory = $true)]
        [string]$Comments
    )

    $owner = New-Object -TypeName PSObject `
        | Add-Member -PassThru -MemberType NoteProperty -Name id -Value $global:currentSession.userId `
        | Add-Member -PassThru -MemberType NoteProperty -Name type -Value "NotSpecified" `
        | Add-Member -PassThru -MemberType NoteProperty -Name tenantId $global:currentSession.tenantId

    $properties = New-Object -TypeName PSObject `
        | Add-Member -PassThru -MemberType NoteProperty -Name stage -Value "Basic" `
        | Add-Member -PassThru -MemberType NoteProperty -Name status -Value "Committed" `
        | Add-Member -PassThru -MemberType NoteProperty -Name creationDate -Value ([DateTime]::UtcNow.ToString("o")) `
        | Add-Member -PassThru -MemberType NoteProperty -Name owner -Value $owner `
        | Add-Member -PassThru -MemberType NoteProperty -Name response -Value $Response `
        | Add-Member -PassThru -MemberType NoteProperty -Name comments -Value $Comments

    $approvalResponse = New-Object -TypeName PSObject `
        | Add-Member -PassThru -MemberType NoteProperty -Name name -Value $ApprovalRequestId `
        | Add-Member -PassThru -MemberType NoteProperty -Name id -Value "/providers/Microsoft.ProcessSimple/environments/$EnvironmentName/approvals/$ApprovalId/approvalResponses/$ApprovalRequestId" `
        | Add-Member -PassThru -MemberType NoteProperty -Name type -Value "/providers/Microsoft.ProcessSimple/environments/approvals/approvalResponses" `
        | Add-Member -PassThru -MemberType NoteProperty -Name properties -Value $properties

    return $approvalResponse
}


#internal, helper function
function CreateHttpResponse
{
    param
    (
        [Parameter(Mandatory = $true)]
        [object]$ResponseObject
    )

    return New-Object -TypeName PSObject `
        | Add-Member -PassThru -MemberType NoteProperty -Name Code -Value $ResponseObject.StatusCode `
        | Add-Member -PassThru -MemberType NoteProperty -Name Description -Value $ResponseObject.StatusDescription `
        | Add-Member -PassThru -MemberType NoteProperty -Name Internal -value $ResponseObject;
}