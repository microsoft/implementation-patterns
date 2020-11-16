#!/bin/bash

# Params
subscription_id=""

log_analytics_resource_group_name=""
log_analytics_workspace_name=""

resource_group_name=""

# Get categories using https://docs.microsoft.com/cli/azure/monitor/diagnostic-settings/categories?view=azure-cli-latest#az_monitor_diagnostic_settings_categories_list
# az monitor diagnostic-settings categories list --subscription "$subscription_id" --resource $resource_id

for resource_id in $(az network public-ip list --subscription ""$subscription_id"" --resource-group ""$resource_group_name"" --query [].id -o tsv)
do
	# Configure Log Analytics Diagnostics
	az monitor diagnostic-settings create --subscription "$subscription_id" --name "pip-diag" --verbose \
		--resource "$resource_id" --resource-group "$log_analytics_resource_group_name" --workspace "$log_analytics_workspace_name" \
		--logs '[
			{
				"category": "DDoSProtectionNotifications",
				"enabled": true,
				"retentionPolicy": {
					"enabled": false,
					"days": 0
				}
			},
			{
				"category": "DDoSMitigationFlowLogs",
				"enabled": true,
				"retentionPolicy": {
					"enabled": false,
					"days": 0
				}
			},
			{
				"category": "DDoSMitigationReports",
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
	az monitor diagnostic-settings show --name "pip-diag" --resource "$resource_id"
done