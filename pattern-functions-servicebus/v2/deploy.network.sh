#!/bin/bash

# ==================================================
# Variables
. ./deploy.variables.sh
# ==================================================
echo "Deploy NSGs"

az deployment group create --subscription "$subscriptionId" -n "NSG-""$location1" --verbose \
	-g "$rgNameNetworkLocation1" --template-file "$templateNsg" \
	--parameters \
	applicationId="$applicationId" \
	productId="$productId" \
	productLine="$productLine" \
	employeeId="$employeeId" \
	businessUnit="$businessUnit" \
	environment="$environment" \
	organization="$organization" \
	timestamp="$timestamp" \
	location="$location1" \
	nsgName="$nsgNameLocation1" \
	nsgRuleInbound100Src="$nsgRuleInbound100Src"

az deployment group create --subscription "$subscriptionId" -n "NSG-""$location2" --verbose \
	-g "$rgNameNetworkLocation2" --template-file "$templateNsg" \
	--parameters \
	applicationId="$applicationId" \
	productId="$productId" \
	productLine="$productLine" \
	employeeId="$employeeId" \
	businessUnit="$businessUnit" \
	environment="$environment" \
	organization="$organization" \
	timestamp="$timestamp" \
	location="$location2" \
	nsgName="$nsgNameLocation2" \
	nsgRuleInbound100Src="$nsgRuleInbound100Src"

echo -e "\n"

echo "Deploy VNets"

az deployment group create --subscription "$subscriptionId" -n "VNet-""$location1" --verbose \
	-g "$rgNameNetworkLocation1" --template-file "$templateNetwork" \
	--parameters \
	applicationId="$applicationId" \
	productId="$productId" \
	productLine="$productLine" \
	employeeId="$employeeId" \
	businessUnit="$businessUnit" \
	environment="$environment" \
	organization="$organization" \
	timestamp="$timestamp" \
	location="$location1" \
	vnetName="$vnetNameLocation1" \
	vnetPrefix="$vnetPrefixLocation1" \
	subnetPrefixFirewall="$subnetPrefixFirewallLocation1" \
	subnetNameShared="$subnetNameShared" \
	subnetPrefixShared="$subnetPrefixSharedLocation1" \
	subnetNameWorkload="$subnetNameWorkload" \
	subnetPrefixWorkload="$subnetPrefixWorkloadLocation1" \
	subnetDelegationServiceNameWorkload="$subnetDelegationServiceNameWorkload" \
	subnetNameWorkloadVNetIntegration="$subnetNameWorkloadVnetIntegration" \
	subnetPrefixWorkloadVNetIntegration="$subnetPrefixWorkloadVnetIntegrationLocation1" \
	nsgNameShared="$nsgNameLocation1" \
	nsgNameWorkload="$nsgNameLocation1" \
	nsgNameWorkloadVNetIntegration="$nsgNameLocation1"

az deployment group create --subscription "$subscriptionId" -n "VNet-""$location2" --verbose \
	-g "$rgNameNetworkLocation2" --template-file "$templateNetwork" \
	--parameters \
	applicationId="$applicationId" \
	productId="$productId" \
	productLine="$productLine" \
	employeeId="$employeeId" \
	businessUnit="$businessUnit" \
	environment="$environment" \
	organization="$organization" \
	timestamp="$timestamp" \
	location="$location2" \
	vnetName="$vnetNameLocation2" \
	vnetPrefix="$vnetPrefixLocation2" \
	subnetPrefixFirewall="$subnetPrefixFirewallLocation2" \
	subnetNameShared="$subnetNameShared" \
	subnetPrefixShared="$subnetPrefixSharedLocation2" \
	subnetNameWorkload="$subnetNameWorkload" \
	subnetPrefixWorkload="$subnetPrefixWorkloadLocation2" \
	subnetDelegationServiceNameWorkload="$subnetDelegationServiceNameWorkload" \
	subnetNameWorkloadVNetIntegration="$subnetNameWorkloadVnetIntegration" \
	subnetPrefixWorkloadVNetIntegration="$subnetPrefixWorkloadVnetIntegrationLocation2" \
	nsgNameShared="$nsgNameLocation2" \
	nsgNameWorkload="$nsgNameLocation2" \
	nsgNameWorkloadVNetIntegration="$nsgNameLocation2"

echo -e "\n"

echo "Deploy VNet Peerings"

