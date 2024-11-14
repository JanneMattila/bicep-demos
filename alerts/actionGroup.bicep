resource actionGroup 'Microsoft.Insights/actionGroups@2023-01-01' = {
  name: 'ag-application-team'
  location: 'eastus'
  properties: {
    groupShortName: 'ag-appteam'
    enabled: true
    emailReceivers: [
      {
        name: 'email1'
        emailAddress: 'contoso-ops@contoso.com'
      }
    ]
    // smsReceivers: [
    //   {
    //     name: 'sms1'
    //     countryCode: '1'
    //     phoneNumber: '123456789'
    //   }
    // ]
    // webhookReceivers: [
    //   {
    //     name: 'webhook1'
    //     serviceUri: 'https://echo.contoso.com/api/echo'
    //   }
    // ]
  }
}

output id string = actionGroup.id
