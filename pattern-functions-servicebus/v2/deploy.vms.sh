#!/bin/bash

# ==================================================
# Variables
. ./deploy.variables.sh
# ==================================================
if $usePublicIps
then
	echo "Deploy Public IPs"

	az deployment group create --subscription "$subscriptionId" -n "PIP-""$location1" --verbose \
		-g "$rgNameVmLocation1" --template-file "$templatePublicIpWithAz" \
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
		availabilityZone="$availabilityZoneLocation1" \
		publicIpName="$virtualMachinePublicIpLocation1" \
		publicIpType="$publicIpType" \
		publicIpSku="$publicIpSku" \
		domainNameLabel="$virtualMachineNameLocation1"

	az deployment group create --subscription "$subscriptionId" -n "PIP-""$location2" --verbose \
		-g "$rgNameVmLocation2" --template-file "$templatePublicIpWithAz" \
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
		availabilityZone="$availabilityZoneLocation2" \
		publicIpName="$virtualMachinePublicIpLocation2" \
		publicIpType="$publicIpType" \
		publicIpSku="$publicIpSku" \
		domainNameLabel="$virtualMachineNameLocation2"

	echo -e "\n"
fi

echo "Deploy Network Interfaces"

if $usePublicIps
then
	az deployment group create --subscription "$subscriptionId" -n "NIC-""$location1" --verbose \
		-g "$rgNameVmLocation1" --template-file "$templateNetworkInterfaceWithPublicIp" \
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
		networkInterfaceName="$networkInterfaceNameLocation1" \
		vnetResourceGroup="$rgNameNetworkLocation1" \
		vnetName="$vnetNameLocation1" \
		subnetName="$subnetNameWorkload" \
		enableAcceleratedNetworking="$enableAcceleratedNetworking" \
		privateIpAllocationMethod="$privateIpAllocationMethod" \
		publicIpResourceGroup="$rgNameVmLocation1" \
		publicIpName="$virtualMachinePublicIpLocation1" \
		ipConfigName="$ipConfigName"

	az deployment group create --subscription "$subscriptionId" -n "NIC-""$location2" --verbose \
		-g "$rgNameVmLocation2" --template-file "$templateNetworkInterfaceWithPublicIp" \
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
		networkInterfaceName="$networkInterfaceNameLocation2" \
		vnetResourceGroup="$rgNameNetworkLocation2" \
		vnetName="$vnetNameLocation2" \
		subnetName="$subnetNameWorkload" \
		enableAcceleratedNetworking="$enableAcceleratedNetworking" \
		privateIpAllocationMethod="$privateIpAllocationMethod" \
		publicIpResourceGroup="$rgNameVmLocation2" \
		publicIpName="$virtualMachinePublicIpLocation2" \
		ipConfigName="$ipConfigName"
else
	az deployment group create --subscription "$subscriptionId" -n "NIC-""$location1" --verbose \
		-g "$rgNameVmLocation1" --template-file "$templateNetworkInterfaceWithoutPublicIp" \
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
		networkInterfaceName="$networkInterfaceNameLocation1" \
		vnetResourceGroup="$rgNameNetworkLocation1" \
		vnetName="$vnetNameLocation1" \
		subnetName="$subnetNameWorkload" \
		enableAcceleratedNetworking="$enableAcceleratedNetworking" \
		privateIpAllocationMethod="$privateIpAllocationMethod" \
		ipConfigName="$ipConfigName"

	az deployment group create --subscription "$subscriptionId" -n "NIC-""$location2" --verbose \
		-g "$rgNameVmLocation2" --template-file "$templateNetworkInterfaceWithoutPublicIp" \
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
		networkInterfaceName="$networkInterfaceNameLocation2" \
		vnetResourceGroup="$rgNameNetworkLocation2" \
		vnetName="$vnetNameLocation2" \
		subnetName="$subnetNameWorkload" \
		enableAcceleratedNetworking="$enableAcceleratedNetworking" \
		privateIpAllocationMethod="$privateIpAllocationMethod" \
		ipConfigName="$ipConfigName"
fi

echo -e "\n"

if $enableBootDiagnostics
then
	echo "Deploy Diagnostics Storage Accounts"

	az deployment group create --subscription "$subscriptionId" -n "DIAG-SA-""$location1" --verbose \
		-g "$rgNameVmLocation1" --template-file "$templateStorageAccount" \
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
		storageAccountName="$bootDiagnosticsStorageAccountNameLocation1" \
		skuName="Standard_LRS" \
		skuTier="Standard" \
		kind="StorageV2" \
		accessTier="Hot" \
		httpsOnly=true \
		hierarchicalEnabled=false \
		defaultAction="Deny" \
		bypass="AzureServices, Logging, Metrics" \
		allowBlobPublicAccess=false \
		minimumTlsVersion="TLS1_2"

	az deployment group create --subscription "$subscriptionId" -n "DIAG-SA-""$location2" --verbose \
		-g "$rgNameVmLocation2" --template-file "$templateStorageAccount" \
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
		storageAccountName="$bootDiagnosticsStorageAccountNameLocation2" \
		skuName="Standard_LRS" \
		skuTier="Standard" \
		kind="StorageV2" \
		accessTier="Hot" \
		httpsOnly=true \
		hierarchicalEnabled=false \
		defaultAction="Deny" \
		bypass="AzureServices, Logging, Metrics" \
		allowBlobPublicAccess=false \
		minimumTlsVersion="TLS1_2"

	echo -e "\n"

	echo "Deploy Diagnostics Storage Account VNet Rules"

	az deployment group create --subscription "$subscriptionId" -n "VM-SA-VNR-""$location1" --verbose \
		-g "$rgNameVmLocation1" --template-file "$templateStorageAccountVnetRuleForVmBootDiagnostics" \
		--parameters \
		location="$location1" \
		storageAccountName="$bootDiagnosticsStorageAccountNameLocation1" \
		skuName="Standard_LRS" \
		skuTier="Standard" \
		kind="StorageV2" \
		virtualNetworkResourceGroup="$rgNameNetworkLocation1" \
		virtualNetworkName="$vnetNameLocation1" \
		subnetName="$subnetNameWorkload" \
		action="Allow"

	az deployment group create --subscription "$subscriptionId" -n "VM-SA-VNR-""$location2" --verbose \
		-g "$rgNameVmLocation2" --template-file "$templateStorageAccountVnetRuleForVmBootDiagnostics" \
		--parameters \
		location="$location2" \
		storageAccountName="$bootDiagnosticsStorageAccountNameLocation2" \
		skuName="Standard_LRS" \
		skuTier="Standard" \
		kind="StorageV2" \
		virtualNetworkResourceGroup="$rgNameNetworkLocation2" \
		virtualNetworkName="$vnetNameLocation2" \
		subnetName="$subnetNameWorkload" \
		action="Allow"

	echo -e "\n"
