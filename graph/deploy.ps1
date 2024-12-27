Param (
    [Parameter(HelpMessage = "Deployment target resource group")] 
    [string] $ResourceGroupName = "rg-microsoft-graph",

    [Parameter(HelpMessage = "Managed Identity Name")] 
    [string] $ManagedIdentityName = "umi-bicep-example",

    [Parameter(HelpMessage = "Managed Identity Principal Id")] 
    [string] $ManagedIdentityPrincipalId = "",

    [Parameter(HelpMessage = "Sign-in Audience")] 
    [ValidateSet("AzureADMyOrg", "AzureADMultipleOrgs")]
    [string] $SignInAudience = "AzureADMyOrg",
    
    [Parameter(HelpMessage = "Issuer (e.g., https://login.microsoftonline.com/<tenant-id>/v2.0)")] 
    [string] $Issuer = "",

    [Parameter(HelpMessage = "Deployment target resource group location")] 
    [string] $Location = "UK South",

    [string] $Template = "main.bicep"
)

$ErrorActionPreference = "Stop"

$date = (Get-Date).ToString("yyyy-MM-dd-HH-mm-ss")
$deploymentName = "Local-$date"

if ([string]::IsNullOrEmpty($env:RELEASE_DEFINITIONNAME)) {
    Write-Host (@"
Not executing inside Azure DevOps Release Management.
Make sure you have done "Login-AzAccount" and
"Select-AzSubscription -SubscriptionName name"
so that script continues to work correctly for you.
"@)
}
else {
    $deploymentName = $env:RELEASE_RELEASENAME
}

# Target deployment resource group
if ($null -eq (Get-AzResourceGroup -Name $ResourceGroupName -Location $Location -ErrorAction SilentlyContinue)) {
    Write-Warning "Resource group '$ResourceGroupName' doesn't exist and it will be created."
    New-AzResourceGroup -Name $ResourceGroupName -Location $Location -Verbose
}

# Additional parameters that we pass to the template deployment
$additionalParameters = New-Object -TypeName hashtable

if ([string]::IsNullOrEmpty($ManagedIdentityPrincipalId) -eq $false) {
    $additionalParameters['ManagedIdentityName'] = $ManagedIdentityName
    $additionalParameters['ManagedIdentityPrincipalId'] = $ManagedIdentityPrincipalId
}

if ([string]::IsNullOrEmpty($Issuer) -eq $false) {
    $additionalParameters['SignInAudience'] = $SignInAudience
    $additionalParameters['Issuer'] = $Issuer
}

$result = New-AzResourceGroupDeployment `
    -DeploymentName $deploymentName `
    -ResourceGroupName $ResourceGroupName `
    -TemplateFile $Template `
    @additionalParameters `
    -Force `
    -Verbose

$result
