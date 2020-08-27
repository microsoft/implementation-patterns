# Databricks Reliability

High Availability and Disaster Recovery Best Practices:

At the VM level, failures are extremely rare as Azure SLAs will guarantee Virtual Machine (VM) connectivity at least 99.9% of the time.
There is also an SLA for the Azure Databricks service SLA which guarantees it will be available 99.95% of the time.
The Databricks cluster manager transparently relaunches any worker instance that is revoked or crashes, ensuring your service is always up and running without the need to manage it yourself.

Regardless, one should still implement some kind of regional disaster recovery topology as detailed below. 

## How to create a regional disaster recovery topology
There are a number of components used for a Big Data pipeline with Azure Databricks: Azure Storage, Azure Database, and other data sources. Azure Databricks is the compute for the Big Data pipeline. It is ephemeral in nature, meaning that while your data is still available in Azure Storage, the compute (Azure Databricks cluster) can be terminated so that you don’t have to pay for compute when you don’t need it. The compute (Azure Databricks) and storage sources must be in the same region so that jobs don’t experience high latency.
To create your own regional disaster recovery topology, follow these requirements:
1.	Provision multiple Azure Databricks workspaces in separate Azure regions. For example, create the primary Azure Databricks workspace in East US2. Create the secondary disaster-recovery Azure Databricks workspace in a separate region, such as West US.
    • E.g. East US2 and West US2 will map to different control planes whereas West and North Europe will map to same control plane

2.	Use geo-redundant storage. The data associated Azure Databricks is stored by default in Azure Storage. The results from Databricks jobs are also stored in Azure Blob Storage, so that the processed data is durable and remains highly available after cluster is terminated. As the Storage and Databricks cluster are co-located, you must use Geo-redundant storage so that data can be accessed in secondary region if primary region is no longer accessible.
3.	Once the secondary region is created, you must migrate the users, user folders, notebooks, cluster configuration, jobs configuration, libraries, storage, init scripts, and reconfigure access control. Additional details are outlined in the following section.
4.  Use Azure Traffic Manager to load balance and distribute API requests between two deployments, when the platform is primarily being used in a backend non-interactive mode.

## Other best practices: 
 Design to honor API and other limits of the platform:
 
    • Jobs per hour per workspace = 5000
    • Maximum concurrent Notebooks attached per cluster = 145
    • Maximum active concurrent runs per workspace = 150