fi

echo "Deploy VMs"

az deployment group create --subscription "$subscriptionId" -n "VM-""$location1" --verbose \
	-g "$rgNameVmLocation1" --template-file "$templateVirtualMachine" \
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
	availabilityZone="$availabilityZoneLocation1" \
	virtualMachineName="$virtualMachineNameLocation1" \
	virtualMachineSize="$virtualMachineSize" \
	imageResourceId="$virtualMachineImageResourceIdLocation1" \
	publisher="$virtualMachinePublisher" \
	offer="$virtualMachineOffer" \
	sku="$virtualMachineSku" \
	version="$virtualMachineVersion" \
	licenseType="$virtualMachineLicenseType" \
	provisionVmAgent="$provisionVmAgent" \
	adminUsername="$adminUsername" \
	adminPassword="$adminPassword" \
	virtualMachineTimeZone="$virtualMachineTimeZoneLocation1" \
	osDiskStorageType="$osDiskStorageType" \
	osDiskSizeInGB="$osDiskSizeInGB" \
	dataDiskStorageType="$dataDiskStorageType" \
	dataDiskCount="$dataDiskCount" \
	dataDiskSizeInGB="$dataDiskSizeInGB" \
	vmAutoShutdownTime="$vmAutoShutdownTime" \
	enableAutoShutdownNotification="$enableAutoShutdownNotification" \
	autoShutdownNotificationWebhookURL="$autoShutdownNotificationWebhookURL" \
	autoShutdownNotificationMinutesBefore="$autoShutdownNotificationMinutesBefore" \
	resourceGroupNameNetwork="$rgNameVmLocation1" \
	networkInterfaceName="$networkInterfaceNameLocation1"

az deployment group create --subscription "$subscriptionId" -n "VM-""$location2" --verbose \
	-g "$rgNameVmLocation2" --template-file "$templateVirtualMachine" \
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
	availabilityZone="$availabilityZoneLocation2" \
	virtualMachineName="$virtualMachineNameLocation2" \
	virtualMachineSize="$virtualMachineSize" \
	imageResourceId="$virtualMachineImageResourceIdLocation2" \
	publisher="$virtualMachinePublisher" \
	offer="$virtualMachineOffer" \
	sku="$virtualMachineSku" \
	version="$virtualMachineVersion" \
	licenseType="$virtualMachineLicenseType" \
	provisionVmAgent="$provisionVmAgent" \
	adminUsername="$adminUsername" \
	adminPassword="$adminPassword" \
	virtualMachineTimeZone="$virtualMachineTimeZoneLocation2" \
	osDiskStorageType="$osDiskStorageType" \
	osDiskSizeInGB="$osDiskSizeInGB" \
	dataDiskStorageType="$dataDiskStorageType" \
	dataDiskCount="$dataDiskCount" \
	dataDiskSizeInGB="$dataDiskSizeInGB" \
	vmAutoShutdownTime="$vmAutoShutdownTime" \
	enableAutoShutdownNotification="$enableAutoShutdownNotification" \
	autoShutdownNotificationWebhookURL="$autoShutdownNotificationWebhookURL" \
	autoShutdownNotificationMinutesBefore="$autoShutdownNotificationMinutesBefore" \
	resourceGroupNameNetwork="$rgNameVmLocation2" \
	networkInterfaceName="$networkInterfaceNameLocation2"

echo -e "\n"

if $enableBootDiagnostics
then
	echo "Configure VM Boot Diagnostics"

	az deployment group create --subscription "$subscriptionId" -n "DIAG-VM-""$location1" --verbose \
		-g "$rgNameVmLocation1" --template-file "$templateVirtualMachineBootDiagnostics" \
		--parameters \
		location="$location1" \
		virtualMachineName="$virtualMachineNameLocation1" \
		enableBootDiagnostics="$enableBootDiagnostics" \
		diagnosticsStorageAccountName="$bootDiagnosticsStorageAccountNameLocation1"

	az deployment group create --subscription "$subscriptionId" -n "DIAG-VM-""$location2" --verbose \
		-g "$rgNameVmLocation2" --template-file "$templateVirtualMachineBootDiagnostics" \
		--parameters \
		location="$location2" \
		virtualMachineName="$virtualMachineNameLocation2" \
		enableBootDiagnostics="$enableBootDiagnostics" \
		diagnosticsStorageAccountName="$bootDiagnosticsStorageAccountNameLocation2"

	echo -e "\n"
fi