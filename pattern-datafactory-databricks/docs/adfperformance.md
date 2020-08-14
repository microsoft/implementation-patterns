
### Performance considerations for SHIR and Azure IR 

![image](https://user-images.githubusercontent.com/22504173/89627977-99b28280-d869-11ea-83dd-fcbaef113c10.png)

 

Azure Data Factory provides the following performance optimization features:
[Data Integration Units](https://docs.microsoft.com/en-us/azure/data-factory/copy-activity-performance#data-integration-units)

o  A Data Integration Unit is a measure that represents the power (a combination of CPU, memory, and network resource allocation) of a single unit in Azure Data Factory. Data Integration Unit only applies to [Azure integration runtime](https://docs.microsoft.com/en-us/azure/data-factory/concepts-integration-runtime#azure-integration-runtime), but not [self-hosted integration runtime](https://docs.microsoft.com/en-us/azure/data-factory/concepts-integration-runtime#self-hosted-integration-runtime).

o  The allowed DIUs to empower a copy activity run is **between 2 and 256**. If not specified or you choose "Auto" on the UI, Data Factory dynamically applies the optimal DIU setting based on your source-sink pair and data pattern. 

[Self-hosted integration runtime scalability](https://docs.microsoft.com/en-us/azure/data-factory/copy-activity-performance#self-hosted-integration-runtime-scalability)

o  If you would like to achieve higher throughput, you can either scale up or scale out the Self-hosted IR:

- - If the CPU and available memory on the Self-hosted IR      node are not fully utilized, but the execution of concurrent jobs is      reaching the limit, you should scale up by increasing the number of      concurrent jobs that can run on a node. See [here](https://docs.microsoft.com/en-us/azure/data-factory/create-self-hosted-integration-runtime#scale-up) for instructions.
  - If on the other hand, the CPU is high on the      Self-hosted IR node or available memory is low, you can add a new node to      help scale out the load across the multiple nodes. See [here](https://docs.microsoft.com/en-us/azure/data-factory/create-self-hosted-integration-runtime#high-availability-and-scalability) for instructions.
  -  

·    [Parallel copy](https://docs.microsoft.com/en-us/azure/data-factory/copy-activity-performance#parallel-copy)

- - You can set      parallel copy (`parallelCopies` property)      on copy activity to indicate the parallelism that you want the copy      activity to use. You can think of this property as the maximum number of      threads within the copy activity that read from your source or write to      your sink data stores in parallel.
  - For each copy      activity run, by default Azure Data Factory dynamically applies the      optimal parallel copy setting based on your source-sink pair and data      pattern.

·    [Staged copy](https://docs.microsoft.com/en-us/azure/data-factory/copy-activity-performance#staged-copy)

- - When you copy      data from a source data store to a sink data store, you might choose to      use Blob storage as an interim staging store.

 
![image](https://user-images.githubusercontent.com/22504173/89628022-ac2cbc00-d869-11ea-8e4f-caa584219637.png)

 

·    When you activate the staging feature, first the data is copied from the source data store to the staging Blob storage (bring your own). Next, the data is copied from the staging data store to the sink data store. Azure Data Factory automatically manages the two-stage flow for you. Azure Data Factory also cleans up temporary data from the staging storage after the data movement is complete.

### Performance considerations for Pipelines and Dataflows
