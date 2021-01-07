#!/bin/bash

# ==================================================
# Variables
. ./deploy.variables.sh
# ==================================================
echo "Deploy Service Bus Namespaces"

az deployment group create --subscription "$subscriptionId" -n "ASB-""$location1" --verbose \
	-g "$rgNameSharedLocation1" --template-file "$templateAsb" \
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
	namespaceName="$asbNamespaceNameLocation1" \
	zoneRedundant="$asbZoneRedundant" \
	messagingUnits="$asbMessagingUnits"

az deployment group create --subscription "$subscriptionId" -n "ASB-""$location2" --verbose \
	-g "$rgNameSharedLocation2" --template-file "$templateAsb" \
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
	namespaceName="$asbNamespaceNameLocation2" \
	zoneRedundant="$asbZoneRedundant" \
	messagingUnits="$asbMessagingUnits"

echo -e "\n"

echo "Deploy Service Bus Namespace SAS Access Policies in addition to default RootManageSharedAccessKey"

az deployment group create --subscription "$subscriptionId" -n "ASB-SAS-""$location1" --verbose \
	-g "$rgNameSharedLocation1" --template-file "$templateAsbSasPolicy" \
	--parameters \
	location="$location1" \
	namespaceName="$asbNamespaceNameLocation1" \
	sasRuleName="$asbSendListenSasPolicyName"

az deployment group create --subscription "$subscriptionId" -n "ASB-SAS-""$location2" --verbose \
	-g "$rgNameSharedLocation2" --template-file "$templateAsbSasPolicy" \
	--parameters \
	location="$location2" \
	namespaceName="$asbNamespaceNameLocation2" \
	sasRuleName="$asbSendListenSasPolicyName"

echo -e "\n"

echo "Configure Service Bus Namespace Trusted Azure service access and any explicit IP rules"

# Do this BEFORE any namespace VNet rules deployed below
az deployment group create --subscription "$subscriptionId" -n "ASB-""$location1" --verbose \
	-g "$rgNameSharedLocation1" --template-file "$templateAsbNetRules" \
	--parameters \
	namespaceName="$asbNamespaceNameLocation1" \
	allowTrustedServices="$asbAllowTrustedServices" \
	defaultAction="$asbDefaultAction"

if $asbVnetAccessRules
then
	echo "Deploy Service Bus Namespace VNet Rules"

	# Allow access to ASB Namespace in Region 1 from Workload Subnet in VNet in Region 1
	az deployment group create --subscription "$subscriptionId" -n "ASB-VNet-Rule-Allow-""$subnetNameWorkload""-""$location1" --verbose \
		-g "$rgNameSharedLocation1" --template-file "$templateAsbVnetRule" \
		--parameters \
		namespaceName="$asbNamespaceNameLocation1" \
		vnetName="$vnetNameLocation1" \
		subnetName="$subnetNameWorkload" \
		resourceGroupNameNetwork="$rgNameNetworkLocation1"

	# Allow access to ASB Namespace in Region 1 from Workload Integration Subnet in VNet in Region 1
	az deployment group create --subscription "$subscriptionId" -n "ASB-VNet-Rule-Allow-""$subnetNameWorkloadVnetIntegration""-""$location1" --verbose \
		-g "$rgNameSharedLocation1" --template-file "$templateAsbVnetRule" \
		--parameters \
		namespaceName="$asbNamespaceNameLocation1" \
		vnetName="$vnetNameLocation1" \
		subnetName="$subnetNameWorkloadVnetIntegration" \
		resourceGroupNameNetwork="$rgNameNetworkLocation1"

	# Allow access to ASB Namespace in Region 1 from Workload Subnet in VNet in Region 2
	az deployment group create --subscription "$subscriptionId" -n "ASB-VNet-Rule-Allow-""$subnetNameWorkload""-""$location2" --verbose \
		-g "$rgNameSharedLocation1" --template-file "$templateAsbVnetRule" \
		--parameters \
		namespaceName="$asbNamespaceNameLocation1" \
		vnetName="$vnetNameLocation2" \
		subnetName="$subnetNameWorkload" \
		resourceGroupNameNetwork="$rgNameNetworkLocation2"

	# Allow access to ASB Namespace in Region 1 from Workload Integration Subnet in VNet in Region 2
	az deployment group create --subscription "$subscriptionId" -n "ASB-VNet-Rule-Allow-""$subnetNameWorkloadVnetIntegration""-""$location2" --verbose \
		-g "$rgNameSharedLocation1" --template-file "$templateAsbVnetRule" \
		--parameters \
		namespaceName="$asbNamespaceNameLocation1" \
		vnetName="$vnetNameLocation2" \
		subnetName="$subnetNameWorkloadVnetIntegration" \
		resourceGroupNameNetwork="$rgNameNetworkLocation2"

	# Allow access to ASB Namespace in Region 2 from Workload Subnet in VNet in Region 2
	az deployment group create --subscription "$subscriptionId" -n "ASB-VNet-Rule-Allow-""$subnetNameWorkload""-""$location2" --verbose \
		-g "$rgNameSharedLocation2" --template-file "$templateAsbVnetRule" \
		--parameters \
		namespaceName="$asbNamespaceNameLocation2" \
		vnetName="$vnetNameLocation2" \
		subnetName="$subnetNameWorkload" \
		resourceGroupNameNetwork="$rgNameNetworkLocation2"

	# Allow access to ASB Namespace in Region 2 from Workload Integration Subnet in VNet in Region 2
	az deployment group create --subscription "$subscriptionId" -n "ASB-VNet-Rule-Allow-""$subnetNameWorkloadVnetIntegration""-""$location2" --verbose \
		-g "$rgNameSharedLocation2" --template-file "$templateAsbVnetRule" \
		--parameters \
		namespaceName="$asbNamespaceNameLocation2" \
		vnetName="$vnetNameLocation2" \
		subnetName="$subnetNameWorkloadVnetIntegration" \
		resourceGroupNameNetwork="$rgNameNetworkLocation2"

	# Allow access to ASB Namespace in Region 2 from Workload Subnet in VNet in Region 1
	az deployment group create --subscription "$subscriptionId" -n "ASB-VNet-Rule-Allow-""$subnetNameWorkload""-""$location1" --verbose \
		-g "$rgNameSharedLocation2" --template-file "$templateAsbVnetRule" \
		--parameters \
		namespaceName="$asbNamespaceNameLocation2" \
		vnetName="$vnetNameLocation1" \
		subnetName="$subnetNameWorkload" \
		resourceGroupNameNetwork="$rgNameNetworkLocation1"

	# Allow access to ASB Namespace in Region 2 from Workload Integration Subnet in VNet in Region 1
	az deployment group create --subscription "$subscriptionId" -n "ASB-VNet-Rule-Allow-""$subnetNameWorkloadVnetIntegration""-""$location1" --verbose \
		-g "$rgNameSharedLocation2" --template-file "$templateAsbVnetRule" \
		--parameters \
		namespaceName="$asbNamespaceNameLocation2" \
		vnetName="$vnetNameLocation1" \
		subnetName="$subnetNameWorkloadVnetIntegration" \
		resourceGroupNameNetwork="$rgNameNetworkLocation1"

	echo -e "\n"
