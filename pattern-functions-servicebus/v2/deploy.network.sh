#!/bin/bash

# ==================================================
# Variables
. ./deploy.variables.sh
# ==================================================
echo "Deploy NSGs"

az deployment group create --subscription "$subscriptionId" -n "NSG-""$location1" --verbose \
	-g "$rgNameNetworkSpoke1Location1" --template-file "$templateNsg" \
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
	-g "$rgNameNetworkSpoke1Location2" --template-file "$templateNsg" \
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

echo "Region 1 Hub VNet"
az deployment group create --subscription "$subscriptionId" -n "VNet-Hub-""$location1" --verbose \
	-g "$rgNameNetworkHubLocation1" --template-file "$templateVnet" \
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
	vnetName="$vnetNameHubLocation1" \
	vnetPrefix="$vnetPrefixHubLocation1" \
	enableDdosProtection="false" \
	enableVmProtection="false"

if $deployFirewall
then
	echo "Region 1 Hub VNet Firewall Subnet"
	az deployment group create --subscription "$subscriptionId" -n "Subnet-Hub-Firewall-""$location1" --verbose \
		-g "$rgNameNetworkHubLocation1" --template-file "$templateSubnet" \
		--parameters \
		vnetName="$vnetNameHubLocation1" \
		subnetName="$subnetNameFirewall" \
		subnetPrefix="$subnetPrefixFirewallLocation1"
fi

echo "Region 2 Hub VNet"
az deployment group create --subscription "$subscriptionId" -n "VNet-Hub-""$location2" --verbose \
	-g "$rgNameNetworkHubLocation2" --template-file "$templateVnet" \
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
	vnetName="$vnetNameHubLocation2" \
	vnetPrefix="$vnetPrefixHubLocation2" \
	enableDdosProtection="false" \
	enableVmProtection="false"

if $deployFirewall
then
	echo "Region 2 Hub VNet Firewall Subnet"
	az deployment group create --subscription "$subscriptionId" -n "Subnet-Hub-Firewall-""$location2" --verbose \
		-g "$rgNameNetworkHubLocation2" --template-file "$templateSubnet" \
		--parameters \
		vnetName="$vnetNameHubLocation2" \
		subnetName="$subnetNameFirewall" \
		subnetPrefix="$subnetPrefixFirewallLocation2"
fi


echo "Region 1 Spoke 1 VNet"
az deployment group create --subscription "$subscriptionId" -n "VNet-Spoke1-""$location1" --verbose \
	-g "$rgNameNetworkSpoke1Location1" --template-file "$templateVnet" \
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
	vnetName="$vnetNameSpoke1Location1" \
	vnetPrefix="$vnetPrefixSpoke1Location1" \
	enableDdosProtection="false" \
	enableVmProtection="false"

echo "Region 1 Spoke 1 VNet Shared Subnet"
az deployment group create --subscription "$subscriptionId" -n "VNet-Spoke1-Subnet-Shared-""$location1" --verbose \
	-g "$rgNameNetworkSpoke1Location1" --template-file "$templateSubnet" \
	--parameters \
	vnetName="$vnetNameSpoke1Location1" \
	subnetName="$subnetNameShared" \
	subnetPrefix="$subnetPrefixSharedLocation1" \
	nsgResourceGroup="$rgNameNetworkSpoke1Location1" \
	nsgName="$nsgNameLocation1" \
	serviceEndpoints="$subnetServiceEndpointsShared" \
	privateEndpointNetworkPolicies="Disabled" \
	privateLinkServiceNetworkPolicies="Disabled"

