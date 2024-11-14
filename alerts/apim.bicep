param resourceName string = 'apim9000000'

resource resource 'Microsoft.ApiManagement/service@2024-05-01' existing = {
  name: resourceName
}

resource metricAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: '${resourceName}-BackendDuration'
  location: 'global'
  properties: {
    description: 'Metric Alert for ApiManagement service BackendDuration'
    scopes: [
      resource.id
    ]
    severity: 3
    enabled: true
    evaluationFrequency: 'PT5M'
    windowSize: 'PT5M'
    autoMitigate: true
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: '1st criterion'
          metricName: 'BackendDuration'
          dimensions: []
          operator: 'GreaterThan'
          threshold: 1000 // 1 second
          timeAggregation: 'Average'
          criterionType: 'StaticThresholdCriterion'
        }
      ]
    }
  }
}
