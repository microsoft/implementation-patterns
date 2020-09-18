# Security in Azure Cosmos DB
## Security Considerations
Data security is a shared responsibility between you, the customer, and your database provider. Depending on the database provider you choose, the amount of responsibility you carry can vary. If you choose an on-premises solution, you need to provide everything from end-point protection to physical security of your hardware - which is no easy task. If you choose a PaaS cloud database provider such as Azure Cosmos DB, your area of concern shrinks considerably.

![](https://docs.microsoft.com/en-us/azure/cosmos-db/media/database-security/nosql-database-security-responsibilities.png)

The preceding diagram shows high-level cloud security components, but what items do you need to worry about specifically for your database solution? And how can you compare solutions to each other?

We recommend the following checklist of requirements on which to compare database systems:

- Network security and firewall settings
- User authentication and fine grained user controls
- Ability to replicate data globally for regional failures
- Ability to fail over from one data center to another
- Local data replication within a data center
- Automatic data backups
- Restoration of deleted data from backups
- Protect and isolate sensitive data
- Monitoring for attacks
- Responding to attacks
- Ability to geo-fence data to adhere to data governance restrictions
- Physical protection of servers in protected data centers
- Certifications

And although it may seem obvious, recent [large-scale database breaches](https://thehackernews.com/2017/01/mongodb-database-security.html) remind us of the simple but critical importance of the following requirements:

- Patched servers that are kept up-to-date
- HTTPS by default/TLS encryption
- Administrative accounts with strong passwords

## How does Azure Cosmos DB secure database

Let's look back at the preceding list - how many of those security requirements does Azure Cosmos DB provide? Every single one.

Let's dig into each one in detail.

|Security requirement|Azure Cosmos DB's security approach|
|---|---|
|Network security|Using an IP firewall is the first layer of protection to secure your database. Azure Cosmos DB supports policy driven IP-based access controls for inbound firewall support. The IP-based access controls are similar to the firewall rules used by traditional database systems, but they are expanded so that an Azure Cosmos database account is only accessible from an approved set of machines or cloud services. <br><br>Azure Cosmos DB enables you to enable a specific IP address (168.61.48.0), an IP range (168.61.48.0/8), and combinations of IPs and ranges. <br><br>All requests originating from machines outside this allowed list are blocked by Azure Cosmos DB. Requests from approved machines and cloud services then must complete the authentication process to be given access control to the resources.<br><br> You can use virtual network service tags to achieve network isolation and protect your Azure Cosmos DB resources from the general Internet. Use service tags in place of specific IP addresses when you create security rules. By specifying the service tag name (for example, AzureCosmosDB) in the appropriate source or destination field of a rule, you can allow or deny the traffic for the corresponding service.|
|Authorization|Azure Cosmos DB uses hash-based message authentication code (HMAC) for authorization. <br><br>Each request is hashed using the secret account key, and the subsequent base-64 encoded hash is sent with each call to Azure Cosmos DB. To validate the request, the Azure Cosmos DB service uses the correct secret key and properties to generate a hash, then it compares the value with the one in the request. If the two values match, the operation is authorized successfully and the request is processed, otherwise there is an authorization failure and the request is rejected.<br><br>You can use either a master key, or a resource token allowing fine-grained access to a resource such as a document.|
|Users and permissions|Using the master key for the account, you can create user resources and permission resources per database. A resource token is associated with a permission in a database and determines whether the user has access (read-write, read-only, or no access) to an application resource in the database. Application resources include container, documents, attachments, stored procedures, triggers, and UDFs. The resource token is then used during authentication to provide or deny access to the resource.|
|Active directory integration (RBAC)| You can also provide or restrict access to the Cosmos account, database, container, and offers (throughput) using Access control (IAM) in the Azure portal. IAM provides role-based access control and integrates with Active Directory. You can use built in roles or custom roles for individuals and groups.|
|Global replication|Azure Cosmos DB offers turnkey global distribution, which enables you to replicate your data to any one of Azure's world-wide datacenters with the click of a button. Global replication lets you scale globally and provide low-latency access to your data around the world.<br><br>In the context of security, global replication ensures data protection against regional failures.|
|Regional failovers|If you have replicated your data in more than one data center, Azure Cosmos DB automatically rolls over your operations should a regional data center go offline. You can create a prioritized list of failover regions using the regions in which your data is replicated.|
|Local replication|Even within a single data center, Azure Cosmos DB automatically replicates data for high availability giving you the choice of [consistency levels](https://github.com/microsoft/implementation-patterns/blob/main/pattern-cosmosdb/docs/reliability.md#consistency-levels). This replication guarantees a 99.99% [availability SLA](https://github.com/microsoft/implementation-patterns/blob/main/pattern-cosmosdb/docs/reliability.md#slas-for-availability) for all single region accounts and all multi-region accounts with relaxed consistency, and 99.999% read availability on all multi-region database accounts.|
|Automated online backups|Azure Cosmos databases are backed up regularly and stored in a geo redundant store.|
|Restore deleted data|The automated online backups can be used to recover data you may have accidentally deleted up to ~30 days after the event.|
|Protect and isolate sensitive data|All data in the regions listed in What's new? is now encrypted at rest.<br><br>Personal data and other confidential data can be isolated to specific container and read-write, or read-only access can be limited to specific users.|
|Monitor for attacks|By using audit logging and activity logs, you can monitor your account for normal and abnormal activity. You can view what operations were performed on your resources, who initiated the operation, when the operation occurred, the status of the operation, and much more as shown in the screenshot following this table.|
|Respond to attacks|Once you have contacted Azure support to report a potential attack, a 5-step incident response process is kicked off. The goal of the 5-step process is to restore normal service security and operations as quickly as possible after an issue is detected and an investigation is started.<br><br>Learn more in [Microsoft Azure Security Response in the Cloud](https://gallery.technet.microsoft.com/Shared-Responsibilities-81d0ff91).|
|Geo-fencing|Azure Cosmos DB ensures data governance for sovereign regions (for example, Germany, China, US Gov).|
|Protected facilities|Data in Azure Cosmos DB is stored on SSDs in Azure's protected data centers.|
|HTTPS/SSL/TLS encryption|All connections to Azure Cosmos DB support HTTPS. Azure Cosmos DB also supports TLS 1.2.<br>It is possible to enforce a minimum TLS version server-side. To do so, please contact [azurecosmosdbtls@service.microsoft.com](mailto:azurecosmosdbtls@service.microsoft.com).|
|Encryption at rest|All data stored into Azure Cosmos DB is encrypted at rest.|
|Patched servers|As a managed database, Azure Cosmos DB eliminates the need to manage and patch servers, that's done for you, automatically.|
|Administrative accounts with strong passwords|It's hard to believe we even need to mention this requirement, but unlike some of our competitors, it's impossible to have an administrative account with no password in Azure Cosmos DB.<br><br> Security via TLS and HMAC secret based authentication is baked in by default.|
|Security and data protection certifications| For the most up-to-date list of certifications see the overall [Azure Compliance site](https://www.microsoft.com/en-us/trustcenter/compliance/complianceofferings) as well as the latest [Azure Compliance Document](https://gallery.technet.microsoft.com/Overview-of-Azure-c1be3942) with all certifications (search for Cosmos). For a more focused read check out the April 25, 2018 post [Azure #CosmosDB: Secure, private, compliant that includes SOCS 1/2 Type 2, HITRUST, PCI DSS Level 1, ISO 27001, HIPAA, FedRAMP High, and many others.

The following screenshot shows how you can use audit logging and activity logs to monitor your account: 

---
> [Back to TOC](../README.md#TOC)