az deployment group create --subscription "$subscriptionId" -n "VNet-Peering-""$location1" --verbose \
	-g "$rgNameNetworkLocation1" --template-file "$templateVnetPeering" \
	--parameters \
	vnetPeeringName="$location1""-""$location2" \
	resourceGroupNameRemote="$rgNameNetworkLocation2" \
	vnetNameLocal="$vnetNameLocation1" \
	vnetNameRemote="$vnetNameLocation2" \
	vnetAddressSpaceRemote="$vnetPrefixLocation2"

az deployment group create --subscription "$subscriptionId" -n "VNet-Peering-""$location2" --verbose \
	-g "$rgNameNetworkLocation2" --template-file "$templateVnetPeering" \
	--parameters \
	vnetPeeringName="$location2""-""$location1" \
	resourceGroupNameRemote="$rgNameNetworkLocation1" \
	vnetNameLocal="$vnetNameLocation2" \
	vnetNameRemote="$vnetNameLocation1" \
	vnetAddressSpaceRemote="$vnetPrefixLocation1"

echo -e "\n"

if $deployFirewall
then
	echo "Deploy Azure Firewall Public IPs"

	az deployment group create --subscription "$subscriptionId" -n "FW-PIP-""$location1" --verbose \
		-g "$rgNameNetworkLocation1" --template-file "$templatePublicIp" \
		--parameters \
		applicationId="$applicationId" \
		productId="$productId" \
		productLine="$productLine" \
		employeeId="$employeeId" \
		businessUnit="$businessUnit" \
		environment="$environment" \
		organization="$organization" \
		timestamp="$timestamp" \
		location="$location1" \
		publicIpName="$firewallPublicIpLocation1" \
		publicIpType="$publicIpType" \
		publicIpSku="$publicIpSku" \
		domainNameLabel="$firewallNameLocation1"

	az deployment group create --subscription "$subscriptionId" -n "FW-PIP-""$location2" --verbose \
		-g "$rgNameNetworkLocation2" --template-file "$templatePublicIp" \
		--parameters \
		applicationId="$applicationId" \
		productId="$productId" \
		productLine="$productLine" \
		employeeId="$employeeId" \
		businessUnit="$businessUnit" \
		environment="$environment" \
		organization="$organization" \
		timestamp="$timestamp" \
		location="$location2" \
		publicIpName="$firewallPublicIpLocation2" \
		publicIpType="$publicIpType" \
		publicIpSku="$publicIpSku" \
		domainNameLabel="$firewallNameLocation2"

	echo "Deploy Azure Firewalls"

	az deployment group create --subscription "$subscriptionId" -n "FW-""$location1" --verbose \
		-g "$rgNameNetworkLocation1" --template-file "$templateFirewall" \
		--parameters \
		applicationId="$applicationId" \
		productId="$productId" \
		productLine="$productLine" \
		employeeId="$employeeId" \
		businessUnit="$businessUnit" \
		environment="$environment" \
		organization="$organization" \
		timestamp="$timestamp" \
		location="$location1" \
		vnetResourceGroup="$rgNameNetworkLocation1" \
		vnetName="$vnetNameLocation1" \
		firewallName="$firewallNameLocation1" \
		firewallSku="$firewallSku" \
		firewallTier="$firewallTier" \
		firewallThreatIntelMode="$firewallThreatIntelMode" \
		publicIpResourceGroup="$rgNameNetworkLocation1" \
		publicIpName="$firewallPublicIpLocation1"

	az deployment group create --subscription "$subscriptionId" -n "FW-""$location2" --verbose \
		-g "$rgNameNetworkLocation2" --template-file "$templateFirewall" \
		--parameters \
		applicationId="$applicationId" \
		productId="$productId" \
		productLine="$productLine" \
		employeeId="$employeeId" \
		businessUnit="$businessUnit" \
		environment="$environment" \
		organization="$organization" \
		timestamp="$timestamp" \
		location="$location2" \
		vnetResourceGroup="$rgNameNetworkLocation2" \
		vnetName="$vnetNameLocation2" \
		firewallName="$firewallNameLocation2" \
		firewallSku="$firewallSku" \
		firewallTier="$firewallTier" \
		firewallThreatIntelMode="$firewallThreatIntelMode" \
		publicIpResourceGroup="$rgNameNetworkLocation2" \
		publicIpName="$firewallPublicIpLocation2"
fi

echo -e "\n"

