#!/bin/bash

# Params
infix=""

subscription_id=""

location1="eastus2"
location2="centralus"

resourceGroup1NameNet="$infix-net-$location1"
resourceGroup2NameNet="$infix-net-$location2"

# Log Analytics RG - can be per region or only one
logAnalyticsResourceGroupName1="sbtest" # Leave blank if you don't want LA diagnostics. Should already exist - not created here
logAnalyticsResourceGroupName2="sbtest" # Leave blank if you don't want LA diagnostics. Should already exist - not created here
# Log Analytics Workspace - for NSG Flow Logging, should be in same region as NSG
logAnalyticsWorkspaceName1="sbp-la-""$location1" # Workspace should already exist - not created here
logAnalyticsWorkspaceName2="sbp-la-""$location2" # Workspace should already exist - not created here
# Storage Account used by NSG Flow Logging - should be in same region as NSG/LA Workspace
flowLogStorageAccountName1="sbopssa""$location1" #Storage account should already exist - not created here
flowLogStorageAccountName2="sbopssa""$location2" #Storage account should already exist - not created here

templateFileVnet="azuredeploy-vnet.json"


# Create first set of network resources

echo "Create first set of network resources"

hubVnetName="hub-vnet"
hubVnetPrefix="10.0.0.0/16"
hubVnetFirewallSubnetName="AzureFirewallSubnet"
hubVnetFirewallSubnetPrefix="10.0.1.0/24"
hubVnetDnsSubnetName="DNSSubnet"
hubVnetDnsSubnetPrefix="10.0.2.0/24"
spokeVnetName="spoke-vnet"
spokeVnetPrefix="10.1.0.0/16"
spokeVnetWorkloadSubnetName="workload-subnet"
spokeVnetWorkloadSubnetPrefix="10.1.2.0/24"
spokeVnetWorkloadNSGName="workload-nsg"

az group create --subscription "$subscription_id" --name "$resourceGroup1NameNet" --location "$location1"

az deployment group create --subscription "$subscription_id" --resource-group "$resourceGroup1NameNet" \
	--name "base-network-""$location1" --template-file "$templateFileVnet" --verbose --parameters \
	hubVnetName="$hubVnetName" hubVnetPrefix="$hubVnetPrefix" \
	firewallSubnetName="$hubVnetFirewallSubnetName" firewallSubnetPrefix="$hubVnetFirewallSubnetPrefix" \
	dnsSubnetName="$hubVnetDnsSubnetName" dnsSubnetPrefix="$hubVnetDnsSubnetPrefix" \
	spokeVnetName="$spokeVnetName" spokeVnetPrefix="$spokeVnetPrefix" \
	workloadSubnetName="$spokeVnetWorkloadSubnetName" workloadSubnetPrefix="$spokeVnetWorkloadSubnetPrefix" \
	workloadNsgName="$spokeVnetWorkloadNSGName"

