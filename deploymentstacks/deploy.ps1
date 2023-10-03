# All common parameters
$location = "North Europe"
$resourceGroupName = "rg-bicep-deploymentstacks-demo"

Login-AzAccount -Tenant $env:CONTOSO_TENANT_ID
Get-AzContext
$me = (Get-AzContext).Account.Id
$me

$user = Get-AzADUser -Mail $me
$user

New-AzResourceGroup -Name $resourceGroupName -Location $location -Verbose

$contentParameters = New-Object -TypeName hashtable
# $subscriptionContentParameters['hubVNetId'] = "..."

$result = New-AzResourceGroupDeploymentStack `
    -Name "RGContent" `
    -ResourceGroupName $resourceGroupName `
    -TemplateFile Main.bicep `
    @contentParameters `
    -DenySettingsMode DenyDelete `
    -DenySettingsApplyToChildScopes `
    -DeleteResources `
    -DeleteResourceGroups `
    -DenySettingsExcludedPrincipal $user.Id `
    -Force `
    -Verbose

$result
