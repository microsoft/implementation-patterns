#!/bin/bash

# ==================================================
# Variables
. ./deploy.variables.sh
# ==================================================
echo "Deploy Storage Accounts"

az deployment group create --subscription "$subscriptionId" -n "WL-SA-""$location1" --verbose \
	-g "$rgNameWorkloadLocation1" --template-file "$templateStorageAccount" \
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
	storageAccountName="$storageAcctNameLocation1" \
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

az deployment group create --subscription "$subscriptionId" -n "WL-SA-""$location2" --verbose \
	-g "$rgNameWorkloadLocation2" --template-file "$templateStorageAccount" \
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
	storageAccountName="$storageAcctNameLocation2" \
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

# If we wanted to allow cross-region Storage Account access (peered VNets) we would need to add two more az deployment calls here
if $workloadVnetIntegration
then
	echo "Deploy Storage Account VNet Rules for Workload"

	az deployment group create --subscription "$subscriptionId" -n "WL-SA-VNR-""$location1" --verbose \
		-g "$rgNameWorkloadLocation1" --template-file "$templateStorageAccountVnetRuleForFunction" \
		--parameters \
		location="$location1" \
		storageAccountName="$storageAcctNameLocation1" \
		skuName="Standard_LRS" \
		skuTier="Standard" \
		kind="StorageV2" \
		virtualNetworkResourceGroup="$rgNameNetworkLocation1" \
		virtualNetworkName="$vnetNameLocation1" \
		subnetNameWorkload="$subnetNameWorkload" \
		subnetNameWorkloadVNetIntegration="$subnetNameWorkloadVnetIntegration" \
		action="Allow"

	az deployment group create --subscription "$subscriptionId" -n "WL-SA-VNR-""$location2" --verbose \
		-g "$rgNameWorkloadLocation2" --template-file "$templateStorageAccountVnetRuleForFunction" \
		--parameters \
		location="$location2" \
		storageAccountName="$storageAcctNameLocation2" \
		skuName="Standard_LRS" \
		skuTier="Standard" \
		kind="StorageV2" \
		virtualNetworkResourceGroup="$rgNameNetworkLocation2" \
		virtualNetworkName="$vnetNameLocation2" \
		subnetNameWorkload="$subnetNameWorkload" \
		subnetNameWorkloadVNetIntegration="$subnetNameWorkloadVnetIntegration" \
		action="Allow"

	echo -e "\n"
fi

if $storageAccountPrivateEndpoint
then
	echo "Deploy Private Endpoints for Storage Accounts"

	# Location 1 Blob Private Endpoint
	az deployment group create --subscription "$subscriptionId" -n "SAB-PE-""$location1" --verbose \
		-g "$rgNameWorkloadLocation1" --template-file "$templatePrivateEndpoint" \
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
		privateDnsZoneResourceGroup="$rgNameNetworkGlobal" \
		privateDnsZoneName="$storageBlobPrivateDnsZoneName" \
		protectedWorkloadResourceGroup="$rgNameWorkloadLocation1" \
		protectedWorkloadResourceType="$storageAccountResourceType" \
		protectedWorkloadName="$storageAcctNameLocation1" \
		protectedWorkloadSubResource="$storageBlobSubResource" \
		privateEndpointName="$storageBlobPrivateEndpointNameLocation1" \
		networkResourceGroup="$rgNameNetworkLocation1" \
		vnetName="$vnetNameLocation1" \
		subnetName="$subnetNameWorkload"

	# Location 1 File Private Endpoint
	az deployment group create --subscription "$subscriptionId" -n "SAF-PE-""$location1" --verbose \
		-g "$rgNameWorkloadLocation1" --template-file "$templatePrivateEndpoint" \
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
		privateDnsZoneResourceGroup="$rgNameNetworkGlobal" \
		privateDnsZoneName="$storageFilePrivateDnsZoneName" \
		protectedWorkloadResourceGroup="$rgNameWorkloadLocation1" \
		protectedWorkloadResourceType="$storageAccountResourceType" \
		protectedWorkloadName="$storageAcctNameLocation1" \
		protectedWorkloadSubResource="$storageFileSubResource" \
		privateEndpointName="$storageFilePrivateEndpointNameLocation1" \
		networkResourceGroup="$rgNameNetworkLocation1" \
		vnetName="$vnetNameLocation1" \
		subnetName="$subnetNameWorkload"

	# Location 2 Blob Private Endpoint
	az deployment group create --subscription "$subscriptionId" -n "SAB-PE-""$location2" --verbose \
		-g "$rgNameWorkloadLocation2" --template-file "$templatePrivateEndpoint" \
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
		privateDnsZoneResourceGroup="$rgNameNetworkGlobal" \
		privateDnsZoneName="$storageBlobPrivateDnsZoneName" \
		protectedWorkloadResourceGroup="$rgNameWorkloadLocation2" \
		protectedWorkloadResourceType="$storageAccountResourceType" \
		protectedWorkloadName="$storageAcctNameLocation2" \
		protectedWorkloadSubResource="$storageBlobSubResource" \
		privateEndpointName="$storageBlobPrivateEndpointNameLocation2" \
		networkResourceGroup="$rgNameNetworkLocation2" \
		vnetName="$vnetNameLocation2" \
		subnetName="$subnetNameWorkload"

	# Location 2 File Private Endpoint
	az deployment group create --subscription "$subscriptionId" -n "SAF-PE-""$location2" --verbose \
		-g "$rgNameWorkloadLocation2" --template-file "$templatePrivateEndpoint" \
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
		privateDnsZoneResourceGroup="$rgNameNetworkGlobal" \
		privateDnsZoneName="$storageFilePrivateDnsZoneName" \
		protectedWorkloadResourceGroup="$rgNameWorkloadLocation2" \
		protectedWorkloadResourceType="$storageAccountResourceType" \
		protectedWorkloadName="$storageAcctNameLocation2" \
		protectedWorkloadSubResource="$storageFileSubResource" \
		privateEndpointName="$storageFilePrivateEndpointNameLocation2" \
		networkResourceGroup="$rgNameNetworkLocation2" \
		vnetName="$vnetNameLocation2" \
		subnetName="$subnetNameWorkload"

	echo -e "\n"
