#!/bin/bash

. ./deploy.variables.sh

templateWorkloadVnetConnection="./template/function.vnet-connection.json"

echo "Region 1 VNet Connection for Workload"
az deployment group create --subscription "$subscriptionId" -n "WL-VNC-""$location1" --verbose \
	-g "$rgNameWorkloadLocation1" --template-file "$templateWorkloadVnetConnection" \
	--parameters \
	location="$location1" \
	functionName="$workloadAppNameLocation1" \
	virtualNetworkResourceGroup="$rgNameNetworkSpoke1Location1" \
	virtualNetworkName="$vnetNameSpoke1Location1" \
	subnetNameForVNetIntegration="$subnetNameWorkloadVnetIntegration"

echo "Region 2 VNet Connection for Workload"
az deployment group create --subscription "$subscriptionId" -n "WL-VNC-""$location2" --verbose \
	-g "$rgNameWorkloadLocation2" --template-file "$templateWorkloadVnetConnection" \
	--parameters \
	location="$location2" \
	functionName="$workloadAppNameLocation2" \
	virtualNetworkResourceGroup="$rgNameNetworkSpoke1Location2" \
	virtualNetworkName="$vnetNameSpoke1Location2" \
	subnetNameForVNetIntegration="$subnetNameWorkloadVnetIntegration"
