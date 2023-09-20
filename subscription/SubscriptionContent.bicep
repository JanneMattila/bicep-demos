// https://github.com/Azure/bicep-lz-vending/blob/615a00667847e02a409946ef19b2e93b8d20ec14/src/carml/v0.6.0/Microsoft.Resources/resourceGroups/deploy.bicep
targetScope = 'subscription'

@description('Optional. Location of the Resource Group. It uses the deployment\'s location when not provided.')
param location string = deployment().location

resource resourceGroupOne 'Microsoft.Resources/resourceGroups@2019-05-01' = {
  name: 'rg-one'
  location: location
}

resource resourceGroupTwo 'Microsoft.Resources/resourceGroups@2019-05-01' = {
  name: 'rg-two'
  location: location
}

module moduleOne 'ResourceGroupOne.bicep' = {
  name: 'moduleOne'
  scope: resourceGroupOne
  params: {
    location: location
  }
}
