param location string = resourceGroup().location

module appServicePlan './appServicePlan.bicep' = {
    name: 'appServicePlan'
    params: {
        skuName: 'B1'
    }
}

output appServicePlanId string = appServicePlan.outputs.id
