param location string = resourceGroup().location

resource logAlertExceptions 'Microsoft.Insights/scheduledQueryRules@2024-01-01-preview' = {
  name: 'lg-alert-exceptions'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    displayName: 'lg-alert-exceptions'
    description: 'Alert on exceptions'
    severity: 2
    enabled: true
    evaluationFrequency: 'PT5M'
    scopes: [
      resourceGroup().id
    ]
    windowSize: 'PT5M'
    autoMitigate: true
    criteria: {
      allOf: [
        {
          query: 'AppExceptions'
          timeAggregation: 'Count'
          dimensions: []
          resourceIdColumn: '_ResourceId'
          operator: 'GreaterThan'
          threshold: 0
          failingPeriods: {
            numberOfEvaluationPeriods: 1
            minFailingPeriodsToAlert: 1
          }
        }
      ]
    }
  }
}
