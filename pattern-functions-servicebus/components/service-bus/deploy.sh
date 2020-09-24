#!/bin/bash

# Params
infix=""

subscription_id=""

location1="eastus2"
location2="centralus"

resourceGroup1NameNet="$infix""-net-""$location1"
resourceGroup2NameNet="$infix""-net-""$location2"

resourceGroup1NameSB="$infix""-sb-""$location1"
resourceGroup2NameSB="$infix""-sb-""$location2"

#logAnalyticsWorkspaceName="sbp-la"  # Leave blank if you don't want LA diagnostics. Workspace should already exist - not created here
#logAnalyticsResourceGroupName="sbtest"  # Should already exist - not created here
# Log Analytics RG - can be per region or only one
logAnalyticsResourceGroupName1="sbtest" # Leave blank if you don't want LA diagnostics. Should already exist - not created here
logAnalyticsResourceGroupName2="sbtest" # Leave blank if you don't want LA diagnostics. Should already exist - not created here
# Log Analytics Workspace
logAnalyticsWorkspaceName1="sbp-la-""$location1" # Workspace should already exist - not created here
logAnalyticsWorkspaceName2="sbp-la-""$location2" # Workspace should already exist - not created here

namespace1Name="$infix""-ns-""$location1"
namespace2Name="$infix""-ns-""$location2"

aliasName="$infix""-ns-alias"

privateDnsZoneName="privatelink.servicebus.windows.net"

privateEndpointNameR1NS1="pepr1ns1"
privateEndpointNameR1NS2="pepr1ns2"
privateEndpointNameR2NS1="pepr2ns1"
privateEndpointNameR2NS2="pepr2ns2"

spokeVnetName="spoke-vnet"
workloadSubnetName="workload-subnet"

templateFileNamespace="azuredeploy-namespace.json"
templateFileNamespaceSasPolicy="azuredeploy-namespace-saspolicy.json"
templateFileQueue="azuredeploy-namespace-queue.json"
templateFileTopic="azuredeploy-namespace-topic.json"
templateFileTopicSubscription="azuredeploy-namespace-topic-subscription.json"
templateFileGeoReplication="azuredeploy-georeplication.json"
templateFilePrivateZone="azuredeploy-privatezone.json"
templateFilePrivateLink="azuredeploy-privatelink.json"
templateFileZoneLink="azuredeploy-zonelink.json"

# Create RGs
az group create --subscription "$subscription_id" --name "$resourceGroup1NameSB" --location "$location1"
az group create --subscription "$subscription_id" --name "$resourceGroup2NameSB" --location "$location2"

# Deploy Primary Namespace
az deployment group create --subscription "$subscription_id" --name "ns1" --verbose \
	--resource-group "$resourceGroup1NameSB" --template-file "$templateFileNamespace" --parameters namespaceName="$namespace1Name"

if [ $logAnalyticsResourceGroupName1 ]
then
	echo "Create Diagnostics Setting for Namespace1 to Log Analytics"

	# Get Primary Namespace Resource ID for Diagnostics
	namespace1ResourceId="$(az servicebus namespace show --subscription "$subscription_id" --resource-group "$resourceGroup1NameSB" --name "$namespace1Name" -o tsv --query "id")"

	# Configure Log Analytics Diagnostics for primary namespace
	# Get categories using https://docs.microsoft.com/cli/azure/monitor/diagnostic-settings/categories?view=azure-cli-latest#az_monitor_diagnostic_settings_categories_list
	az monitor diagnostic-settings create --subscription "$subscription_id" --name "$namespace1Name""-diag" --verbose \
		--resource "$namespace1ResourceId" --resource-group "$logAnalyticsResourceGroupName1" --workspace "$logAnalyticsWorkspaceName1" \
		--logs '[
			{
				"category": "OperationalLogs",
				"enabled": true,
				"retentionPolicy": {
					"enabled": false,
					"days": 0
				}
			}
		]' \
		--metrics '[
			{
				"category": "AllMetrics",
				"enabled": true,
				"retentionPolicy": {
					"enabled": false,
					"days": 0
				}
			}
		]'
fi

# Deploy Primary Namespace Access Policy
az deployment group create --subscription "$subscription_id" --name "ns1sas" --verbose \
	--resource-group "$resourceGroup1NameSB" --template-file "$templateFileNamespaceSasPolicy" --parameters namespaceName="$namespace1Name"

# Deploy Secondary Namespace
# No entities on this namespace as they will come over with replication
az deployment group create --subscription "$subscription_id" --name "ns2" --verbose \
	--resource-group "$resourceGroup2NameSB" --template-file "$templateFileNamespace" --parameters namespaceName="$namespace2Name"

if [ $logAnalyticsResourceGroupName2 ]
then
	echo "Create Diagnostics Setting for Namespace2 to Log Analytics"

	# Get Secondary Namespace Resource ID for Diagnostics
	namespace2ResourceId="$(az servicebus namespace show --subscription "$subscription_id" --resource-group "$resourceGroup2NameSB" --name "$namespace2Name" -o tsv --query "id")"

	# Configure Log Analytics Diagnostics for secondary namespace
	az monitor diagnostic-settings create --subscription "$subscription_id" --name "$namespace2Name""-diag" --verbose \
		--resource "$namespace2ResourceId" --resource-group "$logAnalyticsResourceGroupName2" --workspace "$logAnalyticsWorkspaceName2" \
		--logs '[
			{
				"category": "OperationalLogs",
				"enabled": true,
				"retentionPolicy": {
					"enabled": false,
					"days": 0
				}
			}
		]' \
		--metrics '[
			{
				"category": "AllMetrics",
				"enabled": true,
				"retentionPolicy": {
					"enabled": false,
					"days": 0
				}
			}
		]'
