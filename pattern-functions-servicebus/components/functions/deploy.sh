#!/bin/bash

# Params
resourceGroup1Location="eastus2"
resourceGroup2Location="centralus"

eastNetworkResourceGroupName="Network-RG-EastUS2"
centralNetworkResourceGroupName="Network-RG-CentralUS"

eastWorkloadResourceGroupName="Workload-RG-EastUS2"
centralWorkloadResourceGroupName="Workload-RG-CentralUS"

eastPlanName="demplaneast1"
centralPlanName="demplancentral1"

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