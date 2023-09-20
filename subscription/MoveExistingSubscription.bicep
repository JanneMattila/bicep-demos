// https://github.com/Azure/bicep-lz-vending/blob/main/src/self/Microsoft.Management/managementGroups/subscriptions/deploy.bicep
targetScope = 'managementGroup'

@description('The target management group ID for the subscription. Note: Do not supply the display name. The management group ID forms part of the Azure resource ID e.g., `/providers/Microsoft.Management/managementGroups/{managementGroupId}`.')
param targetManagementGroupId string

@description('The ID of the Subscription to move to the target Management Group')
param subscriptionId string

resource existingManagementGroup 'Microsoft.Management/managementGroups@2021-04-01' existing = {
  scope: tenant()
  name: targetManagementGroupId
}

resource managementGroupSubscriptionAssociation 'Microsoft.Management/managementGroups/subscriptions@2021-04-01' = {
  parent: existingManagementGroup
  name: subscriptionId
}