if [ $logAnalyticsResourceGroupName1 ]
then
	echo "Create Diagnostics Settings for Network Resources 1"

	# Get Resource IDs for Diagnostics
	hubVnetResourceId="$(az network vnet show --subscription "$subscription_id" --resource-group "$resourceGroup1NameNet" --name "$hubVnetName"  -o tsv --query "id")"
	spokeVnetResourceId="$(az network vnet show --subscription "$subscription_id" --resource-group "$resourceGroup1NameNet" --name "$spokeVnetName"  -o tsv --query "id")"
	workloadNsgResourceId="$(az network nsg show --subscription "$subscription_id" --resource-group "$resourceGroup1NameNet" --name "$spokeVnetWorkloadNSGName"  -o tsv --query "id")"

	# Configure Log Analytics Diagnostics for hub VNet
	# Get categories using https://docs.microsoft.com/cli/azure/monitor/diagnostic-settings/categories?view=azure-cli-latest#az_monitor_diagnostic_settings_categories_list
	az monitor diagnostic-settings create --subscription "$subscription_id" --name "$hubVnetName""-diag" --verbose \
		--resource "$hubVnetResourceId" --resource-group "$logAnalyticsResourceGroupName1" --workspace "$logAnalyticsWorkspaceName1" \
		--logs '[
			{
				"category": "VMProtectionAlerts",
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

	# Configure Log Analytics Diagnostics for spoke VNet
	az monitor diagnostic-settings create --subscription "$subscription_id" --name "$spokeVnetName""-diag" --verbose \
		--resource "$spokeVnetResourceId" --resource-group "$logAnalyticsResourceGroupName1" --workspace "$logAnalyticsWorkspaceName1" \
		--logs '[
			{
				"category": "VMProtectionAlerts",
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

	# Configure Log Analytics Diagnostics for workload NSG
	az monitor diagnostic-settings create --subscription "$subscription_id" --name "$spokeVnetWorkloadNSGName""-diag" --verbose \
		--resource "$workloadNsgResourceId" --resource-group "$logAnalyticsResourceGroupName1" --workspace "$logAnalyticsWorkspaceName1" \
		--logs '[
			{
				"category": "NetworkSecurityGroupEvent",
				"enabled": true,
				"retentionPolicy": {
					"enabled": false,
					"days": 0
				}
			},
			{
				"category": "NetworkSecurityGroupRuleCounter",
				"enabled": true,
				"retentionPolicy": {
					"enabled": false,
					"days": 0
				}
			}
		]'

	# Configure NSG flow logging - note: limit of 1 per subscription and region. If you already have NSG flow logger in sub/region, then use az network watcher flow-log configure instead.
	az network watcher flow-log create --subscription "$subscription_id" --location "$location1" --name "$spokeVnetWorkloadNSGName""-flowlog" --verbose \
		--enabled true --traffic-analytics true --nsg "$workloadNsgResourceId" --interval 10 --log-version 2 --retention 0 \
		--storage-account "$flowLogStorageAccountName1" --resource-group "$logAnalyticsResourceGroupName1" --workspace "$logAnalyticsWorkspaceName1"
fi



# Create second set of network resources
echo "Create second set of network resources"

hubVnetName="hub-vnet"
hubVnetPrefix="10.2.0.0/16"
hubVnetFirewallSubnetName="AzureFirewallSubnet"
hubVnetFirewallSubnetPrefix="10.2.1.0/24"
hubVnetDnsSubnetName="DNSSubnet"
hubVnetDnsSubnetPrefix="10.2.2.0/24"
spokeVnetName="spoke-vnet"
spokeVnetPrefix="10.3.0.0/16"
spokeVnetWorkloadSubnetName="workload-subnet"
spokeVnetWorkloadSubnetPrefix="10.3.2.0/24"
spokeVnetWorkloadNSGName="workload-nsg"

az group create --subscription "$subscription_id" --name "$resourceGroup2NameNet" --location "$location2"

az deployment group create --subscription "$subscription_id" --resource-group "$resourceGroup2NameNet" \
	--name "base-network-""$location2" --template-file "$templateFileVnet" --verbose --parameters \
	hubVnetName="$hubVnetName" hubVnetPrefix="$hubVnetPrefix" \
	firewallSubnetName="$hubVnetFirewallSubnetName" firewallSubnetPrefix="$hubVnetFirewallSubnetPrefix" \
	dnsSubnetName="$hubVnetDnsSubnetName" dnsSubnetPrefix="$hubVnetDnsSubnetPrefix" \
	spokeVnetName="$spokeVnetName" spokeVnetPrefix="$spokeVnetPrefix" \
	workloadSubnetName="$spokeVnetWorkloadSubnetName" workloadSubnetPrefix="$spokeVnetWorkloadSubnetPrefix" \
	workloadNsgName="$spokeVnetWorkloadNSGName"

if [ $logAnalyticsResourceGroupName2 ]
then
	echo "Create Diagnostics Settings for Network Resources 2"

	# Get Resource IDs for Diagnostics
	hubVnetResourceId="$(az network vnet show --subscription "$subscription_id" --resource-group "$resourceGroup2NameNet" --name "$hubVnetName"  -o tsv --query "id")"
	spokeVnetResourceId="$(az network vnet show --subscription "$subscription_id" --resource-group "$resourceGroup2NameNet" --name "$spokeVnetName"  -o tsv --query "id")"
	workloadNsgResourceId="$(az network nsg show --subscription "$subscription_id" --resource-group "$resourceGroup2NameNet" --name "$spokeVnetWorkloadNSGName"  -o tsv --query "id")"

	# Configure Log Analytics Diagnostics for hub VNet
	# Get categories using https://docs.microsoft.com/cli/azure/monitor/diagnostic-settings/categories?view=azure-cli-latest#az_monitor_diagnostic_settings_categories_list
	az monitor diagnostic-settings create --subscription "$subscription_id" --name "$hubVnetName""-diag" --verbose \
		--resource "$hubVnetResourceId" --resource-group "$logAnalyticsResourceGroupName2" --workspace "$logAnalyticsWorkspaceName2" \
		--logs '[
			{
				"category": "VMProtectionAlerts",
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

	# Configure Log Analytics Diagnostics for spoke VNet
	az monitor diagnostic-settings create --subscription "$subscription_id" --name "$spokeVnetName""-diag" --verbose \
		--resource "$spokeVnetResourceId" --resource-group "$logAnalyticsResourceGroupName2" --workspace "$logAnalyticsWorkspaceName2" \
		--logs '[
			{
				"category": "VMProtectionAlerts",
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

	# Configure Log Analytics Diagnostics for workload NSG
	az monitor diagnostic-settings create --subscription "$subscription_id" --name "$spokeVnetWorkloadNSGName""-diag" --verbose \
		--resource "$workloadNsgResourceId" --resource-group "$logAnalyticsResourceGroupName2" --workspace "$logAnalyticsWorkspaceName2" \
		--logs '[
			{
				"category": "NetworkSecurityGroupEvent",
				"enabled": true,
				"retentionPolicy": {
					"enabled": false,
					"days": 0
				}
			},
			{
				"category": "NetworkSecurityGroupRuleCounter",
				"enabled": true,
				"retentionPolicy": {
					"enabled": false,
					"days": 0
				}
			}
		]'

	# Configure NSG flow logging - note: limit of 1 per subscription and region. If you already have NSG flow logger in sub/region, then use az network watcher flow-log configure instead.
	az network watcher flow-log create --subscription "$subscription_id" --location "$location2" --name "$spokeVnetWorkloadNSGName""-flowlog" --verbose \
		--enabled true --traffic-analytics true --nsg "$workloadNsgResourceId" --interval 10 --log-version 2 --retention 0 \
		--storage-account "$flowLogStorageAccountName2" --resource-group "$logAnalyticsResourceGroupName2" --workspace "$logAnalyticsWorkspaceName2"
fi