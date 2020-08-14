## High Availability for Azure Data Factory

Azure Data Factory is a highly available service within a region. It has several moving parts (Orchestration, Metadata and Data movement) and each part is guaranteed to provide High availability across availability zones within a region which is completely transparent to the customer. Meta data is stored in the same region as Azure Data Factory region. Orchestration also happens from the same region. Data Movement is realized through integration runtime (Azure or Self-hosted) which defines the location for Data Movement.

As a customer the only component you need to worry about High Availability is for the Self hosted Integration runtime. Azure IR is highly available and a completely managed offering.

1. Please make sure to have more than 1 node (Max 4) for your Self hosted Integration runtime environment in an Active-Active mode so that they dont become the single point of failure. It improves copy performance as well
2. In case you are leveraging Azure VM's to host the Self hosted IR, Please make sure that the VM's are deployed across different Availability Zones or part of the same Availability set for resiliency

Please follow the instructions provided here to create a self hosted IR environment with multiple nodes. https://github.com/microsoft/implementation-patterns/tree/main/pattern-datafactory-databricks/components/self-hosted-integration-runtime


 ## Disaster Recovery for Azure Data Factory
Azure Data Factory doesn't store any user data. It acts as a integration framework to move or transform data from different data sources. Hence, there is no built in mechanism within Azure Data Factory to configure a DR strategy. 

Here are the steps needed achieve a comprehensive Disaster Recovery (DR) strategy for Azure Data Factory for user initiated DR solutions

1. Make sure that all the Azure data sources involved are part of a Geo replication strategy across regions.
2. You need to make sure that you are integrating your Azure Data Factory to a Git repo. In this way, all the artifacts are in a centralized repository which can be easily redeployed in another region ahead of time and make sure that the schedules are disabled. Make sure you configure self hosted integration runtime in the DR region and shutdown to save costs
3. In case you are using Azure Integration runtime(Azure IR) there are 2 variations. One is to use Auto-resolve integration runtime and other is to use explicit region specific Azure IR. Default is to use Auto-resolve which automatically picks a compute region depending on your data sources. You dont have to worry about creating this Azure IR ahead of time as it can automatically pickup a region. For region specific Azure IR, You need to make sure that the Azure IR is configured ahead of time in the Disaster recovery Azure data factory. You only pay for actual utilization.

**Service Level Disaster recovery**: Azure Data Factory team can also do a manual failover incase there is a region wide outage beyond 24 hours. It is failed over to the region pair. In this case the same data factory is failed over and hence any pipelines which failed can be restarted. **RPO = 24 Hrs, RTO = 24 Hrs.**Support ticket needs to be raised.

### DR for ADF data sources and DNS zones
As mentioned above, you need to make sure that all the data sources involved in the pipeline are setup for Geo replication across regions. Make sure that your Linked services are pointing to the DR endpoints. When using Self hosted Intergation Runtime, If your Azure PaaS data sources are enabled for private endpoints, then you need to make sure that the Private DNS zone which is used for the Primary region also include the Virtual links for the DR Virtual network which will host the Self hosted Integration runtime. In this way, the DR virtual network which hosts the Self hosted IR can do name resolution to all the private endpoints when triggered from the DR region.

