#!/bin/bash

# Params
infix=""

subscription_id=""

location1="eastus2"
location2="centralus"

resourceGroup1NameNet="$infix-net-$location1"
resourceGroup2NameNet="$infix-net-$location2"

resourceGroup1NameWorkload="$infix-wl-$location1"
resourceGroup2NameWorkload="$infix-wl-$location2"

appName1="$infix-app-$location1"
appName2="$infix-app-$location2"

planName1="$infix-plan-$location1"
planName2="$infix-plan-$location2"

storageName1="$infix""sa""$location1"
storageName2="$infix""sa""$location2"

spokeVnetName="spoke-vnet"
subnetName="integration-subnet"
subnetPrefix1="10.1.3.0/24"
subnetPrefix2="10.3.3.0/24"

appId="$infix""app"
employeeID="123456"
org="$infix""-org"
env="dev"

templateFilePlan="azuredeploy-plan.json"
templateFileStorage="azuredeploy-storage.json"
templateFileApp="azuredeploy-app.json"
templateFileIntegrationSubnet="azuredeploy-integrationsubnet.json"
templateFileIntegrationVnet="azuredeploy-vnetintegration.json"

# Create RGs
az group create --subscription "$subscription_id" --name "$resourceGroup1NameWorkload" --location "$location1"
az group create --subscription "$subscription_id" --name "$resourceGroup2NameWorkload" --location "$location2"

# Create App Service Plans
az deployment group create --subscription "$subscription_id" --resource-group $resourceGroup1NameWorkload --name "plan1" \
	--template-file "$templateFilePlan" --verbose --parameters \
	planName="$planName1" applicationId="$appId" employeeId="$employeeID" organization="$org" environment="$env"

az deployment group create --subscription "$subscription_id" --resource-group $resourceGroup2NameWorkload --name "plan2" \
	--template-file "$templateFilePlan" --verbose --parameters \
	planName="$planName2" applicationId="$appId" employeeId="$employeeID" organization="$org" environment="$env"

# Create Storage Accounts
az deployment group create --subscription "$subscription_id" --resource-group $resourceGroup1NameWorkload --name "storage1" \
	--template-file "$templateFileStorage" --verbose --parameters \
	storageAccountName="$storageName1" applicationId="$appId" employeeId="$employeeID" organization="$org" environment="$env"

az deployment group create --subscription "$subscription_id" --resource-group $resourceGroup2NameWorkload --name "storage2" \
	--template-file "$templateFileStorage" --verbose --parameters \
	storageAccountName="$storageName2" applicationId="$appId" employeeId="$employeeID" organization="$org" environment="$env"

# Create Function Apps
az deployment group create --subscription "$subscription_id" --resource-group $resourceGroup1NameWorkload --name "app1" \
	--template-file "$templateFileApp" --verbose --parameters \
	appName="$appName1" planName="$planName1" storageAccountName="$storageName1" \
	applicationId="$appId" employeeId="$employeeID" organization="$org" environment="$env"

az deployment group create --subscription "$subscription_id" --resource-group $resourceGroup2NameWorkload --name "app2" \
	--template-file "$templateFileApp" --verbose --parameters \
	appName="$appName2" planName="$planName2" storageAccountName="$storageName2" \
	applicationId="$appId" employeeId="$employeeID" organization="$org" environment="$env"

# Deploy the Integration Subnets
az deployment group create --subscription "$subscription_id" --resource-group $resourceGroup1NameNet --name "subnet1" \
	--template-file "$templateFileIntegrationSubnet" --verbose --parameters \
	existingVnetName="$spokeVnetName" newSubnetName="$subnetName" integrationSubnetPrefix="$subnetPrefix1"

az deployment group create --subscription "$subscription_id" --resource-group $resourceGroup2NameNet --name "subnet2" \
	--template-file "$templateFileIntegrationSubnet" --verbose --parameters \
	existingVnetName="$spokeVnetName" newSubnetName="$subnetName" integrationSubnetPrefix="$subnetPrefix2"

# Enable VNet Integration for the Function Apps
az deployment group create --subscription "$subscription_id" --resource-group $resourceGroup1NameWorkload --name "vnetint1" \
	--template-file "$templateFileIntegrationVnet" --verbose --parameters \
	appName="$appName1" vnetName="$spokeVnetName" subnetName="$subnetName" networkResourceGroup="$resourceGroup1NameNet"

az deployment group create --subscription "$subscription_id" --resource-group $resourceGroup2NameWorkload  --name "vnetint2" \
	--template-file "$templateFileIntegrationVnet" --verbose --parameters \
	appName="$appName2" vnetName="$spokeVnetName" subnetName="$subnetName" networkResourceGroup="$resourceGroup2NameNet"

# Enable Function App Settings (WEBSITE-VNET-ROUTE-ALL) Use CLI to avoid wiping all configuration
az functionapp config appsettings set --subscription "$subscription_id" --name "$appName1" --resource-group "$resourceGroup1NameWorkload" --settings WEBSITE_VNET_ROUTE_ALL=1
az functionapp config appsettings set --subscription "$subscription_id" --name "$appName2" --resource-group "$resourceGroup2NameWorkload" --settings WEBSITE_VNET_ROUTE_ALL=1