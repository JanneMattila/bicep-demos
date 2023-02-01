param storageAccountName1 string
param storageAccountName2 string

param location string = resourceGroup().location

resource storageAccountResource1 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: storageAccountName1
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}
// module deployed to resource group in the same subscription
module exampleModule 'storage.bicep' = {
  name: 'otherRG'
  scope: resourceGroup('rg-other')
  params: {
    location: location
    storageName: storageAccountName2
  }
}
