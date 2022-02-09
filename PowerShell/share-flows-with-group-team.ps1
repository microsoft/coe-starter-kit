# Testable outside of agent
function Grant-AccessToWorkflow ($token, $dataverseHost, $teamName, $workflowId) {
    $odataQuery = 'teams?$filter=name eq '+ "'$teamName'" + '&$select=teamid'
    $response = Invoke-DataverseHttpGet $token $dataverseHost $odataQuery
    $teamId = $response.value[0].teamid
    
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