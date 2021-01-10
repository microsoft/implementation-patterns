#!/bin/bash

# ==================================================
# Variables
. ./deploy.variables.sh
# ==================================================
echo "Deploy Location 1 Service Bus Namespace"
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

echo "Deploy Location 2 Service Bus Namespace"
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

echo "Deploy Location 1 Service Bus Namespace SAS Access Policies in addition to default RootManageSharedAccessKey"
az deployment group create --subscription "$subscriptionId" -n "ASB-SAS-""$location1" --verbose \
	-g "$rgNameSharedLocation1" --template-file "$templateAsbSasPolicy" \
	--parameters \
	location="$location1" \
	namespaceName="$asbNamespaceNameLocation1" \
	sasRuleName="$asbSendListenSasPolicyName"

echo "Deploy Location 2 Service Bus Namespace SAS Access Policies in addition to default RootManageSharedAccessKey"
az deployment group create --subscription "$subscriptionId" -n "ASB-SAS-""$location2" --verbose \
	-g "$rgNameSharedLocation2" --template-file "$templateAsbSasPolicy" \
	--parameters \
	location="$location2" \
	namespaceName="$asbNamespaceNameLocation2" \
	sasRuleName="$asbSendListenSasPolicyName"

echo -e "\n"

# Do these BEFORE any namespace VNet rules deployed below
echo "Configure Location 1 Service Bus Namespace Trusted Azure service access and any explicit IP rules"
az deployment group create --subscription "$subscriptionId" -n "ASB-Net-Rules-""$location1" --verbose \
	-g "$rgNameSharedLocation1" --template-file "$templateAsbNetRules" \
	--parameters \
	namespaceName="$asbNamespaceNameLocation1" \
	allowTrustedServices="$asbAllowTrustedServices" \
	defaultAction="$asbDefaultAction"

echo "Configure Location 2 Service Bus Namespace Trusted Azure service access and any explicit IP rules"
az deployment group create --subscription "$subscriptionId" -n "ASB-Net-Rules-""$location2" --verbose \
	-g "$rgNameSharedLocation2" --template-file "$templateAsbNetRules" \
	--parameters \
	namespaceName="$asbNamespaceNameLocation2" \
	allowTrustedServices="$asbAllowTrustedServices" \
	defaultAction="$asbDefaultAction"

