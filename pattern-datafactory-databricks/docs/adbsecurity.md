
#  Azure Databricks Security Considerations

Here are some of the considerations within Azure Databricks that deals with all the security related nuances

## **Enable VNET Injection for the workspace**

- Make sure that you enable VNET Service endpoints or Private Link Private endpoints to all the Azure PaaS data sources

- Make sure that you delegate the subnets to the Databricks workspace and your NSG rules are configured accordingly

- Make sure that you have added Route tables (UDR's) to the subnets when you are using Firewall\NVA. You need to add the /32 IP addresses for the Control plane, Webapp and other Azure shared resources as documented in this link https://docs.microsoft.com/en-us/azure/databricks/administration-guide/cloud-configurations/azure/udr

- Make sure that you have your own custom DNS assigned to the VNET

  

## **Authentication and user provisioning**

Azure Databricks provides enterprise-grade Azure security, including Azure Active Directory integration, role-based access controls with Single sign on (SSO) capabilities

- Initial Account admins: Users that have Contributor or Owner role on the Azure Databricks workspace in the Azure Portal can sign in as account admins by clicking Launch Workspace. Please make sure that you have only the right users\groups part of the IAM for the workspace resource. They will automatically get Admin access within Databricks workspace as shown below

![image](https://user-images.githubusercontent.com/22504173/92905619-cc641380-f3f1-11ea-9e4c-097bc95c414e.png)
![image](https://user-images.githubusercontent.com/22504173/92905628-d0903100-f3f1-11ea-82b7-8e4e42114d8d.png)

- Azure Databricks admins are members of the `admin` group. To give a user admin privileges, add them to the `admin` group using the [Admin Console](https://docs.microsoft.com/en-us/azure/databricks/administration-guide/admin-console), the [Groups API](https://docs.microsoft.com/en-us/azure/databricks/dev-tools/api/latest/groups), the [SCIM API](https://docs.microsoft.com/en-us/azure/databricks/dev-tools/api/latest/scim/), or a [SCIM-enabled Identity Provider](https://docs.microsoft.com/en-us/azure/databricks/administration-guide/users-groups/scim/).

- You should be manually able to add other users as Admins by going to the "Admin Console" within the workspace and adding the email id's of the users manually. You should be able to grant them **Allow Cluster creation** and **Admin** rights on the workspace. Please make sure that you are granting these permissions only to your super users as these are elevated privileges

  ![image](https://user-images.githubusercontent.com/22504173/92907414-4c3ead80-f3f3-11ea-86f0-e99cce3fb572.png)

  

  ## **Access controls**

  By default, all users can create and modify clusters unless an administrator enables cluster access control. Admins need to enable **Cluster access control** as part of the Admin console. This will allow the admins to now give fine grain access to users on performing certain operations. Example Attach to cluster, edit cluster etc. Table, cluster, pool, job, and workspace access control are available only in the [Azure Databricks Premium Plan](https://databricks.com/product/azure-pricing). You can then enable **No permissions, Can attach to, Can Restart or Can Manage** to your individual users

  ![image](https://user-images.githubusercontent.com/22504173/92912811-2a93f500-f3f8-11ea-9af2-1ca84dbb32fe.png)


  ![image](https://user-images.githubusercontent.com/22504173/92914411-9b87dc80-f3f9-11ea-803b-fdbea72a4b54.png)

- Admins need to enable **Workspace Access control**, Without Workspace access control enabled, All users can see all items within the workspace. WAC will make sure that the individual user folders /Users will become private. Admins can provide fine grained access control to users 


![image](https://user-images.githubusercontent.com/22504173/92913462-c4f43880-f3f8-11ea-9e97-eafd073fe456.png)


- Similarly we need to enable **Jobs access control** to provide fine grain access control to users to manage Jobs. By default, all users can create and modify jobs unless an administrator enables jobs access control. With jobs access control, individual permissions determine a user’s abilities.

  ![image](https://user-images.githubusercontent.com/22504173/92915285-69c34580-f3fa-11ea-9991-f97fd64aaf7c.png)

- Table access control (table ACLs) lets you programmatically grant and revoke access to your data from SQL, Python, and PySpark. Databricks supports fine-grained access control via the Spark SQL interface. By default, all users have access to all data stored in a cluster’s managed tables unless an administrator enables table access control for that cluster. Once table access control is enabled for a cluster, users can set permissions for data objects on that c luster. Once you enable Table access control at the cluster level, you should be able to set data object privileges accordingly similar to any RDBMS permissions. Example DENY SELECT ON <table-name> TO `<user>@<domain-name>`. Its only available on a High Concurrency cluster.

  ![image](https://user-images.githubusercontent.com/22504173/92916985-09cd9e80-f3fc-11ea-92e2-a80a7976505d.png)
