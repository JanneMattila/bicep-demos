
Login-AzAccount

Select-AzSubscription -SubscriptionName "Production"

$subscriptionId = (Get-AzContext).Subscription.Id
$subscriptionId

$additionalParameters = New-Object -TypeName hashtable
$additionalParameters['targetManagementGroupId'] = "mg-prod"
$additionalParameters['subscriptionId'] = $subscriptionId
$location = "North Europe"

$result = New-AzSubscriptionDeployment `
    -DeploymentName "MoveSubscription-$((Get-Date).ToString("yyyy-MM-dd-HH-mm-ss"))" `
    -TemplateFile MoveExistingSubscription.bicep `
    @additionalParameters `
    -Location $location `
    -Verbose

$result
