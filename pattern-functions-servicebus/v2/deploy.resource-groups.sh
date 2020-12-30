#!/bin/bash

# ==================================================
# Variables
. ./deploy.variables.sh
# ==================================================
echo "Create Resource Groups"

if $deployNetwork
then
	# Deploy the RG for global network resources to location1 - could be another region too
	az group create --subscription "$subscriptionId" -n "$rgNameNetworkGlobal" -l "$location1" --verbose

	az group create --subscription "$subscriptionId" -n "$rgNameNetworkLocation1" -l "$location1" --verbose
	az group create --subscription "$subscriptionId" -n "$rgNameNetworkLocation2" -l "$location2" --verbose
fi

if $deployServiceBus
then
	az group create --subscription "$subscriptionId" -n "$rgNameSharedLocation1" -l "$location1" --verbose
	az group create --subscription "$subscriptionId" -n "$rgNameSharedLocation2" -l "$location2" --verbose
fi

if $deployWorkload
then
	az group create --subscription "$subscriptionId" -n "$rgNameWorkloadLocation1" -l "$location1" --verbose
	az group create --subscription "$subscriptionId" -n "$rgNameWorkloadLocation2" -l "$location2" --verbose
fi

if $deployVms
then
	az group create --subscription "$subscriptionId" -n "$rgNameVmLocation1" -l "$location1" --verbose
	az group create --subscription "$subscriptionId" -n "$rgNameVmLocation2" -l "$location2" --verbose
fi

echo -e "\n"
# ==================================================
