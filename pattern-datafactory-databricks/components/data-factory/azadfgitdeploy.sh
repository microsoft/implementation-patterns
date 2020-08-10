  
#!/bin/bash

# Params
resourceGroupLocation="eastus2"
ADFResourceGroupName="TESTRG"
# Create RGs
# az group create --name $ADFResourceGroupName --location $resourceGroupLocation

# Create Data Factory with Azure Devops CI\CD integration
az deployment group create --resource-group $ADFResourceGroupName --template-file adfgitintegrationdeploy.json --parameters @adfgitintegrationdeploy.parameters.json