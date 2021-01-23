#!/bin/bash

# ==================================================
# ==================================================
# CONFIGURE VARIABLES IN THIS BLOCK AT MINIMUM OR YOUR DEPLOYMENT ===WILL=== FAIL
# ALL OTHER BLOCKS/VARIABLES CAN BE LEFT AT DEFAULTS (BUT REVIEW/CHANGE AS NEEDED ANYWAY)

# Deployment
subscriptionId="e61e4c75-268b-4c94-ad48-237aa3231481"
location1="eastus2"
location2="centralus"
# Network
nsgRuleInbound100Src="75.68.47.183" # Inbound allow for debugging - likely remove in production
# VM
# These are Windows VMs to run Azure Service Bus Explorer, Azure Storage Explorer, and Browser tests
# Use Windows-acceptable username and password values
adminUsername="pelazem"
adminPassword="W00hoo@@2020"
# ==================================================
# ==================================================

# ==================================================
# Deployment - set to false to not deploy that set of resources; see deploy.main. for use.
deployResourceGroups="true"
deployNetwork="false"
deployServiceBus="false"
deployWorkloads="false"
deployVms="true"
# ==================================================

# ==================================================
# Business/Naming
applicationId="a1"
productId="p1"
productLine="pl1"
employeeId="e1"
businessUnit="bu1"
environment="dev"
organization="o1"
timestamp="$(date +%FT%T%z)"
# ==================================================

# ==================================================
# Resource Groups
# Network resources
rgNameNetworkGlobal="$businessUnit""-""$environment""-global-network"

rgNameNetworkHubLocation1="$businessUnit""-""$environment""-""$location1""-net-hub"
rgNameNetworkSpoke1Location1="$businessUnit""-""$environment""-""$productLine""-""$location1""-net-spoke"

rgNameNetworkHubLocation2="$businessUnit""-""$environment""-""$location2""-net-hub"
rgNameNetworkSpoke1Location2="$businessUnit""-""$environment""-""$productLine""-""$location2""-net-spoke"

# Shared resources, e.g. ASB NS
rgNameSharedLocation1="$businessUnit""-""$environment""-""$productLine""-""$location1""-shared"
rgNameSharedLocation2="$businessUnit""-""$environment""-""$productLine""-""$location2""-shared"

# Specific workloads, e.g. Azure Functions, and their associated specific resources, e.g. Private Endpoints
rgNameWorkloadLocation1="$businessUnit""-""$environment""-""$applicationId""-""$location1""-workload"
rgNameWorkloadLocation2="$businessUnit""-""$environment""-""$applicationId""-""$location2""-workload"

# Test Assets
rgNameTestLocation1="$businessUnit""-""$environment""-""$applicationId""-""$location1""-test"
rgNameTestLocation2="$businessUnit""-""$environment""-""$applicationId""-""$location2""-test"
# ==================================================

# ==================================================
# NSGs
nsgNameLocation1="$businessUnit""-""$environment""-""$productLine""-""$location1""-nsg"
nsgNameLocation2="$businessUnit""-""$environment""-""$productLine""-""$location2""-nsg"
# ==================================================

# ==================================================
# Networking

# Hub
vnetHubEnableDdos="true"
vnetHubEnableVmProtection="false"
deployFirewall="true"

vnetNameHubLocation1="$businessUnit""-""$environment""-""$productLine""-""$location1""-vnet-hub"
vnetNameHubLocation2="$businessUnit""-""$environment""-""$productLine""-""$location2""-vnet-hub"

vnetPrefixHubLocation1="10.1.0.0/16"
vnetPrefixHubLocation2="10.101.0.0/16"

subnetNameFirewall="AzureFirewallSubnet"
subnetPrefixFirewallLocation1="10.1.1.0/24"
subnetPrefixFirewallLocation2="10.101.1.0/24"

firewallSku="AZFW_VNet"
firewallTier="Standard"
firewallThreatIntelMode="Alert"
firewallNameLocation1="$businessUnit""-""$environment""-""$location1""-fw"
firewallNameLocation2="$businessUnit""-""$environment""-""$location2""-fw"
firewallPublicIpLocation1="$firewallNameLocation1""-pip"
firewallPublicIpLocation2="$firewallNameLocation2""-pip"
# Firewall Public IPs
firewallPublicIpType="Static" # Static or Dynamic - Standard SKU requires Static
firewallPublicIpSku="Standard" # Basic or Standard

