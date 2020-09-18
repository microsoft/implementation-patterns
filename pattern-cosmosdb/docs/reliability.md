# Azure Cosmos DB Account Consistency and Availability

## Consistency levels
Distributed databases that rely on replication for high availability, low latency, or both must make tradeoffs. The tradeoffs are between read consistency vs. availability, latency, and throughput.

Azure Cosmos DB approaches data consistency as a spectrum of choices. This approach includes more options than the two extremes of strong and eventual consistency. You can choose from five well-defined levels on the consistency spectrum. From strongest to weakest, the levels are:

### Strong
Strong consistency offers a linearizability guarantee. Linearizability refers to serving requests concurrently. The reads are guaranteed to return the most recent committed version of an item. A client never sees an uncommitted or partial write. Users are always guaranteed to read the latest committed write.

The following graphic illustrates the strong consistency with musical notes. After the data is written to the "West US 2" region, when you read the data from other regions, you get the most recent value:

![](https://docs.microsoft.com/en-us/azure/cosmos-db/media/consistency-levels/strong-consistency.gif)

### Bounded Stateless
The reads are guaranteed to honor the consistent-prefix guarantee. The reads might lag behind writes by at most "K" versions (that is, "updates") of an item or by "T" time interval, whichever is reached first. In other words, when you choose bounded staleness, the "staleness" can be configured in two ways:

   - The number of versions (K) of the item
   - The time interval (T) by which the reads might lag behind the writes

Bounded staleness offers total global order outside of the "staleness window." When a client performs read operations within a region that accepts writes, the guarantees provided by bounded staleness consistency are identical to those guarantees by the strong consistency.

   - Inside the staleness window, Bounded Staleness provides the following consistency guarantees:
   - Consistency for clients in the same region for a single-master account = Strong
   - Consistency for clients in different regions for a single-master account = Consistent Prefix
   - Consistency for clients writing to a single region for a multi-master account = Consistent Prefix
   - Consistency for clients writing to different regions for a multi-master account = Eventual

Bounded staleness is frequently chosen by globally distributed applications that expect low write latencies but require total global order guarantee. Bounded staleness is great for applications featuring group collaboration and sharing, stock ticker, publish-subscribe/queueing etc. The following graphic illustrates the bounded staleness consistency with musical notes. After the data is written to the "West US 2" region, the "East US 2" and "Australia East" regions read the written value based on the configured maximum lag time or the maximum operations:

![](https://docs.microsoft.com/en-us/azure/cosmos-db/media/consistency-levels/bounded-staleness-consistency.gif)

### Session
Within a single client session reads are guaranteed to honor the consistent-prefix, monotonic reads, monotonic writes, read-your-writes, and write-follows-reads guarantees. This assumes a single "writer" session or sharing the session token for multiple writers.

   - Clients outside of the session performing writes will see the following guarantees:
   - Consistency for clients in same region for a single-master account = Consistent Prefix
   - Consistency for clients in different regions for a single-master account = Consistent Prefix
   - Consistency for clients writing to a single region for a multi-master account = Consistent Prefix
   - Consistency for clients writing to multiple regions for a multi-master account = Eventual

Session consistency is the most widely used consistency level for both single region as well as globally distributed applications. It provides write latencies, availability, and read throughput comparable to that of eventual consistency but also provides the consistency guarantees that suit the needs of applications written to operate in the context of a user. The following graphic illustrates the session consistency with musical notes. The "West US 2 writer" and the "West US 2 reader" are using the same session (Session A) so they both read the same data at the same time. Whereas the "Australia East" region is using "Session B" so, it receives data later but in the same order as the writes.

![](https://docs.microsoft.com/en-us/azure/cosmos-db/media/consistency-levels/session-consistency.gif)

### Constant Prefix
Updates that are returned contain some prefix of all the updates, with no gaps. Consistent prefix consistency level guarantees that reads never see out-of-order writes.

If writes were performed in the order A, B, C, then a client sees either A, A,B, or A,B,C, but never out-of-order permutations like A,C or B,A,C. Consistent Prefix provides write latencies, availability, and read throughput comparable to that of eventual consistency, but also provides the order guarantees that suit the needs of scenarios where order is important.

Below are the consistency guarantees for Consistent Prefix:

   - Consistency for clients in same region for a single-master account = Consistent Prefix
   - Consistency for clients in different regions for a single-master account = Consistent Prefix
   - Consistency for clients writing to a single region for a multi-master account = Consistent Prefix
   - Consistency for clients writing to multiple regions for a multi-master account = Eventual
The following graphic illustrates the consistency prefix consistency with musical notes. In all the regions, the reads never see out of order writes:

![](https://docs.microsoft.com/en-us/azure/cosmos-db/media/consistency-levels/consistent-prefix.gif)

### Eventual
There's no ordering guarantee for reads. In the absence of any further writes, the replicas eventually converge.
Eventual consistency is the weakest form of consistency because a client may read the values that are older than the ones it had read before. Eventual consistency is ideal where the application does not require any ordering guarantees. Examples include count of Retweets, Likes, or non-threaded comments. The following graphic illustrates the eventual consistency with musical notes.

![](https://docs.microsoft.com/en-us/azure/cosmos-db/media/consistency-levels/eventual-consistency.gif)

Each level provides availability and performance tradeoffs and is backed by comprehensive SLAs.

![](https://docs.microsoft.com/en-us/azure/cosmos-db/media/consistency-levels/five-consistency-levels.png)

## Choose the right consistency level
Distributed databases relying on replication for high availability, low latency or both, make the fundamental tradeoff between the read consistency vs. availability, latency, and throughput. Most commercially available distributed databases ask developers to choose between the two extreme consistency models: strong consistency and eventual consistency. Azure Cosmos DB allows developers to choose among the five well-defined consistency models: strong, bounded staleness, session, consistent prefix and eventual. Each of these consistency models is well-defined, intuitive and can be used for specific real-world scenarios. Each of the five consistency models provide precise availability and performance tradeoffs and are backed by comprehensive SLAs. You can configure a default consistency at the account level and override it at the request level. The following simple considerations will help you make the right choice in many common scenarios.

#### SQL API and Table API

Consider the following points if your application is built using SQL API or Table API:
- For many real-world scenarios, session consistency is optimal and it's the recommended option. 
- If your application requires strong consistency, it is recommended that you use bounded staleness consistency level.
- If you need stricter consistency guarantees than the ones provided by session consistency and single-digit-millisecond latency for writes, it is recommended that you use bounded staleness consistency level.
- If your application requires eventual consistency, it is recommended that you use consistent prefix consistency level.
- If you need less strict consistency guarantees than the ones provided by session consistency, it is recommended that you use consistent prefix consistency level.
- If you need the highest availability and the lowest latency, then use eventual consistency level.
- If you need even higher data durability without sacrificing performance, you can create a custom consistency level at the application layer.

### Latency
The read latency for all consistency levels is always guaranteed to be less than 10 milliseconds at the 99th percentile. This read latency is backed by the SLA. The average read latency, at the 50th percentile, is typically 4 milliseconds or less.

The write latency for all consistency levels is always guaranteed to be less than 10 milliseconds at the 99th percentile. This write latency is backed by the SLA. The average write latency, at the 50th percentile, is usually 5 milliseconds or less. Azure Cosmos accounts that span several regions and are configured with strong consistency are an exception to this guarantee.

### Write latency and Strong consistency
For Azure Cosmos accounts configured with strong consistency with more than one region, the write latency is equal to two times round-trip time (RTT) between any of the two farthest regions, plus 10 milliseconds at the 99th percentile. High network RTT between the regions will translate to higher latency for Cosmos DB requests since strong consistency completes an operation only after ensuring that it has been committed to all regions within an account.

The exact RTT latency is a function of speed-of-light distance and the Azure networking topology. Azure networking doesn't provide any latency SLAs for the RTT between any two Azure regions. For your Azure Cosmos account, replication latencies are displayed in the Azure portal. You can use the Azure portal (go to the Metrics blade, select Consistency tab) to monitor the replication latencies between various regions that are associated with your Azure Cosmos account.

### Consistency levels and throughput
- For strong and bounded staleness, reads are done against two replicas in a four replica set (minority quorum) to provide consistency guarantees. Session, consistent prefix and eventual do single replica reads. The result is that, for the same number of request units, read throughput for strong and bounded staleness is half of the other consistency levels.  

- For a given type of write operation, such as insert, replace, upsert, and delete, the write throughput for request units is identical for all consistency levels.

## High availability with Azure Cosmos DB
Azure Cosmos DB transparently replicates your data across all the Azure regions associated with your Azure Cosmos account. 

![](https://docs.microsoft.com/en-us/azure/cosmos-db/media/high-availability/cosmosdb-data-redundancy.png)

- The data within Azure Cosmos containers is horizontally partitioned.

- A partition-set is a collection of multiple replica-sets. Within each region, every partition is protected by a replica-set with all writes replicated and durably committed by a majority of replicas. Replicas are distributed across as many as 10-20 fault domains.

- Each partition across all the regions is replicated. Each region contains all the data partitions of an Azure Cosmos container and can accept writes and serve reads.

If your Azure Cosmos account is distributed across N Azure regions, there will be at least N x 4 copies of all your data. Generally having an Azure Cosmos account in more than 2 regions improves the availability of your application and provides low latency across the associated regions.

### SLAs for availability
As a globally distributed database, Azure Cosmos DB provides comprehensive SLAs that encompass throughput, latency at the 99th percentile, consistency, and high availability. The table below shows the guarantees for high availability provided by Azure Cosmos DB for single and multi-region accounts. For high availability, always configure your Azure Cosmos accounts to have multiple write regions(also called multi-master).

SLAS FOR AVAILABILITY
|Operation type |	Single region | Multi-region (single region writes) | Multi-region (multi-region writes)|
|---------------|---------------|-------------------------------------|-----------------------------------|
|Writes         |99.99          |99.99                                |99.999                             |
|Reads          |99.99          |99.999                               |99.999                             |


---
> [Back to TOC](../README.md#TOC)
