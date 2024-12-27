// https://devblogs.microsoft.com/identity/access-cloud-resources-across-tenants-without-secrets/
extension microsoftGraphV1

param location string = resourceGroup().location

param managedIdentityName string = 'umi-bicep-example'
param managedIdentityPrincipalId string = ''

param signInAudience string = 'AzureADMyOrg'
param issuer string = '${environment().authentication.loginEndpoint}${tenant().tenantId}/v2.0'

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = if (empty(managedIdentityPrincipalId)) {
  name: managedIdentityName
  location: location
}

resource myApp 'Microsoft.Graph/applications@v1.0' = {
  displayName: 'My Bicep Example App'
  uniqueName: 'my-bicep-example-application'
  signInAudience: signInAudience

  resource myMsiFic 'federatedIdentityCredentials@v1.0' = {
    name: 'my-bicep-example-application/${managedIdentityName}'
    description: 'Federated Identity Credentials for Managed Identity'
    audiences: [
      environment().authentication.audiences[1]
    ]
    issuer: issuer
    subject: empty(managedIdentityPrincipalId) ? managedIdentity.properties.principalId : managedIdentityPrincipalId
  }
}

resource exampleGroup 'Microsoft.Graph/groups@v1.0' = if (empty(managedIdentityPrincipalId)) {
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