fi

echo "Deploy Workloads"

az deployment group create --subscription "$subscriptionId" -n "WL-""$location1" --verbose \
	-g "$rgNameWorkloadLocation1" --template-file "$templateWorkload" \
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
	functionName="$workloadAppNameLocation1" \
	hostingPlanName="$workloadPlanNameLocation1" \
	serverFarmResourceGroup="$rgNameWorkloadLocation1" \
	alwaysOn="$workloadAlwaysOn" \
	storageAccountName="$storageAcctNameLocation1" \
	runtimeStack="$workloadRuntimeStack" \
	runtimeStackVersion="$workloadRuntimeVersion" \
	skuTier="$workloadHostingPlanSkuTier" \
	skuName="$workloadHostingPlanSkuName" \
	workerSize="$workloadWorkerSize" \
	workerSizeId="$workloadWorkerSizeId" \
	numberOfWorkers="$workloadWorkerCount" \
	appInsightsName="$workloadAppInsightsNameLocation1" \
	addPrivateEndpoint="$workloadPrivateEndpoint" \
	routeAllTrafficThroughVNet="$workloadRouteAllTrafficThroughVnet"

az deployment group create --subscription "$subscriptionId" -n "WL-""$location2" --verbose \
	-g "$rgNameWorkloadLocation2" --template-file "$templateWorkload" \
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
	functionName="$workloadAppNameLocation2" \
	hostingPlanName="$workloadPlanNameLocation2" \
	serverFarmResourceGroup="$rgNameWorkloadLocation2" \
	alwaysOn="$workloadAlwaysOn" \
	storageAccountName="$storageAcctNameLocation2" \
	runtimeStack="$workloadRuntimeStack" \
	runtimeStackVersion="$workloadRuntimeVersion" \
	skuTier="$workloadHostingPlanSkuTier" \
	skuName="$workloadHostingPlanSkuName" \
	workerSize="$workloadWorkerSize" \
	workerSizeId="$workloadWorkerSizeId" \
	numberOfWorkers="$workloadWorkerCount" \
	appInsightsName="$workloadAppInsightsNameLocation2" \
	addPrivateEndpoint="$workloadPrivateEndpoint" \
	routeAllTrafficThroughVNet="$workloadRouteAllTrafficThroughVnet"

echo -e "\n"

if $workloadPrivateEndpoint
then
	echo "Deploy Private Endpoints for Workloads"

	az deployment group create --subscription "$subscriptionId" -n "WL-PE-""$location1" --verbose \
		-g "$rgNameWorkloadLocation1" --template-file "$templatePrivateEndpoint" \
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
		privateDnsZoneResourceGroup="$rgNameNetworkGlobal" \
		privateDnsZoneName="$workloadPrivateDnsZoneName" \
		protectedWorkloadResourceGroup="$rgNameWorkloadLocation1" \
		protectedWorkloadResourceType="$workloadResourceType" \
		protectedWorkloadName="$workloadAppNameLocation1" \
		protectedWorkloadSubResource="$workloadSubResource" \
		privateEndpointName="$workloadPrivateEndpointNameLocation1" \
		networkResourceGroup="$rgNameNetworkLocation1" \
		vnetName="$vnetNameLocation1" \
		subnetName="$subnetNameWorkload"

	az deployment group create --subscription "$subscriptionId" -n "WL-PE-""$location2" --verbose \
		-g "$rgNameWorkloadLocation2" --template-file "$templatePrivateEndpoint" \
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
		privateDnsZoneResourceGroup="$rgNameNetworkGlobal" \
		privateDnsZoneName="$workloadPrivateDnsZoneName" \
		protectedWorkloadResourceGroup="$rgNameWorkloadLocation2" \
		protectedWorkloadResourceType="$workloadResourceType" \
		protectedWorkloadName="$workloadAppNameLocation2" \
		protectedWorkloadSubResource="$workloadSubResource" \
		privateEndpointName="$workloadPrivateEndpointNameLocation2" \
		networkResourceGroup="$rgNameNetworkLocation2" \
		vnetName="$vnetNameLocation2" \
		subnetName="$subnetNameWorkload"

	echo -e "\n"
fi

if $workloadVnetIntegration
then
	echo "VNet Integration for Workloads"

	az deployment group create --subscription "$subscriptionId" -n "WL-VN-""$location1" --verbose \
		-g "$rgNameWorkloadLocation1" --template-file "$templateWorkloadVnetIntegration" \
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
		functionName="$workloadAppNameLocation1" \
		virtualNetworkResourceGroup="$rgNameNetworkLocation1" \
		virtualNetworkName="$vnetNameLocation1" \
		subnetNameForVNetIntegration="$subnetNameWorkloadVnetIntegration"

	az deployment group create --subscription "$subscriptionId" -n "WL-VN-""$location2" --verbose \
		-g "$rgNameWorkloadLocation2" --template-file "$templateWorkloadVnetIntegration" \
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
		functionName="$workloadAppNameLocation2" \
		virtualNetworkResourceGroup="$rgNameNetworkLocation2" \
		virtualNetworkName="$vnetNameLocation2" \
		subnetNameForVNetIntegration="$subnetNameWorkloadVnetIntegration"

	echo -e "\n"
fi