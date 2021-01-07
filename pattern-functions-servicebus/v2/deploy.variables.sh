#!/bin/bash

# ==================================================
# ==================================================
# CONFIGURE VARIABLES IN THIS BLOCK AT MINIMUM OR YOUR DEPLOYMENT ===WILL=== FAIL
# ALL OTHER BLOCKS/VARIABLES CAN BE LEFT AT DEFAULTS (BUT REVIEW/CHANGE AS NEEDED ANYWAY)

# Deployment
subscriptionId="PROVIDE"
location1="eastus2"
location2="centralus"
# Network
nsgRuleInbound100Src="PROVIDE" # Inbound allow for debugging - likely remove in production
# VM
# These are Windows VMs to run Azure Service Bus Explorer, Azure Storage Explorer, and Browser tests
# Use Windows-acceptable username and password values
adminUsername="PROVIDE"
adminPassword="PROVIDE"
# ==================================================
# ==================================================

# ==================================================
# Deployment - set to false to not deploy that set of resources; see deploy.main. for use.
deployResourceGroups="true"
deployNetwork="true"
deployServiceBus="true"
deployWorkloads="true"
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
rgNameNetworkLocation1="$businessUnit""-""$environment""-""$productLine""-""$location1""-network"
rgNameNetworkLocation2="$businessUnit""-""$environment""-""$productLine""-""$location2""-network"

# Shared resources, e.g. ASB NS
rgNameSharedLocation1="$businessUnit""-""$environment""-""$productLine""-""$location1""-shared"
rgNameSharedLocation2="$businessUnit""-""$environment""-""$productLine""-""$location2""-shared"

# Specific workloads, e.g. Azure Functions, and their associated specific resources, e.g. Private Endpoints
rgNameWorkloadLocation1="$businessUnit""-""$environment""-""$applicationId""-""$location1""-workload"
rgNameWorkloadLocation2="$businessUnit""-""$environment""-""$applicationId""-""$location2""-workload"

# Test Assets - VMs
rgNameVmLocation1="$businessUnit""-""$environment""-""$applicationId""-""$location1""-vm"
rgNameVmLocation2="$businessUnit""-""$environment""-""$applicationId""-""$location2""-vm"
# ==================================================

# ==================================================
# NSGs
nsgNameLocation1="$businessUnit""-""$environment""-""$productLine""-""$location1""-nsg"
nsgNameLocation2="$businessUnit""-""$environment""-""$productLine""-""$location2""-nsg"
# ==================================================

# ==================================================
# Networking
deployFirewall="true"

subnetNameShared="$businessUnit""-""$environment""-shared-sbt"
subnetNameWorkload="$businessUnit""-""$environment""-""$productId""-sbt"
subnetDelegationServiceNameWorkload="Microsoft.Web/serverFarms"
subnetNameWorkloadVnetIntegration="$businessUnit""-""$environment""-""$productId""-vnet-int-sbt"

vnetNameLocation1="$businessUnit""-""$environment""-""$productLine""-""$location1""-vnet"
vnetPrefixLocation1="10.11.0.0/16"
subnetPrefixFirewallLocation1="10.11.1.0/24"
subnetPrefixSharedLocation1="10.11.10.0/24"
subnetPrefixWorkloadLocation1="10.11.20.0/24"
subnetPrefixWorkloadVnetIntegrationLocation1="10.11.21.0/28"

vnetNameLocation2="$businessUnit""-""$environment""-""$productLine""-""$location2""-vnet"
vnetPrefixLocation2="10.12.0.0/16"
subnetPrefixFirewallLocation2="10.12.1.0/24"
subnetPrefixSharedLocation2="10.12.10.0/24"
subnetPrefixWorkloadLocation2="10.12.20.0/24"
subnetPrefixWorkloadVnetIntegrationLocation2="10.12.21.0/28"