if $asbPrivateEndpoint
then
	echo "Deploy ASB Private DNS Zones and link to VNets"

	# Create ASB Private DNS Zone
	az deployment group create --subscription "$subscriptionId" -n "ASB-DNS" --verbose \
		-g "$rgNameNetworkGlobal" --template-file "$templatePrivateDnsZone" \
		--parameters \
		employeeId="$employeeId" \
		businessUnit="$businessUnit" \
		environment="$environment" \
		organization="$organization" \
		timestamp="$timestamp" \
		privateDnsZoneName="$asbPrivateDnsZoneName"

	# Create Location 1 VNet Link to ASB Private DNS Zone
	az deployment group create --subscription "$subscriptionId" -n "ASB-DNS-VNet-""$location1" --verbose \
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
		privateDnsZoneName="$asbPrivateDnsZoneName" \
		vnetResourceGroup="$rgNameNetworkLocation1" \
		vnetName="$vnetNameLocation1"

	# Create Location 2 VNet Link to ASB Private DNS Zone
	az deployment group create --subscription "$subscriptionId" -n "ASB-DNS-VNet-""$location2" --verbose \
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
		privateDnsZoneName="$asbPrivateDnsZoneName" \
		vnetResourceGroup="$rgNameNetworkLocation2" \
		vnetName="$vnetNameLocation2"
fi

if $storageAccountPrivateEndpoint
then
	echo "Deploy Storage Private DNS Zones and link to VNets"

	# Create Storage Blob Private DNS Zone
	az deployment group create --subscription "$subscriptionId" -n "STB-DNS" --verbose \
		-g "$rgNameNetworkGlobal" --template-file "$templatePrivateDnsZone" \
		--parameters \
		employeeId="$employeeId" \
		businessUnit="$businessUnit" \
		environment="$environment" \
		organization="$organization" \
		timestamp="$timestamp" \
		privateDnsZoneName="$storageBlobPrivateDnsZoneName"

	# Create Storage File Private DNS Zone
	az deployment group create --subscription "$subscriptionId" -n "STF-DNS" --verbose \
		-g "$rgNameNetworkGlobal" --template-file "$templatePrivateDnsZone" \
		--parameters \
		employeeId="$employeeId" \
		businessUnit="$businessUnit" \
		environment="$environment" \
		organization="$organization" \
		timestamp="$timestamp" \
		privateDnsZoneName="$storageFilePrivateDnsZoneName"

	# Create Location 1 VNet Link to Storage Blob Private DNS Zone
	az deployment group create --subscription "$subscriptionId" -n "STB-DNS-VNet-""$location1" --verbose \
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
		privateDnsZoneName="$storageBlobPrivateDnsZoneName" \
		vnetResourceGroup="$rgNameNetworkLocation1" \
		vnetName="$vnetNameLocation1"

	# Create Location 2 VNet Link to Storage Blob Private DNS Zone
	az deployment group create --subscription "$subscriptionId" -n "STB-DNS-VNet-""$location2" --verbose \
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
		privateDnsZoneName="$storageBlobPrivateDnsZoneName" \
		vnetResourceGroup="$rgNameNetworkLocation2" \
		vnetName="$vnetNameLocation2"

	# Create Location 1 VNet Link to Storage File Private DNS Zone
	az deployment group create --subscription "$subscriptionId" -n "STF-DNS-VNet-""$location1" --verbose \
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
		privateDnsZoneName="$storageFilePrivateDnsZoneName" \
		vnetResourceGroup="$rgNameNetworkLocation1" \
		vnetName="$vnetNameLocation1"

	# Create Location 2 VNet Link to Storage File Private DNS Zone
	az deployment group create --subscription "$subscriptionId" -n "STF-DNS-VNet-""$location2" --verbose \
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
		privateDnsZoneName="$storageFilePrivateDnsZoneName" \
		vnetResourceGroup="$rgNameNetworkLocation2" \
		vnetName="$vnetNameLocation2"
fi

if $workloadPrivateEndpoint
then
	echo "Deploy Workload Private DNS Zones and link to VNets"

	# Create Workload Private DNS Zone
	az deployment group create --subscription "$subscriptionId" -n "WL-DNS" --verbose \
		-g "$rgNameNetworkGlobal" --template-file "$templatePrivateDnsZone" \
		--parameters \
		employeeId="$employeeId" \
		businessUnit="$businessUnit" \
		environment="$environment" \
		organization="$organization" \
		timestamp="$timestamp" \
		privateDnsZoneName="$workloadPrivateDnsZoneName"

	# Create Location 1 VNet Link to Workload Private DNS Zone
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
		vnetResourceGroup="$rgNameNetworkLocation1" \
		vnetName="$vnetNameLocation1"

	# Create Location 2 VNet Link to Workload Private DNS Zone
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
		vnetResourceGroup="$rgNameNetworkLocation2" \
		vnetName="$vnetNameLocation2"
fi

echo -e "\n"