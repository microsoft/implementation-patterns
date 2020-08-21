## Composable Deployment Code

Below you'll find a set of fully parameterized ARM templates that can be used to deploy the above noted architecture. 

These ARM templates have been constructed in a modular way to optimize reuse potential.

Within each of the below folders you'll find a deploy.sh file that provides an example of how to sequentially deploy the templates with the appropriate parameters.

1. [Base Network](https://github.com/microsoft/implementation-patterns/tree/main/pattern-datafactory-databricks/components/base-network)
2. [Data Factory](https://github.com/microsoft/implementation-patterns/tree/main/pattern-datafactory-databricks/components/data-factory)
3. [Self Hosted Integration runtime](https://github.com/microsoft/implementation-patterns/tree/main/pattern-datafactory-databricks/components/self-hosted-integration-runtime)
4. [Azure Integration runtime](https://github.com/microsoft/implementation-patterns/tree/main/pattern-datafactory-databricks/components/azure-integration-runtime)

