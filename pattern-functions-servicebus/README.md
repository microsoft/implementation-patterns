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
- [Architecture and Composable Deployment Code](docs/architecture.md)
- [Cost Optimization Considerations](docs/costoptimization.md)
- [Operational Considerations](docs/operational.md)
- [Performance and Scalability Considerations](docs/performance.md)
- [Reliability Considerations](docs/reliability.md)
- [Security Considerations](docs/security.md)  
 










