firewallSku="AZFW_VNet"
firewallTier="Standard"
firewallThreatIntelMode="Alert"
firewallNameLocation1="$businessUnit""-""$environment""-""$location1""-fw"
firewallNameLocation2="$businessUnit""-""$environment""-""$location2""-fw"
firewallPublicIpLocation1="$firewallNameLocation1""-pip"
firewallPublicIpLocation2="$firewallNameLocation2""-pip"

subnetIdWorkloadLocation1="/subscriptions/""$subscriptionId""/resourceGroups/""$rgNameNetworkLocation1""/providers/Microsoft.Network/virtualNetworks/""$vnetNameLocation1""/subnets/""$subnetNameWorkload"
subnetIdWorkloadLocation2="/subscriptions/""$subscriptionId""/resourceGroups/""$rgNameNetworkLocation2""/providers/Microsoft.Network/virtualNetworks/""$vnetNameLocation2""/subnets/""$subnetNameWorkload"
subnetIdWorkloadVnetIntegrationLocation1="/subscriptions/""$subscriptionId""/resourceGroups/""$rgNameNetworkLocation1""/providers/Microsoft.Network/virtualNetworks/""$vnetNameLocation1""/subnets/""$subnetNameWorkloadVnetIntegration"
subnetIdWorkloadVnetIntegrationLocation2="/subscriptions/""$subscriptionId""/resourceGroups/""$rgNameNetworkLocation2""/providers/Microsoft.Network/virtualNetworks/""$vnetNameLocation2""/subnets/""$subnetNameWorkloadVnetIntegration"
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

asbNamespaceNameLocation1="$applicationId""-""$employeeId""-""$location1""-service-bus"
asbPrivateEndpointNameLocation1="$businessUnit""-""$environment""-asb-pe-""$location1"

asbNamespaceNameLocation2="$applicationId""-""$employeeId""-""$location2""-service-bus"
asbPrivateEndpointNameLocation2="$businessUnit""-""$environment""-asb-pe-""$location2"
# ==================================================

# ==================================================
# Storage
storageAccountPrivateEndpoint="true"

storageAccountResourceType="Microsoft.Storage/storageAccounts"
storageBlobSubResource="blob"
storageFileSubResource="file"
storageBlobPrivateDnsZoneName="privatelink.blob.core.windows.net"
storageFilePrivateDnsZoneName="privatelink.file.core.windows.net"

storageAcctNameLocation1="$businessUnit""$environment""sa""$location1"
storageBlobPrivateEndpointNameLocation1="$businessUnit""-""$environment""-sb-pe-""$location1"
storageFilePrivateEndpointNameLocation1="$businessUnit""-""$environment""-sf-pe-""$location1"

storageAcctNameLocation2="$businessUnit""$environment""sa""$location2"
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

workloadPlanNameLocation1="asp-""$businessUnit""-""$environment""-""$applicationId""-""$location1""-workload"
workloadAppNameLocation1="$applicationId""-""$employeeId""-""$location1""-app"
workloadVnetIntegrationNameLocation1="$workloadAppNameLocation1""/VirtualNetwork"
workloadAppInsightsNameLocation1="$workloadAppNameLocation1""-insights"
workloadPrivateEndpointNameLocation1="$businessUnit""-""$environment""-app-pe-""$location1"

workloadPlanNameLocation2="asp-""$businessUnit""-""$environment""-""$applicationId""-""$location2""-workload"
workloadAppNameLocation2="$applicationId""-""$employeeId""-""$location2""-app"
workloadVnetIntegrationNameLocation2="$workloadAppNameLocation2""/VirtualNetwork"
workloadAppInsightsNameLocation2="$workloadAppNameLocation2""-insights"
workloadPrivateEndpointNameLocation2="$businessUnit""-""$environment""-app-pe-""$location2"
# ==================================================

# ==================================================
# VM
enableAcceleratedNetworking="true" # This is not supported for all VM Sizes - check your VM Size!
provisionVmAgent="true"
enableBootDiagnostics="true"
useVmCustomImage="true"

