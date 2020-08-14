## Security considerations

- **Customer data storage**

  Azure Data Factory (ADF) does not store your actual data during ETL workflow. It does store certain meta data (*pipeline*, *trigger*, *activity*, *linked* *service* and *dataset* definitions in JSON) and ensures that any secure string fields in the definition is always encrypted at rest

- **Network Security**

  - VNET security for Self Hosted Integration Runtime
  - Managed VNET for Azure Integration Runtime

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

- **Firewall requirements for Self Hosted Integration Runtime**

  - Outbound ports and domains

    Self-hosted IR only requires outbound ports to connect to Azure Services/ data stores. It has no inbound requirements in the firewall. 

    In the *corporate firewall*, you need to configure the following domains and **outbound** ports:

    | **Domain names**                | **Ports** | **Description**                                              |      |
    | ------------------------------- | --------- | ------------------------------------------------------------ | ---- |
    | ***.servicebus.windows.net**    | 443       | Used for communication with the back-end data movement service |      |
    | ***.core.windows.net**          | 443       | Used for staged copy through Azure Blob storage (if configured) |      |
    | ***.frontend.clouddatahub.net** | 443       | Used for communication with the back-end data movement service |      |
    | **download.microsoft.com**      | 443       | Used for downloading the updates                             |      |

    Based on your source and sink, you might have to whitelist additional domains and outbound ports in your corporate firewall or Windows firewall.

  - IP addresses

  - Service endpoints

  - Private endpoints

  - On-premises Credentials encryption
