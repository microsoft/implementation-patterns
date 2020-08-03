Common Azure DevOps patterns when consuming ARM templates, following best practices.

We will be using service principals created in Azure DevOps and scoped to specific resource groups in Azure
- Azure implementation patterns connection

Azure DevOps project: https://dev.azure.com/implementation-patterns/implementation-patterns

We currently have just 2 builds:

[![Build Status](https://dev.azure.com/implementation-patterns/implementation-patterns/_apis/build/status/microsoft.implementation-patterns?branchName=main)](https://dev.azure.com/implementation-patterns/implementation-patterns/_build/latest?definitionId=2&branchName=main)

[![Build Status](https://dev.azure.com/implementation-patterns/implementation-patterns/_apis/build/status/Servicebus%20deployment?branchName=main)](https://dev.azure.com/implementation-patterns/implementation-patterns/_build/latest?definitionId=3&branchName=main)

## Best Practices
- **Outputs**: Use Outputs to extract information where needed. For example, to get the Storage Access Key:

      ARM code to prepare property for extraction

  This in the script, you can access it like this:

      Azure CLI to extract output

  To save in a keyvault, use:

      Azure CLI to save KeyVault code
    
- **Parallel Jobs**: With this method of deployment, we can make use of parallel jobs. For example, to deploy storage, cdn and sql. Storage (30s) is a dependency for CDN (30s), but SQL (120s) can be deployed independently - we could argue that running this in 3 jobs will be fast

    Diagram showing serial deployment in 3 minutes
    
    Diagram showing parallel deployment in 2 minutes
    
- **Dependencies**: watch out for missing DependsOn. Troubleshooting - use a Azure CLI window. 
- **Secrets**: Don't have secrets visible in code. 
