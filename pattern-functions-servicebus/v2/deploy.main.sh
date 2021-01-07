#!/bin/bash

# ==================================================
# Variables
. ./deploy.variables.sh
# ==================================================

if $deployResourceGroups
then
	./deploy.resource-groups.sh
fi

if $deployNetwork
then
	./deploy.network.sh
fi

if $deployServiceBus
then
	./deploy.asb.sh
fi

if $deployWorkloads
then
	./deploy.workloads.sh
fi

if $deployVms
then
	./deploy.vms.sh
fi