echo "Region 1 Spoke 1 VNet Workload Subnet"
az deployment group create --subscription "$subscriptionId" -n "VNet-Spoke1-Subnet-Workload-""$location1" --verbose \
	-g "$rgNameNetworkSpoke1Location1" --template-file "$templateSubnet" \
	--parameters \
	vnetName="$vnetNameSpoke1Location1" \
	subnetName="$subnetNameWorkload" \
	subnetPrefix="$subnetPrefixWorkloadLocation1" \
	nsgResourceGroup="$rgNameNetworkSpoke1Location1" \
	nsgName="$nsgNameLocation1" \
	serviceEndpoints="$subnetServiceEndpointsWorkload" \
	privateEndpointNetworkPolicies="Disabled" \
	privateLinkServiceNetworkPolicies="Disabled"

echo "Region 1 Spoke 1 VNet Workload VNet Integration Subnet"
az deployment group create --subscription "$subscriptionId" -n "VNet-Spoke1-Subnet-Workload-Integration""$location1" --verbose \
	-g "$rgNameNetworkSpoke1Location1" --template-file "$templateSubnet" \
	--parameters \
	vnetName="$vnetNameSpoke1Location1" \
	subnetName="$subnetNameWorkloadVnetIntegration" \
	subnetPrefix="$subnetPrefixWorkloadVnetIntegrationLocation1" \
	nsgResourceGroup="$rgNameNetworkSpoke1Location1" \
	nsgName="$nsgNameLocation1" \
	serviceEndpoints="$subnetServiceEndpointsWorkload" \
	delegationService="$subnetDelegationServiceWorkload" \
	privateEndpointNetworkPolicies="Disabled" \
	privateLinkServiceNetworkPolicies="Disabled"

echo "Region 1 Spoke 1 VNet Test Subnet"
az deployment group create --subscription "$subscriptionId" -n "VNet-Spoke1-Subnet-Test-""$location1" --verbose \
	-g "$rgNameNetworkSpoke1Location1" --template-file "$templateSubnet" \
	--parameters \
	vnetName="$vnetNameSpoke1Location1" \
	subnetName="$subnetNameTest" \
	subnetPrefix="$subnetPrefixTestLocation1" \
	nsgResourceGroup="$rgNameNetworkSpoke1Location1" \
	nsgName="$nsgNameLocation1" \
	serviceEndpoints="$subnetServiceEndpointsTest" \
	privateEndpointNetworkPolicies="Disabled" \
	privateLinkServiceNetworkPolicies="Disabled"


echo "Region 2 Spoke 1 VNet"
az deployment group create --subscription "$subscriptionId" -n "VNet-Spoke1-""$location2" --verbose \
	-g "$rgNameNetworkSpoke1Location2" --template-file "$templateVnet" \
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
	vnetName="$vnetNameSpoke1Location2" \
	vnetPrefix="$vnetPrefixSpoke1Location2" \
	enableDdosProtection="false" \
	enableVmProtection="false"

echo "Region 2 Spoke 1 VNet Shared Subnet"
az deployment group create --subscription "$subscriptionId" -n "VNet-Spoke1-Subnet-Shared-""$location2" --verbose \
	-g "$rgNameNetworkSpoke1Location2" --template-file "$templateSubnet" \
	--parameters \
	vnetName="$vnetNameSpoke1Location2" \
	subnetName="$subnetNameShared" \
	subnetPrefix="$subnetPrefixSharedLocation2" \
	nsgResourceGroup="$rgNameNetworkSpoke1Location2" \
	nsgName="$nsgNameLocation2" \
	serviceEndpoints="$subnetServiceEndpointsShared" \
	privateEndpointNetworkPolicies="Disabled" \
	privateLinkServiceNetworkPolicies="Disabled"

echo "Region 2 Spoke 1 VNet Workload Subnet"
az deployment group create --subscription "$subscriptionId" -n "VNet-Spoke1-Subnet-Workload-""$location2" --verbose \
	-g "$rgNameNetworkSpoke1Location2" --template-file "$templateSubnet" \
	--parameters \
	vnetName="$vnetNameSpoke1Location2" \
	subnetName="$subnetNameWorkload" \
	subnetPrefix="$subnetPrefixWorkloadLocation2" \
	nsgResourceGroup="$rgNameNetworkSpoke1Location2" \
	nsgName="$nsgNameLocation2" \
	serviceEndpoints="$subnetServiceEndpointsWorkload" \
	privateEndpointNetworkPolicies="Disabled" \
	privateLinkServiceNetworkPolicies="Disabled"

