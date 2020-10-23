#!/bin/bash

# Params
subscription_id=""
location=""

log_analytics_resource_group_name=""
log_analytics_workspace_name=""

# Get LA resource ID, needed for az monitor command
log_analytics_resource_id="$(az monitor log-analytics workspace show --subscription "$subscription_id" -g "$log_analytics_resource_group_name" -n "$log_analytics_workspace_name" -o tsv --query "id")"

echo "Create diagnostic setting"
az monitor diagnostic-settings subscription create --subscription "$subscription_id" --location "$location" --verbose \
	--name "sub-diag-eastus2" --workspace "$log_analytics_resource_id" \
	--logs '[
		{
			"category": "Administrative",
			"enabled": true
		},
		{
			"category": "Alert",
			"enabled": true
		},
		{
			"category": "Autoscale",
			"enabled": true
		},
		{
			"category": "Policy",
			"enabled": true
		},
		{
			"category": "Recommendation",
			"enabled": true
		},
		{
			"category": "ResourceHealth",
			"enabled": true
		},
		{
			"category": "Security",
			"enabled": true
		},
		{
			"category": "ServiceHealth",
			"enabled": true
		}
	]'

echo "Verify diagnostic setting"
az monitor diagnostic-settings subscription show --subscription "$subscription_id" --name "sub-diag-""$location"
