# Azure Cosmos DB Pattern
## Performance and Scalability Considerations
### Throughput Scaling
### Storage Scaling
### Geographically Scaling

## Scaling
With Azure Cosmos DB, you pay for the throughput you provision and the storage you consume on an hourly basis. Throughput must be provisioned to ensure that sufficient system resources are available for your Azure Cosmos database at all times. 

Azure Cosmos DB supports many APIs, such as SQL, MongoDB, Cassandra, Gremlin, and Table. Each API has its own set of database operations. These operations range from simple point reads and writes to complex queries. Each database operation consumes system resources based on the complexity of the operation.

The cost of all database operations is normalized by Azure Cosmos DB and is expressed by Request Units (or RUs, for short). You can think of RUs per second as the currency for throughput. RUs per second is a rate-based currency. It abstracts the system resources such as CPU, IOPS, and memory that are required to perform the database operations supported by Azure Cosmos DB. A minimum of 10 RU/s is required to store each 1 GB of data.

The cost to do a point read for a 1 KB item is 1 Request Unit (or 1 RU). All other database operations are similarly assigned a cost using RUs. No matter which API you use to interact with your Azure Cosmos container, costs are always measured by RUs. Whether the database operation is a write, point read, or query, costs are always measured in RUs.

The following image shows the high-level idea of RUs:


