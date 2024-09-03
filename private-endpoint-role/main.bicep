// Copied from:
// https://techcommunity.microsoft.com/t5/azure-networking-blog/effortless-private-endpoint-management-in-azure-landing-zones-a/ba-p/4231936
targetScope = 'managementGroup'

metadata name = 'PrivateEndpointDnsContributor Role'
metadata description = 'Role for registring a Prviate Endpoint in a Private DNS Zone'

var varRole = {
  name: '[${managementGroup().name}] PrivateEndpointDnsContributor'
  description: 'Role for Contributing to Private Endpoint DNS Configuration'
}

resource resRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' = {
  name: guid(varRole.name, managementGroup().name)
  properties: {
    roleName: varRole.name
    description: varRole.description
    type: 'CustomRole'
    permissions: [
      {
        actions: [
          'Microsoft.Resources/subscriptions/resourceGroups/read'
          'Microsoft.Network/privateDnsZones/read'
          'Microsoft.Network/privateDnsZones/*/read'
          'Microsoft.Network/privateDnsZones/join/action'
        ]
        notActions: []
        dataActions: []
        notDataActions: []
      }
    ]
    assignableScopes: [
      tenantResourceId('Microsoft.Management/managementGroups', managementGroup().name)
    ]
  }
}

output outRoleDefinitionId string = resRoleDefinition.id
