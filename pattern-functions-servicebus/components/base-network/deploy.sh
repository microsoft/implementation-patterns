#!/bin/bash

# Params
infix="ipfsb"

subscription_id=""

resourceGroup1Location="eastus2"
resourceGroup2Location="centralus"

resourceGroup1NameNet="$infix-net-$resourceGroup1Location"
resourceGroup2NameNet="$infix-net-$resourceGroup2Location"

vnet1Prefix="10.0.0.0/16"
vnet1FirewallSubnetPrefix="10.0.1.0/24"
vnet1DnsSubnetPrefix="10.0.2.0/24"
vnet1SpokePrefix="10.1.0.0/16"
vnet1WorkloadSubnetPrefix="10.1.2.0/24"

vnet2Prefix="10.2.0.0/16"
vnet2FirewallSubnetPrefix="10.2.1.0/24"
vnet2DnsSubnetPrefix="10.2.2.0/24"
vnet2SpokePrefix="10.3.0.0/16"
vnet2WorkloadSubnetPrefix="10.3.2.0/24"

templateFileVnet="azuredeploy-vnet.json"

# Create RGs
az group create --subscription "$subscription_id" --name "$resourceGroup1NameNet" --location "$resourceGroup1Location"
az group create --subscription "$subscription_id" --name "$resourceGroup2NameNet" --location "$resourceGroup2Location"

# Create VNets
az deployment group create --subscription "$subscription_id" --resource-group $resourceGroup1NameNet \
	--name "vnet1" --template-file "$templateFileVnet" --verbose --parameters \
	hubVnetPrefix="$vnet1Prefix" firewallSubnetPrefix="$vnet1FirewallSubnetPrefix" DNSSubnetPrefix="$vnet1DnsSubnetPrefix" \
	spokeVnetPrefix="$vnet1SpokePrefix" workloadSubnetPrefix="$vnet1WorkloadSubnetPrefix"

az deployment group create --subscription "$subscription_id" --resource-group $resourceGroup2NameNet \
	--name "vnet2" --template-file "$templateFileVnet" --verbose --parameters \
	hubVnetPrefix="$vnet2Prefix" firewallSubnetPrefix="$vnet2FirewallSubnetPrefix" DNSSubnetPrefix="$vnet2DnsSubnetPrefix" \
	spokeVnetPrefix="$vnet2SpokePrefix" workloadSubnetPrefix="$vnet2WorkloadSubnetPrefix"
