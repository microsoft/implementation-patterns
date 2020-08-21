  
#!/bin/bash

# Params
resourceGroupLocation="eastus2"
ADFResourceGroupName="TESTRG"
# Create RGs
# az group create --name $ADFResourceGroupName --location $resourceGroupLocation

# Create Self hosted integration runtime
az deployment group create --resource-group $ADFResourceGroupName --template-file adf-template.json --parameters @adf-template.parameters.json