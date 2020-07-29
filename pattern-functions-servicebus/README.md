# Producer / Consumer Pattern Using Azure Service Bus and Azure Functions
Many cloud native applications are expected to handle a large number of requests. Rather than process each request synchronously, a common technique is for the application to pass them through a messaging system to another service (a consumer service) that handles them asynchronously. This strategy helps to ensure that the business logic in the application isn't blocked while the requests are being processed. For full details on this pattern see the [following article](https://docs.microsoft.com/en-us/azure/architecture/patterns/competing-consumers).

On Azure, the primary enterprise messaging service is [Azure Service Bus](https://docs.microsoft.com/en-us/azure/service-bus-messaging/service-bus-messaging-overview).

[Azure Functions](https://docs.microsoft.com/en-us/azure/azure-functions/#:~:text=Azure%20Functions%20Documentation.%20Azure%20Functions%20is%20a%20serverless,code%20in%20response%20to%20a%20variety%20of%20events.) offers a convenient compute platform from which to implement a producer consumer pattern with relatively little underlying infrastructure management.

Azure Functions and Service Bus are relatively simple to get up and running in their default configurations. Things get significantly more complex when implementing them in environments with stringent security requirements that dictate more aggressive network perimeter security and segmentation.
  
This document describes key considerations for deploying Azure Functions alongside Service Bus in a fully locked down environment using technologies including regional VNet Integration for functions, private endpoints for Service Bus and a variety of network security controls including Network Security Groups and Azure Firewall.

We've modeled this architecture on an fairly aggressive set of requirements from a performance/scalability, reliability and security perspective. Those requirements will be noted within the document. Your implementation of this pattern may differ depending on your needs.

Similar to other architectures available in the [Azure Architecture Center](https://docs.microsoft.com/en-us/azure/architecture/browse/), this document touches on each pillar defined in the [Microsoft Azure Well-Architected Framework](https://docs.microsoft.com/en-us/azure/architecture/framework).

In addition to defining the architectural pattern we will also provide composable deployment artifacts (ARM templates and Pipelines) to get your started on your journey towards repeatable deployment.  

## TOC
- [Architecture and Composable Deployment Code](#Architecture-and-Composable-Deployment-Code)
	- [Virtual Network Foundation](#Virtual-Network-Foundation)
	- [Azure Service Bus](#Azure-Service-Bus)
	- [Azure Functions](#Azure-Functions)
- [Cost Optimization Considerations](#Cost-Optimization-Considerations)
	- Functions
	- Service Bus
- [Operational Considerations](#Operational-Considerations)
	- Infrastructure Deployment Pipelines
	- Code Deployment Pipelines
	- Monitoring
- [Performance and Scalability Considerations](#Performance-and-Scalability-Considerations)
	- Initial Sizing
	- Ongoing Scale Mangement
- [Reliability Considerations](#Reliability-Considerations)
	- High Availability
	- Disaster Recovery
- [Security Considerations](#Security-Considerations) 
	- Identity and Access Management
	- Network Security
	- Storage, Data and Encryption
	- Governance  

## Architecture and Composable Deployment Code
### Virtual Network Foundation
#### Implementation
![](images/networking-foundation.png)
This guide assumes that you are deploying your solution into a networking environment with the following characteristics:

- [Hub and Spoke](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/hub-spoke-network-topology)  network architecture.   

- The hub VNet (1) is used for hosting shared services like Azure Firewall, DNS forwarding and providing connectivity to on-premises networks. In a real implementation, the hub network would be connected to an on-premises network via ExpressRoute, S2S VPN, etc (2). In our reference examples we'll, exclude this portion of the architecture for simplicity.  

- The spoke network (3) is used for hosting business workloads. In this case we're integrating our Function App to a dedicated subnet ("Integration Subnet") that sits within the spoke network. We'll use a second subnet ("Workload Subnet") for hosting other components of the solution including private endpoints for our Service Bus namespaces, etc.  

- The Hub is peered to Spoke using Azure VNet Peering.  

- In many locked down environments [Forced tunneling](https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-forced-tunneling-rm) is in place. E.G. routes are being published over ExpressRoute via BGP that override the default 0.0.0.0/0 -> Internet system route in all connected Azure subnets. The effect is that there is **no** direct route to the internet from within Azure subnets. Internet destined traffic is sent to the VPN/ER gateway. We can simulate this in a test environment by using restrictive NSGs and Firewall rules to prohibit internet egress. We'll route any internet egress traffic to Azure firewall (4) using a UDR (5) where it can be filtered and audited.  

- Generally, custom DNS is configured on the spoke VNet settings. DNS forwarders in the hub are referenced. These forwarders  provide conditional forwarding to the Azure internal resolver and on premises DNS servers as needed. In this reference implementation we'll deploy a simple BIND forwarder (6) into our hub network that will be configured to forward requests to the Azure internal resolver.   

- We'll deploy an identical configuration across two regions.
#### Deployment
1. Create a resource group for each region's network resources
	```bash
	az group create --location eastus2 --name network-eastus2-rg  

	az group create --location centralus --name network-centralus-rg
	```
2. Deploy the base VNets and Subnets to both regions ([ARM Template](templates/base-network/azuredeploy.json))
	```bash
	az deployment group create --resource-group network-eastus2-rg --name network-eastus2 --template-file ./templates/base-network/azuredeploy.json --parameters hubVnetPrefix="10.0.0.0/16" firewallSubnetPrefix="10.0.1.0/24" DNSSubnetPrefix="10.0.2.0/24" spokeVnetPrefix="10.1.0.0/16" workloadSubnetPrefix="10.1.2.0/24"

	az deployment group create --resource-group network-centralus-rg --name network-centralus --template-file ./templates/base-network/azuredeploy.json --parameters hubVnetPrefix="10.2.0.0/16" firewallSubnetPrefix="10.2.1.0/24" DNSSubnetPrefix="10.2.2.0/24" spokeVnetPrefix="10.3.0.0/16" workloadSubnetPrefix="10.3.2.0/24"
	
	```
3. Deploy and configure Azure Firewall in both regions ([ARM Template](templates/firewall/azuredeploy.json))
	```bash
	az deployment group create --resource-group network-eastus2-rg --name firewall-eastus2 --template-file ./templates/firewall/azuredeploy.json --parameters  networkResourceGroup=network-eastus2-rg vnetName=hub-vnet subnetName=AzureFirewallSubnet
	
	az deployment group create --resource-group network-centralus-rg --name firewall-centralus --template-file ./templates/firewall/azuredeploy.json --parameters networkResourceGroup=network-centralus-rg vnetName=hub-vnet subnetName=AzureFirewallSubnet
	```
4. Deploy BIND DNS forwarders in both regions ([ARM Template](templates/bind-forwarder/azuredeploy.json))
	```bash
	az deployment group create --resource-group network-eastus2-rg --name bind-eastus2 --template-file ./templates/bind-forwarder/azuredeploy.json --parameters adminUsername=$userName sshKeyData=$sshKey vnetName=hub-vnet subnetName=DNSSubnet
	
	az deployment group create --resource-group network-centralus-rg --name bind-centralus --template-file ./templates/bind-forwarder/azuredeploy.json --parameters adminUsername=$userName sshKeyData=$sshKey vnetName=hub-vnet subnetName=DNSSubnet
	```

[top ->](#TOC)    
### Azure Service Bus
#### Requirements
- Predictable / Consistent Performance
- Direct integration to and accessibility from private networks
- No accessibility from public networks
- Cross Region Entity Replication
- No message loss on regional failure
- Ability to fail back and forth between primary and secondary regions on a scheduled basis for DR drills
#### Implementation
![](images/networking-servicebus.png)  
The base-level resource for Azure Service Bus is a Service Bus Namespace. Namespaces contain the entities that we will be working with ( Queues, Topics and Subscriptions ).

When creating a namespace in a single region, there are relatively few decisions you'll need to make. You will need to specify the name, pricing tier, initial scale and redundancy settings, subscription, resource group and location.

In our reference implementation we will be deploying a Premium namespace. This is the tier that is recommended for most production workloads due to it's performance characteristics. In addition, the Premium tier supports VNet integration which allows us to isolate the namespace to a private network. This is key to achieving our overall security objectives.   
  
- We'll create a namespace in both regions. (1)   

- We'll configure geo-redundancy (2) with the EastUS2 namespace being primary and the CentralUS namespace being secondary. This will replicate all entity information between regions (but not messages).

- The namespace will be set up with two private endpoints each. One in the region that the namespace is deployed in (3) and one in the other region (4). This will allow private access from both regions. We will configure access restrictions (per-namespace firewall) on the namespace such that the endpoint will be the only method one can use to connect to the namespace. This effectively takes the namespace off the Internet.    
TODO: Elaborate on this path vs via ER GW.

- A set of private DNS zones (5), requisite A records and VNet links will be created such that queries originating from any VNet that is configured to use our bind forwarders will resolve the namespace name to the IP of the private endpoint and not the public IP. This is done via split horizon DNS. E.G. externally, the namespace URLs will continue to resolve to the public IP's which will be inaccessible due to the access restriction configuration. Internally the same URLs will resolve to the IP of the private endpoint.  
  Normally, we would maintain a single zone per service for private link. Because we need DNS queries for the namespace to resolve to different endpoint IP's depending on where the queries are initiated from we'll use two zones which we can link to different networks in this scenario.
  
- TODO: Add specifics on DNS resolution and network path to private endpoints for both regions from on-premises.
#### Deployment
1. Create resource groups for our reference workload
	```bash
	# for East resources
	az group create --location eastus2 --name refworkload-eastus2-rg  

	# for Central resources
	az group create --location centralus --name refworkload-centralus-rg
	```
2. Create Private DNS Zone for Service Bus ([ARM Template](templates/service-bus/azuredeploy-privatezone.json))
	```bash
	# for East
	az deployment group create --resource-group refworkload-eastus2-rg --name zone-eastus2 --template-file ./templates/service-bus/azuredeploy-privatezone.json --parameters privateDnsZoneName=privatelink.servicebus.windows.net   

	# for Central
	az deployment group create --resource-group refworkload-centralus-rg --name zone-centralus --template-file ./templates/service-bus/azuredeploy-privatezone.json --parameters privateDnsZoneName=privatelink.servicebus.windows.net 
	```
3. Link the Private DNS Zones ([ARM Template](templates/service-bus/azuredeploy-zonelink.json))
	```bash
	# Link the East Zone to the East DNS Network
	az deployment group create --resource-group refworkload-eastus2-rg --name link-east --template-file ./templates/service-bus/azuredeploy-zonelink.json --parameters privateDnsZoneName=privatelink.servicebus.windows.net vnetName=hub-vnet networkResourceGroup=network-eastus2-rg
	
	# Link the Central Zone to the Central DNS Network
	az deployment group create --resource-group refworkload-centralus-rg --name link-east --template-file ./templates/service-bus/azuredeploy-zonelink.json --parameters privateDnsZoneName=privatelink.servicebus.windows.net vnetName=hub-vnet networkResourceGroup=network-centralus-rg
	```
3. Create the Namespaces ([ARM Template](templates/service-bus/azuredeploy-namespace.json))
	```bash
	# East namespace
	az deployment group create --resource-group refworkload-eastus2-rg --name namespace-eastus2 --template-file ./templates/service-bus/azuredeploy-namespace.json --parameters namespaceName=kskrefns1  

	# Central namespace
	az deployment group create --resource-group refworkload-centralus-rg --name namespace-centralus --template-file ./templates/service-bus/azuredeploy-namespace.json --parameters namespaceName=kskrefns2
	```
2. Enable Private Endpoints (two per region)([ARM Template](templates/service-bus/azuredeploy-privatelink.json))
	```bash
	# Central to Central
	az deployment group create --resource-group refworkload-centralus-rg --name plink-centralcentral --template-file ./templates/service-bus/azuredeploy-privatelink.json --parameters namespaceName=kskrefns2 privateEndpointName=centraltocentral privateDnsZoneName=privatelink.servicebus.windows.net vnetName=spoke-vnet subnetName=workload-subnet networkResourceGroup=network-centralus-rg namespaceResourceGroup=refworkload-centralus-rg primary=true  

	# Central to East
	az deployment group create --resource-group refworkload-centralus-rg --name plink-centraleast --template-file ./templates/service-bus/azuredeploy-privatelink.json --parameters namespaceName=kskrefns1 privateEndpointName=centraltoeast privateDnsZoneName=privatelink.servicebus.windows.net vnetName=spoke-vnet subnetName=workload-subnet networkResourceGroup=network-centralus-rg namespaceResourceGroup=refworkload-eastus2-rg primary=true  

	# East to East
	az deployment group create --resource-group refworkload-eastus2-rg --name plink-easteast --template-file ./templates/service-bus/azuredeploy-privatelink.json --parameters namespaceName=kskrefns1 privateEndpointName=easttoeast privateDnsZoneName=privatelink.servicebus.windows.net vnetName=spoke-vnet subnetName=workload-subnet networkResourceGroup=network-eastus2-rg namespaceResourceGroup=refworkload-eastus2-rg primary=true  

	# East to Central
	az deployment group create --resource-group refworkload-eastus2-rg --name plink-eastcentral --template-file ./templates/service-bus/azuredeploy-privatelink.json --parameters namespaceName=kskrefns2 privateEndpointName=easttocentral privateDnsZoneName=privatelink.servicebus.windows.net vnetName=spoke-vnet subnetName=workload-subnet networkResourceGroup=network-eastus2-rg namespaceResourceGroup=refworkload-centralus-rg primary=true
	```

4. Establish Geo-Redundancy ([ARM Template](templates/service-bus/azuredeploy-georeplication.json))
	```bash
	az deployment group create --resource-group refworkload-eastus2-rg --name link-east --template-file ./templates/service-bus/azuredeploy-georeplication.json --parameters namespaceName=kskrefns1 pairedNamespaceResourceGroup=refworkload-centralus-rg pairedNamespaceName=kskrefns2 aliasName=kskrefns
	```
5. Create a test queue and topic in the primary namespace ([ARM Template](templates/service-bus/azuredeploy-queuestopics.json))
	```bash
	 az deployment group create --resource-group refworkload-eastus2-rg --name link-east --template-file ./templates/service-bus/azuredeploy-queuestopics.json --parameters namespaceName=kskrefns1 queueName=queue1 topicName=topic1
	```

[top ->](#TOC) 

### Azure Functions
#### Requirements
- Support for Java (version 8)
- Support for .NET Core C# (version 3.1)
- Ability to run in multiple regions (East US 2 and Central US)
- Connectivity to Azure and on-premises private networks
- Dynamic scaling based on incoming event load / queue depth
#### Implementation
![](images/networking-functions.png)  
- A function app (1) will be deployed into each region for hosting our producer and consumer functions  

- Both function apps (1) will be configured to leverage regional VNet integration (2) to send all egress traffic from all functions into a newly created integration subnet in each region.  

- A UDR (3) will be created and assigned to the integration subnet such that all traffic destined for the internet will be sent through Azure Firewall in the hub VNet. This will allow us to filter and audit all outbound traffic.  

- The Firewall will be configured to allow traffic to public App Insights endpoints to enable built-in monitoring facilitated by the Azure Functions host running in the Function App.

- DNS settings on the Spoke VNet will be configured such that all DNS queries (4) originating from subnets in the VNet will be sent to our custom DNS forwarders.
#### Deploy Infrastructure
1. Deploy and Configure the Integration Subnet for Regional VNet Integration for both regions ([ARM Template](templates/integration-subnet/azuredeploy.json)) - *Requires Network Perms*
	```bash
	az deployment group create --resource-group network-eastus2-rg --name integration-eastus2 --template-file ./templates/integration-subnet/azuredeploy.json --parameters existingVnetName=spoke-vnet integrationSubnetPrefix="10.1.6.0/24"
	
	az deployment group create --resource-group network-centralus-rg --name integration-centralus --template-file ./templates/integration-subnet/azuredeploy.json --parameters existingVnetName=spoke-vnet integrationSubnetPrefix="10.3.6.0/24"
	```
2. Deploy App Service Plans ([ARM Template](templates/functions/azuredeploy-plan.json))
	```bash
	# East
	az deployment group create --resource-group refworkload-eastus2-rg --name appplan-eastus2 --template-file ./templates/functions/azuredeploy-plan.json --parameters planName="kskrefeastus2"
	
	# Central
	az deployment group create --resource-group refworkload-centralus-rg --name appplan-centralus --template-file ./templates/functions/azuredeploy-plan.json --parameters planName="kskrefcentralus"
	```
3. Deploy the Function App Storage Accounts ([ARM Template](templates/functions/azuredeploy-storage.json))
	```bash
	# East
	az deployment group create --resource-group refworkload-eastus2-rg --name funcstor-eastus2 --template-file ./templates/functions/azuredeploy-storage.json --parameters storageAccountName="kskrefeastus2"
	
	# Central
	az deployment group create --resource-group refworkload-centralus-rg --name funcstor-centralus --template-file ./templates/functions/azuredeploy-storage.json --parameters storageAccountName="kskrefcentralus"
	```
4. Deploy Function Apps ([ARM Template](templates/functions/azuredeploy-app.json)) TODO: Add Storage to template.
	```bash
	# East
	az deployment group create --resource-group refworkload-eastus2-rg --name app-eastus2 --template-file ./templates/functions/azuredeploy-app.json --parameters planName="kskrefeastus2" appName="kskrefeastus2" vnetName=spoke-vnet subnetName=integration-subnet networkResourceGroup=network-eastus2-rg
	
	# Central
	az deployment group create --resource-group refworkload-centralus-rg --name app-centralus --template-file ./templates/functions/azuredeploy-app.json --parameters planName="kskrefcentralus" appName="kskrefcentralus" vnetName=spoke-vnet subnetName=integration-subnet networkResourceGroup=network-centralus-rg
	```
5. Update Function App Config for routing and storage 
	```bash
	```
#### Deploy Reference Function Code
1. TBD
	```bash
	TBD
	```
2. TBD
	```bash
	TBD
	```
3. TBD
	```bash
	TBD
	```
[top ->](#TOC)  
## Cost Optimization Considerations
Cost in Azure accrues over time based on the services that are used within your solution. In most cases there are a large number of meters that need to be accounted for if you're looking to draw a comprehensive pictures of cost. Generally however the vast majority of overall cost will come a smaller number of core services that are in use. This being said, with this solution we'll focus on service bus, functions and networking costs as they will constitute the majority of your spend.
### Service Bus
As previously mentioned, Service Bus Namespaces can be provisioned in one of three tiers ( Basic, Standard and Premium). For details on how these tiers are priced please see the following [pricing document](https://azure.microsoft.com/en-us/pricing/details/service-bus/?&OCID=AID2100131_SEM_XoKIJQAAAFvOgjyo:20200722185658:s&msclkid=525e7aa4c0e71f13cee325bc4b11ecf8&ef_id=XoKIJQAAAFvOgjyo:20200722185658:s&dclid=CNyPsu_E4eoCFYg_DAodvM8HkA).

Requirements dictate that we use Premium Namespaces in this solution. The primary unit of scale for Premium Namespaces is the Messaging Unit (MU). Billing is based on how many messaging units (1,2,4 or 8) you run per namespace per hour. The cost is linear per MU. Current rates can be found in the above linked pricing document.

In general, you'll want to be sure that you're running only as many messaging units in your namespace as your performance and scale requirements dictate. It's difficult to discern the number of MUs you will require without conducting some initial scale testing. We generally recommend you start with one or two MUs, test and scale accordingly. See [Performance and Scalability considerations](#Performance-and-Scalability-considerations) for more information.

### Functions
There's a great article [here](https://docs.microsoft.com/en-us/azure/azure-functions/functions-scale) that describes the hosting options for Azure functions. In a nutshell, you can run functions in a Comsumption Plan, Premium Plan or an App Service Plan.  
  
Requirements for this solution dictate that we use either the Premium Plan or App Service plan as these support the networking integration functionality we need.

Premium Plan is recommended due to the fact that it supports automatic dynamic scaling with a [high scale out limit](https://docs.microsoft.com/en-us/azure/azure-functions/functions-premium-plan#region-max-scale-out). When using an App Service Plan you need to manually [configure auto-scaling](https://docs.microsoft.com/en-us/azure/app-service/manage-scale-up) within the confines of the specific plan you've selected.

Billing for the Premium plan is based on the number of instances of a given app plan size that are active per hour. At least one instance must be warm at all times per plan. This means that there's a minimum monthly cost per active plan, regardless of the number of executions.

When provisioning a premium plan, you first need to select a [plan size](https://docs.microsoft.com/en-us/azure/azure-functions/functions-premium-plan#available-instance-skus) EP1, EP2 or EP3. This defines the instance size that your plan will scale at when it scales in and out. It also dictates the base cost that will be charged per instance as you scale. Your plan will initially be set with a "minimum instance" setting of 1. It's possible to adjust this upwards to accommodate what you know to be baseline load. You will however incur the full cost of additional instances at the plan size if you do so.

It is also possible to adjust the Maximum instance burst ceiling on the plan such that the plan will never burst beyond the defined number of instances. Setting this ceiling can contain cost but it does so by potentially placing a limit on the scale of your apps.

A premium plan can have one or more function apps attached to it. At the function app level you can select the number of [pre-warmed instances](https://docs.microsoft.com/en-us/azure/azure-functions/functions-premium-plan#pre-warmed-instances) you want to run. This number cannot exceed the "minimum instance" level set at the plan level. This functionality is designed to avoid what are commonly referred to as cold starts. Adjusting this setting upward will cause you to be charged for the number of pre-warmed instances on an ongoing basis.	

Below is a snippet of the scale adjustment sliders in the portal. This is from the app level scale settings and shows both app and plan scaling parameters:  

![](images/scale-out.png) 


### Networking
## Operational Considerations
### Code Deployment
Insert here specifics on Azure DevOps code build and deployment pipeline.
### Infrastructure Provisioning
Insert here specifics on Azure DevOps infrastructure deployment pipeline.
### Monitoring
Insert here guidance on infrastructure and App Monitoring.
## Performance and Scalability Considerations
### Functions Performance
### Functions Scale
## Reliability Considerations
### Requirements
- Describe target RPO / RTO.
- Describe FMA.
### High Availability
- Describe Design
- Describe fail-over, fail-back process.
### Disaster Recovery
- Describe Design  
Active Passive / Non-HTTP Trigger Failover
![](images/activePassiveNonHTTPNormal.png) 
Active Passive / Non-HTTP Trigger Failover - Failover
![](images/activePassiveNonHTTPFailed.png) 
- Describe fail-over, fail-back process.
- Describe backup / recovery process.
## Security Considerations
### Identity and Access Management
- Describe Control Plane IAM implementation
- Describe Data Plane IAM implementation
- Describe App Authentication / Authorization implementation
### Network Security
- Describe network security controls
	- Azure Firewall for Egress Filtering / Auditing
	- Network Security Groups for network segmentation.
	- Routing configuration (BGP route propagation and UDRs)
	- On-Premises Firewalls
### Storage, Data and Encryption
- Describe approaches for protecting data at rest and in flight.





