fi


# Set up Geo-Replication
az deployment group create --subscription "$subscription_id" --name "georep" --verbose \
	--resource-group "$resourceGroup1NameSB" --template-file "$templateFileGeoReplication" --parameters \
	namespaceName="$namespace1Name" pairedNamespaceName="$namespace2Name" pairedNamespaceResourceGroup="$resourceGroup2NameSB" aliasName="$aliasName"


# Enable Private Endpoints, Private Zones
# Create region 1
az deployment group create --subscription "$subscription_id" --name "pz1" --verbose \
	--resource-group "$resourceGroup1NameSB" --template-file "$templateFilePrivateZone" \
	--parameters privateDnsZoneName="$privateDnsZoneName"

# Create region 2
az deployment group create --subscription "$subscription_id" --name "pz2" --verbose \
	--resource-group "$resourceGroup2NameSB" --template-file "$templateFilePrivateZone" \
	--parameters privateDnsZoneName="$privateDnsZoneName"

# Endpoint in region 2 pointing to Namespace 2
az deployment group create --subscription "$subscription_id" --name "epr2ns2" --verbose \
	--resource-group "$resourceGroup2NameSB" --template-file "$templateFilePrivateLink" --parameters \
	namespaceName="$namespace2Name" \
	privateEndpointName="$privateEndpointNameR2NS2" \
	privateDnsZoneName="$privateDnsZoneName" \
	vnetName="$spokeVnetName" \
	subnetName="$workloadSubnetName" \
	networkResourceGroup="$resourceGroup2NameNet" \
	namespaceResourceGroup="$resourceGroup2NameSB" \
	primary=false

# Endpoint in region 2 pointing to Namespace 1
az deployment group create --subscription "$subscription_id" --name "epr2ns1" --verbose \
	--resource-group "$resourceGroup2NameSB" --template-file "$templateFilePrivateLink" --parameters \
	namespaceName="$namespace1Name" \
	privateEndpointName="$privateEndpointNameR2NS1" \
	privateDnsZoneName="$privateDnsZoneName" \
	vnetName="$spokeVnetName" \
	subnetName="$workloadSubnetName" \
	networkResourceGroup="$resourceGroup2NameNet" \
	namespaceResourceGroup="$resourceGroup1NameSB" \
	primary=false

# Endpoint in region 1 pointing to Namespace 1
az deployment group create --subscription "$subscription_id" --name "epr1ns1" --verbose \
	--resource-group "$resourceGroup1NameSB" --template-file "$templateFilePrivateLink" --parameters \
	namespaceName="$namespace1Name" \
	privateEndpointName="$privateEndpointNameR1NS1" \
	privateDnsZoneName="$privateDnsZoneName" \
	vnetName="$spokeVnetName" \
	subnetName="$workloadSubnetName" \
	networkResourceGroup="$resourceGroup1NameNet" \
	namespaceResourceGroup="$resourceGroup1NameSB" \
	primary=true

# Endpoint in region 1 pointing to Namespace 2
az deployment group create --subscription "$subscription_id" --name "epr1ns2" --verbose \
	--resource-group "$resourceGroup1NameSB" --template-file "$templateFilePrivateLink" --parameters \
	namespaceName="$namespace2Name" \
	privateEndpointName="$privateEndpointNameR1NS2" \
	privateDnsZoneName="$privateDnsZoneName" \
	vnetName="$spokeVnetName" \
	subnetName="$workloadSubnetName" \
	networkResourceGroup="$resourceGroup1NameNet"  \
	namespaceResourceGroup="$resourceGroup2NameSB" \
	primary=true

# Link Zones to VNets
az deployment group create --subscription "$subscription_id" --name "zv1" --verbose \
	--resource-group "$resourceGroup1NameSB" --template-file "$templateFileZoneLink" --parameters \
	privateDnsZoneName="$privateDnsZoneName" \
	vnetName="$spokeVnetName" \
	networkResourceGroup=$resourceGroup1NameNet

az deployment group create --subscription "$subscription_id" --name "zv2" --verbose \
	--resource-group "$resourceGroup2NameSB" --template-file "$templateFileZoneLink" --parameters \
	privateDnsZoneName="$privateDnsZoneName" \
	vnetName="$spokeVnetName" \
	networkResourceGroup="$resourceGroup2NameNet"



# Create Queue
az deployment group create --subscription "$subscription_id" --name "ns1q" --verbose \
	--resource-group "$resourceGroup1NameSB" --template-file "$templateFileQueue" --parameters namespaceName="$namespace1Name"

# Create Topic
az deployment group create --subscription "$subscription_id" --name "ns1t" --verbose \
	--resource-group "$resourceGroup1NameSB" --template-file "$templateFileTopic" --parameters namespaceName="$namespace1Name"

# Create Topic Subscription
az deployment group create --subscription "$subscription_id" --name "ns1ts" --verbose \
	--resource-group "$resourceGroup1NameSB" --template-file "$templateFileTopicSubscription" --parameters namespaceName="$namespace1Name"
