## Security considerations

- **Customer data storage**

  Azure Data Factory (ADF) does not store your actual data during ETL workflow. It does store certain meta data (*pipeline*, *trigger*, *activity*, *linked* *service* and *dataset* definitions in JSON) and ensures that any secure string fields in the definition is always encrypted at rest

- **Data encryption in transit**

- **Data encryption at rest**

  - Customer Managed Keys for ADF

    Azure Data Factory encrypts data at rest, including entity definitions, any data cached while runs are in progress, and data cached for Data Preview. By default, data is encrypted with a randomly generated Microsoft-managed key that is uniquely assigned to your data factory. You can now enable Bring Your Own Key (BYOK) with customer-managed keys(CMK) feature in Azure Data Factory. When you specify a CMK, Data Factory uses **both** the factory system key and the CMK to encrypt customer data

    It can only be configured on empty data factory, you need to enable it right after data factory is created and requires to have a Azure Key vault in the same region and AAD tenant. You cannot disable CMK once enabled.

    ![image](https://user-images.githubusercontent.com/22504173/90235263-0213dd80-ddef-11ea-9f4f-531557cfd734.png)

- **Credentials Encryption**

  **Default encryption** – Secure values like credentials/ connection strings/ keys in linked services are by default encrypted and cannot be seen in plain text. The default encrypted fields are pre-defined per connector. Default encrypted fields are stored either on the self-hosted IR machine (when using self-hosted IR in the linked service reference) or in ADF managed Cosmos DB storage in Azure (when using Azure IR); **Explicit encryption** - Additionally, any property in Pipeline, Activity, Dataset and Linked Service JSON definition, can be explicitly marked as secure string to ensure ADF encrypts those fields as well. Once you declare a field as secure string explicitly, you will not see them in plain text. Explicitly encrypted fields are always stored in ADF managed Cosmos DB storage

  - **Store encrypted credentials in an Azure Data Factory managed store (in Cloud)**. Data Factory helps protect your data store credentials by encrypting them with certificates managed by Microsoft. These certificates are rotated every two years . The encrypted credentials are securely stored in an Azure Cosmos DB managed by Azure Data Factory. 

  - **Store credentials locally when using self-hosted IR (on-premise/ on self-hosted IR machine)**. If you want to encrypt and store credentials locally on the self-hosted integration runtime, follow the steps in [Encrypt credentials for on-premises data stores in Azure Data Factory](https://docs.microsoft.com/en-us/azure/data-factory/encrypt-credentials-self-hosted-integration-runtime). All connectors support this option. The self-hosted integration runtime uses Windows [DPAPI](https://msdn.microsoft.com/library/ms995355.aspx) to encrypt the sensitive data and credential information. Use the **New-AzDataFactoryV2LinkedServiceEncryptedCredential** cmdlet to encrypt linked service credentials and sensitive details in the linked service. You can then use the JSON returned to create a linked service by using the **Set-AzDataFactoryV2LinkedService** cmdlet.

  - **Store credentials in Azure Key Vault**. You can also store the data store's credentials in [Azure Key Vault](https://azure.microsoft.com/services/key-vault/). Data Factory retrieves the credential during the execution of an activity. For more information, see [Store credential in Azure Key Vault](https://docs.microsoft.com/en-us/azure/data-factory/store-credentials-in-key-vault).

  

- **Identity Management**

  As explained above, we have different options to connect using credentials to data sources. When creating a data factory, a managed identity can be created along with factory creation. The managed identity is a managed application registered to Azure Active Directory, and represents this specific data factory. Its created automatically when using Azure Portal or Powershell.

  Here is a snippet on how you would assign this in ARM template

  ```
  ​```json
  {
      "contentVersion": "1.0.0.0",
      "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
      "resources": [{
          "name": "<dataFactoryName>",
          "apiVersion": "2018-06-01",
          "type": "Microsoft.DataFactory/factories",
          "location": "<region>",
          "identity": {
  			"type": "SystemAssigned"
  		}
      }]
  }
  ​```
  ```

- **Network Security for Azure Integration Runtime**

  By default, Azure Integration runtime is created in public space and supports connecting to data stores and computes services with public accessible endpoints. 

  - Managed virtual network

    Currently in preview, this option will allow us to host Azure Integration runtime securely within a ADF managed Virtual network(meaning customer doesnt own this VNET). In this way, you can only connect to Azure data sources securely using a managed private endpoint. Only port 443 is opened for outbound connections.

    ![image](https://user-images.githubusercontent.com/22504173/90241980-2628ec00-ddfa-11ea-90ce-c0e2e28fb4c8.png)
    ![image](https://user-images.githubusercontent.com/22504173/90242310-c7b03d80-ddfa-11ea-84d4-fd1d677a9f45.png)

    

- **Network Security for Self Hosted Integration Runtime**

  - Service endpoints\ Private endpoints

    In case you are hosting Self hosted Integration runtime on a Azure VNET, then you could enable Service endpoints or Private endpoints to your Azure PaaS data stores. This will guarantee that the traffic is reaching to these respective data stores from Self hosted IR securely over Azure backbone and Private endpoints will also ensure that your outbound traffic is going over a private IP address local to the VNET. 

  - Outbound ports and domains

    Self-hosted IR only requires outbound ports to connect to Azure Services/ data stores. It has no inbound requirements in the firewall. In the *corporate firewall*, you need to configure the following domains and **outbound** ports:

    | **Domain names**                | **Ports** | **Description**                                              |      |
    | ------------------------------- | --------- | ------------------------------------------------------------ | ---- |
    | ***.servicebus.windows.net**    | 443       | Used for communication with the back-end data movement service |      |
    | ***.core.windows.net**          | 443       | Used for staged copy through Azure Blob storage (if configured) |      |
    | ***.frontend.clouddatahub.net** | 443       | Used for communication with the back-end data movement service |      |
    | **download.microsoft.com**      | 443       | Used for downloading the updates                             |      |

    Based on your source and sink, you might have to whitelist additional domains and outbound ports in your corporate firewall or Windows firewall.

  - IP addresses and URLs whitelisting

    In the above table, you can see that we are using Wildcard domains which is not allowed by many security teams at regulated industries. In those scenarios, you can check the View Service URLs on the Self hosted Integration runtime properties to get all the URLs which can be whitelisted on your external firewall.

    ![image](https://user-images.githubusercontent.com/22504173/90240950-2b853700-ddf8-11ea-8a92-15756aeacfa4.png)
    ![image](https://user-images.githubusercontent.com/22504173/90241000-38a22600-ddf8-11ea-80b9-d2b7e6823a0a.png)

    

    
