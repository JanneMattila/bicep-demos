param storageAccountName string = 's00000000010234'

param location string = resourceGroup().location

resource storageAccountResource 'Microsoft.Storage/storageAccounts@2019-06-01' = {
    name: storageAccountName
    location: location
    kind: 'StorageV2'
    sku: {
        name: 'Standard_LRS'
    }
}

output storage object = storageAccountResource
output storageId string = storageAccountResource.id
output storageBlobEndpoint string = storageAccountResource.properties.primaryEndpoints.blob
