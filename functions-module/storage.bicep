param storageName string
param location string = resourceGroup().location

resource storageAccountResource 'Microsoft.Storage/storageAccounts@2019-06-01' = {
    name: storageName
    location: location
    kind: 'StorageV2'
    sku: {
        name: 'Standard_LRS'
    }
    properties: {
        supportsHttpsTrafficOnly: true
    }
}

// Prepare storage connection string to Azure Functions
var storageKeyValue = listKeys(storageAccountResource.id, '2019-06-01').keys[0].value

output storageKey string = storageKeyValue
output storageConnectionString string = 'DefaultEndpointsProtocol=https;AccountName=${storageName};AccountKey=${storageKeyValue}'