![](https://docs.microsoft.com/en-us/azure/cosmos-db/media/request-units/request-units.png)

## Throughput scaling
### Request Unit Considerations
The number of RUs for an application is provisioned on a per-second basis in increments of 100 RUs per second. To scale the provisioned throughput for an application, increase or decrease the number of RUs at any time. RUs scale in increments or decrements of 100 RUs. Changes are made either programmatically or by using the Azure portal. Billing is on an hourly basis, the hour is billed for the maximum nuber of RUS specified during the hour.

Azure Cosmos DB allows you to set provisioned throughput on your databases and containers. There are two types of provisioned throughput, standard (manual) or autoscale. This is an overview of how provisioned throughput works.

An Azure Cosmos database is a unit of management for a set of containers. A database consists of a set of schema-agnostic containers. An Azure Cosmos container is the unit of scalability for both throughput and storage. A container is horizontally partitioned across a set of machines within an Azure region and is distributed across all Azure regions associated with your Azure Cosmos account.

With Azure Cosmos DB, you can provision throughput at two granularities:

- Azure Cosmos containers
- Azure Cosmos databases

![](https://azurecomcdn.azureedge.net/mediahandler/acomblog/media/Default/blog/8d036cf9-df49-45d3-b540-00f18c4f5c31.png)

#### Set throughput on a container

The throughput provisioned on an Azure Cosmos container is exclusively reserved for that container. The container receives the provisioned throughput all the time. The provisioned throughput on a container is financially backed by SLAs. Setting provisioned throughput on a container is the most frequently used option. You can elastically scale throughput for a container by provisioning any amount of throughput by using Request Units (RUs).

The throughput provisioned for a container is evenly distributed among its physical partitions, and assuming a good partition key that distributes the logical partitions evenly among the physical partitions, the throughput is also distributed evenly across all the logical partitions of the container. You cannot selectively specify the throughput for logical partitions. Because one or more logical partitions of a container are hosted by a physical partition, the physical partitions belong exclusively to the container and support the throughput provisioned on the container.

If the workload running on a logical partition consumes more than the throughput that was allocated to the underlying physical partition, it's possible that your operations will be rate-limited. What is known as a hot partition occurs when one logical partition has disproportionately more requests than other partition key values.

When rate-limiting occurs, you can either increase the provisioned throughput for the entire container or retry the operations. You also should ensure that you choose a partition key that evenly distributes storage and request volume. 

It is recommended that you configure throughput at the container granularity when you want guaranteed performance for the container.

The following image shows how a physical partition hosts one or more logical partitions of a container
![](https://docs.microsoft.com/en-us/azure/cosmos-db/media/set-throughput/resource-partition.png)

#### Set throughput on a database

When you provision throughput on an Azure Cosmos database, the throughput is shared across all the containers (called shared database containers) in the database. An exception is if you specified a provisioned throughput on specific containers in the database. Sharing the database-level provisioned throughput among its containers is analogous to hosting a database on a cluster of machines. Because all containers within a database share the resources available on a machine, you naturally do not get predictable performance on any specific container.

Setting throughput on an Azure Cosmos database guarantees that you receive the provisioned throughput for that database all the time. Because all containers within the database share the provisioned throughput, Azure Cosmos DB doesn't provide any predictable throughput guarantees for a particular container in that database. The portion of the throughput that a specific container can receive is dependent on:

- The number of containers.
- The choice of partition keys for various containers.
- The distribution of the workload across various logical partitions of the containers.

It is recommended that you configure throughput on a database when you want to share the throughput across multiple containers, but don't want to dedicate the throughput to any particular container.

The following examples demonstrate where it's preferred to provision throughput at the database level:

- Sharing a database's provisioned throughput across a set of containers is useful for a multitenant application. Each user can be represented by a distinct Azure Cosmos container.

- Sharing a database's provisioned throughput across a set of containers is useful when you migrate a NoSQL database, such as MongoDB or Cassandra, hosted on a cluster of VMs or from on-premises physical servers to Azure Cosmos DB. Think of the provisioned throughput configured on your Azure Cosmos database as a logical equivalent, but more cost-effective and elastic, to that of the compute capacity of your MongoDB or Cassandra cluster.

All containers created inside a database with provisioned throughput must be created with a partition key. At any given point in time, the throughput allocated to a container within a database is distributed across all the logical partitions of that container. When you have containers that share provisioned throughput configured on a database, you can't selectively apply the throughput to a specific container or a logical partition.

Containers in a shared throughput database share the throughput (RU/s) allocated to that database. You can have up to four containers with a minimum of 400 RU/s on the database. With standard (manual) provisioned throughput, each new container after the first four will require an additional 100 RU/s minimum. For example, if you have a shared throughput database with eight containers, the minimum RU/s on the database will be 800 RU/s. With autoscale provisioned throughput, you can have up to 25 containers in a database with autoscale max 4000 RU/s (scales between 400 - 4000 RU/s).

In February 2020, Microsoft introduced a change that allows you to have a maximum of 25 containers in a shared throughput database, which better enables throughput sharing across the containers. After the first 25 containers, more containers can be added to the database only if they are provisioned with dedicated throughput, which is separate from the shared throughput of the database.
If an Azure Cosmos DB account already contains a shared throughput database with >=25 containers, the account and all other accounts in the same Azure subscription are exempt from this change.

The following image shows how a physical partition can host one or more logical partitions that belong to different containers within a database:
![](https://docs.microsoft.com/en-us/azure/cosmos-db/media/set-throughput/resource-partition2.png)

#### Set throughput on a database and a container

You can combine the two models. Provisioning throughput on both the database and the container is allowed. When creating a container in a database with shared throughout that need to be outside of the shared pool, enable Provision dedicated throughput for this container option and explicitly configure the number of RUs of provisioned throughput on that container. Note that you can configure shared and dedicated throughput only when creating the database and container.

A container with provisioned throughput cannot be converted to shared database container. Conversely a shared database container cannot be converted to have a dedicated throughput.

### Update throughput

After you create an Azure Cosmos container or a database, you can update the provisioned throughput. There is no limit on the maximum provisioned throughput that you can configure on the database or the container.

To estimate the minimum provisioned throughput of a database or container, find the maximum of:

- 400 RU/s
- Current storage in GB * 10 RU/s
- Highest RU/s provisioned on the database or container / 100
- Container count * 100 RU/s (shared throughput database only)

The actual minimum RU/s may vary depending on your account configuration. You can use Azure Monitor metrics to view the history of provisioned throughput (RU/s) and storage on a resource.

You can retrieve the minimum throughput of a container or a database programmatically by using the SDKs or view the value in the Azure portal. When using the .NET SDK, the DocumentClient.ReplaceOfferAsync method allows you to scale the provisioned throughput value. When using the Java SDK, the RequestOptions.setOfferThroughput method allows you to scale the provisioned throughput value.

When using the .NET SDK, the DocumentClient.ReadOfferAsync method allows you to retrieve the minimum throughput of a container or a database.

You can scale the provisioned throughput of a container or a database at any time. When a scale operation is performed to increase the throughput, it can take longer time due to the system tasks to provision the required resources. You can check the status of the scale operation in Azure portal or programmatically using the SDKs. When using the .NET SDK, you can get the status of the scale operation by using the DocumentClient.ReadOfferAsync method.


## Storage Scaling
### Partitioning

Azure Cosmos DB uses partitioning to scale individual containers in a database to meet the performance needs of your application. In partitioning, the items in a container are divided into distinct subsets called logical partitions. Logical partitions are formed based on the value of a partition key that is associated with each item in a container. All items in a logical partition have the same partition key value.

For example, a container holds items. Each item has a unique value for the UserID property. If UserID serves as the partition key for the items in the container and there are 1,000 unique UserID values, 1,000 logical partitions are created for the container.

In addition to a partition key that determines the item's logical partition, each item in a container has an item ID (unique within a logical partition). Combining the partition key and the item ID creates the item's index, which uniquely identifies the item.

Choosing a partition key is an important decision that will affect your application's performance.

#### Logical Partitioning

Azure Cosmos DB transparently and automatically manages the placement of logical partitions on physical partitions to efficiently satisfy the scalability and performance needs of the container. As the throughput and storage requirements of an application increase, Azure Cosmos DB moves logical partitions to automatically spread the load across a greater number of physical partitions. You can learn more about physical partitions.

Azure Cosmos DB uses hash-based partitioning to spread logical partitions across physical partitions. Azure Cosmos DB hashes the partition key value of an item. The hashed result determines the physical partition. Then, Azure Cosmos DB allocates the key space of partition key hashes evenly across the physical partitions.

##### Transactions (in stored procedures or triggers) are allowed only against items in a single logical partition.

### Choosing a partition key
 A partition key has two components: partition key path and the partition key value. For example, consider an item { "userId" : "Andrew", "worksFor": "Microsoft" } if you choose "userId" as the partition key, the following are the two partition key components:

- The partition key path (For example: "/userId"). The partition key path accepts alphanumeric and underscore(_) characters. You can also use nested objects by using the standard path notation(/).

- The partition key value (For example: "Andrew"). The partition key value can be of string or numeric types.

To learn about the limits on throughput, storage, and length of the partition key, see the Azure Cosmos DB service quotas article.

Selecting your partition key is a simple but important design choice in Azure Cosmos DB. Once you select your partition key, it is not possible to change it in-place. If you need to change your partition key, you should move your data to a new container with your new desired partition key.

For all containers, your partition key should:

- Be a property that has a value which does not change. If a property is your partition key, you can't update that property's value.
- Have a high cardinality. In other words, the property should have a wide range of possible values.
Spread request unit (RU) consumption and data storage evenly across all logical partitions. This ensures even RU consumption and storage distribution across your physical partitions.
- If you need multi-item ACID transactions in Azure Cosmos DB, you will need to use stored procedures or triggers. All JavaScript-based stored procedures and triggers are scoped to a single logical partition.


---
> [Back to TOC](../README.md#TOC)
