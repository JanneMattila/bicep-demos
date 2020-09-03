param webAppPrefix string = 'bicep'
param location string = resourceGroup().location

// Create unique name for our web site
var webAppName = '${webAppPrefix}${uniqueString(resourceGroup().id)}'

// This is app service plan for our serverless app:
resource farm 'Microsoft.Web/serverfarms@2019-08-01' = {
    name: 'asp-func'
    location: location
    sku: {
        name: 'Y1'
        tier: 'Dynamic'
    }
}

/*
 Here we create our Azure Functions site.
 */
resource appServiceResource 'Microsoft.Web/sites@2018-11-01' = {
    name: webAppName
    location: location
    kind: 'functionapp'
    identity: {
        type: 'SystemAssigned'
    }
    properties: {
        name: webAppName
        siteConfig: {
            appSettings: [
                {
                name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
                value: 'false'
                }
            ]
        }
        serverFarmId: farm.id
    }
}

output webApp string = webAppName
output webAppUri string = appServiceResource.properties.hostNames[0]
