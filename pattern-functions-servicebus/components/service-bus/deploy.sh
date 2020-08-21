#!/bin/bash

# Params
resourceGroup1Name="ServiceBusDem-EastUS2"
resourceGroup2Name="ServiceBusDem-CentralUS"

resourceGroup1Location="eastus2"
resourceGroup2Location="centralus"

namespace1Name="namespace1ksk"
namespace2Name="namespace2ksk"

aliasName="namespacekskalias"

eastNetworkResourceGroupName="Network-RG-EastUS2"
centralNetworkResourceGroupName="Network-RG-CentralUS"

# Create RGs
az group create --name $resourceGroup1Name --location $resourceGroup1Location
az group create --name $resourceGroup2Name --location $resourceGroup2Location

# Deploy Primary Namespace
az deployment group create --name primaryns --resource-group $resourceGroup1Name --template-file azuredeploy-namespace.json --parameters namespaceName=$namespace1Name
# Create Topics and Queues
az deployment group create --name queuestopics --resource-group $resourceGroup1Name --template-file azuredeploy-queuestopics.json --parameters namespaceName=$namespace1Name

# Deploy Secondary Namespace
# No entities on this namespace as they will come over with replication
az deployment group create --name secondaryns --resource-group $resourceGroup2Name --template-file azuredeploy-namespace.json --parameters namespaceName=$namespace2Name

# Set up Geo-Replication
az deployment group create --name georep --resource-group $resourceGroup1Name --template-file azuredeploy-georeplication.json --parameters namespaceName=$namespace1Name pairedNamespaceName=$namespace2Name pairedNamespaceResourceGroup=$resourceGroup2Name aliasName=$aliasName

# Enable Private Endpoints, Private Zones
# Create East US 2 Zone
az deployment group create --name eastuszone --resource-group $resourceGroup1Name --template-file azuredeploy-privatezone.json --parameters privateDnsZoneName=privatelink.servicebus.windows.net
# Create Central US Zone
az deployment group create --name centraluszone --resource-group $resourceGroup2Name --template-file azuredeploy-privatezone.json --parameters privateDnsZoneName=privatelink.servicebus.windows.net

# Endpoint in Central pointing to Central Namespace
az deployment group create --name centralusep1 --resource-group $resourceGroup2Name --template-file azuredeploy-privatelink.json --parameters namespaceName=$namespace2Name privateEndpointName=CentraltoCentral privateDnsZoneName=privatelink.servicebus.windows.net vnetName=spoke-vnet subnetName=workload-subnet networkResourceGroup=$centralNetworkResourceGroupName namespaceResourceGroup=$resourceGroup2Name primary=false
# Endpoint in Central pointing to East Namespace
az deployment group create --name centralusep2 --resource-group $resourceGroup2Name --template-file azuredeploy-privatelink.json --parameters namespaceName=$namespace1Name privateEndpointName=CentraltoEast privateDnsZoneName=privatelink.servicebus.windows.net vnetName=spoke-vnet subnetName=workload-subnet networkResourceGroup=$centralNetworkResourceGroupName namespaceResourceGroup=$resourceGroup1Name primary=false
# Endpoint in East pointing to East Namespace
az deployment group create --name eastusep1 --resource-group $resourceGroup1Name --template-file azuredeploy-privatelink.json --parameters namespaceName=$namespace1Name privateEndpointName=EasttoEast privateDnsZoneName=privatelink.servicebus.windows.net vnetName=spoke-vnet subnetName=workload-subnet networkResourceGroup=$eastNetworkResourceGroupName  namespaceResourceGroup=$resourceGroup1Name primary=true
# Endpoint in East pointing to Central Namespace
az deployment group create --name eastusep2 --resource-group $resourceGroup1Name --template-file azuredeploy-privatelink.json --parameters namespaceName=$namespace2Name privateEndpointName=EasttoCentral privateDnsZoneName=privatelink.servicebus.windows.net vnetName=spoke-vnet subnetName=workload-subnet networkResourceGroup=$eastNetworkResourceGroupName   namespaceResourceGroup=$resourceGroup2Name primary=true

# Link Zones to VNets
az deployment group create --name eastuszonelink --resource-group $resourceGroup1Name --template-file azuredeploy-zonelink.json --parameters privateDnsZoneName=privatelink.servicebus.windows.net vnetName=spoke-vnet networkResourceGroup=$eastNetworkResourceGroupName
az deployment group create --name centraluszonelink --resource-group $resourceGroup2Name --template-file azuredeploy-zonelink.json --parameters privateDnsZoneName=privatelink.servicebus.windows.net vnetName=spoke-vnet networkResourceGroup=$centralNetworkResourceGroupName