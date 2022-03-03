# Testable outside of agent
function Grant-AccessToWorkflow ($token, $dataverseHost, $teamName, $workflowId) {
    $teamId = Get-TeamId $token $dataverseHost $teamName
    if($teamId -ne '') {
        $body = "{
        `n    `"Target`":{
        `n        `"workflowid`":`"$workflowId`",
        `n        `"@odata.type`": `"Microsoft.Dynamics.CRM.workflow`"
        `n    },
        `n    `"PrincipalAccess`":{
        `n        `"Principal`":{
        `n            `"teamid`": `"$teamId`",
        `n            `"@odata.type`": `"Microsoft.Dynamics.CRM.team`"
        `n        },
        `n        `"AccessMask`": `"ReadAccess`"
        `n    }
        `n}"
    
        $requestUrlRemainder = "GrantAccess"
        Invoke-DataverseHttpPost $token $dataverseHost $requestUrlRemainder $body
    }
}

function Grant-AccessToConnector ($token, $dataverseHost, $teamName, $workflowId) {
    $teamId = Get-TeamId $token $dataverseHost $teamName
    if($teamId -ne '') {
        $body = "{
        `n    `"Target`":{
        `n        `"connectorid`":`"$workflowId`",
        `n        `"@odata.type`": `"Microsoft.Dynamics.CRM.connector`"
        `n    },
        `n    `"PrincipalAccess`":{
        `n        `"Principal`":{
        `n            `"teamid`": `"$teamId`",
        `n            `"@odata.type`": `"Microsoft.Dynamics.CRM.team`"
        `n        },
        `n        `"AccessMask`": `"ReadAccess`"
        `n    }
        `n}"
    
        $requestUrlRemainder = "GrantAccess"
        Invoke-DataverseHttpPost $token $dataverseHost $requestUrlRemainder $body
    }
}

function Get-TeamId ($token, $dataverseHost, $teamName) {
    $teamId = ''
    $odataQuery = 'teams?$filter=name eq ' + "'$teamName'" + '&$select=teamid'
    $response = Invoke-DataverseHttpGet $token $dataverseHost $odataQuery
    if($response.value.length -gt 0) {
        $teamId = $response.value[0].teamid
    }
    return $teamId
}