if $asbVnetAccessRules
then
	echo "Deploy Service Bus Namespace VNet Rules"

	echo "Allow access to ASB Namespace in Region 1 from Workload Subnet in VNet in Region 1"
	az deployment group create --subscription "$subscriptionId" -n "ASB-VNet-Rule-Allow-""$subnetNameWorkload""-""$location1" --verbose \
		-g "$rgNameSharedLocation1" --template-file "$templateAsbVnetRule" \
		--parameters \
		namespaceName="$asbNamespaceNameLocation1" \
		vnetName="$vnetNameSpoke1Location1" \
		subnetName="$subnetNameWorkload" \
		resourceGroupNameNetwork="$rgNameNetworkSpoke1Location1"

	echo "Allow access to ASB Namespace in Region 1 from Workload Integration Subnet in VNet in Region 1"
	az deployment group create --subscription "$subscriptionId" -n "ASB-VNet-Rule-Allow-""$subnetNameWorkloadVnetIntegration""-""$location1" --verbose \
		-g "$rgNameSharedLocation1" --template-file "$templateAsbVnetRule" \
		--parameters \
		namespaceName="$asbNamespaceNameLocation1" \
		vnetName="$vnetNameSpoke1Location1" \
		subnetName="$subnetNameWorkloadVnetIntegration" \
		resourceGroupNameNetwork="$rgNameNetworkSpoke1Location1"

	echo "Allow access to ASB Namespace in Region 1 from Test Subnet in VNet in Region 1"
	az deployment group create --subscription "$subscriptionId" -n "ASB-VNet-Rule-Allow-""$subnetNameTest""-""$location1" --verbose \
		-g "$rgNameSharedLocation1" --template-file "$templateAsbVnetRule" \
		--parameters \
		namespaceName="$asbNamespaceNameLocation1" \
		vnetName="$vnetNameSpoke1Location1" \
		subnetName="$subnetNameTest" \
		resourceGroupNameNetwork="$rgNameNetworkSpoke1Location1"


	echo "Allow access to ASB Namespace in Region 1 from Workload Subnet in VNet in Region 2"
	az deployment group create --subscription "$subscriptionId" -n "ASB-VNet-Rule-Allow-""$subnetNameWorkload""-""$location2" --verbose \
		-g "$rgNameSharedLocation1" --template-file "$templateAsbVnetRule" \
		--parameters \
		namespaceName="$asbNamespaceNameLocation1" \
		vnetName="$vnetNameSpoke1Location2" \
		subnetName="$subnetNameWorkload" \
		resourceGroupNameNetwork="$rgNameNetworkSpoke1Location2"

	echo "Allow access to ASB Namespace in Region 1 from Workload Integration Subnet in VNet in Region 2"
	az deployment group create --subscription "$subscriptionId" -n "ASB-VNet-Rule-Allow-""$subnetNameWorkloadVnetIntegration""-""$location2" --verbose \
		-g "$rgNameSharedLocation1" --template-file "$templateAsbVnetRule" \
		--parameters \
		namespaceName="$asbNamespaceNameLocation1" \
		vnetName="$vnetNameSpoke1Location2" \
		subnetName="$subnetNameWorkloadVnetIntegration" \
		resourceGroupNameNetwork="$rgNameNetworkSpoke1Location2"

	echo "Allow access to ASB Namespace in Region 1 from Test Subnet in VNet in Region 2"
	az deployment group create --subscription "$subscriptionId" -n "ASB-VNet-Rule-Allow-""$subnetNameTest""-""$location1" --verbose \
		-g "$rgNameSharedLocation1" --template-file "$templateAsbVnetRule" \
		--parameters \
		namespaceName="$asbNamespaceNameLocation1" \
		vnetName="$vnetNameSpoke1Location2" \
		subnetName="$subnetNameTest" \
		resourceGroupNameNetwork="$rgNameNetworkSpoke1Location2"


	echo "Allow access to ASB Namespace in Region 2 from Workload Subnet in VNet in Region 2"
	az deployment group create --subscription "$subscriptionId" -n "ASB-VNet-Rule-Allow-""$subnetNameWorkload""-""$location2" --verbose \
		-g "$rgNameSharedLocation2" --template-file "$templateAsbVnetRule" \
		--parameters \
		namespaceName="$asbNamespaceNameLocation2" \
		vnetName="$vnetNameSpoke1Location2" \
		subnetName="$subnetNameWorkload" \
		resourceGroupNameNetwork="$rgNameNetworkSpoke1Location2"

	echo "Allow access to ASB Namespace in Region 2 from Workload Integration Subnet in VNet in Region 2"
	az deployment group create --subscription "$subscriptionId" -n "ASB-VNet-Rule-Allow-""$subnetNameWorkloadVnetIntegration""-""$location2" --verbose \
		-g "$rgNameSharedLocation2" --template-file "$templateAsbVnetRule" \
		--parameters \
		namespaceName="$asbNamespaceNameLocation2" \
		vnetName="$vnetNameSpoke1Location2" \
		subnetName="$subnetNameWorkloadVnetIntegration" \
		resourceGroupNameNetwork="$rgNameNetworkSpoke1Location2"

	echo "Allow access to ASB Namespace in Region 2 from Test Subnet in VNet in Region 2"
	az deployment group create --subscription "$subscriptionId" -n "ASB-VNet-Rule-Allow-""$subnetNameTest""-""$location2" --verbose \
		-g "$rgNameSharedLocation2" --template-file "$templateAsbVnetRule" \
		--parameters \
		namespaceName="$asbNamespaceNameLocation2" \
		vnetName="$vnetNameSpoke1Location2" \
		subnetName="$subnetNameTest" \
		resourceGroupNameNetwork="$rgNameNetworkSpoke1Location2"


	echo "Allow access to ASB Namespace in Region 2 from Workload Subnet in VNet in Region 1"
	az deployment group create --subscription "$subscriptionId" -n "ASB-VNet-Rule-Allow-""$subnetNameWorkload""-""$location1" --verbose \
		-g "$rgNameSharedLocation2" --template-file "$templateAsbVnetRule" \
		--parameters \
		namespaceName="$asbNamespaceNameLocation2" \
		vnetName="$vnetNameSpoke1Location1" \
		subnetName="$subnetNameWorkload" \
		resourceGroupNameNetwork="$rgNameNetworkSpoke1Location1"

	echo "Allow access to ASB Namespace in Region 2 from Workload Integration Subnet in VNet in Region 1"
	az deployment group create --subscription "$subscriptionId" -n "ASB-VNet-Rule-Allow-""$subnetNameWorkloadVnetIntegration""-""$location1" --verbose \
		-g "$rgNameSharedLocation2" --template-file "$templateAsbVnetRule" \
		--parameters \
		namespaceName="$asbNamespaceNameLocation2" \
		vnetName="$vnetNameSpoke1Location1" \
		subnetName="$subnetNameWorkloadVnetIntegration" \
		resourceGroupNameNetwork="$rgNameNetworkSpoke1Location1"

	echo "Allow access to ASB Namespace in Region 2 from Test Subnet in VNet in Region 1"
	az deployment group create --subscription "$subscriptionId" -n "ASB-VNet-Rule-Allow-""$subnetNameTest""-""$location1" --verbose \
		-g "$rgNameSharedLocation2" --template-file "$templateAsbVnetRule" \
		--parameters \
		namespaceName="$asbNamespaceNameLocation2" \
		vnetName="$vnetNameSpoke1Location1" \
		subnetName="$subnetNameTest" \
		resourceGroupNameNetwork="$rgNameNetworkSpoke1Location1"

	echo -e "\n"
