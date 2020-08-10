#!/bin/bash

# Params
resourceGroupLocation="eastus2"

# Create RGs
az group create --name $eastADFResourceGroupName --location $resourceGroupLocation

# Create Dara Factory
az deployment group create --resource-group $eastADFResourceGroupName --name ADFdeployment  --template-file adfazuredeploy.json --parameters name="adfsrgoeastus4"
