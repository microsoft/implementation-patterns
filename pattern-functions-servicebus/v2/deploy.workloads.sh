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
	echo "Deploy Region 1 Storage Account VNet Rules for Workload"
	az deployment group create --subscription "$subscriptionId" -n "WL-SA-VNR-""$location1" --verbose \
		-g "$rgNameWorkloadLocation1" --template-file "$templateStorageAccountVnetRuleForFunction" \
		--parameters \
		location="$location1" \
		storageAccountName="$storageAcctNameLocation1" \
		skuName="Standard_LRS" \
		skuTier="Standard" \
		kind="StorageV2" \
		virtualNetworkResourceGroup="$rgNameNetworkSpoke1Location1" \
		virtualNetworkName="$vnetNameSpoke1Location1" \
		subnetNameWorkload="$subnetNameWorkload" \
		subnetNameWorkloadVNetIntegration="$subnetNameWorkloadVnetIntegration" \
		action="Allow"

	echo "Deploy Region 2 Storage Account VNet Rules for Workload"
	az deployment group create --subscription "$subscriptionId" -n "WL-SA-VNR-""$location2" --verbose \
		-g "$rgNameWorkloadLocation2" --template-file "$templateStorageAccountVnetRuleForFunction" \
		--parameters \
		location="$location2" \
		storageAccountName="$storageAcctNameLocation2" \
		skuName="Standard_LRS" \
		skuTier="Standard" \
		kind="StorageV2" \
		virtualNetworkResourceGroup="$rgNameNetworkSpoke1Location2" \
		virtualNetworkName="$vnetNameSpoke1Location2" \
		subnetNameWorkload="$subnetNameWorkload" \
		subnetNameWorkloadVNetIntegration="$subnetNameWorkloadVnetIntegration" \
		action="Allow"

	echo -e "\n"
fi

if $storageAccountPrivateEndpoint
then
	echo "Deploy Private Endpoints for Storage Accounts"

	echo "Region 1 Blob Private Endpoint"
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
		networkResourceGroup="$rgNameNetworkSpoke1Location1" \
		vnetName="$vnetNameSpoke1Location1" \
		subnetName="$subnetNameWorkload"

	echo "Region 1 File Private Endpoint"
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
		networkResourceGroup="$rgNameNetworkSpoke1Location1" \
		vnetName="$vnetNameSpoke1Location1" \
		subnetName="$subnetNameWorkload"

	echo "Region 2 Blob Private Endpoint"
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
		networkResourceGroup="$rgNameNetworkSpoke1Location2" \
		vnetName="$vnetNameSpoke1Location2" \
		subnetName="$subnetNameWorkload"

	echo "Region 2 File Private Endpoint"
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
		networkResourceGroup="$rgNameNetworkSpoke1Location2" \
		vnetName="$vnetNameSpoke1Location2" \
		subnetName="$subnetNameWorkload"

	echo -e "\n"
fi

echo "Deploy Region 1 Workload"
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

echo "Deploy Region 2 Workload"
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
	echo "Deploy Region 1 Private Endpoint for Workloads"
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
		networkResourceGroup="$rgNameNetworkSpoke1Location1" \
		vnetName="$vnetNameSpoke1Location1" \
		subnetName="$subnetNameWorkload"

	echo "Deploy Region 2 Private Endpoint for Workloads"
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
		networkResourceGroup="$rgNameNetworkSpoke1Location2" \
		vnetName="$vnetNameSpoke1Location2" \
		subnetName="$subnetNameWorkload"

	echo -e "\n"
fi

if $workloadVnetIntegration
then
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

	echo -e "\n"
fi