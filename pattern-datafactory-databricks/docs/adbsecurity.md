#  Azure Databricks Security Considerations

Here are some of the considerations within Azure Databricks that deals with all the security related nuances

## **Enable VNET Injection for the workspace**

- Make sure that you enable VNET Service endpoints or Private Link Private endpoints to all the Azure PaaS data sources

- Make sure that you delegate the subnets to the Databricks workspace and your NSG rules are configured accordingly

- Make sure that you have added Route tables (UDR's) to the subnets when you are using Firewall\NVA. You need to add the /32 IP addresses for the Control plane, Webapp and other Azure shared resources as documented in this link https://docs.microsoft.com/en-us/azure/databricks/administration-guide/cloud-configurations/azure/udr

- Make sure that you have your own custom DNS assigned to the VNET

- Enable IP Access lists for your workspace https://docs.microsoft.com/en-us/azure/databricks/security/network/ip-access-list

  

## **Regulate user provisioning**

Azure Databricks provides enterprise-grade Azure security, including Azure Active Directory integration, role-based access controls with Single sign on (SSO) capabilities. It allows for Multi Factory Authentication and Azure AD conditional access.

- Initial Account admins: Users that have Contributor or Owner role on the Azure Databricks workspace in the Azure Portal can sign in as account admins by clicking Launch Workspace. Please make sure that you have only the right users\groups part of the IAM for the workspace resource. They will automatically get Admin access within Databricks workspace as shown below

![image](https://user-images.githubusercontent.com/22504173/92905619-cc641380-f3f1-11ea-9e4c-097bc95c414e.png)
![image](https://user-images.githubusercontent.com/22504173/92905628-d0903100-f3f1-11ea-82b7-8e4e42114d8d.png)

- Azure Databricks admins are members of the `admin` group. To give a user admin privileges, add them to the `admin` group using the [Admin Console](https://docs.microsoft.com/en-us/azure/databricks/administration-guide/admin-console), the [Groups API](https://docs.microsoft.com/en-us/azure/databricks/dev-tools/api/latest/groups), the [SCIM API](https://docs.microsoft.com/en-us/azure/databricks/dev-tools/api/latest/scim/), or a [SCIM-enabled Identity Provider](https://docs.microsoft.com/en-us/azure/databricks/administration-guide/users-groups/scim/).

Azure Databricks supports SCIM, an open standard that allows you to automate user/group provisioning via a gallery application. SCIM lets you use Azure Active Directory to create users in Azure Databricks and give them the proper level of access, as well as remove access for users (deprovision them) when they leave the organization or no longer need access to Azure Databricks.


- You should be manually able to add other users as Admins by going to the "Admin Console" within the workspace and adding the email id's of the users manually. You should be able to grant them **Allow Cluster creation** and **Admin** rights on the workspace. Please make sure that you are granting these permissions only to your super users as these are elevated privileges

  ![image](https://user-images.githubusercontent.com/22504173/92907414-4c3ead80-f3f3-11ea-86f0-e99cce3fb572.png)

  

  ## Enable Azure AD Credential Passthrough

  When enabled, authentication automatically takes place in Azure Data Lake Storage (ADLS Gen2) from Azure Databricks clusters using the same Azure Active Directory (Azure AD) identity that one uses to log into Azure Databricks. Commands running on a configured cluster will be able to read and write data in ADLS without needing to configure service principal credentials. Any ACLs applied at the folder or file level in ADLS are enforced based on the user's identity. ADLS Gen2 support hierarchical namespaces which can provide granular permissions at a folder or file level using ACL's. This will reduce another layer of permissioning needed to grant to databricks users. This currently works for SparkSQL and Python workloads only.

  ![image](https://user-images.githubusercontent.com/22504173/92925511-98e0b380-f408-11ea-9711-6fba5b78c805.png)

  For Standard clusters, You need to provide the user name which will be used to access ADLS Gen2. For High concurrency cluster, you just need to check the box to enable credential passthrough. 

  ADLS Passthrough is configured when you create a cluster in the Azure Databricks workspace. ADLS Gen1 requires Databricks Runtime 5.1+. ADLS Gen2 requires 5.3+.

  

  ## Always Hide secrets in a Key vault

  Please make sure not to expose any sensitive information like Connection strings or passwords in Clear text. This can be a security violation for many compliance scenarios. You should always use a vault to securely store and access them. You can either use Data bricks internal Key Vault for this purpose or use Azure's Key Vault.

  If using Azure Key Vault, create separate AKV-backed secret scopes and corresponding AKVs to store credentials pertaining to different data stores. This will help prevent users from accessing credentials that they might not have access to. Since access controls are applicable to the entire secret scope, users with access to the scope will see all secrets for the AKV associated with that scope.

  For Azure Key Vault backed secret scope

  You need to access the following URL  https://<databricks workspace URL>#secrets/createScope

  ![image](https://user-images.githubusercontent.com/22504173/92942989-33002600-f420-11ea-8131-13d568efb3de.png)

  

  Running the below command within the notebook will be able to retrieve the keys from AKV during execution

  ```bash
  dbutils.secrets.get(scope = "akvtest", key = "MySecret")
  ```

  The following command in Databricks CLI will allow you to see all the secret scopes associated with your workspace

  ```bash
  C:\Program Files (x86)\Microsoft Visual Studio\Shared\Python37_64>databricks secrets list-scopes
  Scope    Backend         KeyVault URL
  -------  --------------  ---------------------------------
  akvtest  AZURE_KEYVAULT  https://srgo****.vault.azure.net/
  ```

  

  

  ## Do not store anything on the Default DBFS location

  This recommendation is driven by security and data availability concerns. Every Workspace comes with a default DBFS, primarily designed to store libraries and other system-level configuration artifacts such as Init scripts. You should not store any production data in it, because:

  1. The lifecycle of default DBFS is tied to the Workspace. Deleting the workspace will also delete the default DBFS and permanently remove its contentents.
  2. One can't restrict access to this default folder and its contents.

  ***This recommendation doesn't apply to Blob or ADLS folders explicitly mounted as DBFS by the end user***



  ## Configure Customer-managed keys on Notebooks
You can now encrypt Notebooks within your workspace with a Customer Managed Key in your Azure Key vault. You enable the key for Azure Databricks notebook encryption and open a support ticket to deliver the resource identifier of the key who will then encrypt the encrypted key as documented in this link https://docs.microsoft.com/en-us/azure/databricks/security/keys/customer-managed-key-notebook
  ![image](https://user-images.githubusercontent.com/22504173/92971967-69a16500-f44f-11ea-9ca8-1ce3d1c5dcf7.png)

  ## Configure Customer-managed keys on default (root) DBFS

  Please encrypt the default root DBFS storage account which is present in the locked storage encrypted with a Customer Managed Key (CMK) from Azure Key Vault. By default, Its managed by a Microsoft managed key but changing it to a CMK with proper key rotation is the best way to secure the root DBFS. This is currently in preview and your subscription needs to be whitelisted for this service. Create a Managed Identity on the DBFS root and then add it to the Access policy on the Key vault.

  ![image](https://user-images.githubusercontent.com/22504173/92959241-74e99600-f439-11ea-865b-84d528ff6571.png)
  ![image](https://user-images.githubusercontent.com/22504173/92959255-79ae4a00-f439-11ea-86a3-9ef6efe4bd9c.png)

 Apart from the Root DBFS, Any Blob storage or ADLS Gen2 mounted to the cluster needs to have Encryption with CMK and ACL's applied at folder and file level for security purposes.

  ## Configure Audit logs via Diagnostic settings in Azure Monitor
  Databricks provides comprehensive end-to-end audit logs of activities performed by Databricks users, allowing your enterprise to monitor detailed Databricks usage patterns. This is available via seamless integration with Azure Monitor.
  
Services / Entities included are:
      Accounts
      Clusters
      Notebooks
      DBFS
      Workspace
      Jobs
      Secrets
      SSH
      SQL Permissions


  ## **Enable Access controls**

  By default, all users can create and modify clusters unless an administrator enables cluster access control. Admins need to enable **Cluster access control** as part of the Admin console. This will allow the admins to now give fine grain access to users on performing certain operations. Example Attach to cluster, edit cluster etc. Table, cluster, pool, job, and workspace access control are available only in the [Azure Databricks Premium Plan](https://databricks.com/product/azure-pricing). You can then enable **No permissions, Can attach to, Can Restart or Can Manage** to your individual users

  ![image](https://user-images.githubusercontent.com/22504173/92912811-2a93f500-f3f8-11ea-9af2-1ca84dbb32fe.png)


  ![image](https://user-images.githubusercontent.com/22504173/92914411-9b87dc80-f3f9-11ea-803b-fdbea72a4b54.png)

- Admins need to enable **Workspace Access control**, Without Workspace access control enabled, All users can see all items within the workspace. WAC will make sure that the individual user folders /Users will become private. Admins can provide fine grained access control to users 


![image](https://user-images.githubusercontent.com/22504173/92913462-c4f43880-f3f8-11ea-9e97-eafd073fe456.png)



- Similarly we need to enable **Jobs access control** to provide fine grain access control to users to manage Jobs. By default, all users can create and modify jobs unless an administrator enables jobs access control. With jobs access control, individual permissions determine a user’s abilities.

  ![image](https://user-images.githubusercontent.com/22504173/92915285-69c34580-f3fa-11ea-9991-f97fd64aaf7c.png)

- Table access control (table ACLs) lets you programmatically grant and revoke access to your data from SQL, Python, and PySpark. Databricks supports fine-grained access control via the Spark SQL interface. By default, all users have access to all data stored in a cluster’s managed tables unless an administrator enables table access control for that cluster. Once table access control is enabled for a cluster, users can set permissions for data objects on that c luster. Once you enable Table access control at the cluster level, you should be able to set data object privileges accordingly similar to any RDBMS permissions. Example DENY SELECT ON <table-name> TO `<user>@<domain-name>`. Its only available on a High Concurrency cluster.

  ![image](https://user-images.githubusercontent.com/22504173/92916985-09cd9e80-f3fc-11ea-92e2-a80a7976505d.png)



