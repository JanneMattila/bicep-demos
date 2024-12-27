// https://devblogs.microsoft.com/identity/access-cloud-resources-across-tenants-without-secrets/
extension microsoftGraphV1

param location string = resourceGroup().location

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'umi-bicep-example'
  location: location
}

resource myApp 'Microsoft.Graph/applications@v1.0' = {
  displayName: 'My Bicep Example App'
  uniqueName: 'my-bicep-example-application'

  resource myMsiFic 'federatedIdentityCredentials@v1.0' = {
    name: 'my-bicep-example-application/${managedIdentity.name}'
    description: 'Federated Identity Credentials for Managed Identity'
    audiences: [
      environment().authentication.audiences[1]
    ]
    issuer: '${environment().authentication.loginEndpoint}${tenant().tenantId}/v2.0'
    subject: managedIdentity.properties.principalId
  }
}

resource exampleGroup 'Microsoft.Graph/groups@v1.0' = {
  displayName: 'My Bicep Example Group'
  uniqueName: 'my-bicep-example-group'
  mailEnabled: false
  mailNickname: 'my-bicep-example-group'
  securityEnabled: true
  owners: [
    managedIdentity.properties.principalId
    deployer().objectId
  ]
  members: [
    managedIdentity.properties.principalId
    deployer().objectId
  ]
}
