#!/bin/bash

# When deploying private endpoints, NICs with system-assigned names are generated for each endpoint.
# This script retrieves NICs in the specified resource group and enables diagnostics for each.
# You don't HAVE to have private endpoints; this will work on any resource group with any number of NICs.

# Params
subscription_id=""

log_analytics_resource_group_name=""
log_analytics_workspace_name=""

resource_group_name=""

# Get categories using https://docs.microsoft.com/cli/azure/monitor/diagnostic-settings/categories?view=azure-cli-latest#az_monitor_diagnostic_settings_categories_list
# az monitor diagnostic-settings categories list --subscription "$subscription_id" --resource $resource_id

# Configure Log Analytics Diagnostics for each NIC
for resource_id in $(az network nic list --subscription ""$subscription_id"" --resource-group ""$resource_group_name"" --query [].id -o tsv)
do
	az monitor diagnostic-settings create --subscription "$subscription_id" --name "nic-diag" --verbose \
		--resource "$resource_id" --resource-group "$log_analytics_resource_group_name" --workspace "$log_analytics_workspace_name" \
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
	az monitor diagnostic-settings show --name "nic-diag" --resource "$resource_id"
done
