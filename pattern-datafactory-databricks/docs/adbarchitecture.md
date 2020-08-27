# Azure Databricks Architecture Patterns

### Virtual Network Foundation

#### Implementation

![adfarch](https://user-images.githubusercontent.com/22504173/88923589-f4335980-d23f-11ea-9aa0-f69fee0d2aff.png)


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
