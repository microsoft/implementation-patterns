## Security consideration

- **Customer data storage**

  Azure Data Factory (ADF) does not store your actual data during ETL workflow. It does store certain meta data (*pipeline*, *trigger*, *activity*, *linked* *service* and *dataset* definitions in JSON) and ensures that any secure string fields in the definition is always encrypted at rest

- **Network Security**

  - VNET security for Self Hosted Integration Runtime
  - Managed VNET for Azure Integration Runtime

- **Data encryption in transit**

- **Data encryption at rest**

  - Customer Managed Keys for ADF

- **Compliance**

- **Firewall requirements for Self Hosted Integration Runtime**
  - Outbound ports and domains
  - IP addresses
  - Service endpoints
  - Private endpoints
  - On-premises Credentials encryption

