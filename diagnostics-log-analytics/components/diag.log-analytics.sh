#!/bin/bash

# Params
subscription_id=""

log_analytics_resource_group_name=""
log_analytics_workspace_name=""

resource_group_name=""
resource_name=""

# Get Resource ID for Diagnostics
resource_id="$(az monitor log-analytics workspace show --subscription "$subscription_id" -g "$resource_group_name" -n "$resource_name" -o tsv --query "id")"

# Get categories using https://docs.microsoft.com/cli/azure/monitor/diagnostic-settings/categories?view=azure-cli-latest#az_monitor_diagnostic_settings_categories_list
# az monitor diagnostic-settings categories list --subscription "$subscription_id" --resource $resource_id

# Configure Log Analytics Diagnostics
az monitor diagnostic-settings create --subscription "$subscription_id" --name "$resource_name""-diag" --verbose \
	--resource "$resource_id" --resource-group "$log_analytics_resource_group_name" --workspace "$log_analytics_workspace_name" \
	--logs '[
		{
			"category": "Audit",
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

echo "Verify diagnostic setting"
az monitor diagnostic-settings show --name "$resource_name""-diag" --resource "$resource_id"