echo "Region 2 Spoke 1 VNet Workload VNet Integration Subnet"
az deployment group create --subscription "$subscriptionId" -n "VNet-Spoke1-Subnet-Workload-""$location2" --verbose \
	-g "$rgNameNetworkSpoke1Location2" --template-file "$templateSubnet" \
	--parameters \
	vnetName="$vnetNameSpoke1Location2" \
	subnetName="$subnetNameWorkloadVnetIntegration" \
	subnetPrefix="$subnetPrefixWorkloadVnetIntegrationLocation2" \
	nsgResourceGroup="$rgNameNetworkSpoke1Location2" \
	nsgName="$nsgNameLocation2" \
	serviceEndpoints="$subnetServiceEndpointsWorkload" \
	delegationService="$subnetDelegationServiceWorkload" \
	privateEndpointNetworkPolicies="Disabled" \
	privateLinkServiceNetworkPolicies="Disabled"

echo "Region 2 Spoke 1 VNet Test Subnet"
az deployment group create --subscription "$subscriptionId" -n "VNet-Spoke1-Subnet-Test-""$location2" --verbose \
	-g "$rgNameNetworkSpoke1Location2" --template-file "$templateSubnet" \
	--parameters \
	vnetName="$vnetNameSpoke1Location2" \
	subnetName="$subnetNameTest" \
	subnetPrefix="$subnetPrefixTestLocation2" \
	nsgResourceGroup="$rgNameNetworkSpoke1Location2" \
	nsgName="$nsgNameLocation2" \
	serviceEndpoints="$subnetServiceEndpointsTest" \
	privateEndpointNetworkPolicies="Disabled" \
	privateLinkServiceNetworkPolicies="Disabled"

echo -e "\n"

echo "Deploy VNet Peerings"

echo "Region 1 Hub / Spoke 1 VNet Peering"
az deployment group create --subscription "$subscriptionId" -n "VNet-Peering-Hub-Spoke-1-""$location1" --verbose \
	-g "$rgNameNetworkHubLocation1" --template-file "$templateVnetPeering" \
	--parameters \
	vnetPeeringName="$vnetNameHubLocation1""-""$vnetNameSpoke1Location1" \
	resourceGroupNameRemote="$rgNameNetworkSpoke1Location1" \
	vnetNameLocal="$vnetNameHubLocation1" \
	vnetNameRemote="$vnetNameSpoke1Location1" \
	vnetAddressSpaceRemote="$vnetPrefixSpoke1Location1"

echo "Region 1 Spoke 1 / Hub VNet Peering"
az deployment group create --subscription "$subscriptionId" -n "VNet-Peering-Spoke-1-Hub-""$location1" --verbose \
	-g "$rgNameNetworkSpoke1Location1" --template-file "$templateVnetPeering" \
	--parameters \
	vnetPeeringName="$vnetNameSpoke1Location1""-""$vnetNameHubLocation1" \
	resourceGroupNameRemote="$rgNameNetworkHubLocation1" \
	vnetNameLocal="$vnetNameSpoke1Location1" \
	vnetNameRemote="$vnetNameHubLocation1" \
	vnetAddressSpaceRemote="$vnetPrefixHubLocation1"

echo "Region 2 Hub / Spoke 1 VNet Peering"
az deployment group create --subscription "$subscriptionId" -n "VNet-Peering-Hub-Spoke-1-""$location2" --verbose \
	-g "$rgNameNetworkHubLocation2" --template-file "$templateVnetPeering" \
	--parameters \
	vnetPeeringName="$vnetNameHubLocation2""-""$vnetNameSpoke1Location2" \
	resourceGroupNameRemote="$rgNameNetworkSpoke1Location2" \
	vnetNameLocal="$vnetNameHubLocation2" \
	vnetNameRemote="$vnetNameSpoke1Location2" \
	vnetAddressSpaceRemote="$vnetPrefixSpoke1Location2"

