using 'main.bicep'

param subnets = [
  {
    name: 'snet-1-with-rt'
    addressPrefix: '10.0.0.0/24'
    serviceEndpoints: []
  }
  {
    name: 'snet-2-with-nsg'
    addressPrefix: '10.0.1.0/24'
    serviceEndpoints: [
      {
        service: 'Microsoft.Storage'
      }
    ]
  }
  {
    name: 'snet-3-with-rt-and-nsg'
    addressPrefix: '10.0.2.0/24'
    serviceEndpoints: [
      {
        service: 'Microsoft.Storage'
      }
      {
        service: 'Microsoft.Sql'
      }
    ]
  }
]
