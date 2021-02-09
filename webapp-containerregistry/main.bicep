param appName string = 'contoso0000000002'
param acrName string = 'contoso0000000002'
param location string = resourceGroup().location

resource acr 'Microsoft.ContainerRegistry/registries@2020-11-01-preview' = {
  name: acrName
  location: location
  sku: {
    name: 'Basic'
  }
}

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

resource appService 'Microsoft.Web/sites@2020-06-01' = {
  name: appName
  location: location
  kind: 'web'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    siteConfig: {
      alwaysOn: true
      http20Enabled: true
      ftpsState: 'Disabled'

      // Read instructions at the end of this document how to deploy image
      acrUseManagedIdentityCreds: true
      linuxFxVersion: 'DOCKER|${acr.properties.loginServer}/echo:latest'
    }

    serverFarmId: appServicePlan.id
    httpsOnly: true
    clientAffinityEnabled: false
  }
}

// 1. Pull image from Docker Hub to local machine
// docker pull jannemattila/echo
//
// 2. Login to ACR
// $acr = "contoso0000000002"
// az acr login --name $acr
//
// 3. Tag image
// docker tag jannemattila/echo "$acr.azurecr.io/echo"
//
// 4. Push image to ACR
// docker push "$acr.azurecr.io/echo"