#!/bin/bash

# Params
infix="ipfsb"

subscription_id=""

resourceGroup1Location="eastus2"
resourceGroup2Location="centralus"

resourceGroup1NameNet="$infix-net-$resourceGroup1Location"
resourceGroup2NameNet="$infix-net-$resourceGroup2Location"

resourceGroup1NameSB="$infix-sb-$resourceGroup1Location"
resourceGroup2NameSB="$infix-sb-$resourceGroup2Location"

namespace1Name="$infix""namespace1"
namespace2Name="$infix""namespace2"

aliasName="$infix""namespacealias"

privateDnsZoneName="privatelink.servicebus.windows.net"

privateEndpointNameR1NS1="pepr1ns1"
privateEndpointNameR1NS2="pepr1ns2"
privateEndpointNameR2NS1="pepr2ns1"
privateEndpointNameR2NS2="pepr2ns2"

spokeVnetName="spoke-vnet"
workloadSubnetName="workload-subnet"

templateFileNamespace="azuredeploy-namespace.json"
templateFileQueuesTopics="azuredeploy-queuestopics.json"
templateFileGeoReplication="azuredeploy-georeplication.json"
templateFilePrivateZone="azuredeploy-privatezone.json"
templateFilePrivateLink="azuredeploy-privatelink.json"
templateFileZoneLink="azuredeploy-zonelink.json"

# Create RGs
az group create --subscription "$subscription_id" --name "$resourceGroup1NameSB" --location "$resourceGroup1Location"
az group create --subscription "$subscription_id" --name "$resourceGroup2NameSB" --location "$resourceGroup2Location"

# Deploy Primary Namespace
az deployment group create --subscription "$subscription_id" --name "ns1" --verbose \
	--resource-group "$resourceGroup1NameSB" --template-file "$templateFileNamespace" --parameters namespaceName="$namespace1Name"

# Create Topics and Queues
az deployment group create --subscription "$subscription_id" --name "ns1qt" --verbose \
	--resource-group "$resourceGroup1NameSB" --template-file "$templateFileQueuesTopics" --parameters namespaceName="$namespace1Name"

# Deploy Secondary Namespace
# No entities on this namespace as they will come over with replication
az deployment group create --subscription "$subscription_id" --name "ns2" --verbose \
	--resource-group "$resourceGroup2NameSB" --template-file "$templateFileNamespace" --parameters namespaceName="$namespace2Name"

# Set up Geo-Replication
az deployment group create --subscription "$subscription_id" --name "georep" --verbose \
	--resource-group "$resourceGroup1NameSB" --template-file "$templateFileGeoReplication" --parameters \
	namespaceName="$namespace1Name" pairedNamespaceName="$namespace2Name" pairedNamespaceResourceGroup="$resourceGroup2NameSB" aliasName="$aliasName"

# Enable Private Endpoints, Private Zones
# Create region 1
az deployment group create --subscription "$subscription_id" --name "pz1" --verbose \
	--resource-group "$resourceGroup1NameSB" --template-file "$templateFilePrivateZone" \
	--parameters privateDnsZoneName="$privateDnsZoneName"

# Create region 2
az deployment group create --subscription "$subscription_id" --name "pz2" --verbose \
	--resource-group "$resourceGroup2NameSB" --template-file "$templateFilePrivateZone" \
	--parameters privateDnsZoneName="$privateDnsZoneName"

# Endpoint in region 2 pointing to Namespace 2
az deployment group create --subscription "$subscription_id" --name "epr2ns2" --verbose \
	--resource-group "$resourceGroup2NameSB" --template-file "$templateFilePrivateLink" --parameters \
	namespaceName="$namespace2Name" \
	privateEndpointName="$privateEndpointNameR2NS2" \
	privateDnsZoneName="$privateDnsZoneName" \
	vnetName="$spokeVnetName" \
	subnetName="$workloadSubnetName" \
	networkResourceGroup="$resourceGroup2NameNet" \
	namespaceResourceGroup="$resourceGroup2NameSB" \
	primary=false

# Endpoint in region 2 pointing to Namespace 1
az deployment group create --subscription "$subscription_id" --name "epr2ns1" --verbose \
	--resource-group "$resourceGroup2NameSB" --template-file "$templateFilePrivateLink" --parameters \
	namespaceName="$namespace1Name" \
	privateEndpointName="$privateEndpointNameR2NS1" \
	privateDnsZoneName="$privateDnsZoneName" \
	vnetName="$spokeVnetName" \
	subnetName="$workloadSubnetName" \
	networkResourceGroup="$resourceGroup2NameNet" \
	namespaceResourceGroup="$resourceGroup1NameSB" \
	primary=false

# Endpoint in region 1 pointing to Namespace 1
az deployment group create --subscription "$subscription_id" --name "epr1ns1" --verbose \
	--resource-group "$resourceGroup1NameSB" --template-file "$templateFilePrivateLink" --parameters \
	namespaceName="$namespace1Name" \
	privateEndpointName="$privateEndpointNameR1NS1" \
	privateDnsZoneName="$privateDnsZoneName" \
	vnetName="$spokeVnetName" \
	subnetName="$workloadSubnetName" \
	networkResourceGroup="$resourceGroup1NameNet" \
	namespaceResourceGroup="$resourceGroup1NameSB" \
	primary=true

# Endpoint in region 1 pointing to Namespace 2
az deployment group create --subscription "$subscription_id" --name "epr1ns2" --verbose \
	--resource-group "$resourceGroup1NameSB" --template-file "$templateFilePrivateLink" --parameters \
	namespaceName="$namespace2Name" \
	privateEndpointName="$privateEndpointNameR1NS2" \
	privateDnsZoneName="$privateDnsZoneName" \
	vnetName="$spokeVnetName" \
	subnetName="$workloadSubnetName" \
	networkResourceGroup="$resourceGroup1NameNet"  \
	namespaceResourceGroup="$resourceGroup2NameSB" \
	primary=true

# Link Zones to VNets
az deployment group create --subscription "$subscription_id" --name "zv1" --verbose \
	--resource-group "$resourceGroup1NameSB" --template-file "$templateFileZoneLink" --parameters \
	privateDnsZoneName="$privateDnsZoneName" \
	vnetName="$spokeVnetName" \
	networkResourceGroup=$resourceGroup1NameNet

az deployment group create --subscription "$subscription_id" --name "zv2" --verbose \
	--resource-group "$resourceGroup2NameSB" --template-file "$templateFileZoneLink" --parameters \
	privateDnsZoneName="$privateDnsZoneName" \
	vnetName="$spokeVnetName" \
	networkResourceGroup="$resourceGroup2NameNet"
