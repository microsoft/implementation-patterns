
#!/bin/bash

# Params
resourceGroupLocation="eastus2"
ADFResourceGroupName="TESTRG"
# Create RGs
# az group create --name $ADFResourceGroupName --location $resourceGroupLocation

# Create Self hosted integration runtime
az deployment group create --resource-group $ADFResourceGroupName --template-file adfazureirdeploy.json --parameters @adfazureirdeploy.parameters.json