virtualMachineSize="Standard_D4s_v3"
virtualMachineUsePublicIp="true" #Set to false if you don't want public IPs on VMs - you'll need a bastion/jumpbox to access VMs without public IPs

availabilityZoneLocation1="1"
availabilityZoneLocation2="1"

# If deploying VMs from custom images, set here
virtualMachineImageResourceIdLocation1="/subscriptions/""$subscriptionId""/resourceGroups/shared/providers/Microsoft.Compute/images/wi-dev-image-eastus2"
virtualMachineImageResourceIdLocation2="/subscriptions/""$subscriptionId""/resourceGroups/shared/providers/Microsoft.Compute/images/wi-dev-image-centralus"

virtualMachinePublisher="MicrosoftWindowsServer"
virtualMachineOffer="WindowsServer"
virtualMachineLicenseType="Windows_Server"
virtualMachineSku="2019-datacenter-smalldisk-g2"

virtualMachineVersion="latest"
osDiskStorageType="Premium_LRS"
osDiskSizeInGB=127
dataDiskStorageType="Premium_LRS"
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

bootDiagnosticsStorageAccountNameLocation1="$businessUnit""$environment""dl1"
bootDiagnosticsStorageAccountNameLocation2="$businessUnit""$environment""dl2"
# ==================================================

# ==================================================
# Public IPs
publicIpType="Static" # Static or Dynamic - Standard SKU requires Static
publicIpSku="Standard" # Basic or Standard

virtualMachinePublicIpLocation1="$virtualMachineNameLocation1""-pip"
virtualMachinePublicIpLocation2="$virtualMachineNameLocation2""-pip"
# ==================================================

# ==================================================
# Network Interfaces
privateIpAllocationMethod="Dynamic"
ipConfigName="ipConfig1"

networkInterfaceNameLocation1="$virtualMachineNameLocation1""-nic"
networkInterfaceNameLocation2="$virtualMachineNameLocation2""-nic"
# ==================================================

# ==================================================
# Templates
templateNsg="./arm/arm.net.nsg.json"
templateNetwork="./arm/arm.net.vnet.json"
templatePrivateEndpoint="./arm/arm.net.private-endpoint.json"
templateVnetPeering="./arm/arm.net.vnet-peering.json"
templatePrivateDnsZone="./arm/arm.net.private-dns-zone.json"
templatePrivateDnsZoneVnetLink="./arm/arm.net.private-dns-zone-vnet-link.json"

templateFirewall="./arm/arm.net.firewall.json"

templateStorageAccount="./arm/arm.storage.account.json"
templateStorageAccountVnetRuleForFunction="./arm/arm.storage.account.vnet-rule.function.json"
templateStorageAccountVnetRuleForVmBootDiagnostics="./arm/arm.storage.account.vnet-rule.vm-boot-diagnostics.json"

templateAsb="./arm/arm.asb.namespace.json"
templateAsbSasPolicy="./arm/arm.asb.saspolicy.json"
templateAsbNetRules="./arm/arm.asb.net-rules.json"
templateAsbVnetRule="./arm/arm.asb.vnet-rule.json"
templateAsbQueue="./arm/arm.asb.queue.json"
templateAsbTopic="./arm/arm.asb.topic.json"
templateAsbSubscription="./arm/arm.asb.subscription.json"

templateWorkload="./arm/arm.function.json"
templateWorkloadVnetIntegration="./arm/arm.function.vnet-integration.json"

templatePublicIp="./arm/arm.net.public-ip.json"
templatePublicIpWithAz="./arm/arm.net.public-ip-az.json"

templateNetworkInterfaceWithPublicIp="./arm/arm.net.network-interface-public-ip.json"
templateNetworkInterfaceWithoutPublicIp="./arm/arm.net.network-interface.json"

if $useVmCustomImage
then
	templateVirtualMachine="./arm/arm.vm.windows.custom-image.json"
else
	templateVirtualMachine="./arm/arm.vm.windows.json"
fi

templateVirtualMachineBootDiagnostics="./arm/arm.vm.boot-diagnostics.json"
# ==================================================