param appName string
param domainName string
param thumbprint string
param location string = resourceGroup().location

resource hostNameSsl 'Microsoft.Web/sites@2020-06-01' = {
  name: appName
  location: location
  properties: {
    hostNameSslStates: [
      {
        name: domainName
        sslState: 'SniEnabled'
        thumbprint: thumbprint
        toUpdate: true
      }
    ]
  }
}
