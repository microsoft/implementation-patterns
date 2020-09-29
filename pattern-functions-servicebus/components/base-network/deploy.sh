#!/bin/bash

# Params
infix=""

subscription_id=""

location1="eastus2"
location2="centralus"

resourceGroup1NameNet="$infix-net-$location1"
resourceGroup2NameNet="$infix-net-$location2"

templateFileVnet="azuredeploy-vnet.json"


# Create first set of network resources
hubVnetName="hub-vnet"
hubVnetPrefix="10.0.0.0/16"
hubVnetFirewallSubnetName="AzureFirewallSubnet"
hubVnetFirewallSubnetPrefix="10.0.1.0/24"
hubVnetDnsSubnetName="DNSSubnet"
hubVnetDnsSubnetPrefix="10.0.2.0/24"
spokeVnetName="spoke-vnet"
spokeVnetPrefix="10.1.0.0/16"
spokeVnetWorkloadSubnetName="workload-subnet"
spokeVnetWorkloadSubnetPrefix="10.1.2.0/24"
spokeVnetWorkloadNSGName="workload-nsg"

az group create --subscription "$subscription_id" --name "$resourceGroup1NameNet" --location "$location1"

az deployment group create --subscription "$subscription_id" --resource-group "$resourceGroup1NameNet" \
	--name "base-network-""$location1" --template-file "$templateFileVnet" --verbose --parameters \
	hubVnetName="$hubVnetName" hubVnetPrefix="$hubVnetPrefix" \
	firewallSubnetName="$hubVnetFirewallSubnetName" firewallSubnetPrefix="$hubVnetFirewallSubnetPrefix" \
	dnsSubnetName="$hubVnetDnsSubnetName" dnsSubnetPrefix="$hubVnetDnsSubnetPrefix" \
	spokeVnetName="$spokeVnetName" spokeVnetPrefix="$spokeVnetPrefix" \
	workloadSubnetName="$spokeVnetWorkloadSubnetName" workloadSubnetPrefix="$spokeVnetWorkloadSubnetPrefix" \
	workloadNsgName="$spokeVnetWorkloadNSGName"



# Create second set of network resources
hubVnetName="hub-vnet"
hubVnetPrefix="10.2.0.0/16"
hubVnetFirewallSubnetName="AzureFirewallSubnet"
hubVnetFirewallSubnetPrefix="10.2.1.0/24"
hubVnetDnsSubnetName="DNSSubnet"
hubVnetDnsSubnetPrefix="10.2.2.0/24"
spokeVnetName="spoke-vnet"
spokeVnetPrefix="10.3.0.0/16"
spokeVnetWorkloadSubnetName="workload-subnet"
spokeVnetWorkloadSubnetPrefix="10.3.2.0/24"
spokeVnetWorkloadNSGName="workload-nsg"

az group create --subscription "$subscription_id" --name "$resourceGroup2NameNet" --location "$location2"

az deployment group create --subscription "$subscription_id" --resource-group "$resourceGroup2NameNet" \
	--name "base-network-""$location2" --template-file "$templateFileVnet" --verbose --parameters \
	hubVnetName="$hubVnetName" hubVnetPrefix="$hubVnetPrefix" \
	firewallSubnetName="$hubVnetFirewallSubnetName" firewallSubnetPrefix="$hubVnetFirewallSubnetPrefix" \
	dnsSubnetName="$hubVnetDnsSubnetName" dnsSubnetPrefix="$hubVnetDnsSubnetPrefix" \
	spokeVnetName="$spokeVnetName" spokeVnetPrefix="$spokeVnetPrefix" \
	workloadSubnetName="$spokeVnetWorkloadSubnetName" workloadSubnetPrefix="$spokeVnetWorkloadSubnetPrefix" \
	workloadNsgName="$spokeVnetWorkloadNSGName"
