param appName1 string = 'contoso00000000010'
param appName2 string = 'contoso00000000011'
param location1 string = 'north europe'
param location2 string = 'west europe'

param frontDoorName string = 'contoso0000000001'

module webApp1 './webApp.bicep' = {
  name: 'webApp1'
  params: {
    appPlanName: 'appServicePlan1'
    appName: appName1
    location: location1
  }
}

module webApp2 './webApp.bicep' = {
  name: 'webApp2'
  params: {
    appPlanName: 'appServicePlan2'
    appName: appName2
    location: location2
  }
}

resource frontDoor 'Microsoft.Network/frontDoors@2020-05-01' = {
  name: frontDoorName
  location: 'global'
  properties: {
    friendlyName: frontDoorName
    
  }
}