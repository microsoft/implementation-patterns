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

## Geographically Scaling
### Global data distribution with Azure Cosmos DB

Today's applications are required to be highly responsive and always online. To achieve low latency and high availability, instances of these applications need to be deployed in datacenters that are close to their users. These applications are typically deployed in multiple datacenters and are called globally distributed. Globally distributed applications need a globally distributed database that can transparently replicate the data anywhere in the world to enable the applications to operate on a copy of the data that's close to its users.

Azure Cosmos DB is a globally distributed database service that's designed to provide low latency, elastic scalability of throughput, well-defined semantics for data consistency, and high availability. In short, if your application needs guaranteed fast response time anywhere in the world, if it's required to be always online, and needs unlimited and elastic scalability of throughput and storage, you should build your application on Azure Cosmos DB.

You can configure your databases to be globally distributed and available in any of the Azure regions. To lower the latency, place the data close to where your users are. Choosing the required regions depends on the global reach of your application and where your users are located. Cosmos DB transparently replicates the data to all the regions associated with your Cosmos account. It provides a single system image of your globally distributed Azure Cosmos database and containers that your application can read and write to locally.

With Azure Cosmos DB, you can add or remove the regions associated with your account at any time. Your application doesn't need to be paused or redeployed to add or remove a region. It continues to be highly available all the time because of the multi-homing capabilities that the service natively provides.

