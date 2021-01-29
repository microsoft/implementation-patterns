#!/bin/bash

# ==================================================
# Variables
. ./deploy.variables.sh
# ==================================================

if $workloadPrivateEndpoint
then
	echo "Deploy Workload Private DNS Zones and link to VNets"

	echo "Create Workload Private DNS Zone"
	az deployment group create --subscription "$subscriptionId" -n "WL-DNS" --verbose \
		-g "$rgNameNetworkGlobal" --template-file "$templatePrivateDnsZone" \
		--parameters \
		employeeId="$employeeId" \
		businessUnit="$businessUnit" \
		environment="$environment" \
		organization="$organization" \
		timestamp="$timestamp" \
		privateDnsZoneName="$workloadPrivateDnsZoneName"

	echo "Create Location 1 Spoke VNet Link to Workload Private DNS Zone"
	az deployment group create --subscription "$subscriptionId" -n "WL-DNS-VNet-""$location1" --verbose \
		-g "$rgNameNetworkGlobal" --template-file "$templatePrivateDnsZoneVnetLink" \
		--parameters \
		applicationId="$applicationId" \
		productId="$productId" \
		productLine="$productLine" \
		employeeId="$employeeId" \
		businessUnit="$businessUnit" \
		environment="$environment" \
		organization="$organization" \
		timestamp="$timestamp" \
		privateDnsZoneName="$workloadPrivateDnsZoneName" \
		vnetResourceGroup="$rgNameNetworkSpoke1Location1" \
		vnetName="$vnetNameSpoke1Location1"

	echo "Create Location 2 Spoke VNet Link to Workload Private DNS Zone"
	az deployment group create --subscription "$subscriptionId" -n "WL-DNS-VNet-""$location2" --verbose \
		-g "$rgNameNetworkGlobal" --template-file "$templatePrivateDnsZoneVnetLink" \
		--parameters \
		applicationId="$applicationId" \
		productId="$productId" \
		productLine="$productLine" \
		employeeId="$employeeId" \
		businessUnit="$businessUnit" \
		environment="$environment" \
		organization="$organization" \
		timestamp="$timestamp" \
		privateDnsZoneName="$workloadPrivateDnsZoneName" \
		vnetResourceGroup="$rgNameNetworkSpoke1Location2" \
		vnetName="$vnetNameSpoke1Location2"
fi
