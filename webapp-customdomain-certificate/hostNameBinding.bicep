param appName string
param domainName string

resource hostNameBinding 'Microsoft.Web/sites/hostNameBindings@2020-06-01' = {
  name: '${appName}/${domainName}'
  properties: {
    siteName: appName
    customHostNameDnsRecordType: 'CName'
    hostNameType: 'Verified'
  }
}

output name string = domainName
