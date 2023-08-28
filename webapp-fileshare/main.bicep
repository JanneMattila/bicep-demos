param appName string = 'contoso0000000002'
param storageAccountName string = 'contoso0000000002'
param location string = resourceGroup().location

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

resource fileService 'Microsoft.Storage/storageAccounts/fileServices@2022-09-01' = {
  name: 'default'
  parent: storageAccount
  properties: {
    shareDeleteRetentionPolicy: {
      enabled: true
      days: 7
    }
  }
}

resource fileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2022-09-01' = {
  name: 'share1'
  parent: fileService
  properties: {
    enabledProtocols: 'SMB'
    accessTier: 'Hot'
    shareQuota: 10
  }
}

var storagePrimaryKey = listKeys(storageAccount.id, '2019-06-01').keys[0].value

resource appServicePlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: 'asp-webapp'
  location: location
  kind: 'linux'
  sku: {
    name: 'B1'
  }
  properties: {
    reserved: true
  }
}

resource appService 'Microsoft.Web/sites@2022-09-01' = {
  name: appName
  location: location
  kind: 'app,linux,container'
  properties: {
    siteConfig: {
      alwaysOn: true
      http20Enabled: true
      linuxFxVersion: 'DOCKER|jannemattila/webapp-fs-tester:1.1.12'

      azureStorageAccounts: {
        share1: {
          accountName: storageAccount.name
          accessKey: storagePrimaryKey
          type: 'AzureFiles'
          mountPath: '/mnt/share1'
          shareName: 'share1'
        }
      }
    }
    serverFarmId: appServicePlan.id
    httpsOnly: true
    clientAffinityEnabled: false
  }
}
