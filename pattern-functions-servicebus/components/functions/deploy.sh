#!/bin/bash

# Params
resourceGroup1Location="eastus2"
resourceGroup2Location="centralus"

eastNetworkResourceGroupName="Network-RG-EastUS2"
centralNetworkResourceGroupName="Network-RG-CentralUS"

eastWorkloadResourceGroupName="Workload-RG-EastUS2"
centralWorkloadResourceGroupName="Workload-RG-CentralUS"

eastAppName="demappeast1"
centralAppName="demappcentral1"

eastPlanName="demplaneast1"
centralPlanName="demplancentral1"

eastStorageName="demstoreast1"
centralStorageName="demstorcentral1"

appId="ap123456"
employeeID="123456"
org="orga"
env="dev"

# Create RGs
az group create --name $eastWorkloadResourceGroupName --location $resourceGroup1Location
az group create --name $centralWorkloadResourceGroupName --location $resourceGroup2Location

# Create App Service Plans
az deployment group create --resource-group $eastWorkloadResourceGroupName --name plan-eastus2 --template-file azuredeploy-plan.json --parameters planName=$eastPlanName applicationId=$appId employeeId=$employeeID organization=$org environment=$env
az deployment group create --resource-group $centralWorkloadResourceGroupName --name plan-centralus --template-file azuredeploy-plan.json --parameters planName=$centralPlanName applicationId=$appId employeeId=$employeeID organization=$org environment=$env

# Create Storage Accounts
az deployment group create --resource-group $eastWorkloadResourceGroupName --name storage-eastus2 --template-file azuredeploy-storage.json --parameters storageAccountName=$eastStorageName applicationId=$appId employeeId=$employeeID organization=$org environment=$env
az deployment group create --resource-group $centralWorkloadResourceGroupName --name storage-centralus --template-file azuredeploy-storage.json --parameters storageAccountName=$centralStorageName applicationId=$appId employeeId=$employeeID organization=$org environment=$env

# Create Function Apps
az deployment group create --resource-group $eastWorkloadResourceGroupName --name app-eastus2 --template-file azuredeploy-app.json --parameters appName=$eastAppName planName=$eastPlanName storageAccountName=$eastStorageName applicationId=$appId employeeId=$employeeID organization=$org environment=$env
az deployment group create --resource-group $centralWorkloadResourceGroupName --name app-centralus --template-file azuredeploy-app.json --parameters appName=$centralAppName planName=$centralPlanName storageAccountName=$centralStorageName applicationId=$appId employeeId=$employeeID organization=$org environment=$env

# Deploy the Integration Subnets
az deployment group create --resource-group $eastNetworkResourceGroupName --name app-eastus2 --template-file azuredeploy-integrationsubnet.json --parameters existingVnetName="spoke-vnet" newSubnetName="integration-subnet" integrationSubnetPrefix="10.1.3.0/24"
az deployment group create --resource-group $centralNetworkResourceGroupName --name app-centralus --template-file azuredeploy-integrationsubnet.json --parameters existingVnetName="spoke-vnet" newSubnetName="integration-subnet" integrationSubnetPrefix="10.3.3.0/24"
