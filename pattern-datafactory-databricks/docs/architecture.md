# Azure Data Factory Architecture Patterns

## Architecture and Composable Deployment Code

### Virtual Network Foundation

#### Implementation

![adfarch](https://user-images.githubusercontent.com/22504173/88923589-f4335980-d23f-11ea-9aa0-f69fee0d2aff.png)


Azure Data Factory is a PaaS service hosted within Azure. ADF by itself is just a metadata store which stores artifacts information like (*pipeline*, *trigger*, *activity*, *linked* *service* and *dataset* definitions in JSON) and is hosted in Azure public space. However, the actual data integration compute which performs data movement activity is performed by Integration Runtimes as explained below. You can create Azure Data Factory optionally with CI\CD integration to Git repo if needed. Here are the scripts and templates to automate the setup. [Provisioning Azure Data Factory with or without CI\CD integration](https://github.com/microsoft/implementation-patterns/tree/main/pattern-datafactory-databricks/components/data-factory)


There is a default Azure Integration Runtime called AutoResolveIntegrationRuntime which gets provisioned automatically when  Data factory is provisioned and the region is automatically resolved depending on the pipeline data sources. Azure IR is mainly used to perform data movement or activity dispatch whenever you need to connect to cloud data sources which have a publicly accessible endpoint. You can additionally create more Azure IR incase you need to create in a specific region or you have customized Spark clusters you want to provision for Mapping Dataflows. Recently, we have previewed a new features to host Azure IR within a Managed VNET(VNET which is managed by ADF). In this Managed VNET option, you can connect to any cloud data source using Private endpoints or Private Link. Here are the scripts and templates to automate the setup [Provisioning Azure Integration Runtime – Custom clusters, Managed VNET concepts](https://github.com/microsoft/implementation-patterns/tree/main/pattern-datafactory-databricks/components/azure-integration-runtime)


In a typical enterprise scenario, for any data integration use case there is always a need to integrate data from On-premises sources which are not exposed to Internet. This is where we need to leverage the Self hosted Integration runtime. SHIR is typically provisioned on VM resources either On-premises or on Azure VMs. The advantage of provisioning them on Azure VMs is to take advantage of the ExpressRoute connections the Virtual network (Private peering) already has to the On-premises data center. So you provision the VMs within this Virtual network and then configure the Self hosted Integration runtime software on the node which will then act as the compute environment for your data movement activities. Virtual network only needs outbound access to few URLs on port 443. Here are the scripts and templates to automate the setup [Provisioning Self Hosted Integration Runtime, Considerations](https://github.com/microsoft/implementation-patterns/tree/main/pattern-datafactory-databricks/components/self-hosted-integration-runtime)
