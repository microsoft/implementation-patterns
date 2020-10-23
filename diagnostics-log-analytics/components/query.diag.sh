#!/bin/bash

# Params
subscription_id="e61e4c75-268b-4c94-ad48-237aa3231481"
location="eastus"
log_analytics_resource_group_name="sbtest"
log_analytics_workspace_name="pz-la-eastus2"
resource_id="/SUBSCRIPTIONS/E61E4C75-268B-4C94-AD48-237AA3231481/RESOURCEGROUPS/SBTEST/PROVIDERS/MICROSOFT.SERVICEBUS/NAMESPACES/PZ-SB-EASTUS2"

# Variables
workspace_resource_id="$(az monitor log-analytics workspace show --subscription "$subscription_id" -g "$log_analytics_resource_group_name" -n "$log_analytics_workspace_name" -o tsv --query 'id')"

query_text="AzureDiagnostics | where ResourceId == '$resource_id' | order by TimeGenerated desc | limit 1"

echo "Install Azure CLI Log Analytics extension"

az extension add --name log-analytics

echo "Query the workspace"

echo "$workspace_resource_id"
az monitor log-analytics query --workspace "$workspace_resource_id" --analytics-query "$query_text" -t "P3DT12H" --verbose --debug

echo $query_text