fi

if $asbPrivateEndpoint
then
	echo "Deploy Location 1 Private Endpoint for Service Bus Namespace"
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
		networkResourceGroup="$rgNameNetworkSpoke1Location1" \
		vnetName="$vnetNameSpoke1Location1" \
		subnetName="$subnetNameShared"

	echo "Deploy Location 2 Private Endpoint for Service Bus Namespace"
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
		networkResourceGroup="$rgNameNetworkSpoke1Location2" \
		vnetName="$vnetNameSpoke1Location2" \
		subnetName="$subnetNameShared"

	echo -e "\n"
fi

echo "Deploy Location 1 Service Bus Queue"
az deployment group create --subscription "$subscriptionId" -n "ASB-Q-""$location1" --verbose \
	-g "$rgNameSharedLocation1" --template-file "$templateAsbQueue" \
	--parameters \
	namespaceName="$asbNamespaceNameLocation1" \
	queueName="$asbQueueName"

echo "Deploy Location 2 Service Bus Queue"
az deployment group create --subscription "$subscriptionId" -n "ASB-Q-""$location2" --verbose \
	-g "$rgNameSharedLocation2" --template-file "$templateAsbQueue" \
	--parameters \
	namespaceName="$asbNamespaceNameLocation2" \
	queueName="$asbQueueName"

echo -e "\n"

echo "Deploy Location 1 Service Bus Topic"
az deployment group create --subscription "$subscriptionId" -n "ASB-T-""$location1" --verbose \
	-g "$rgNameSharedLocation1" --template-file "$templateAsbTopic" \
	--parameters \
	namespaceName="$asbNamespaceNameLocation1" \
	topicName="$asbTopicName"

echo "Deploy Location 1 Service Bus Subscription"
az deployment group create --subscription "$subscriptionId" -n "ASB-TS-""$location1" --verbose \
	-g "$rgNameSharedLocation1" --template-file "$templateAsbSubscription" \
	--parameters \
	namespaceName="$asbNamespaceNameLocation1" \
	topicName="$asbTopicName" \
	subscriptionName="$asbSubscriptionName"

echo "Deploy Location 2 Service Bus Topic"
az deployment group create --subscription "$subscriptionId" -n "ASB-T-""$location2" --verbose \
	-g "$rgNameSharedLocation2" --template-file "$templateAsbTopic" \
	--parameters \
	namespaceName="$asbNamespaceNameLocation2" \
	topicName="$asbTopicName"

echo "Deploy Location 2 Service Bus Subscription"
az deployment group create --subscription "$subscriptionId" -n "ASB-TS-""$location2" --verbose \
	-g "$rgNameSharedLocation2" --template-file "$templateAsbSubscription" \
	--parameters \
	namespaceName="$asbNamespaceNameLocation2" \
	topicName="$asbTopicName" \
	subscriptionName="$asbSubscriptionName"
