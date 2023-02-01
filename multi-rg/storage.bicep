param storageName string
param location string

resource storageAccountResource 'Microsoft.Storage/storageAccounts@2019-06-01' = {
    name: storageName
    location: location
    kind: 'StorageV2'
    sku: {
        name: 'Standard_LRS'
    }
}
