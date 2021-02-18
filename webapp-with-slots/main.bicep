param appName string = 'contoso00000000020'
param location string = 'north europe'
param deployProductionSite bool = true

resource appServicePlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: 'asp'
  location: location
  kind: 'linux'
  sku: {
    name: 'S1'
    capacity: 1
  }
  properties: {
    reserved: true
  }
}

resource appService 'Microsoft.Web/sites@2020-06-01' = if (deployProductionSite) {
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
      healthCheckPath: '/'

      linuxFxVersion: 'DOCKER|jannemattila/webapp-update:1.0.4'
      appSettings: [
        {
          name: 'AppEnvironment'
          value: 'Banana'
        }
        {
          name: 'AppEnvironmentSticky'
          value: 'Banana'
        }
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
        {
          name: 'WEBSITE_SWAP_WARMUP_PING_PATH'
          value: '/'
        }
        {
          name: 'WEBSITE_SWAP_WARMUP_PING_STATUSES'
          value: '200'
        }
      ]
    }
    serverFarmId: appServicePlan.id
    httpsOnly: true
    clientAffinityEnabled: false
  }
}

resource config 'Microsoft.Web/sites/config@2020-06-01' = {
  name: '${appName}/slotConfigNames'
  location: location
  properties: {
    appSettingNames: [
      'AppEnvironmentSticky'
    ]
  }
}

resource slot 'Microsoft.Web/sites/slots@2020-06-01' = {
  name: '${appName}/staging'
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
      healthCheckPath: '/'

      linuxFxVersion: 'DOCKER|jannemattila/webapp-update:1.0.4'
      appSettings: [
        {
          name: 'AppEnvironment'
          value: 'Orange'
        }
        {
          name: 'AppEnvironmentSticky'
          value: 'Orange'
        }
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
        {
          name: 'WEBSITE_SWAP_WARMUP_PING_PATH'
          value: '/'
        }
        {
          name: 'WEBSITE_SWAP_WARMUP_PING_STATUSES'
          value: '200'
        }
      ]
    }
    serverFarmId: appServicePlan.id
    httpsOnly: true
    clientAffinityEnabled: false
  }
}

//
// Switch-AzWebAppSlot -ResourceGroupName "rg-bicep-slots" -Name "contoso00000000020" -SourceSlotName "staging" -SwapWithPreviewAction ResetSlotSwap -Verbose
// Switch-AzWebAppSlot -ResourceGroupName "rg-bicep-slots" -Name "contoso00000000020" -SourceSlotName "staging" -DestinationSlotName Production  -SwapWithPreviewAction ApplySlotConfig -Verbose
// Switch-AzWebAppSlot -ResourceGroupName "rg-bicep-slots" -Name "contoso00000000020" -SourceSlotName "staging" -DestinationSlotName Production  -SwapWithPreviewAction CompleteSlotSwap -Verbose
//