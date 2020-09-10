# Azure Databricks Architecture Patterns

### Virtual Network Foundation

#### Implementation

![image](https://user-images.githubusercontent.com/22504173/91381485-8013b380-e7f5-11ea-99be-ed41e03d1cb4.png)

## **Azure Databricks VNET Considerations:** 
By default, Azure Databricks is deployed as a managed service within a Virtual Network (VNET ) which is Microsoft managed into a locked resource group. However, Most of the enterprises don't prefer this option but rather want the service to be injected into their own Virtual Network. We call this VNET injection so that the Data plane (Clusters) is injected into the VNET but there are few control plane components like the Webapp and Notebooks still running in Microsoft managed environment. 

VNET injection provides benefits like ability to deploy Databricks into an existing VNET to access your Onpremises data, Azure Paas resources etc in a private and secure way using Private endpoints or service endpoints, Use Custom DNS for Databricks, Send traffic through any Azure NVA for traffic inspection, Use your own NSG and UDR rules giving you more flexibility and control. 

![image](https://user-images.githubusercontent.com/22504173/91550801-1a0f5500-e8f7-11ea-812e-62f946129e2d.png)

Few considerations for VNET Injection are

- The VNET location and subscription have to be the same as Databricks workspace

- There are two subnets public and private which needs to be assigned to each databricks workspace. The public communicates with Control plane and private for internal communication. Do not share these subnets with other resources. These subnets will be delegated to Microsoft.Databricks/workspaces service which allows the service to create NSG rules. You cannot share multiple Databricks workspaces the same subnets. You need to create new subnet pairs for each workspace

- A CIDR block between /16 - /24 for the virtual network and a CIDR block up to /26 for the private and public subnets.

Please refer to this link for detailed implementation of Azure Databricks with VNET injection
https://cloudsafari.ca/2020/09/data-platform/Azure-Databricks-VNET-Integration

  
## **Azure Databricks Workspace Considerations:** 

Workspaces enables users to organize—and share—their Notebooks, Libraries and Dashboards. We recommend that you assign workspaces based on a related group of people working together collaboratively

How many workspaces do you need to deploy? The answer to this question depends a lot on your organization's structure. Customers commonly partition workspaces based on teams or departments and arrive at that division naturally.

Here are some of the other considerations where you may want to create an additional workspace

- **Azure Subscription Limits** 
  - Subscriptions have certain limits as well like 250 storage accounts, Max egress from storage accounts 50 GBps or 2500 VMs per region. Create a new workspace when you think you will approach these subscription limits. Define workspace level tags which propagate to initially provisioned resources in managed resource group. Try to follow the same pattern on how you assign a subscription to your organization and applications to Azure Databricks workspaces as well.
- **Databricks Workspace Limits**
  - Azure Databricks imposes certain API limits as it is a multitenant service to make sure that it guarantee SLAs to all the customers. Limits like **150 simultaneous jobs** in a workspace or **150 Notebooks or execution contexts attached to a cluster** or **1500 Databricks API calls/hour**
- **Dev\Test and Prod**
  - Its always recommend to have a separate workspace for Prod and Non-prod environments. Especially related to the entitlements on the resources as you may want to limit access on a Production environment compared to a Dev\Test environment where you want to give more knobs to the developers to play with. Its also recommended to create these workspaces in different subscriptions to prevent any unnecessary issues.
- **Consider isolating each workspace into its own VNET**
  - VNET Injection is a feature within Azure Databricks where you can provision the Data plane of Azure databricks within your own VNET. All you need are 2 subnets within the VNET for each workspace. You can have as many workspaces as you want within the VNET. However, we recommend to use only 1 Workspace per VNET to provide workspace level isolation completely.
- **Define workspace level tags** which propagate to initially provisioned resources in managed resource group, as well as to pools and clusters in the workspace, and then to Azure billing for chargeback

Summarizing everything so far, For a typical enterprise customer who operates different business units, At a minimum you would need 2 Databricks workspaces for each business unit for Prod and Non-prod. All the application teams within that business unit should be able to share the cluster resources accordingly.
