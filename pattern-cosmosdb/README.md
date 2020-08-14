# Azure Cosmos DB 
Today's applications are required to be highly responsive and always online. To achieve low latency and high availability, instances of these applications need to be deployed in datacenters that are close to their users. Applications need to respond in real time to large changes in usage at peak hours, store ever increasing volumes of data, and make this data available to users in milliseconds.

Azure Cosmos DB is Microsoft's globally distributed, multi-model database service. With a click of a button, Cosmos DB enables you to elastically and independently scale throughput and storage across any number of Azure regions worldwide. You can elastically scale throughput and storage, and take advantage of fast, single-digit-millisecond data access using your favorite API including: SQL, MongoDB, Cassandra, Tables, or Gremlin. Cosmos DB provides comprehensive service level agreements (SLAs) for throughput, latency, availability, and consistency guarantees, something no other database service offers.
![Azure Cosmos DB](https://docs.microsoft.com/en-us/azure/cosmos-db/media/introduction/azure-cosmos-db.png)

This document describes key considerations for deploying Azure Comso DB. It includes Creation of the Cosomos DB Accoutn, APIs, Consistency Levels and Partitions. It will also cover deploying Azure Cosmos DB in a fully locked down environment using technologies including Application Tokens, IP Firewall, VNet integration, Private Endpoint, RBAC and Data Encryption using customer-managed keys.

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
 










































