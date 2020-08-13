#!/bin/bash

# Params
resourceGroup1Location="eastus2"
resourceGroup2Location="centralus"

eastNetworkResourceGroupName="Network-RG-EastUS2"
centralNetworkResourceGroupName="Network-RG-CentralUS"

# Create RGs
az group create --name $eastNetworkResourceGroupName --location $resourceGroup1Location
az group create --name $centralNetworkResourceGroupName --location $resourceGroup2Location

# Create VNets
az deployment group create --resource-group $eastNetworkResourceGroupName --name network-eastus2 --template-file azuredeploy-vnet.json --parameters hubVnetPrefix="10.0.0.0/16" firewallSubnetPrefix="10.0.1.0/24" DNSSubnetPrefix="10.0.2.0/24" spokeVnetPrefix="10.1.0.0/16" workloadSubnetPrefix="10.1.2.0/24"
az deployment group create --resource-group $centralNetworkResourceGroupName --name network-centralus --template-file azuredeploy-vnet.json --parameters hubVnetPrefix="10.2.0.0/16" firewallSubnetPrefix="10.2.1.0/24" DNSSubnetPrefix="10.2.2.0/24" spokeVnetPrefix="10.3.0.0/16" workloadSubnetPrefix="10.3.2.0/24"