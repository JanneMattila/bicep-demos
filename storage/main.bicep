param storageAccountName string = 'stor100000001'

param location string = resourceGroup().location

resource storageAccountResource 'Microsoft.Storage/storageAccounts@2019-06-01' = {
    name: storageAccountName
    location: location
    kind: 'Storage'
    sku: {
        name: 'Standard_LRS'
    }
}

output storage object = storageAccountResource
output storageId string = storageAccountResource.id
output storageKeys object = listKeys(storageAccountResource.id, '2019-06-01')

// Return primary key of storage account
output storagePrimaryKey string = listKeys(storageAccountResource.id, '2019-06-01').keys[0].value

output storageBlobEndpoint string = storageAccountResource.properties.primaryEndpoints.blob