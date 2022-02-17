$subscriptionName = "AzureDev"
$acrName = "myacrbicepdemo00010"
$resourceGroupName = "my-bicep-registry"
$location = "westeurope"

# Login and set correct context
az login -o table
az account set --subscription $subscriptionName -o table

az group create -l $location -n $resourceGroupName -o table

$loginServer = (az acr create -l $location -g $resourceGroupName -n $acrName --sku Basic --query loginServer -o tsv)
$loginServer

# Publish files to registry
# Requires: Bicep CLI to v0.4.1008 or later, so remember to:
az bicep upgrade

az bicep publish --file storage\main.bicep --target "br:$loginServer/bicep/modules/storage:v1"
"br:$loginServer/bicep/modules/storage:v1"

# Wipe out the resources
az group delete --name $resourceGroupName -y
