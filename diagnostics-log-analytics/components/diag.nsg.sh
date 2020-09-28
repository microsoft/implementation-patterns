#!/bin/bash

# Params
subscription_id=""

log_analytics_resource_group_name=""
log_analytics_workspace_name=""

resource_group_name=""
resource_name=""

flow_log_location=""
flow_log_storage_acct_name="" # Leave blank if don't want NSG flow logging to be configured

# Get Resource ID for Diagnostics
resource_id="$(az network nsg show --subscription "$subscription_id" -g "$resource_group_name" -n "$resource_name"  -o tsv --query "id")"

# Get categories using https://docs.microsoft.com/cli/azure/monitor/diagnostic-settings/categories?view=azure-cli-latest#az_monitor_diagnostic_settings_categories_list
# az monitor diagnostic-settings categories list --subscription "$subscription_id" --resource $resource_id

# Configure Log Analytics Diagnostics
az monitor diagnostic-settings create --subscription "$subscription_id" --name "$resource_name""-diag" --verbose \
	--resource "$resource_id" --resource-group "$log_analytics_resource_group_name" --workspace "$log_analytics_workspace_name" \
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

if [ $flow_log_storage_acct_name ]
then
	# Configure NSG flow logging - note: limit of 1 per subscription and region. If you already have NSG flow logger in sub/region, then use az network watcher flow-log configure instead.
	az network watcher flow-log create --subscription "$subscription_id" --location "$flow_log_location" --name "$resource_name""-flowlog" --verbose \
		--enabled true --traffic-analytics true --nsg "$resource_id" --interval 10 --log-version 2 --retention 0 \
		--storage-account "$flow_log_storage_acct_name" --resource-group "$resource_group_name" --workspace "$log_analytics_workspace_name"
fi

echo "Verify diagnostic setting"
az monitor diagnostic-settings show --name "$resource_name""-diag" --resource "$resource_id"
