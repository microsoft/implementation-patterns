### Provision HA for Self-hosted integration runtimes. Multi nodes and AZ support for VMs. (Automation)
### Provision DR for Azure Data Factory and Self hosted Integration runtime
 ## Disaster Recovery for Azure Data Factory
Azure Data Factory doesn't store any user data. It acts as a integration framework to move or transform data from different data sources. Hence, there is no built in mechanism within Azure Data Factory to configure a DR strategy. 

Here are the steps needed achieve a comprehensive Disaster Recovery (DR) strategy for Azure Data Factory for user initiated DR solutions

1. Make sure that all the Azure data sources involved are part of a Geo replication strategy across regions.
2. You need to make sure that you are integrating your Azure Data Factory to a Git repo. In this way, all the artifacts are in a centralized repository which can be easily redeployed in another region ahead of time and make sure that the schedules are disabled. Make sure you configure self hosted integration runtime in the DR region and shutdown to save costs

Service Level Disaster recovery: Azure Data Factory team can also do a manual failover incase there is a region wide outage beyond 24 hours. Support ticket needs to be raised.

### DR for ADF data sources and DNS zones
As mentiooed
