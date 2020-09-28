# Diagnostics and Log Analytics

## TOC

- [Getting Started / Prerequisites](Getting-Started)
- [Overview](Overview)

## Getting Started / Prerequisites

- Azure Subscription with appropriate role based access for the components you chose to deploy
- Linux Command Line (Bash)
- Azure CLI

[top ->](#TOC)

## Overview
Monitoring and Diagnostics are critical aspects of a mature platform, not just "in production" but also in any development or test environment.

Azure Monitor [Log Analytics](https://docs.microsoft.com/azure/azure-monitor/log-query/get-started-portal) is the Azure native log sink. This folder contains two sets of artifacts:
1. Deployment [template](components/deploy.log-analytics-workspace.json) and [script](components/deploy.log-analytics-workspace.json) for a Log Analytics Workspace
2. A set of shell scripts to configure Azure resources to send Diagnostics logs and/or metrics to a Log Analytics Workspace

Some of the scripts to configure Azure resources for Log Analytics also configure resource-native diagnostics. For example, the [VM script](./components/diag.vm.sh) also configures VM and boot diagnostics in addition to sending metrics to a Log Analytics Workspace

[top ->](#TOC)
