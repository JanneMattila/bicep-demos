param echoAddress string = 'http://your-favorite-request-bin-service'
param azureDevOpsOrganizationName string = 'orgname'
param azureDevOpsPipelineDefinitionId int = 1
param azureDevOpsProjectName string = 'project'
param location string = resourceGroup().location

var logicAppName = 'keyvault-event-handler'
var azureDevOpsConnectionName = 'azure-devops-connection'

resource azureDevOpsConnection 'Microsoft.Web/connections@2016-06-01' = {
  name: azureDevOpsConnectionName
  location: location
  properties: {
    api: {
      id: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Web/locations/${location}/managedApis/visualstudioteamservices'
    }
    displayName: azureDevOpsConnectionName
  }
}

resource logicApp 'Microsoft.Logic/workflows@2016-06-01' = {
  name: logicAppName
  location: location
  properties: {
    definition: {
      '$schema': 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'
      contentVersion: '1.0.0.0'
      parameters: {
        '$connections': {
          defaultValue: {}
          type: 'Object'
        }
        EchoAddress: {
          defaultValue: echoAddress
          type: 'String'
        }
        OrganizationName: {
          defaultValue: azureDevOpsOrganizationName
          type: 'String'
        }
        PipelineDefinitionId: {
          defaultValue: azureDevOpsPipelineDefinitionId
          type: 'Int'
        }
        TeamProjectName: {
          defaultValue: azureDevOpsProjectName
          type: 'String'
        }
      }
      triggers: {
        manual: {
          type: 'Request'
          kind: 'Http'
          inputs: {
            schema: {
              properties: {
                data: {
                  properties: {
                    EXP: {}
                    Id: {
                      type: 'string'
                    }
                    NBF: {}
                    ObjectName: {
                      type: 'string'
                    }
                    ObjectType: {
                      type: 'string'
                    }
                    VaultName: {
                      type: 'string'
                    }
                    Version: {
                      type: 'string'
                    }
                  }
                  type: 'object'
                }
                dataschema: {
                  type: 'string'
                }
                id: {
                  type: 'string'
                }
                source: {
                  type: 'string'
                }
                specversion: {
                  type: 'string'
                }
                subject: {
                  type: 'string'
                }
                time: {
                  type: 'string'
                }
                type: {
                  type: 'string'
                }
              }
              type: 'object'
            }
          }
        }
      }
      actions: {
        HTTP: {
          runAfter: {}
          type: 'Http'
          inputs: {
            body: {
              eventType: '@{triggerBody()?[\'type\']}'
              objectName: '@{triggerBody()?[\'data\']?[\'ObjectName\']}'
              objectType: '@{triggerBody()?[\'data\']?[\'ObjectType\']}'
              vaultName: '@{triggerBody()?[\'data\']?[\'VaultName\']}'
            }
            method: 'POST'
            uri: '@{parameters(\'EchoAddress\')}'
          }
        }
        Send_an_HTTP_request_to_Azure_DevOps: {
          runAfter: {
            HTTP: [
              'Succeeded'
            ]
          }
          type: 'ApiConnection'
          inputs: {
            body: {
              Body: '{\n "definition":  {\n  "id": @{parameters(\'PipelineDefinitionId\')}\n }\n}'
              Method: 'POST'
              Uri: '@{parameters(\'TeamProjectName\')}/_apis/build/builds?api-version=5.1'
            }
            host: {
              connection: {
                name: '@parameters(\'$connections\')[\'visualstudioteamservices\'][\'connectionId\']'
              }
            }
            method: 'post'
            path: '/httprequest'
            queries: {
              account: '@parameters(\'OrganizationName\')'
            }
          }
        }
      }
      outputs: {}
    }
    parameters: {
      '$connections': {
        value: {
          visualstudioteamservices: {
            id: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Web/locations/${location}/managedApis/visualstudioteamservices'
            connectionId: azureDevOpsConnection.id
            connectionName: azureDevOpsConnectionName
          }
        }
      }
    }
  }
}

output logicApp string = logicApp.id