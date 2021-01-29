#!/bin/bash

# ==================================================
# Variables
. ./deploy.variables.sh
# ==================================================
if $virtualMachineUsePublicIp
then
	echo "Deploy Location 1 VM Public IP"
	az deployment group create --subscription "$subscriptionId" -n "VM-PIP-""$location1" --verbose \
		-g "$rgNameTestLocation1" --template-file "$templatePublicIp" \
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
		publicIpType="$virtualMachinePublicIpType" \
		publicIpSku="$virtualMachinePublicIpSku" \
		domainNameLabel="$virtualMachineNameLocation1"

	echo "Deploy Location 2 VM Public IP"
	az deployment group create --subscription "$subscriptionId" -n "VM-PIP-""$location2" --verbose \
		-g "$rgNameTestLocation2" --template-file "$templatePublicIp" \
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
		publicIpType="$virtualMachinePublicIpType" \
		publicIpSku="$virtualMachinePublicIpSku" \
		domainNameLabel="$virtualMachineNameLocation2"

	echo -e "\n"
fi

echo "Deploy Location 1 VM Network Interface"
az deployment group create --subscription "$subscriptionId" -n "VM-NIC-""$location1" --verbose \
	-g "$rgNameTestLocation1" --template-file "$templateNetworkInterface" \
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
	networkInterfaceName="$virtualMachineNetworkInterfaceNameLocation1" \
	vnetResourceGroup="$rgNameNetworkSpoke1Location1" \
	vnetName="$vnetNameSpoke1Location1" \
	subnetName="$subnetNameTest" \
	enableAcceleratedNetworking="$enableAcceleratedNetworking" \
	privateIpAllocationMethod="$privateIpAllocationMethod" \
	publicIpResourceGroup="$rgNameTestLocation1" \
	publicIpName="$virtualMachinePublicIpLocation1" \
	ipConfigName="$ipConfigName"

echo "Deploy Location 2 VM Network Interface"
az deployment group create --subscription "$subscriptionId" -n "VM-NIC-""$location2" --verbose \
	-g "$rgNameTestLocation2" --template-file "$templateNetworkInterface" \
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
	networkInterfaceName="$virtualMachineNetworkInterfaceNameLocation2" \
	vnetResourceGroup="$rgNameNetworkSpoke1Location2" \
	vnetName="$vnetNameSpoke1Location2" \
	subnetName="$subnetNameTest" \
	enableAcceleratedNetworking="$enableAcceleratedNetworking" \
	privateIpAllocationMethod="$privateIpAllocationMethod" \
	publicIpResourceGroup="$rgNameTestLocation2" \
	publicIpName="$virtualMachinePublicIpLocation2" \
	ipConfigName="$ipConfigName"

echo -e "\n"

if $enableBootDiagnostics
then
	echo "Deploy Location 1 Diagnostics Storage Account"
	az deployment group create --subscription "$subscriptionId" -n "VM-DIAG-SA-""$location1" --verbose \
		-g "$rgNameTestLocation1" --template-file "$templateStorageAccount" \
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
		minimumTlsVersion="TLS1_2" \
		virtualNetworkResourceGroup="$rgNameNetworkSpoke1Location1" \
		virtualNetworkName="$vnetNameSpoke1Location1" \
		subnetNamesToAllow="$subnetNameTest"

	echo "Deploy Location 2 Diagnostics Storage Account"
	az deployment group create --subscription "$subscriptionId" -n "VM-DIAG-SA-""$location2" --verbose \
		-g "$rgNameTestLocation2" --template-file "$templateStorageAccount" \
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
		minimumTlsVersion="TLS1_2" \
		virtualNetworkResourceGroup="$rgNameNetworkSpoke1Location2" \
		virtualNetworkName="$vnetNameSpoke1Location2" \
		subnetNamesToAllow="$subnetNameTest"

	echo -e "\n"
fi

echo "Deploy Location 1 VM"
az deployment group create --subscription "$subscriptionId" -n "VM-""$location1" --verbose \
	-g "$rgNameTestLocation1" --template-file "$templateVirtualMachine" \
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
	resourceGroupNameNetworkInterface="$rgNameTestLocation1" \
	networkInterfaceName="$virtualMachineNetworkInterfaceNameLocation1"

echo "Deploy Location 2 VM"
az deployment group create --subscription "$subscriptionId" -n "VM-""$location2" --verbose \
	-g "$rgNameTestLocation2" --template-file "$templateVirtualMachine" \
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
	resourceGroupNameNetworkInterface="$rgNameTestLocation2" \
	networkInterfaceName="$virtualMachineNetworkInterfaceNameLocation2"

echo -e "\n"

if $enableBootDiagnostics
then
	echo "Configure Location 1 VM Boot Diagnostics"
	az deployment group create --subscription "$subscriptionId" -n "DIAG-VM-""$location1" --verbose \
		-g "$rgNameTestLocation1" --template-file "$templateVirtualMachineBootDiagnostics" \
		--parameters \
		location="$location1" \
		virtualMachineName="$virtualMachineNameLocation1" \
		enableBootDiagnostics="$enableBootDiagnostics" \
		diagnosticsStorageAccountName="$bootDiagnosticsStorageAccountNameLocation1"

	echo "Configure Location 2 VM Boot Diagnostics"
	az deployment group create --subscription "$subscriptionId" -n "DIAG-VM-""$location2" --verbose \
		-g "$rgNameTestLocation2" --template-file "$templateVirtualMachineBootDiagnostics" \
		--parameters \
		location="$location2" \
		virtualMachineName="$virtualMachineNameLocation2" \
		enableBootDiagnostics="$enableBootDiagnostics" \
		diagnosticsStorageAccountName="$bootDiagnosticsStorageAccountNameLocation2"

	echo -e "\n"
fi