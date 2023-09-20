# All common parameters
$location = "North Europe"

Login-AzAccount

####################################
# Step 1: Create subscription
####################################

$createSubscriptionParameters = New-Object -TypeName hashtable
$createSubscriptionParameters['subscriptionDisplayName'] = "sub-team1-nonprod"
$createSubscriptionParameters['subscriptionAliasName'] = "sub-team1-nonprod"

# https://portal.azure.com/#view/Microsoft_Azure_GTM/ModernBillingMenuBlade/~/BillingAccounts
$createSubscriptionParameters['subscriptionBillingScope'] = "/providers/Microsoft.Billing/billingAccounts/account1"

$result = New-AzSubscriptionDeployment `
    -DeploymentName "CreateSubscription$((Get-Date).ToString("yyyy-MM-dd-HH-mm-ss"))" `
    -TemplateFile CreateSubscription.bicep `
    @createSubscriptionParameters `
    -Location $location `
    -Verbose

####################################
# Step 2: Move subscription
####################################

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

####################################
# Step 3: Prepare subscription
####################################

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

####################################
# Step 4: Deploy subscription
####################################

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