fi

if $asbPrivateEndpoint
then
	echo "Deploy Private Endpoints for Service Bus Namespaces"

	az deployment group create --subscription "$subscriptionId" -n "ASB-PE-""$location1" --verbose \
		-g "$rgNameSharedLocation1" --template-file "$templatePrivateEndpoint" \
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
		privateDnsZoneName="$asbPrivateDnsZoneName" \
		protectedWorkloadResourceGroup="$rgNameSharedLocation1" \
		protectedWorkloadResourceType="$asbResourceType" \
		protectedWorkloadName="$asbNamespaceNameLocation1" \
		protectedWorkloadSubResource="$asbSubResource" \
		privateEndpointName="$asbPrivateEndpointNameLocation1" \
		networkResourceGroup="$rgNameNetworkLocation1" \
		vnetName="$vnetNameLocation1" \
		subnetName="$subnetNameShared"

	az deployment group create --subscription "$subscriptionId" -n "ASB-PE-""$location2" --verbose \
		-g "$rgNameSharedLocation2" --template-file "$templatePrivateEndpoint" \
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
		privateDnsZoneName="$asbPrivateDnsZoneName" \
		protectedWorkloadResourceGroup="$rgNameSharedLocation2" \
		protectedWorkloadResourceType="$asbResourceType" \
		protectedWorkloadName="$asbNamespaceNameLocation2" \
		protectedWorkloadSubResource="$asbSubResource" \
		privateEndpointName="$asbPrivateEndpointNameLocation2" \
		networkResourceGroup="$rgNameNetworkLocation2" \
		vnetName="$vnetNameLocation2" \
		subnetName="$subnetNameShared"

	echo -e "\n"
fi

echo "Deploy Service Bus Queues"

az deployment group create --subscription "$subscriptionId" -n "ASB-Q-""$location1" --verbose \
	-g "$rgNameSharedLocation1" --template-file "$templateAsbQueue" \
	--parameters \
	namespaceName="$asbNamespaceNameLocation1" \
	queueName="$asbQueueName"

az deployment group create --subscription "$subscriptionId" -n "ASB-Q-""$location2" --verbose \
	-g "$rgNameSharedLocation2" --template-file "$templateAsbQueue" \
	--parameters \
	namespaceName="$asbNamespaceNameLocation2" \
	queueName="$asbQueueName"

echo -e "\n"

echo "Deploy Service Bus Topics and Subscriptions"

az deployment group create --subscription "$subscriptionId" -n "ASB-T-""$location1" --verbose \
	-g "$rgNameSharedLocation1" --template-file "$templateAsbTopic" \
	--parameters \
	namespaceName="$asbNamespaceNameLocation1" \
	topicName="$asbTopicName"

az deployment group create --subscription "$subscriptionId" -n "ASB-TS-""$location1" --verbose \
	-g "$rgNameSharedLocation1" --template-file "$templateAsbSubscription" \
	--parameters \
	namespaceName="$asbNamespaceNameLocation1" \
	topicName="$asbTopicName" \
	subscriptionName="$asbSubscriptionName"

az deployment group create --subscription "$subscriptionId" -n "ASB-T-""$location2" --verbose \
	-g "$rgNameSharedLocation2" --template-file "$templateAsbTopic" \
	--parameters \
	namespaceName="$asbNamespaceNameLocation2" \
	topicName="$asbTopicName"

az deployment group create --subscription "$subscriptionId" -n "ASB-TS-""$location2" --verbose \
	-g "$rgNameSharedLocation2" --template-file "$templateAsbSubscription" \
	--parameters \
	namespaceName="$asbNamespaceNameLocation2" \
	topicName="$asbTopicName" \
	subscriptionName="$asbSubscriptionName"
