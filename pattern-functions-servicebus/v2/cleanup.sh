#!/bin/bash

# ==================================================
# Variables
. ./deploy.variables.sh
# ==================================================

az group delete --subscription "$subscriptionId" -n "$rgNameVmLocation1" --yes --verbose
az group delete --subscription "$subscriptionId" -n "$rgNameVmLocation2" --yes --verbose

az group delete --subscription "$subscriptionId" -n "$rgNameWorkloadLocation1" --yes --verbose
az group delete --subscription "$subscriptionId" -n "$rgNameWorkloadLocation2" --yes --verbose

az group delete --subscription "$subscriptionId" -n "$rgNameSharedLocation1" --yes --verbose
az group delete --subscription "$subscriptionId" -n "$rgNameSharedLocation2" --yes --verbose

az group delete --subscription "$subscriptionId" -n "$rgNameNetworkSpoke1Location2" --yes --verbose
az group delete --subscription "$subscriptionId" -n "$rgNameNetworkSpoke1Location1" --yes --verbose

az group delete --subscription "$subscriptionId" -n "$rgNameNetworkHubLocation2" --yes --verbose
az group delete --subscription "$subscriptionId" -n "$rgNameNetworkHubLocation1" --yes --verbose

az group delete --subscription "$subscriptionId" -n "$rgNameNetworkGlobal" --yes --verbose
