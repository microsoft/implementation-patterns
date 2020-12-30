# Producer / Consumer Pattern Using Azure Service Bus and Azure Functions  

Two versions of this pattern are provided:

#### [v1](v1/)

A two-region deployment that implements Azure Service Bus [Geo-Disaster Recovery](https://docs.microsoft.com/azure/service-bus-messaging/service-bus-geo-dr) (Geo-DR), Azure Private DNS, and Private Endpoints for Azure Service Bus.

#### [v2](v2/)

A two-region deployment that uses distinct Azure Service Bus namespaces without Geo-DR to permit active/active or active/passive patterns, with traffic management and/or load balancing deferred to external solutions.

Additionally, this version implements Azure Private Link and Private Endpoints for Azure Service Bus Namespaces, Azure Storage Accounts, and Azure Functions.

Each version folder contains a README with extensive additional detail.