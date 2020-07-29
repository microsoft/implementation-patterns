#!/bin/bash

# Params
resourceGroup1Name="ServiceBusDem-EastUS2"
resourceGroup2Name="ServiceBusDem-CentralUS"
resourceGroup1Location="eastus2"
resourceGroup2Location="centralus"
namespace1Name="namespace1ksk"
namespace2Name="namespace2ksk"
aliasName="namespacekskalias"
eastNetworkResourceGroupName="Foundation-HubAndSpoke-EastUS2"
centralNetworkResourceGroupName="Foundation-HubAndSpoke-CentralUS"

# Create RGs
az group create --name $resourceGroup1Name --location $resourceGroup1Location
