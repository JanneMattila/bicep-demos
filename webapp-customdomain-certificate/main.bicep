// Create unique name for our web site
param appName string = 'contoso0000000001'
param domainName string = 'contoso1.jannemattila.com'
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

module hostNameBindings './hostNameBindings.bicep' = {
  name: 'hostNameBindings'
  params: {
    appName: appService.outputs.name
    domainName: domainName
  }
}

module certificates './certificates.bicep' = {
  name: 'certificates'
  params: {
    domainName: hostNameBindings.outputs.name
    appServicePlanId: appServicePlan.outputs.id
  }
}

module hostNameSsl './hostNameSsl.bicep' = {
  name: 'hostNameSsl'
  params: {
    appName: appService.outputs.name
    domainName: hostNameBindings.outputs.name
    thumbprint: certificates.outputs.thumbprint
  }
}