echo "Region 2 Spoke 1 / Hub VNet Peering"
az deployment group create --subscription "$subscriptionId" -n "VNet-Peering-Spoke-1-Hub-""$location2" --verbose \
	-g "$rgNameNetworkSpoke1Location2" --template-file "$templateVnetPeering" \
	--parameters \
	vnetPeeringName="$vnetNameSpoke1Location2""-""$vnetNameHubLocation2" \
	resourceGroupNameRemote="$rgNameNetworkHubLocation2" \
	vnetNameLocal="$vnetNameSpoke1Location2" \
	vnetNameRemote="$vnetNameHubLocation2" \
	vnetAddressSpaceRemote="$vnetPrefixHubLocation2"

echo "Region 1 Hub / Region 2 Hub VNet Peering"
az deployment group create --subscription "$subscriptionId" -n "VNet-Peering-Hub-""$location1""-""Hub-""$location2" --verbose \
	-g "$rgNameNetworkHubLocation1" --template-file "$templateVnetPeering" \
	--parameters \
	vnetPeeringName="$vnetNameHubLocation1""-""$vnetNameHubLocation2" \
	resourceGroupNameRemote="$rgNameNetworkHubLocation2" \
	vnetNameLocal="$vnetNameHubLocation1" \
	vnetNameRemote="$vnetNameHubLocation2" \
	vnetAddressSpaceRemote="$vnetPrefixHubLocation2"

echo "Region 2 Hub / Region 1 Hub VNet Peering"
az deployment group create --subscription "$subscriptionId" -n "VNet-Peering-Hub-""$location2""-""Hub-""$location1" --verbose \
	-g "$rgNameNetworkHubLocation2" --template-file "$templateVnetPeering" \
	--parameters \
	vnetPeeringName="$vnetNameHubLocation2""-""$vnetNameHubLocation1" \
	resourceGroupNameRemote="$rgNameNetworkHubLocation1" \
	vnetNameLocal="$vnetNameHubLocation2" \
	vnetNameRemote="$vnetNameHubLocation1" \
	vnetAddressSpaceRemote="$vnetPrefixHubLocation1"

echo -e "\n"

if $deployFirewall
then
	echo "Deploy Location 1 Azure Firewall Public IP"
	az deployment group create --subscription "$subscriptionId" -n "FW-PIP-""$location1" --verbose \
		-g "$rgNameNetworkHubLocation1" --template-file "$templatePublicIp" \
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
		publicIpType="$firewallPublicIpType" \
		publicIpSku="$firewallPublicIpSku" \
		domainNameLabel="$firewallNameLocation1"

	echo "Deploy Location 2 Azure Firewall Public IP"
	az deployment group create --subscription "$subscriptionId" -n "FW-PIP-""$location2" --verbose \
		-g "$rgNameNetworkHubLocation2" --template-file "$templatePublicIp" \
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
		publicIpType="$firewallPublicIpType" \
		publicIpSku="$firewallPublicIpSku" \
		domainNameLabel="$firewallNameLocation2"

	echo "Deploy Location 1 Azure Firewall"
	az deployment group create --subscription "$subscriptionId" -n "FW-""$location1" --verbose \
		-g "$rgNameNetworkHubLocation1" --template-file "$templateFirewall" \
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
		vnetResourceGroup="$rgNameNetworkHubLocation1" \
		vnetName="$vnetNameHubLocation1" \
		firewallName="$firewallNameLocation1" \
		firewallAvailabilityZones="$firewallAvailabilityZones" \
		firewallSku="$firewallSku" \
		firewallTier="$firewallTier" \
		firewallThreatIntelMode="$firewallThreatIntelMode" \
		publicIpResourceGroup="$rgNameNetworkHubLocation1" \
		publicIpAddressNames="$firewallPublicIpLocation1"

	echo "Deploy Location 2 Azure Firewall"
	az deployment group create --subscription "$subscriptionId" -n "FW-""$location2" --verbose \
		-g "$rgNameNetworkHubLocation2" --template-file "$templateFirewall" \
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
		vnetResourceGroup="$rgNameNetworkHubLocation2" \
		vnetName="$vnetNameHubLocation2" \
		firewallName="$firewallNameLocation2" \
		firewallAvailabilityZones="$firewallAvailabilityZones" \
		firewallSku="$firewallSku" \
		firewallTier="$firewallTier" \
		firewallThreatIntelMode="$firewallThreatIntelMode" \
		publicIpResourceGroup="$rgNameNetworkHubLocation2" \
		publicIpAddressNames="$firewallPublicIpLocation2"