![](https://docs.microsoft.com/en-us/azure/cosmos-db/media/distribute-data-globally/deployment-topology.png)

### Key benefits of global distribution

**Build global active-active apps.** With its novel multi-master replication protocol, every region supports both writes and reads. The multi-master capability also enables:
   - Unlimited elastic write and read scalability.
   - 99.999% read and write availability all around the world.
   - Guaranteed reads and writes served in less than 10 milliseconds at the 99th percentile.
By using the Azure Cosmos DB multi-homing APIs, your application is aware of the nearest region and can send requests to that region. The nearest region is identified without any configuration changes. As you add and remove regions to and from your Azure Cosmos account, your application does not need to be redeployed or paused, it continues to be highly available at all times.

**Build highly responsive apps.** Your application can perform near real-time reads and writes against all the regions you chose for your database. Azure Cosmos DB internally handles the data replication between regions with consistency level guarantees of the level you've selected.

**Build highly available apps.** Running a database in multiple regions worldwide increases the availability of a database. If one region is unavailable, other regions automatically handle application requests. Azure Cosmos DB offers 99.999% read and write availability for multi-region databases.

**Maintain business continuity during regional outages.** Azure Cosmos DB supports automatic failover during a regional outage. During a regional outage, Azure Cosmos DB continues to maintain its latency, availability, consistency, and throughput SLAs. To help make sure that your entire application is highly available, Cosmos DB offers a manual failover API to simulate a regional outage. By using this API, you can carry out regular business continuity drills.

**Scale read and write throughput globally.** You can enable every region to be writable and elastically scale reads and writes all around the world. The throughput that your application configures on an Azure Cosmos database or a container is guaranteed to be delivered across all regions associated with your Azure Cosmos account. The provisioned throughput is guaranteed up by financially backed SLAs.

[**Choose from several well-defined consistency models.**](https://github.com/microsoft/implementation-patterns/blob/main/pattern-cosmosdb/docs/reliability.md#consistency-levels) The Azure Cosmos DB replication protocol offers five well-defined, practical, and intuitive consistency models. Each model has a tradeoff between consistency and performance. Use these consistency models to build globally distributed applications with ease.

**Global distribution in Azure Cosmos DB is turnkey:** At any time, with a few clicks or programmatically with a single API call, you can add or remove the geographical regions associated with your Cosmos database. A Cosmos database, in turn, consists of a set of Cosmos containers. In Cosmos DB, containers serve as the logical units of distribution and scalability. The collections, tables, and graphs you create are (internally) just Cosmos containers. Containers are completely schema-agnostic and provide a scope for a query. Data in a Cosmos container is automatically indexed upon ingestion. Automatic indexing enables users to query the data without the hassles of schema or index management, especially in a globally distributed setup.
  - In a given region, data within a container is distributed by using a partition-key, which you provide and is transparently managed by the underlying physical partitions (local distribution).
  - Each physical partition is also replicated across geographical regions (global distribution).  
When an app using Cosmos DB elastically scales throughput on a Cosmos container or consumes more storage, Cosmos DB transparently handles partition management operations (split, clone, delete) across all the regions. Independent of the scale, distribution, or failures, Cosmos DB continues to provide a single system image of the data within the containers, which are globally distributed across any number of regions.

As shown in the following image, the data within a container is distributed along two dimensions - within a region and across regions, worldwide:

![](https://docs.microsoft.com/en-us/azure/cosmos-db/media/global-dist-under-the-hood/distribution-of-resource-partitions.png)

A physical partition is implemented by a group of replicas, called a replica-set. Each machine hosts hundreds of replicas that correspond to various physical partitions within a fixed set of processes as shown in the image above. Replicas corresponding to the physical partitions are dynamically placed and load balanced across the machines within a cluster and data centers within a region.

A replica uniquely belongs to an Azure Cosmos DB tenant. Each replica hosts an instance of Cosmos DB’s database engine, which manages the resources as well as the associated indexes. The Cosmos database engine operates on an atom-record-sequence (ARS) based type system. The engine is agnostic to the concept of a schema, blurring the boundary between the structure and instance values of records. Cosmos DB achieves full schema agnosticism by automatically indexing everything upon ingestion in an efficient manner, which allows users to query their globally distributed data without having to deal with schema or index management.

The Cosmos database engine consists of components including implementation of several coordination primitives, language runtimes, the query processor, and the storage and indexing subsystems responsible for transactional storage and indexing of data, respectively. To provide durability and high availability, the database engine persists its data and index on SSDs and replicates it among the database engine instances within the replica-set(s) respectively. Larger tenants correspond to higher scale of throughput and storage and have either bigger or more replicas or both. Every component of the system is fully asynchronous – no thread ever blocks, and each thread does short-lived work without incurring any unnecessary thread switches. Rate-limiting and back-pressure are plumbed across the entire stack from the admission control to all I/O paths. Cosmos database engine is designed to exploit fine-grained concurrency and to deliver high throughput while operating within frugal amounts of system resources.

Cosmos DB’s global distribution relies on two key abstractions – replica-sets and partition-sets. A replica-set is a modular Lego block for coordination, and a partition-set is a dynamic overlay of one or more geographically distributed physical partitions. To understand how global distribution works, we need to understand these two key abstractions.

### Conflict resolution

Our design for the update propagation, conflict resolution, and causality tracking is inspired from the prior work on epidemic algorithms and the Bayou system. While the kernels of the ideas have survived and provide a convenient frame of reference for communicating the Cosmos DB’s system design, they have also undergone significant transformation as we applied them to the Cosmos DB system. This was needed, because the previous systems were designed neither with the resource governance nor with the scale at which Cosmos DB needs to operate, nor to provide the capabilities (for example, bounded staleness consistency) and the stringent and comprehensive SLAs that Cosmos DB delivers to its customers.

Recall that a partition-set is distributed across multiple regions and follows Cosmos DBs (multi-master) replication protocol to replicate the data among the physical partitions comprising a given partition-set. Each physical partition (of a partition-set) accepts writes and serves reads typically to the clients that are local to that region. Writes accepted by a physical partition within a region are durably committed and made highly available within the physical partition before they are acknowledged to the client. These are tentative writes and are propagated to other physical partitions within the partition-set using an anti-entropy channel. Clients can request either tentative or committed writes by passing a request header. The anti-entropy propagation (including the frequency of propagation) is dynamic, based on the topology of the partition-set, regional proximity of the physical partitions, and the consistency level configured. Within a partition-set, Cosmos DB follows a primary commit scheme with a dynamically selected arbiter partition. The arbiter selection is dynamic and is an integral part of the reconfiguration of the partition-set based on the topology of the overlay. The committed writes (including multi-row/batched updates) are guaranteed to be ordered.

We employ encoded vector clocks (containing region ID and logical clocks corresponding to each level of consensus at the replica-set and partition-set, respectively) for causality tracking and version vectors to detect and resolve update conflicts. The topology and the peer selection algorithm are designed to ensure fixed and minimal storage and minimal network overhead of version vectors. The algorithm guarantees the strict convergence property.

For the Cosmos databases configured with multiple write regions, the system offers a number of flexible automatic conflict resolution policies for the developers to choose from, including:

Last-Write-Wins (LWW), which, by default, uses a system-defined timestamp property (which is based on the time-synchronization clock protocol). Cosmos DB also allows you to specify any other custom numerical property to be used for conflict resolution.
Application-defined (Custom) conflict resolution policy (expressed via merge procedures), which is designed for application-defined semantics reconciliation of conflicts. These procedures get invoked upon detection of the write-write conflicts under the auspices of a database transaction on the server side. The system provides exactly once guarantee for the execution of a merge procedure as a part of the commitment protocol. There are several conflict resolution samples available for you to play with.

### Consistency Models
Whether you configure your Cosmos database with a single or multiple write regions, you can choose from the five well-defined consistency models. With multiple write regions, the following are a few notable aspects of the consistency levels:

The bounded staleness consistency guarantees that all reads will be within K prefixes or T seconds from the latest write in any of the regions. Furthermore, reads with bounded staleness consistency are guaranteed to be monotonic and with consistent prefix guarantees. The anti-entropy protocol operates in a rate-limited manner and ensures that the prefixes do not accumulate and the backpressure on the writes does not have to be applied. Session consistency guarantees monotonic read, monotonic write, read your own writes, write follows read, and consistent prefix guarantees, worldwide. For the databases configured with strong consistency, the benefits (low write latency, high write availability) of multiple write regions does not apply, because of synchronous replication across regions.

The semantics of the five consistency models in Cosmos DB are described here, and mathematically described using a high-level TLA+ specifications ![here](https://github.com/microsoft/implementation-patterns/blob/main/pattern-cosmosdb/docs/reliability.md#azure-cosmos-db-account-consistency-and-availability).
---
> [Back to TOC](../README.md#TOC)
