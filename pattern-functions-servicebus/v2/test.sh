#!/bin/bash

. ./deploy.variables.sh

az deployment group create --subscription "$subscriptionId" -n "FW-PIP-""$location1" --verbose \
	-g "netfu" --template-file "$templatePublicIp" \
	--parameters \
	applicationId="$applicationId" \
	productId="$productId" \
	productLine="$productLine" \
	employeeId="$employeeId" \
	businessUnit="$businessUnit" \
	environment="$environment" \
	organization="$organization" \
	timestamp="$timestamp" \
	location="$location1" \
	publicIpName="pzpip1" \
	publicIpType="$publicIpType" \
	publicIpSku="$publicIpSku" \
	domainNameLabel="pzpip1"
