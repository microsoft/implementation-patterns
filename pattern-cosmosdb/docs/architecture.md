# Azure Cosmos DB Account Multi Region Pattern
## Architecture and Composable Deployment Code
### Implementation
![](https://docs.microsoft.com/en-us/azure/cosmos-db/media/introduction/azure-cosmos-db.png)
This guide assumes that you are deploying your solution into a networking environment with the following characteristics:

![Azure Cosmos DB](https://www.gotcosmos.com/images/architecture/web.png?v=v5wUB5Zw9Tq66qcMudl0AA6uVu5QImOsEjuUxY1ULwU)  Azure Cosmos DB architecture.   

- Azure Cosmos DB can be deployed to one or more Azure Regions transparently. For reads, Azure Traffic manager handles routing requests to the requestor's nearest region.

### Azure Cosmo DB
#### Requirements
- Predictable / Consistent Performance
- Direct integration to and accessibility from private networks
- No accessibility from public networks
- Cross Region Replication
#### Implementation

The base-level resource for Azure Cosmos DB is an Azure Cosmos DB Account. Accounts contain the entities that we will be working with ( Databases, Containers, Collestions, Documents ).

![](https://azurecomcdn.azureedge.net/mediahandler/acomblog/media/Default/blog/8d036cf9-df49-45d3-b540-00f18c4f5c31.png)

When creating an account in a single region, there are relatively few decisions needed. The delpoyment requires the name, pricing tier, initial scale and redundancy settings, subscription, resource group, consistency levey and location.

This reference implementation will deploy a SQL API Account. This is the most commonly deployed API and is recommended for most production workloads due to it's flexability and ease of development.    
  
- Create an account in 2 Azure Regions (1)  

- Configure geo-redundancy (2) with the another Azure Region by adding it to the Azure Cosmos DB Account. This replicaiton is at the Azure Comos DB Account level, not at the individual database/container level.
![](https://docs.microsoft.com/en-us/azure/cosmos-db/media/how-to-manage-database-account/replicate-data-globally.png)

- The account should be set up in the same region as the Resource Group it is in. 

- Geo Redundancy can be enabled by deploying to multiple regions

- RUs at account or Datbase Level?

- Default Consistency level

#### Deployment
1. Create resource group for our reference workload
	```bash
	# for East resources
	az group create --location eastus2 --name cosmos-db-rg
	```
2. Create Comos DB Account with default consistency level ([ARM Template](../components/cosmosaccount/cosmosaccount.json#L1))
	```bash
	resourceGroupName='cosmos-db-rg'
	accountName='mycosmosaccount' #needs to be lower case and less than 44 characters

	az cosmosdb create \
    		-n $accountName \
    		-g $resourceGroupName \
    		--default-consistency-level Session \   		
   		--locations regionName='West US 2' failoverPriority=0 isZoneRedundant=False \
		--locations regionName='East US 2' failoverPriority=1 isZoneRedundant=False
	```
	[ARM Template Region](../components/cosmosaccount/cosmosaccount.json#L9)
	
	[Session consistency level](../components/cosmosaccount/cosmosaccount.json#L28)
	
	![](https://docs.microsoft.com/en-us/azure/cosmos-db/media/consistency-levels/session-consistency.gif)
	
	
3. Change consistency level ([ARM Template](../components/cosmosaccount/combinedCosmos.json#L1))
	```bash
	# update an existing account's default consistency
	az cosmosdb update --name $accountName --resource-group $resourceGroupName --default-consistency-level Strong
	```
	[Consistency Levels and Latency](../docs/reliability.md)
	
	The new consistency level is Strong Consistency
	
	![](https://docs.microsoft.com/en-us/azure/cosmos-db/media/consistency-levels/strong-consistency.gif)
	
	![](https://docs.microsoft.com/en-us/azure/cosmos-db/media/consistency-levels/five-consistency-levels.png)

4. Add region ([ARM Template](../components/cosmosaccount/combinedCosmos.json#L59))
	```bash
	az cosmosdb update --name $accountName --resource-group $resourceGroupName \
		--locations regionName="East US 2" failoverPriority=0 isZoneRedundant=False \
		--locations regionName="West US 2" failoverPriority=1 isZoneRedundant=False  \
		--locations regionName="South Central US" failoverPriority=2 isZoneRedundant=False
	```
5. Enable multiple write regions([ARM Template](../components/cosmosaccount/combinedCosmos.json#L122))
	```bash
	# Get the account resource id for an existing account
	accountId=$(az cosmosdb show -g $resourceGroupName -n $accountName --query id -o tsv)
	az cosmosdb update --ids $accountId --enable-multiple-write-locations true
	```
6. Set failover policy
	```bash
	# Assume region order is initially 'West US 2'=0 'East US 2'=1 'South Central US'=2 for account
	resourceGroupName='myResourceGroup'
	accountName='mycosmosaccount'

	# Get the account resource id for an existing account
	accountId=$(az cosmosdb show -g $resourceGroupName -n $accountName --query id -o tsv)

	# Make South Central US the next region to fail over to instead of East US 2
	az cosmosdb failover-priority-change --ids $accountId \
		--failover-policies 'West US 2=0' 'South Central US=1' 'East US 2=2'
	```
7. Enable Automaic Failover
	```bash
	# Enable automatic failover on an existing account
	resourceGroupName='myResourceGroup'
	accountName='mycosmosaccount'

	# Get the account resource id for an existing account
	accountId=$(az cosmosdb show -g $resourceGroupName -n $accountName --query id -o tsv)

	az cosmosdb update --ids $accountId --enable-automatic-failover true
	```
[top ->](#Architecture-and-Composable-Deployment-Code)    

### Azure Cosmos DB database
#### The following sections demonstrate how to manage the Azure Cosmos DB database, including:
- Create a database
- Create a database with shared throughput
- Change database throughput
- Manage locks on a database

After you create an Azure Cosmos DB account under your Azure subscription, you can manage data in your account by creating databases, containers, and items. You can create one or multiple Azure Cosmos databases under your account. A database is analogous to a namespace. A database is the unit of management for a set of Azure Cosmos containers. The following table shows how an Azure Cosmos database is mapped to various API-specific entities:

The following image shows the hierarchy of different entities in an Azure Cosmos DB account:
![](https://docs.microsoft.com/en-us/azure/cosmos-db/media/databases-containers-items/cosmos-entities.png)

1. Create a Cosmos database.([ARM Template](../components/cosmosaccount/combinedCosmos.json#L97))
	```bash
	resourceGroupName='MyResourceGroup'
	accountName='mycosmosaccount'
	databaseName='database1'

	az cosmosdb sql database create \
    		-a $accountName \
    		-g $resourceGroupName \
    		-n $databaseName
	```
2. Create a database with shared throughput ([ARM Template](../components/cosmosaccount/combinedCosmos.json#L114))
	```bash
	resourceGroupName='MyResourceGroup'
	accountName='mycosmosaccount'
	databaseName='database1'
	throughput=400

	az cosmosdb sql database create \
 	   -a $accountName \
 	   -g $resourceGroupName \
  	  -n $databaseName \
  	  --throughput $throughput
	```
3. Change database throughput ([ARM Template](../components/cosmosaccount/combinedCosmos.json#L137))
	```bash
	resourceGroupName='MyResourceGroup'
	accountName='mycosmosaccount'
	databaseName='database1'
	newRU=1000
	
	# Get minimum throughput to make sure newRU is not lower than minRU
	minRU=$(az cosmosdb sql database throughput show \
	    -g $resourceGroupName -a $accountName -n $databaseName \
	    --query resource.minimumThroughput -o tsv)
	
	if [ $minRU -gt $newRU ]; then
	    newRU=$minRU
	fi
	
	az cosmosdb sql database throughput update \
	    -a $accountName \
	    -g $resourceGroupName \
	    -n $databaseName \
	    --throughput $newRU
	```
4. Manage lock on a database
	```bash
	resourceGroupName='myResourceGroup'
	accountName='my-cosmos-account'
	databaseName='myDatabase'
	
	lockType='CanNotDelete' # CanNotDelete or ReadOnly
	databaseParent="databaseAccounts/$accountName"
	databaseLockName="$databaseName-Lock"
	
	# Create a delete lock on database
	az lock create --name $databaseLockName \
	    --resource-group $resourceGroupName \
	    --resource-type Microsoft.DocumentDB/sqlDatabases \
	    --lock-type $lockType \
	    --parent $databaseParent \
	    --resource $databaseName
	
	# Delete lock on database
	lockid=$(az lock show --name $databaseLockName \
	        --resource-group $resourceGroupName \
	        --resource-type Microsoft.DocumentDB/sqlDatabases \
	        --resource $databaseName \
	        --parent $databaseParent \
	        --output tsv --query id)
	az lock delete --ids $lockid
	```

1
[top ->](#Architecture-and-Composable-Deployment-Code) 
---
> [Back to TOC](../README.md#TOC) 
