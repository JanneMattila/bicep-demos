
cd storage-demo

az login -o none --only-show-errors

az group create -l "swedencentral" -n "rg-storage-bicep" -o table

az bicep version
bicep --version

az bicep build --file main.bicep

az deployment group create --name "deploy-1" --mode Complete -g "rg-storage-bicep" --template-file main.bicep --what-if
az deployment group create --name "deploy-1" --mode Complete -g "rg-storage-bicep" --template-file main.bicep

# Add some properties

az deployment group create --name "deploy-2" --mode Complete -g "rg-storage-bicep" --template-file main.bicep --what-if
az deployment group create --name "deploy-2" --mode Complete -g "rg-storage-bicep" --template-file main.bicep

az group delete --name "rg-storage-bicep" -y
