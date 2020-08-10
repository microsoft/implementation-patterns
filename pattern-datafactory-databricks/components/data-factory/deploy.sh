#!/bin/bash

# Params
name="adfsrgoeastus2"
resourceGroupLocation="eastus2"

# Create RGs
az group create --name $eastADFResourceGroupName --location $resourceGroupLocation

# Create VNets
az deployment group create --resource-group $eastADFResourceGroupName --name ADFdeployment  --template-file adfazuredeploy.json --parameters name="adfsrgoeastus4"