# Spoke
vnetSpoke1EnableDdos="true"
vnetSpoke1EnableVmProtection="true"

subnetNameShared="$businessUnit""-""$environment""-shared-sbt"
subnetNameWorkload="$businessUnit""-""$environment""-""$productId""-sbt"
subnetDelegationServiceNameWorkload="Microsoft.Web/serverFarms"
subnetNameWorkloadVnetIntegration="$businessUnit""-""$environment""-""$productId""-vnet-int-sbt"
subnetNameTest="$businessUnit""-""$environment""-test-sbt"

subnetServiceEndpointsShared="Microsoft.EventHub, Microsoft.KeyVault, Microsoft.ServiceBus, Microsoft.Storage"
subnetServiceEndpointsWorkload="Microsoft.AzureCosmosDB, Microsoft.CognitiveServices, Microsoft.ContainerRegistry, Microsoft.EventHub, Microsoft.KeyVault, Microsoft.ServiceBus, Microsoft.Sql, Microsoft.Storage, Microsoft.Web"
subnetDelegationServiceWorkload="Microsoft.Web/serverFarms"
subnetServiceEndpointsTest="Microsoft.AzureCosmosDB, Microsoft.CognitiveServices, Microsoft.ContainerRegistry, Microsoft.EventHub, Microsoft.KeyVault, Microsoft.ServiceBus, Microsoft.Sql, Microsoft.Storage, Microsoft.Web"

vnetNameSpoke1Location1="$businessUnit""-""$environment""-""$productLine""-""$location1""-vnet-spoke"
vnetPrefixSpoke1Location1="10.11.0.0/16"
subnetPrefixSharedLocation1="10.11.1.0/24"
subnetPrefixWorkloadLocation1="10.11.10.0/24"
subnetPrefixWorkloadVnetIntegrationLocation1="10.11.11.0/28"
subnetPrefixTestLocation1="10.11.254.0/24"

vnetNameSpoke1Location2="$businessUnit""-""$environment""-""$productLine""-""$location2""-vnet-spoke"
vnetPrefixSpoke1Location2="10.111.0.0/16"
subnetPrefixSharedLocation2="10.111.1.0/24"
subnetPrefixWorkloadLocation2="10.111.10.0/24"
subnetPrefixWorkloadVnetIntegrationLocation2="10.111.11.0/28"
subnetPrefixTestLocation2="10.111.254.0/24"

subnetIdWorkloadLocation1="/subscriptions/""$subscriptionId""/resourceGroups/""$rgNameNetworkSpoke1Location1""/providers/Microsoft.Network/virtualNetworks/""$vnetNameLocation1""/subnets/""$subnetNameWorkload"
subnetIdWorkloadLocation2="/subscriptions/""$subscriptionId""/resourceGroups/""$rgNameNetworkSpoke1Location2""/providers/Microsoft.Network/virtualNetworks/""$vnetNameLocation2""/subnets/""$subnetNameWorkload"
subnetIdWorkloadVnetIntegrationLocation1="/subscriptions/""$subscriptionId""/resourceGroups/""$rgNameNetworkSpoke1Location1""/providers/Microsoft.Network/virtualNetworks/""$vnetNameLocation1""/subnets/""$subnetNameWorkloadVnetIntegration"
subnetIdWorkloadVnetIntegrationLocation2="/subscriptions/""$subscriptionId""/resourceGroups/""$rgNameNetworkSpoke1Location2""/providers/Microsoft.Network/virtualNetworks/""$vnetNameLocation2""/subnets/""$subnetNameWorkloadVnetIntegration"
# ==================================================

# ==================================================
# Azure Service Bus
asbZoneRedundant="true"
asbAllowTrustedServices="true"
asbVnetAccessRules="true"
asbPrivateEndpoint="true"

asbResourceType="Microsoft.ServiceBus/namespaces"
asbSubResource="namespace"
asbSendListenSasPolicyName="SendListen"
asbDefaultAction="Deny"
asbPrivateDnsZoneName="privatelink.servicebus.windows.net"
asbMessagingUnits=1

