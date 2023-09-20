# All common parameters
$location = "North Europe"

Login-AzAccount

Select-AzSubscription -SubscriptionName "Production"

$subscriptionId = (Get-AzContext).Subscription.Id
$subscriptionId



$moveExistingSubscriptionParameters = New-Object -TypeName hashtable
$moveExistingSubscriptionParameters['targetManagementGroupId'] = "mg-prod"
$moveExistingSubscriptionParameters['subscriptionId'] = $subscriptionId

$result = New-AzSubscriptionDeployment `
    -DeploymentName "MoveExistingSubscription$((Get-Date).ToString("yyyy-MM-dd-HH-mm-ss"))" `
    -TemplateFile MoveExistingSubscription.bicep `
    @moveExistingSubscriptionParameters `
    -Location $location `
    -Verbose

$result

New-AzSubscriptionDeployment `
    -TemplateFile MoveExistingSubscription.bicep `
    @moveExistingSubscriptionParameters `
    -Location $location `
    -Verbose -WhatIfResultFormat FullResourcePayloads -WhatIf

# Example:
# https://github.com/Azure/bicep-lz-vending/blob/615a00667847e02a409946ef19b2e93b8d20ec14/.github/scripts/Register-SubResourceProviders.ps1

$providerNamespaces = @(
    "Microsoft.Batch"
    "Microsoft.Cache"
)

foreach ($providerNamespace in $providerNamespaces) {
    Register-AzResourceProvider -ProviderNamespace $providerNamespace
}

$providerNamespaces | ForEach-Object {
    $providerNamespace = $_
    $registered = $false
    while (-not $registered) {
        $registered = (Get-AzResourceProvider -ProviderNamespace $providerNamespace).RegistrationState -eq "Registered"
        if (-not $registered) {
            Write-Host "Waiting for provider $providerNamespace to finish registering..."
            Start-Sleep -Seconds 15
        }
    }
}

$subscriptionContentParameters = New-Object -TypeName hashtable
# $additionalParametersToSubscriptionContent['hubVNetId'] = "..."

$result = New-AzSubscriptionDeployment `
    -DeploymentName "SubscriptionContent$((Get-Date).ToString("yyyy-MM-dd-HH-mm-ss"))" `
    -TemplateFile SubscriptionContent.bicep `
    @subscriptionContentParameters `
    -Location $location `
    -Verbose

New-AzSubscriptionDeployment `
    -TemplateFile SubscriptionContent.bicep `
    @subscriptionContentParameters `
    -Location $location `
    -Verbose -WhatIfResultFormat FullResourcePayloads -WhatIf