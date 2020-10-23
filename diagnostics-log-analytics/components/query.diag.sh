#!/bin/bash

# Params
subscription_id=""
location=""
log_analytics_resource_group_name=""
log_analytics_workspace_name=""
resource_id=""

# Variables
workspace_resource_id="$(az monitor log-analytics workspace show --subscription "$subscription_id" -g "$log_analytics_resource_group_name" -n "$log_analytics_workspace_name" -o tsv --query 'id')"

query_text="AzureDiagnostics | where ResourceId == '$resource_id' | order by TimeGenerated desc | limit 1"

echo "Install Azure CLI Log Analytics extension"

az extension add --name log-analytics

echo "Query the workspace"

echo "$workspace_resource_id"
az monitor log-analytics query --workspace "$workspace_resource_id" --analytics-query "$query_text" -t "P3DT12H" --verbose --debug

echo $query_text