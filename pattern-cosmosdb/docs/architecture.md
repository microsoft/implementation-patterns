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

##### TODO: Make this Cosmos Specific
#### Deployment
1. Create resource group for our reference workload
	```bash
	# for East resources
	az group create --location eastus2 --name cosmos-db-rg
	```
2. Create Comos DB Account with default consistency level ([ARM Template](../components/cosmosaccount/cosmosaccount.json))
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
	Default consistency level
	
	![](https://docs.microsoft.com/en-us/azure/cosmos-db/media/consistency-levels/strong-consistency.gif)
	
	[Consistency Levels and Latency](..reliability.md)
	
3. Add region ([ARM Template](../components/cosmosaccount/cosmosaccount.json))
	```bash
	az cosmosdb update --name $accountName --resource-group $resourceGroupName \
		--locations regionName="East US 2" failoverPriority=0 isZoneRedundant=False \
		--locations regionName="West US 2" failoverPriority=1 isZoneRedundant=False  \
		--locations regionName="South Central US" failoverPriority=2 isZoneRedundant=False
	```
4. Enable multiple write regions([ARM Template](../components/cosmosaccount/cosmosaccount.json))
	```bash
	# Get the account resource id for an existing account
	accountId=$(az cosmosdb show -g $resourceGroupName -n $accountName --query id -o tsv)
	az cosmosdb update --ids $accountId --enable-multiple-write-locations true
	```
5. Set failover policy
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
6. Enable Automaic Failover
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

#### Implementation
![](images/networking-functions.png)  
- A function app (1) will be deployed into each region for hosting our producer and consumer functions  

- Both function apps (1) will be configured to leverage regional VNet integration (2) to send all egress traffic from all functions into a newly created integration subnet in each region.  

- A UDR (3) will be created and assigned to the integration subnet such that all traffic destined for the internet will be sent through Azure Firewall in the hub VNet. This will allow us to filter and audit all outbound traffic.  

- The Firewall will be configured to allow traffic to public App Insights endpoints to enable built-in monitoring facilitated by the Azure Functions host running in the Function App.

- DNS settings on the Spoke VNet will be configured such that all DNS queries (4) originating from subnets in the VNet will be sent to our custom DNS forwarders.
#### Deploy Infrastructure
1
[top ->](#Architecture-and-Composable-Deployment-Code) 
---
> [Back to TOC](../README.md#TOC) 