asbQueueName="q1"
asbTopicName="t1"
asbSubscriptionName="$asbTopicName""s1"

asbNamespaceNameLocation1="$applicationId""-""$employeeId""-""$location1""-asb"
asbPrivateEndpointNameLocation1="$businessUnit""-""$environment""-asb-pe-""$location1"

asbNamespaceNameLocation2="$applicationId""-""$employeeId""-""$location2""-asb"
asbPrivateEndpointNameLocation2="$businessUnit""-""$environment""-asb-pe-""$location2"
# ==================================================

# ==================================================
# Workload - Storage
storageAccountPrivateEndpoint="true"

storageAccountResourceType="Microsoft.Storage/storageAccounts"
storageBlobSubResource="blob"
storageFileSubResource="file"
storageBlobPrivateDnsZoneName="privatelink.blob.core.windows.net"
storageFilePrivateDnsZoneName="privatelink.file.core.windows.net"

storageAcctNameLocation1="$businessUnit""$environment""$applicationId""l1"
storageBlobPrivateEndpointNameLocation1="$businessUnit""-""$environment""-sb-pe-""$location1"
storageFilePrivateEndpointNameLocation1="$businessUnit""-""$environment""-sf-pe-""$location1"

storageAcctNameLocation2="$businessUnit""$environment""$applicationId""l2"
storageBlobPrivateEndpointNameLocation2="$businessUnit""-""$environment""-sb-pe-""$location2"
storageFilePrivateEndpointNameLocation2="$businessUnit""-""$environment""-sf-pe-""$location2"
# ==================================================

# ==================================================
# Workload - Function
workloadVnetIntegration="true"
workloadPrivateEndpoint="true"

workloadResourceType="Microsoft.Web/sites"
workloadSubResource="sites"
workloadHostingPlanSkuTier="PremiumV2"
workloadHostingPlanSkuName="P1v2"
workloadWorkerSize="3"
workloadWorkerSizeId="3"
workloadWorkerCount="1"
workloadAlwaysOn="true"
workloadRuntimeStack="dotnet"
workloadRuntimeVersion="3.1"
workloadRouteAllTrafficThroughVnet="1"
workloadPrivateDnsZoneName="privatelink.azurewebsites.net"

workloadPlanNameLocation1="$businessUnit""-""$environment""-""$applicationId""-""$location1""-asp"
workloadAppNameLocation1="$applicationId""-""$employeeId""-""$location1""-app"
workloadVnetIntegrationNameLocation1="$workloadAppNameLocation1""/VirtualNetwork"
workloadAppInsightsNameLocation1="$workloadAppNameLocation1""-insights"
workloadPrivateEndpointNameLocation1="$businessUnit""-""$environment""-""$location1""-app-pe"

workloadPlanNameLocation2="$businessUnit""-""$environment""-""$applicationId""-""$location2""-asp"
workloadAppNameLocation2="$applicationId""-""$employeeId""-""$location2""-app"
workloadVnetIntegrationNameLocation2="$workloadAppNameLocation2""/VirtualNetwork"
workloadAppInsightsNameLocation2="$workloadAppNameLocation2""-insights"
workloadPrivateEndpointNameLocation2="$businessUnit""-""$environment""-""$location2""-app-pe"
# ==================================================

# ==================================================
# VM
enableAcceleratedNetworking="true" # This is not supported for all VM Sizes - check your VM Size!
provisionVmAgent="true"
enableBootDiagnostics="true"

virtualMachineSize="Standard_D4s_v3"
virtualMachineUsePublicIp="true" #Set to false if you don't want public IPs on VMs - you'll need a bastion/jumpbox to access VMs without public IPs

availabilityZoneLocation1="1"
availabilityZoneLocation2="1"

