param resourceName string = 'backend9000000'

resource resource 'Microsoft.Web/sites@2023-12-01' existing = {
  name: resourceName
}

resource metricAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: '${resourceName}-Requests'
  location: 'global'
  properties: {
    description: 'The total number of requests regardless of their resulting HTTP status code. For WebApps and FunctionApps.'
    scopes: [
      resource.id
    ]
    severity: 2
    enabled: true
    evaluationFrequency: 'PT5M'
    windowSize: 'PT5M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: '1st criterion'
          metricName: 'Requests'
          dimensions: []
          operator: 'GreaterThan'
          threshold: 50
          timeAggregation: 'Total'
          criterionType: 'StaticThresholdCriterion'
        }
      ]
    }
  }
}
