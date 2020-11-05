// Web application name
param appName string = 'contoso0000000001'
param domainName string = 'contoso.jannemattila.com'
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

module hostNameBinding './hostNameBinding.bicep' = {
  name: 'hostNameBinding'
  params: {
    appName: appService.outputs.name
    domainName: domainName
  }
}

module certificate './certificate.bicep' = {
  name: 'certificate'
  params: {
    domainName: hostNameBinding.outputs.name
    appServicePlanId: appServicePlan.outputs.id
  }
}

module hostNameSsl './hostNameSsl.bicep' = {
  name: 'hostNameSsl'
  params: {
    appName: appService.outputs.name
    domainName: hostNameBinding.outputs.name
    thumbprint: certificate.outputs.thumbprint
  }
}