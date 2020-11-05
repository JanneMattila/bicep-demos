// Create unique name for our web site
param appName string = 'contoso0000000001'
param location string = resourceGroup().location

module appServicePlan './appServicePlan.bicep' = {
  name: 'appServicePlan'
  params: {
    skuName: 'B1'
  }
}

module appService './appService.bicep' = {
  name: 'appService'
  params: {
    appName: appName
    appServicePlanId: appServicePlan.outputs.id
  }
}

output appServicePlanId string = appServicePlan.outputs.id
