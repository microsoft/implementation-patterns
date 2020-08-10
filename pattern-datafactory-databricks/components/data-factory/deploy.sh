#!/bin/bash

# Params
name="adfsrgoeastus2"
resourceGroupLocation="eastus2"

# Create VNets
az deployment group create --resource-group $resourceGroupLocation --name ADFdeployment  --template-file adfazuredeploy.json --parameters name="adfsrgoeastus3"