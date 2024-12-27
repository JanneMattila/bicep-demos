extension microsoftGraphV1

param location string = resourceGroup().location

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'umi-multi-tenant-example'
  location: location
}

resource myApp 'Microsoft.Graph/applications@v1.0' = {
  displayName: 'Multi-Tenant Example App'
  uniqueName: 'my-multi-tenant-application'
  signInAudience: 'AzureADMultipleOrgs'

  resource myMsiFic 'federatedIdentityCredentials@v1.0' = {
    name: 'my-multi-tenant-application/${managedIdentity.name}'
    description: 'Federated Identity Credentials for Managed Identity'
    audiences: [
      'api://AzureADTokenExchange'
    ]
    issuer: '${environment().authentication.loginEndpoint}${tenant().tenantId}/v2.0'
    subject: managedIdentity.properties.principalId
  }
}
