# Azure Cosmos DB Account
## Cost Optimization Considerations
Cost in Azure accrues over time based on the services that are used within your solution. In most cases there are a large number of meters that need to be accounted for if you're looking to draw a comprehensive pictures of cost. Generally however the vast majority of overall cost will come a smaller number of core services that are in use. This being said, with this solution we'll focus on Azure Comsos DB, so our costs are controlled by Request Units (RUs).
### Resource Units
Azure Cosmos DB supports many APIs, such as SQL, MongoDB, Cassandra, Gremlin, and Table. Each API has its own set of database operations. These operations range from simple point reads and writes to complex queries. Each database operation consumes system resources based on the complexity of the operation.

The cost of all database operations is normalized by Azure Cosmos DB and is expressed by Request Units (or RUs, for short). You can think of RUs as a performance currency abstracting the system resources such as CPU, IOPS, and memory that are required to perform the database operations supported by Azure Cosmos DB.

The cost to do a point read (i.e. fetching a single item by its ID and partition key value) for a 1 KB item is 1 Request Unit (or 1 RU). All other database operations are similarly assigned a cost using RUs. No matter which API you use to interact with your Azure Cosmos container, costs are always measured by RUs. Whether the database operation is a write, point read, or query, costs are always measured in RUs.

The following image shows the high-level idea of RUs:
![](https://docs.microsoft.com/en-us/azure/cosmos-db/media/request-units/request-units.png)

To manage and plan capacity, Azure Cosmos DB ensures that the number of RUs for a given database operation over a given dataset is deterministic. You can examine the response header to track the number of RUs that are consumed by any database operation. When you understand the factors that affect RU charges and your application's throughput requirements, you can run your application cost effectively.

The type of Azure Cosmos account you're using determines the way consumed RUs get charged:

In provisioned throughput mode, you provision the number of RUs for your application on a per-second basis in increments of 100 RUs per second. To scale the provisioned throughput for your application, you can increase or decrease the number of RUs at any time in increments or decrements of 100 RUs. You can make your changes either programmatically or by using the Azure portal. You are billed on an hourly basis for the amount of RUs per second you have provisioned. You can provision throughput at two distinct granularities:
Containers: For more information, see Provision throughput on an Azure Cosmos container.
Databases: For more information, see Provision throughput on an Azure Cosmos database.
In serverless mode, you don't have to provision any throughput when creating resources in your Azure Cosmos account. At the end of your billing period, you get billed for the amount of Request Units that has been consumed by your database operations.

#### Request Unit considerations
While you estimate the number of RUs consumed by your workload, consider the following factors:

- Item size: As the size of an item increases, the number of RUs consumed to read or write the item also increases.

- Item indexing: By default, each item is automatically indexed. Fewer RUs are consumed if you choose not to index some of your items in a container.

- Item property count: Assuming the default indexing is on all properties, the number of RUs consumed to write an item increases as the item property count increases.

- Indexed properties: An index policy on each container determines which properties are indexed by default. To reduce the RU consumption for write operations, limit the number of indexed properties.

- Data consistency: The strong and bounded staleness consistency levels consume approximately two times more RUs while performing read operations when compared to that of other relaxed consistency levels.

- Type of reads: Point reads cost significantly fewer RUs than queries.

- Query patterns: The complexity of a query affects how many RUs are consumed for an operation. Factors that affect the cost of query operations include:

- The number of query results
  + The number of predicates
  + The nature of the predicates
  + The number of user-defined functions
  + The size of the source data
  + The size of the result set
  + Projections
Azure Cosmos DB guarantees that the same query on the same data always costs the same number of RUs on repeated executions.

- Script usage: As with queries, stored procedures and triggers consume RUs based on the complexity of the operations that are performed. As you develop your application, inspect the request charge header to better understand how much RU capacity each operation consumes.



### Optimize provisioned throughput cost in Azure Cosmos DB
By offering provisioned throughput model, Azure Cosmos DB offers predictable performance at any scale. Reserving or provisioning throughput ahead of time eliminates the “noisy neighbor effect” on your performance. You specify the exact amount of throughput you need and Azure Cosmos DB guarantees the configured throughput, backed by SLA.

You can start with a minimum throughput of 400 RU/sec and scale up to tens of millions of requests per second or even more. Each request you issue against your Azure Cosmos container or database, such as a read request, write request, query request, stored procedures have a corresponding cost that is deducted from your provisioned throughput. If you provision 400 RU/s and issue a query that costs 40 RUs, you will be able to issue 10 such queries per second. Any request beyond that will get rate-limited and you should retry the request. If you are using client drivers, they support the automatic retry logic.

You can provision throughput on databases or containers and each strategy can help you save on costs depending on the scenario.

#### Optimize by provisioning throughput at different levels
- If you provision throughput on a database, all the containers, for example collections/tables/graphs within that database can share the throughput based on the load. Throughput reserved at the database level is shared unevenly, depending on the workload on a specific set of containers.

- If you provision throughput on a container, the throughput is guaranteed for that container, backed by the SLA. The choice of a logical partition key is crucial for even distribution of load across all the logical partitions of a container. See Partitioning and horizontal scaling articles for more details.

The following are some guidelines to decide on a provisioned throughput strategy:

##### Consider provisioning throughput on an Azure Cosmos database (containing a set of containers) if:

1. You have a few dozen Azure Cosmos containers and want to share throughput across some or all of them.

2. You are migrating from a single-tenant database designed to run on IaaS-hosted VMs or on-premises, for example, NoSQL or relational databases to Azure Cosmos DB. And if you have many collections/tables/graphs and you do not want to make any changes to your data model. Note, you might have to compromise some of the benefits offered by Azure Cosmos DB if you are not updating your data model when migrating from an on-premises database. It's recommended that you always reaccess your data model to get the most in terms of performance and also to optimize for costs.

3. You want to absorb unplanned spikes in workloads by virtue of pooled throughput at the database level subjected to unexpected spike in workload.

4. Instead of setting specific throughput on individual containers, you care about getting the aggregate throughput across a set of containers within the database.
##### TODO Link to composeable code. Add Code Block for Database

##### Consider provisioning throughput on an individual container if:

1. You have a few Azure Cosmos containers. Because Azure Cosmos DB is schema-agnostic, a container can contain items that have heterogeneous schemas and does not require customers to create multiple container types, one for each entity. It is always an option to consider if grouping separate say 10-20 containers into a single container makes sense. With a 400 RUs minimum for containers, pooling all 10-20 containers into one could be more cost effective.

2. You want to control the throughput on a specific container and get the guaranteed throughput on a given container backed by SLA.
##### TODO Link to composeable code. Add Code Block for individual container

##### Consider a hybrid of the above two strategies:

1. As mentioned earlier, Azure Cosmos DB allows you to mix and match the above two strategies, so you can now have some containers within Azure Cosmos database, which may share the throughput provisioned on the database as well as, some containers within the same database, which may have dedicated amounts of provisioned throughput.

2. You can apply the above strategies to come up with a hybrid configuration, where you have both database level provisioned throughput with some containers having dedicated throughput.
##### TODO Link to composeable code. Add blocks to both?

### Optimize with rate-limiting your requests
For workloads that aren't sensitive to latency, you can provision less throughput and let the application handle rate-limiting when the actual throughput exceeds the provisioned throughput. The server will preemptively end the request with RequestRateTooLarge (HTTP status code 429) and return the x-ms-retry-after-ms header indicating the amount of time, in milliseconds, that the user must wait before retrying the request.
```
HTTP Status 429, 
 Status Line: RequestRateTooLarge 
 x-ms-retry-after-ms :100
 ```
### Partitioning strategy and provisioned throughput costs
Good partitioning strategy is important to optimize costs in Azure Cosmos DB. Ensure that there is no skew of partitions, which are exposed through storage metrics. Ensure that there is no skew of throughput for a partition, which is exposed with throughput metrics. Ensure that there is no skew towards particular partition keys. Dominant keys in storage are exposed through metrics but the key will be dependent on your application access pattern. It's best to think about the right logical partition key. A good partition key is expected to have the following characteristics:

- Choose a partition key that spreads workload evenly across all partitions and evenly over time. In other words, you shouldn't have some keys to with majority of the data and some keys with less or no data.

- Choose a partition key that enables access patterns to be evenly spread across logical partitions. The workload is reasonably even across all the keys. In other words, the majority of the workload shouldn't be focused on a few specific keys.

- Choose a partition key that has a wide range of values.

The basic idea is to spread the data and the activity in your container across the set of logical partitions, so that resources for data storage and throughput can be distributed across the logical partitions. Candidates for partition keys may include the properties that appear frequently as a filter in your queries. Queries can be efficiently routed by including the partition key in the filter predicate. With such a partitioning strategy, optimizing provisioned throughput will be a lot easier.

> [Back to TOC](../README.md#TOC)
