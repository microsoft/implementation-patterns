#!/bin/bash

# Params
subscription_id=""

log_analytics_resource_group_name=""
log_analytics_workspace_name=""

resource_group_name=""
resource_name=""

storage_acct_name="pztestlasaeus" # Leave blank to not configure VM and boot diagnostics

# Get Resource ID for Diagnostics
resource_id="$(az vm show --subscription "$subscription_id" -g "$resource_group_name" -n "$resource_name"  -o tsv --query "id")"

# Configure Log Analytics Diagnostics
# Get categories using https://docs.microsoft.com/cli/azure/monitor/diagnostic-settings/categories?view=azure-cli-latest#az_monitor_diagnostic_settings_categories_list
az monitor diagnostic-settings create --subscription "$subscription_id" --name "$resource_name""-diag" --verbose \
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
az monitor diagnostic-settings show --name "$resource_name""-diag" --resource "$resource_id"

if [ $storage_acct_name ]
then
	# Configure Boot Diagnostics
	az vm boot-diagnostics enable --verbose --ids "$resource_id" --storage "https://""$storage_acct_name"".blob.core.windows.net"

	# Configure VM diagnostics - see https://docs.microsoft.com/cli/azure/vm/diagnostics?view=azure-cli-latest#az_vm_diagnostics_set
	# For troubleshooting, see https://aka.ms/VMExtensionLinuxDiagnosticsTroubleshoot (pay attention to all)

	default_config="$(az vm diagnostics get-default-config | sed "s#__DIAGNOSTIC_STORAGE_ACCOUNT__#""$storage_acct_name""#g" | sed "s#__VM_OR_VMSS_RESOURCE_ID__#""$resource_id""#g")"
	storage_sastoken="$(az storage account generate-sas --account-name ""$storage_acct_name"" --expiry 2037-12-31T23:59:00Z --permissions wlacu --resource-types co --services bt -o tsv)"
	protected_settings="{'storageAccountName': '""$storage_acct_name""', 'storageAccountSasToken': '""$storage_sastoken""'}"

	az vm diagnostics set --verbose --ids "$resource_id" --no-auto-upgrade $false --settings "$default_config" --protected-settings "$protected_settings"
fi