fi

echo -e "\n"

if $asbPrivateEndpoint
then
	echo "Deploy ASB Private DNS Zones and link to VNets"

	echo "Create ASB Private DNS Zone"
	az deployment group create --subscription "$subscriptionId" -n "ASB-DNS" --verbose \
		-g "$rgNameNetworkGlobal" --template-file "$templatePrivateDnsZone" \
		--parameters \
		employeeId="$employeeId" \
		businessUnit="$businessUnit" \
		environment="$environment" \
		organization="$organization" \
		timestamp="$timestamp" \
		privateDnsZoneName="$asbPrivateDnsZoneName"

	echo "Create Location 1 Spoke VNet Link to ASB Private DNS Zone"
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
		vnetResourceGroup="$rgNameNetworkSpoke1Location1" \
		vnetName="$vnetNameSpoke1Location1"

	echo "Create Location 2 Spoke VNet Link to ASB Private DNS Zone"
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
		vnetResourceGroup="$rgNameNetworkSpoke1Location2" \
		vnetName="$vnetNameSpoke1Location2"
fi

if $storageAccountPrivateEndpoint
then
	echo "Deploy Storage Private DNS Zones and link to VNets"

	echo "Create Storage Blob Private DNS Zone"
	az deployment group create --subscription "$subscriptionId" -n "STB-DNS" --verbose \
		-g "$rgNameNetworkGlobal" --template-file "$templatePrivateDnsZone" \
		--parameters \
		employeeId="$employeeId" \
		businessUnit="$businessUnit" \
		environment="$environment" \
		organization="$organization" \
		timestamp="$timestamp" \
		privateDnsZoneName="$storageBlobPrivateDnsZoneName"

	echo "Create Storage File Private DNS Zone"
	az deployment group create --subscription "$subscriptionId" -n "STF-DNS" --verbose \
		-g "$rgNameNetworkGlobal" --template-file "$templatePrivateDnsZone" \
		--parameters \
		employeeId="$employeeId" \
		businessUnit="$businessUnit" \
		environment="$environment" \
		organization="$organization" \
		timestamp="$timestamp" \
		privateDnsZoneName="$storageFilePrivateDnsZoneName"

	echo "Create Location 1 Spoke VNet Link to Storage Blob Private DNS Zone"
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
		vnetResourceGroup="$rgNameNetworkSpoke1Location1" \
		vnetName="$vnetNameSpoke1Location1"

	echo "Create Location 2 Spoke VNet Link to Storage Blob Private DNS Zone"
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
		vnetResourceGroup="$rgNameNetworkSpoke1Location2" \
		vnetName="$vnetNameSpoke1Location2"

	echo "Create Location 1 Spoke VNet Link to Storage File Private DNS Zone"
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
		vnetResourceGroup="$rgNameNetworkSpoke1Location1" \
		vnetName="$vnetNameSpoke1Location1"

	echo "Create Location 2 Spoke VNet Link to Storage File Private DNS Zone"
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
		vnetResourceGroup="$rgNameNetworkSpoke1Location2" \
		vnetName="$vnetNameSpoke1Location2"
fi

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

echo -e "\n"