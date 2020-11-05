param skuName string
param location string = resourceGroup().location

resource farm 'Microsoft.Web/serverfarms@2020-06-01' = {
    name: 'asp-webapp'
    location: location
    sku: {
        name: skuName
    }
}

output id string = farm.id
