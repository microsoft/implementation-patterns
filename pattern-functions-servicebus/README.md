# Producer / Consumer Pattern Using Azure Service Bus and Azure Functions  

## TOC
- [Getting Started / Prerequisites](Getting-Started)
- [Architectural Overview](Architectural-Overview)
- [Composable Deployment Code](Composable-Deployment-Code)
- Considerations for a Well Architected Solution
	- [Cost Optimization](docs/costoptimization.md)
	- [Operational](docs/operational.md)
	- [Performance and Scalability](docs/performance.md)
	- [Reliability](docs/reliability.md)
	- [Security](docs/security.md)   

## Getting Started / Prerequisites
- Azure Subscription with appropriate role based access for the components you chose to deploy
- Linux Command Line (Bash)
- Azure CLI

[top ->](#TOC)

## Architectural Overview
Many cloud native applications are expected to handle a large number of requests. Rather than process each request synchronously, a common technique is for the application to pass them through a messaging system to another service (a consumer service) that handles them asynchronously. This strategy helps to ensure that the business logic in the application isn't blocked while the requests are being processed. For full details on this pattern see the [following article](https://docs.microsoft.com/en-us/azure/architecture/patterns/competing-consumers).

On Azure, the primary enterprise messaging service is [Azure Service Bus](https://docs.microsoft.com/en-us/azure/service-bus-messaging/service-bus-messaging-overview).

[Azure Functions](https://docs.microsoft.com/en-us/azure/azure-functions/#:~:text=Azure%20Functions%20Documentation.%20Azure%20Functions%20is%20a%20serverless,code%20in%20response%20to%20a%20variety%20of%20events.) offers a convenient compute platform from which to implement a producer consumer pattern with relatively little underlying infrastructure management.

Azure Functions and Service Bus are relatively simple to get up and running in their default configurations. Things get significantly more complex when implementing them in environments with stringent security requirements that dictate more aggressive network perimeter security and segmentation.
  
This document describes key considerations for deploying Azure Functions alongside Service Bus in a fully locked down environment using technologies including regional VNet Integration for functions, private endpoints for Service Bus and a variety of network security controls including Network Security Groups and Azure Firewall.

We've modeled this architecture on an fairly aggressive set of requirements from a performance/scalability, reliability and security perspective. Those requirements will be noted within the document. Your implementation of this pattern may differ depending on your needs.

Similar to other architectures available in the [Azure Architecture Center](https://docs.microsoft.com/en-us/azure/architecture/browse/), this document touches on each pillar defined in the [Microsoft Azure Well-Architected Framework](https://docs.microsoft.com/en-us/azure/architecture/framework).  

[top ->](#TOC)

### Virtual Network Foundation
![](docs/images/networking-foundation.png)
This guide assumes that you are deploying your solution into a networking environment with the following characteristics:

- [Hub and Spoke](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/hub-spoke-network-topology)  network architecture.   

- The hub VNet (1) is used for hosting shared services like Azure Firewall, DNS forwarding and providing connectivity to on-premises networks. In a real implementation, the hub network would be connected to an on-premises network via ExpressRoute, S2S VPN, etc (2). In our reference examples we'll, exclude this portion of the architecture for simplicity.  

- The spoke network (3) is used for hosting business workloads. In this case we're integrating our Function App to a dedicated subnet ("Integration Subnet") that sits within the spoke network. We'll use a second subnet ("Workload Subnet") for hosting other components of the solution including private endpoints for our Service Bus namespaces, etc.  

- The Hub is peered to Spoke using Azure VNet Peering.  

- In many locked down environments [Forced tunneling](https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-forced-tunneling-rm) is in place. E.G. routes are being published over ExpressRoute via BGP that override the default 0.0.0.0/0 -> Internet system route in all connected Azure subnets. The effect is that there is **no** direct route to the internet from within Azure subnets. Internet destined traffic is sent to the VPN/ER gateway. We can simulate this in a test environment by using restrictive NSGs and Firewall rules to prohibit internet egress. We'll route any internet egress traffic to Azure firewall (4) using a UDR (5) where it can be filtered and audited.  

- Generally, custom DNS is configured on the spoke VNet settings. DNS forwarders in the hub are referenced. These forwarders  provide conditional forwarding to the Azure internal resolver and on premises DNS servers as needed. In this reference implementation we'll deploy a simple BIND forwarder (6) into our hub network that will be configured to forward requests to the Azure internal resolver.  

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
![](docs/images/networking-servicebus.png)  
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

[top ->](#TOC)

### Azure Functions
#### Requirements
- Support for Java (version 8)
- Support for .NET Core C# (version 3.1)
- Ability to run in multiple regions (East US 2 and Central US)
- Connectivity to Azure and on-premises private networks
- Dynamic scaling based on incoming event load / queue depth
#### Implementation
![](docs/images/networking-functions.png)  
- A function app (1) will be deployed into each region for hosting our producer and consumer functions  

- Both function apps (1) will be configured to leverage regional VNet integration (2) to send all egress traffic from all functions into a newly created integration subnet in each region.  

- A UDR (3) will be created and assigned to the integration subnet such that all traffic destined for the internet will be sent through Azure Firewall in the hub VNet. This will allow us to filter and audit all outbound traffic.  

- The Firewall will be configured to allow traffic to public App Insights endpoints to enable built-in monitoring facilitated by the Azure Functions host running in the Function App.

- DNS settings on the Spoke VNet will be configured such that all DNS queries (4) originating from subnets in the VNet will be sent to our custom DNS forwarders.

[top ->](#TOC)

## Composable Deployment Code
1. [Base Networking](components/base-network)
2. [Integration Subnet](components/integration-subnet)
3. [Firewall](components/firewall)
4. [BIND DNS Forwarders](components/functions)
5. [Service Bus](components/integration-subnet)
6. [Functions](components/service-bus)









































