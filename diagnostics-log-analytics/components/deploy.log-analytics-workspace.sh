#!/bin/bash

# Params
infix="x"

subscription_id=""
location=""
resource_group_name="latest"

workspace_name="$infix""-""$location"
workspace_sku="pergb2018"
workspace_retention_days=90
public_access_ingest="Disabled"
public_access_query="Disabled"

template_file="deploy.log-analytics-workspace.json"

echo "Create resource group"

az group create --subscription "$subscription_id" --name "$resource_group_name" --location "$location"

echo "Create Log Analytics workspace"

az deployment group create --verbose --subscription "$subscription_id" --resource-group "$resource_group_name" \
	--name "$workspace_name" --template-file "$template_file" --parameters \
	location="$location" workspace_name="$workspace_name" workspace_sku="$workspace_sku" \
	workspace_retention_days="$workspace_retention_days" public_access_ingest=$public_access_ingest \
	public_access_query=$public_access_query

echo "Get workspace info"

az monitor log-analytics workspace show --verbose --subscription "$subscription_id" \
	--resource-group "$resource_group_name" --workspace-name "$workspace_name"

echo "Get workspace provisioning status for post-deploy check"

provisioning_state="$(az monitor log-analytics workspace show --subscription "$subscription_id" -g "$resource_group_name" -n "$workspace_name" -o tsv --query 'provisioningState')"

echo $provisioning_state