# If deploying VMs from custom images, set here
virtualMachineImageResourceIdLocation1="/subscriptions/""$subscriptionId""/resourceGroups/shared/providers/Microsoft.Compute/images/wi-dev-image-eastus2"
virtualMachineImageResourceIdLocation2="/subscriptions/""$subscriptionId""/resourceGroups/shared/providers/Microsoft.Compute/images/wi-dev-image-centralus"
# Otherwise set these. The ARM template for VMs will use custom image resource ID over these, if the custom image is specified.
virtualMachinePublisher="MicrosoftWindowsServer"
virtualMachineOffer="WindowsServer"
virtualMachineLicenseType="Windows_Server"
virtualMachineSku="2019-datacenter-smalldisk-g2"

virtualMachineVersion="latest"
osDiskStorageType="Premium_LRS" # Accepted values: Premium_LRS, StandardSSD_LRS, Standard_LRS, UltraSSD_LRS
osDiskSizeInGB=32
dataDiskStorageType="Premium_LRS" # Accepted values: Premium_LRS, StandardSSD_LRS, Standard_LRS, UltraSSD_LRS
dataDiskCount=0
dataDiskSizeInGB=32
vmAutoShutdownTime="1800"
enableAutoShutdownNotification="Disabled"
autoShutdownNotificationWebhookURL="" # Provide if set enableAutoShutdownNotification="Enabled"
autoShutdownNotificationMinutesBefore=15

# Windows VM names are limited to 16 characters
virtualMachineNamePrefix="$businessUnit""$environment""$applicationId"
virtualMachineNameSuffix="01"
virtualMachineNameLocation1="$virtualMachineNamePrefix""l1""$virtualMachineNameSuffix"
virtualMachineNameLocation2="$virtualMachineNamePrefix""l2""$virtualMachineNameSuffix"
virtualMachineTimeZoneLocation1="Eastern Standard Time"
virtualMachineTimeZoneLocation2="Central Standard Time"

bootDiagnosticsStorageAccountNameLocation1="$virtualMachineNamePrefix""dl1"
bootDiagnosticsStorageAccountNameLocation2="$virtualMachineNamePrefix""dl2"
# ==================================================

# ==================================================
# VM Public IPs
virtualMachinePublicIpType="Static" # Static or Dynamic - Standard SKU requires Static
virtualMachinePublicIpSku="Standard" # Basic or Standard

virtualMachinePublicIpLocation1="$virtualMachineNameLocation1""-pip"
virtualMachinePublicIpLocation2="$virtualMachineNameLocation2""-pip"
# ==================================================

# ==================================================
# VM Network Interfaces
privateIpAllocationMethod="Dynamic"
ipConfigName="ipConfig1"

virtualMachineNetworkInterfaceNameLocation1="$virtualMachineNameLocation1""-nic"
virtualMachineNetworkInterfaceNameLocation2="$virtualMachineNameLocation2""-nic"
# ==================================================

# ==================================================
# Templates
templateNsg="./template/net.nsg.json"
templateVnet="./template/net.vnet.json"
templateSubnet="./template/net.vnet.subnet.json"
templatePrivateEndpoint="./template/net.private-endpoint.json"
templateVnetPeering="./template/net.vnet-peering.json"
templatePrivateDnsZone="./template/net.private-dns-zone.json"
templatePrivateDnsZoneVnetLink="./template/net.private-dns-zone-vnet-link.json"

templateFirewall="./template/net.firewall.json"

templateStorageAccount="./template/storage.account.json"
templateStorageAccountVnetRuleForFunction="./template/storage.account.vnet-rule.function.json"
templateStorageAccountVnetRuleForVmBootDiagnostics="./template/storage.account.vnet-rule.vm-boot-diagnostics.json"

templateAsb="./template/asb.namespace.json"
templateAsbSasPolicy="./template/asb.saspolicy.json"
templateAsbNetRules="./template/asb.net-rules.json"
templateAsbVnetRule="./template/asb.vnet-rule.json"
templateAsbQueue="./template/asb.queue.json"
templateAsbTopic="./template/asb.topic.json"
templateAsbSubscription="./template/asb.subscription.json"

templateWorkload="./template/function.json"
templateWorkloadVnetConnection="./template/function.vnet-connection.json"

templatePublicIp="./template/net.public-ip.json"
templateNetworkInterface="./template/net.network-interface.json"

templateVirtualMachine="./template/vm.windows.json"
templateVirtualMachineBootDiagnostics="./template/vm.boot-diagnostics.json"
# ==================================================
