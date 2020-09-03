param webAppPrefix string = 'bicep'
param location string = resourceGroup().location

// Create unique name for our web site
var appName = '${webAppPrefix}${uniqueString(resourceGroup().id)}'

resource storageAccountResource 'Microsoft.Storage/storageAccounts@2019-06-01' = {
    name: appName
    location: location
    kind: 'StorageV2'
    sku: {
        name: 'Standard_LRS'
    }
    properties: {
        supportsHttpsTrafficOnly: true
    }
}

resource appInsightsResource 'Microsoft.Insights/components@2015-05-01' = {
    name: 'ai-${appName}'
    location: location
    properties: {
        Application_Type: 'web'
    }
}

// This is app service plan for our serverless app:
resource farm 'Microsoft.Web/serverfarms@2019-08-01' = {
    name: 'asp-func'
    location: location
    sku: {
        name: 'Y1'
        tier: 'Dynamic'
    }
}

// Prepare storage connection string to Azure Functions
var storageKey = listKeys(storageAccountResource.id, '2019-06-01').keys[0].value
var storageConnectionString = 'DefaultEndpointsProtocol=https;AccountName=${appName};AccountKey=${storageKey}'

/*
 Here we create our Azure Functions site.
 */
resource appServiceResource 'Microsoft.Web/sites@2018-11-01' = {
    name: appName
    location: location
    kind: 'functionapp'
    identity: {
        type: 'SystemAssigned'
    }
    properties: {
        name: appName
        siteConfig: {
            appSettings: [
                {
                    name: 'AzureWebJobsDisableHomepage'
                    value: 'false' 
                }
                {
                    name: 'AzureWebJobsStorage'
                    value: storageConnectionString
                }
                {
                    name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
                    value: storageConnectionString
                }
                {
                    name: 'WEBSITE_CONTENTSHARE'
                    value: appName
                }
                {
                    name: 'FUNCTIONS_WORKER_RUNTIME'
                    value: 'dotnet'
                }
                {
                    name: 'FUNCTIONS_EXTENSION_VERSION'
                    value: '~3'
                }
                {
                    name: 'WEBSITE_RUN_FROM_PACKAGE'
                    value: '1'
                }
                {
                    name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
                    value: appInsightsResource.properties.InstrumentationKey
                }
            ]
        }
        serverFarmId: farm.id
    }
}

output webApp string = appName
output webAppUri string = appServiceResource.properties.hostNames[0]

output instrumentationKey string = appInsightsResource.properties.InstrumentationKey
