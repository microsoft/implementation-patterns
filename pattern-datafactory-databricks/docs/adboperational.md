# Operational Considerations for Azure Databricks

## Monitoring: 

Monitoring is a critical part of any production-level solution, and Azure Databricks offers robust functionality for monitoring custom application metrics, streaming query events, and application log messages. Azure Databricks can send this monitoring data to different logging services.

The following steps show how to send monitoring data from Azure Databricks to Azure Monitor, the monitoring data platform for Azure: 

Before you begin, ensure you have the following prerequisites in place:

1. Clone or download this [GitHub repository](https://github.com/mspnp/spark-monitoring).
2. An active Azure Databricks workspace. For instructions on how to deploy an Azure Databricks workspace, see get started with Azure Databricks..
3. Install the Azure Databricks CLI.
    * An Azure Databricks personal access token is required to use the CLI. For instructions, see token management.
    * You can also use the Azure Databricks CLI from the Azure Cloud Shell.
4. A Java IDE, with the following resources:
   * Java Devlopment Kit (JDK) version 1.8
   * Scala language SDK 2.11
   * Apache Maven 3.5.4
5. Follow the remaining steps in the repo above. 

## Continuous Integration and Delivery: 

Though it can vary based on your needs, a typical configuration for an Azure Databricks pipeline includes the following steps:

# Continuous integration:

1. Code
    * Develop code and unit tests in an Azure Databricks notebook or using an external IDE.</li>
    * Manually run tests. </li>
    * Commit code and tests to a git branch.
2. Build
    * Gather new and updated code and tests.</li>
    * Run automated tests.</li>
    * Build libraries and non-notebook Apache Spark code.</li>
3. Release: Generate a release artifact.

# Continuous delivery:

1. Deploy
   * Deploy notebooks.
   * Deploy libraries.
2. Test: Run automated tests and report results.
3. Operate: Programmatically schedule data engineering, analytics, and machine learning workflows.
