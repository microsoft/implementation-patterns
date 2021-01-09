#!/bin/bash

subscriptionId="e61e4c75-268b-4c94-ad48-237aa3231481"
location1="eastus2"
resourceGroup="netfu"

nsgNameLocation1="nsg-""$location1"
nsgRuleInbound100Src="75.68.47.183" # Inbound allow for debugging - likely remove in production

templateNsg="./template/net.nsg.json"
templateVNet="./template/net.vnet.json"
templateSubnet="./template/net.vnet.subnet.json"

vnetNameHubLocation1="vnet-hub-""$location1"
vnetPrefixHubLocation1="10.50.0.0/16"
subnetPrefixFirewallLocation1="10.50.1.0/24"

vnetNameSpoke1Location1="vnet-spoke1-""$location1"
vnetPrefixSpoke1Location1="10.60.0.0/16"
subnetNameShared="shared"
subnetPrefixShared="10.60.10.0/24"

## NSG
#az deployment group create --subscription "$subscriptionId" -n "NSG-""$location1" --verbose \
#	-g "$resourceGroup" --template-file "$templateNsg" \
#	--parameters \
#	location="$location1" \
#	nsgName="$nsgNameLocation1" \
#	nsgRuleInbound100Src="$nsgRuleInbound100Src"

## Hub VNet with Firewall Subnet
#az deployment group create --subscription "$subscriptionId" -n "VNet-Hub-""$location1" --verbose \
#	-g "$resourceGroup" --template-file "$templateVNet" \
#	--parameters \
#	location="$location1" \
#	vnetName="$vnetNameHubLocation1" \
#	vnetPrefix="$vnetPrefixHubLocation1" \
#	subnetPrefixFirewall="$subnetPrefixFirewallLocation1"

## Spoke 1 VNet
#az deployment group create --subscription "$subscriptionId" -n "VNet-Spoke1-""$location1" --verbose \
#	-g "$resourceGroup" --template-file "$templateVNet" \
#	--parameters \
#	location="$location1" \
#	vnetName="$vnetNameSpoke1Location1" \
#	vnetPrefix="$vnetPrefixSpoke1Location1"


# Spoke 1 Shared Subnet
az deployment group create --subscription "$subscriptionId" -n "Subnet-Shared-""$location1" --verbose \
	-g "$resourceGroup" --template-file "$templateSubnet" \
	--parameters \
	vnetName="$vnetNameSpoke1Location1" \
	subnetName="$subnetNameShared" \
	subnetPrefix="$subnetPrefixShared" \
	nsgResourceGroup="$resourceGroup" \
	nsgName="$nsgNameLocation1" \
	serviceEndpoints="Microsoft.AzureCosmosDB, Microsoft.CognitiveServices, Microsoft.ContainerRegistry, Microsoft.EventHub, Microsoft.KeyVault, Microsoft.ServiceBus, Microsoft.Sql, Microsoft.Storage, Microsoft.Web" \
	delegationService="Microsoft.Web/serverFarms"

# 
# $nsgNameLocation1
# Spoke 1 Workload Subnet


# Spoke 1 Workload VNet Integration Subnet
