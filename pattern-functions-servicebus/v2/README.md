# Producer / Consumer Pattern Using Azure Service Bus and Azure Functions  

## TOC

- [Pre-Requisites](Pre-Requisites)
- [Architecture](Architecture)
  - [Motivation and Goals](Motivation-and-Goals)
  - [Azure Regions and Resource Groups](Azure-Regions-and-Resource-Groups)
  - [Network](Network)
- [Getting Started](Getting-Started)
  - [Preparing to Test](Preparing-to-Test)
  - [Custom VM Images](Custom-VM-Images)
- [Network Security Tests](Network-Security-Tests)
- [Deployment Assets](Deployment-Assets)
  - [Preparation for Production](Preparation-for-Production)

## Pre-Requisites

To work with and deploy this pattern, you will need the following.

- Azure Subscription with sufficient permission to deploy Resource Groups and Resources.
  - This pattern does not use Managed Identities or Service Principals, so you do not need permission to create or modify directory objects.
- Bash shell with latest Azure CLI installed
  - You can use the [Azure Cloud Shell](https://docs.microsoft.com/azure/cloud-shell/overview) in the [Azure Portal](https://docs.microsoft.com/azure/azure-portal/). The Cloud Shell has the Azure CLI and many other tools already installed. You will just need to upload the scripts and ARM template files from this pattern into the Cloud Shell to get started.
  - If you use a local Bash shell, you can install the [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli).
- Your favorite editor for shell scripts and ARM template files. [Visual Studio Code](https://code.visualstudio.com) is free and excellent!

[top ->](#TOC)

## Architecture

This pattern has some similarities to [v1](../v1). Please review the README there for foundational understanding.

### Motivation and Goals

The motivation for this pattern is to deploy a set of inter-related resources, including a secured network, shared resources such as Azure Service Bus Namespaces, and individual workloads such as Azure Functions which use the shared resources.

The pattern's goal is to show how to implement network security for each resource type, so that resources are not publicly addressable or accessible but are fully capable of inter-operating. This is accomplished using Azure Private Link and Private Endpoints, Virtual Networks with Network Security Groups, and per-resource network access restrictions.

Azure Private DNS is used so that resources _within_ the network environment resolve each other using private FQDNs and IP addresses, so that all traffic between components stays on the Azure backbone and uses Private Link connections.

Other resources _outside_ the network environment (such as workloads on premise or outside of the VNets in this pattern) will still resolve deployed components by their public FQDNs - i.e. split-horizon DNS. Actual connectivity will be secured as described above.

Azure Service Bus (ASB) Namespaces are deployed to each Azure region. Unlike v1 of this pattern, ASB geo-DR is NOT used in this pattern, as it does not enable message replication. Instead, the ASB Namespaces are left independent, though deployed with similar configuration and initial messaging entities, to enable externally controlled active/active or active/passive messaging patterns.

### Azure Regions and Resource Groups

This pattern splits components into distinct, purpose-oriented Resource Groups (RGs). This supports modular deployments, where network, shared, and workload components may not be deployed at the same time, or may re-use previously deployed components, or may be completed by different people with different levels of Azure permissions.

One RG for global network resources is deployed (regardless of how many Azure Regions are deployed to). Additionally, Resource Groups are deployed into _each_ Azure Region for the following components: Network, Shared (such as Azure Service Bus), Workload (such as Azure Functions), and Testing (such as VMs to work with resources that have network access restrictions).

![Azure Regions and Resource Groups](assets/Architecture-RegionsRGs.png)

### Network

For simplicity, this pattern focuses on deployment of the actual workload and shared resources. One Azure Virtual Network (VNet) is deployed in each Azure Region. The regional VNets are peered to each other.

A full, per-region hub-and-spoke architecture is not deployed in this pattern, as v1 explores that and adding hub VNets to this pattern is an additive exercise.

Each VNet contains Subnets for the following purposes: shared resources such as Azure Service Bus Namespaces; workload resources and Private Endpoint Network Interfaces; and Azure Function VNet integration.

This pattern supports designating a distinct Network Security Group (NSG) for each Subnet. For simplicity, the same NSG is used for each Subnet but this is easily adjusted in [deploy.network.sh](./deploy.network.sh).

Additionally, Subnets are configured as follows:

- Service Endpoints are configured to allow connectivity from resources _in_ the subnet _to_ the Service Endpoint's resource type outside the subnet
- Private Links are configured to allow connectivity _to_ Private Endpoints deployed for protected resources
- Network Interfaces are deployed to provide connectivity for Private Endpoints
- Service Delegation is configured for the Workload Integration subnet, to allow the delegated-to service to deploy other components as needed.

The VNets are Peered, so that resources in one VNet can resolve resources in the other VNet and can connect to resources in the other VNet, as allowed by network access restrictions.

Each VNet is also linked to a set of Private DNS Zones, which are globally-deployed resources. This permits resolution of resources protected by Private Endpoints by their internal FQDNs and private IP addresses. Recall that these DNS Zones will only be used by resources in the VNet, since this pattern includes VNet-DNS Zone link deployment, whereas DNS clients outside of these VNets will use public Azure DNS resolution (split-horizon DNS).

This diagram shows the logical network design with Azure services used in each VNet/subnet, as well as globally:

![Azure Network Services](assets/Architecture-Network-Services.png)

This diagram shows connection flow between Azure services within each VNet, between the peered VNets, and also shows workloads outside the VNets failing to connect to services within each VNet, as intended.

![Azure Network Flow](assets/Architecture-Network-Flow.png)

[top ->](#TOC)

## Getting Started

To start working with this pattern, download the files in this folder and its sub-folders, or fork/clone this repository.

First, edit [deploy.variables.sh](./deploy.variables.sh). This shell script defines many variables used by the actual deployment scripts. Each of the other deploy.*.sh scripts calls this script in the same shell, so that variables are set once but can be used in each component script:

```bash
. ./deploy.variables.sh
```

Minimally, edit the first section of deploy.variables.sh, and provide real values for those variables (such as `subscriptionId`) currently stubbed out with a value of `"PROVIDE"`. If you make no other changes, you can deploy all resources now by running [deploy.main.sh](./deploy.main.sh).

In deploy.main.sh, note the use of boolean variables set in deploy.variables.sh to conditionally run each component of the deployment. For example, network resources are only deployed if the variable in question is set to true:

```bash
if $deployNetwork
then
    ./deploy.network.sh
fi
```

### Preparing to Test

If you decide to reproduce the network security tests listed below, you will need test environments outside of the deployed VNets to test that access is correctly denied, and test environments inside the VNets to test that access is correctly granted.

`deploy.main.sh` includes a section to conditionally deploy a set of VMs within the VNet for testing:

```bash
if $deployVms
then
  ./deploy.vms.sh
fi
```

Set `$deployVms="true"` in `deploy.variables.sh` to deploy one VM into each VNet.

Set `nsgRuleInbound100Src="(your source IP)"` in `deploy.variables.sh`. This will configure the deployed Network Security Group (NSG) to allow you to access the deployed environment from outside the VNets, including connecting to the VMs to install and use test tools.

The following tools are highly recommended to test connecting to and managing Azure resources:

- [Azure Storage Explorer](https://storageexplorer.com): Connect to and manage Azure Storage accounts and resources
- [Azure Service Bus Explorer](https://github.com/paolosalvatori/ServiceBusExplorer): Connect to, manage, and send/receive messages on Service Bus Namespaces and resources (queues, topics, subscriptions)

### Custom VM Images

For repeated deployments, it may be useful to install and configure required software on the deployed VMs, then generalize each VM and capture a VM image to Azure so that new VMs will be deployed with the required software already installed. This deployment contains support for deploying from such images.

To deploy VMs for testing from custom images, modify `deploy.variables.sh` as follows.

Find the following section and supplement the image resource IDs with your specific information:

```bash
# If deploying VMs from custom images, set here and also pick the correct VM template below (vm.windows.custom-image or vm.windows)
virtualMachineImageResourceIdLocation1="/subscriptions/""$subscriptionId""/resourceGroups/PROVIDE"
virtualMachineImageResourceIdLocation2="/subscriptions/""$subscriptionId""/resourceGroups/PROVIDE"
```

Then find the following section:

```bash
templateVirtualMachine="./arm/arm.vm.windows.json"
# templateVirtualMachine="./arm/arm.vm.windows.custom-image.json"
```

Note that both lines set the same variable. The default is to use the bare Windows VM template provided; if you have custom images, comment the first line and uncomment the second line, as follows:

```bash
# templateVirtualMachine="./arm/arm.vm.windows.json"
templateVirtualMachine="./arm/arm.vm.windows.custom-image.json"
```

References
[Create a managed image of a generalized VM in Azure](https://docs.microsoft.com/azure/virtual-machines/windows/capture-image-resource)
[Create a VM from a managed image](https://docs.microsoft.com/azure/virtual-machines/windows/create-vm-generalized-managed)

[top ->](#TOC)

## Network Security Tests

The following tests capture typical network security requirements and were carried out to validate the network security of this deployment.

Test | Tool | Expected Result | Actual Result = Expected? | Notes
---- | ---- | --------------- | :-----------------------: | -----
Access Workload Storage Account in Region 1 from Outside VNets | Azure Storage Explorer | Deny List or Access Blobs, File Shares | Yes | Workload Storage Accounts have Private Endpoint AND VNet Access Restrictions
Access Workload Storage Account in Region 2 from Outside VNets | Azure Storage Explorer | Deny List or Access Blobs, File Shares | Yes | Workload Storage Accounts have Private Endpoint AND VNet Access Restrictions
Access Workload Storage Account in Region 1 from VNet in Region 1 | Azure Storage Explorer on VM in Region 1 | Allow List or Access Blobs, File Shares | Yes | Workload Storage Accounts configured for VNet access and Private Endpoint, which allows peered VNet access
Access Workload Storage Account in Region 2 from VNet in Region 1 | Azure Storage Explorer on VM in Region 1 | Allow List or Access Blobs, File Shares | Yes | Workload Storage Accounts configured for VNet access and Private Endpoint, which allows peered VNet access
Access Workload Storage Account in Region 1 from VNet in Region 2 | Azure Storage Explorer on VM in Region 2 | Allow List or Access Blobs, File Shares | Yes | Workload Storage Accounts configured for VNet access and Private Endpoint, which allows peered VNet access
Access Workload Storage Account in Region 2 from VNet in Region 2 | Azure Storage Explorer on VM in Region 2 | Allow List or Access Blobs, File Shares | Yes | Workload Storage Accounts configured for VNet access and Private Endpoint, which allows peered VNet access
Access Service Bus Namespace in Region 1 from Outside VNets | Azure Service Bus Explorer | Deny Access to Namespace and Objects (Queues, Topics, Subscriptions) | Yes | Service Bus Namespaces configured for VNet access restriction and Private Endpoint
Access Service Bus Namespace in Region 2 from Outside VNets | Azure Service Bus Explorer | Deny Access to Namespace and Objects (Queues, Topics, Subscriptions) | Yes | Service Bus Namespaces configured for VNet access restriction and Private Endpoint
Access Service Bus Namespace in Region 1 from VNet in Region 1 | Azure Service Bus Explorer on VM in Region 1 | Allow Access to Namespace and Objects, including Object Management and Counts | Yes | Service Bus Namespaces configured for VNet access restriction and Private Endpoint, which allows peered VNet access
Access Service Bus Namespace in Region 2 from VNet in Region 1 | Azure Service Bus Explorer on VM in Region 1 | Allow Access to Namespace and Objects, including Object Management and Counts | Yes | Service Bus Namespaces configured for VNet access restriction and Private Endpoint, which allows peered VNet access
Access Service Bus Namespace in Region 1 from VNet in Region 2 | Azure Service Bus Explorer on VM in Region 2 | Allow Access to Namespace and Objects, including Object Management and Counts | Yes | Service Bus Namespaces configured for VNet access restriction and Private Endpoint, which allows peered VNet access
Access Service Bus Namespace in Region 2 from VNet in Region 2 | Azure Service Bus Explorer on VM in Region 2 | Allow Access to Namespace and Objects, including Object Management and Counts | Yes | Service Bus Namespaces configured for VNet access restriction and Private Endpoint, which allows peered VNet access
Access Workload Advanced Tools (Function App / Kudu) in Region 1 from Outside VNets | Browser to Azure Portal, Function App, Advanced Tools | Deny Access with Error 403 | Yes | Workload Function Apps configured for VNet access restriction and Private Endpoint, with same configuration applied to Function App Advanced Tools (Kudu)
Access Workload Advanced Tools (Function App / Kudu) in Region 2 from Outside VNets | Browser to Azure Portal, Function App, Advanced Tools | Deny Access with Error 403 | Yes | Workload Function Apps configured for VNet access restriction and Private Endpoint, with same configuration applied to Function App Advanced Tools (Kudu)
Access Workload Advanced Tools (Function App / Kudu) in Region 1 from VNet in Region 1 | Browser to Azure Portal, Function App, Advanced Tools on VM in Region 1 | Allow Access | Yes | Workload Function Apps configured for VNet access restriction and Private Endpoint, which allows peered VNet access, with same configuration applied to Function App Advanced Tools (Kudu)
Access Workload Advanced Tools (Function App / Kudu) in Region 2 from VNet in Region 1 | Browser to Azure Portal, Function App, Advanced Tools on VM in Region 1 | Allow Access | Yes | Workload Function Apps configured for VNet access restriction and Private Endpoint, which allows peered VNet access, with same configuration applied to Function App Advanced Tools (Kudu)
Access Workload Advanced Tools (Function App / Kudu) in Region 1 from VNet in Region 2 | Browser to Azure Portal, Function App, Advanced Tools on VM in Region 2 | Allow Access | Yes | Workload Function Apps configured for VNet access restriction and Private Endpoint, which allows peered VNet access, with same configuration applied to Function App Advanced Tools (Kudu)
Access Workload Advanced Tools (Function App / Kudu) in Region 2 from VNet in Region 2 | Browser to Azure Portal, Function App, Advanced Tools on VM in Region 2 | Allow Access | Yes | Workload Function Apps configured for VNet access restriction and Private Endpoint, which allows peered VNet access, with same configuration applied to Function App Advanced Tools (Kudu)
Create Function in Region 1 from Outside VNets in Azure Portal | Browser to Azure Portal, Function App | Allow | Yes | Resource management is allowed, though resource access is not due to network restrictions
Create Function in Region 2 from Outside VNets in Azure Portal | Browser to Azure Portal, Function App | Allow | Yes | Resource management is allowed, though resource access is not due to network restrictions
Create Function in Region 1 from VNet in Region 1 in Azure Portal | Browser to Azure Portal, Function App on VM in Region 1 | Allow | Yes | Resource management is allowed
Create Function in Region 2 from VNet in Region 1 in Azure Portal | Browser to Azure Portal, Function App on VM in Region 1 | Allow | Yes | Resource management is allowed
Create Function in Region 1 from VNet in Region 2 in Azure Portal | Browser to Azure Portal, Function App on VM in Region 2 | Allow | Yes | Resource management is allowed
Create Function in Region 2 from VNet in Region 2 in Azure Portal | Browser to Azure Portal, Function App on VM in Region 2 | Allow | Yes | Resource management is allowed
Invoke HTTP Trigger Workload Function in Region 1 from Outside VNets | Browser to Function URL | Deny Access with Error 403 | Yes | Resource management is allowed, though resource access is not due to network restrictions
Invoke HTTP Trigger Workload Function in Region 1 from Outside VNets | Browser to Function URL | Deny Access with Error 403 | Yes | Resource management is allowed, though resource access is not due to network restrictions
Access Workload Function Log in Region 1 from Outside VNets in Azure Portal | Browser to Azure Portal, Function App, Function Log | Deny Access | Yes | Resource access not allowed due to network restrictions
Access Workload Function Log in Region 2 from Outside VNets in Azure Portal | Browser to Azure Portal, Function App, Function Log | Deny Access | Yes | Resource access not allowed due to network restrictions
Access Workload Function Log in Region 1 from VNet in Region 1 in Azure Portal | Browser to Azure Portal, Function App, Function Log on VM in Region 1 | Allow Access | Yes | Workload Function Apps configured for VNet access restriction and Private Endpoint, which allows peered VNet access
Access Workload Function Log in Region 2 from VNet in Region 1 in Azure Portal | Browser to Azure Portal, Function App, Function Log on VM in Region 1 | Allow Access | Yes | Workload Function Apps configured for VNet access restriction and Private Endpoint, which allows peered VNet access
Access Workload Function Log in Region 1 from VNet in Region 2 in Azure Portal | Browser to Azure Portal, Function App, Function Log on VM in Region 2 | Allow Access | Yes | Workload Function Apps configured for VNet access restriction and Private Endpoint, which allows peered VNet access
Access Workload Function Log in Region 2 from VNet in Region 2 in Azure Portal | Browser to Azure Portal, Function App, Function Log on VM in Region 2 | Allow Access | Yes | Workload Function Apps configured for VNet access restriction and Private Endpoint, which allows peered VNet access
Workload Function in Region 1 triggered by Queue in Service Bus in Region 1 | Azure Service Bus Explorer on VM in Region 1 to send messages and monitor counts. Browser on VM in Region 1 to monitor Function Log. | Function in Region 1 triggered when message sent to ASB Queue in Region 1 | Yes | Region 1 Service Bus Namespace VNet access rules include allowing Region 1 Workload integration subnet access.
Workload Function in Region 1 triggered by Topic/Subscription in Service Bus in Region 1 | Azure Service Bus Explorer on VM in Region 1 to send messages and monitor counts. Browser on VM in Region 1 to monitor Function Log. | Function in Region 1 triggered when message sent to ASB Topic in Region 1 | Yes | Region 1 Service Bus Namespace VNet access rules include allowing Region 1 Workload integration subnet access.
Workload Function in Region 1 triggered by Queue in Service Bus in Region 2 | Azure Service Bus Explorer on VM in Region 2 to send messages and monitor counts. Browser on VM in Region 1 to monitor Function Log. | Function in Region 1 triggered when message sent to ASB Queue in Region 2 | Yes | Region 2 Service Bus Namespace VNet access rules include allowing Region 1 Workload integration subnet access.
Workload Function in Region 1 triggered by Topic/Subscription in Service Bus in Region 2 | Azure Service Bus Explorer on VM in Region 2 to send messages and monitor counts. Browser on VM in Region 1 to monitor Function Log. | Function in Region 1 triggered when message sent to ASB Topic in Region 2 | Yes | Region 2 Service Bus Namespace VNet access rules include allowing Region 1 Workload integration subnet access.
Workload Function in Region 2 triggered by Queue in Service Bus in Region 1 | Azure Service Bus Explorer on VM in Region 1 to send messages and monitor counts. Browser on VM in Region 2 to monitor Function Log. | Function in Region 2 triggered when message sent to ASB Queue in Region 1 | Yes | Region 1 Service Bus Namespace VNet access rules include allowing Region 2 Workload integration subnet access.
Workload Function in Region 2 triggered by Topic/Subscription in Service Bus in Region 1 | Azure Service Bus Explorer on VM in Region 1 to send messages and monitor counts. Browser on VM in Region 2 to monitor Function Log. | Function in Region 2 triggered when message sent to ASB Topic in Region 1 | Yes | Region 1 Service Bus Namespace VNet access rules include allowing Region 2 Workload integration subnet access.
Workload Function in Region 2 triggered by Queue in Service Bus in Region 2 | Azure Service Bus Explorer on VM in Region 2 to send messages and monitor counts. Browser on VM in Region 2 to monitor Function Log. | Function in Region 2 triggered when message sent to ASB Queue in Region 2 | Yes | Region 2 Service Bus Namespace VNet access rules include allowing Region 2 Workload integration subnet access.
Workload Function in Region 2 triggered by Topic/Subscription in Service Bus in Region 2 | Azure Service Bus Explorer on VM in Region 2 to send messages and monitor counts. Browser on VM in Region 2 to monitor Function Log. | Function in Region 2 triggered when message sent to ASB Topic in Region 2 | Yes | Region 2 Service Bus Namespace VNet access rules include allowing Region 2 Workload integration subnet access.
Trigger Function in Region 1 without VNet Integration when Message Sent to ASB Queue in Region 1  | Azure Service Bus Explorer on VM in Region 1 to send messages and monitor counts. Browser on VM in Region 1 to monitor Function Log. | Function that is not VNet-integrated is NOT triggered when message sent to ASB Queue. | Yes | Region 1 Service Bus Namespace VNet access rules only allow Queue or Topic access from clients in VNet, and deny access to all others. Functions that are not VNet-integrated will be denied access.
Trigger Function in Region 1 without VNet Integration when Message Sent to ASB Topic in Region 1  | Azure Service Bus Explorer on VM in Region 1 to send messages and monitor counts. Browser on VM in Region 1 to monitor Function Log. | Function that is not VNet-integrated is NOT triggered when message sent to ASB Topic. | Yes | Region 1 Service Bus Namespace VNet access rules only allow Queue or Topic access from clients in VNet, and deny access to all others. Functions that are not VNet-integrated will be denied access.
Trigger Function in Region 2 without VNet Integration when Message Sent to ASB Queue in Region 2 | Azure Service Bus Explorer on VM in Region 2 to send messages and monitor counts. Browser on VM in Region 2 to monitor Function Log. | Function that is not VNet-integrated is NOT triggered when message sent to ASB Queue. | Yes | Region 2 Service Bus Namespace VNet access rules only allow Queue or Topic access from clients in VNet, and deny access to all others. Functions that are not VNet-integrated will be denied access.
Trigger Function in Region 2 without VNet Integration when Message Sent to ASB Topic in Region 2 | Azure Service Bus Explorer on VM in Region 2 to send messages and monitor counts. Browser on VM in Region 2 to monitor Function Log. | Function that is not VNet-integrated is NOT triggered when message sent to ASB Topic. | Yes | Region 2 Service Bus Namespace VNet access rules only allow Queue or Topic access from clients in VNet, and deny access to all others. Functions that are not VNet-integrated will be denied access.

## Deployment Assets

This pattern uses the following deployment technologies and assets:

- Bash shell scripts: these can be run in any bash shell, including [WSL2 on Windows 10](https://docs.microsoft.com/windows/wsl/about) and [Azure Cloud Shell](https://docs.microsoft.com/azure/cloud-shell/overview).
- [Azure Resource Manager (ARM) Templates](https://docs.microsoft.com/azure/templates/). 
- [Azure Command Line Interface (CLI)](https://docs.microsoft.com/cli/azure/reference-index) commands. Azure Resource Groups are created directly using CLI command [`az group create`](https://docs.microsoft.com/cli/azure/group#az_group_create). All other Azure resources are created by deploying from ARM templates using CLI command [`az deployment group create`](https://docs.microsoft.com/cli/azure/deployment/group#az_deployment_group_create).

The [ARM templates in this deployment](./arm) are highly componentized to permit flexible re-use in different combinations, with a deployment script or other automation controller artifact controlling configuration and order of deployment. That is, each ARM template covers the fewest Azure resources possible, with the design goal being one resource type in one ARM template file.

Alternative approaches could include:

- Composite ARM templates (as emitted, for example, by "Export Template" in the Azure portal).
  - This approach was not used in this pattern as it leads to highly specific templates that are not easily re-used in other environments or with changing requirements, and are not suited to programmatic deployments.
- Nested ARM templates: these "templates of templates" use a parent/child approach to compose deployments from modular child templates. This approach was not used as the parent templates are still highly specific, and programmatic flexibility was desired.
- Conditional deployment: [ARM conditional deployment](https://docs.microsoft.com/azure/azure-resource-manager/templates/conditional-resource-deployment) permits for some deployment customization, but customization at levels "above" and within individual resources was desired, whereas the ARM condition element does not cascade to child resources and is limited to deploy/not deploy, and cannot be used to conditionally control individual resource configuration properties.

The scripted approach used in this pattern does result in potentially longer deployment times than a composite/nested ARM template approach, as strict procedural scripting prevents the ARM deployment controller from decomposing and parallelizing a composite template. This trade-off was accepted for greater programmatic flexibility.

#### Preparation for Production

##### NSG Access Rules

The deployment includes a network access rule on the NSG to allow for inbound (into the VNets/subnets) access for testing purposes. You may decide to remove this for production purposes.

To do so, edit [`arm.net.nsg.json`](./arm/arm.net.nsg.json) and remove the `DevTestInbound` rule with priority 100. You may also need to edit this file to remove (or add) other network access rules required in your environment.

##### VNet / Subnet Configuration

The VNet configuration in [`arm.net.vnet.json`](arm/arm.net.vnet.json) deploys the three subnets described above (Shared, Workload, Workload VNet Integration) and configures a set of Service Endpoints on each subnet. You may need to edit this file to correspond to your subnet and Service Endpoint requirements.
