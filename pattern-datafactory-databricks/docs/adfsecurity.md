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

  Default encryption – Secure values like **credentials/ connection strings/ keys** in linked services are by **default encrypted** and cannot be seen in plain text. The **default encrypted** fields are pre-defined per connector. Default encrypted fields are stored either on the self-hosted IR machine (when using self-hosted IR in the linked service reference) or in ADF managed Cosmos DB storage in Azure (when using Azure IR)

  Explicit encryption - Additionally, any property in Pipeline, Activity, Dataset and Linked Service JSON definition, can be **explicitly** marked as **secure string** to ensure ADF encrypts those fields as well. Once you declare a field as secure string explicitly, you will not see them in plain text. Explicitly encrypted fields are always stored in ADF managed Cosmos DB storage

  

- **Identity Management**

- **Firewall requirements for Self Hosted Integration Runtime**

  - Outbound ports and domains
  - IP addresses
  - Service endpoints
  - Private endpoints
  - On-premises Credentials encryption
