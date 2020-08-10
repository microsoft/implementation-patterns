Common Azure DevOps patterns when consuming ARM templates, following best practices.

We will be using service principals created in Azure DevOps and scoped to specific resource groups in Azure
- Azure implementation patterns connection

Azure DevOps project: https://dev.azure.com/implementation-patterns/implementation-patterns

We currently have just 2 builds:

[![Build Status](https://dev.azure.com/implementation-patterns/implementation-patterns/_apis/build/status/microsoft.implementation-patterns?branchName=main)](https://dev.azure.com/implementation-patterns/implementation-patterns/_build/latest?definitionId=2&branchName=main)

[![Build Status](https://dev.azure.com/implementation-patterns/implementation-patterns/_apis/build/status/Servicebus%20deployment?branchName=main)](https://dev.azure.com/implementation-patterns/implementation-patterns/_build/latest?definitionId=3&branchName=main)

## Best Practices
- **Outputs**: Use Outputs to extract information where needed. This can be used to generate access keys and connection strings and save them in a key vault without touching the secrets. For example, to get the Storage Access Key:

      "outputs": {
        "storageAccountKey": {
          "type": "string",
          "value": "[listKeys(resourceId('Microsoft.Storage/storageAccounts', parameters('storageAccountName')), providers('Microsoft.Storage', 'storageAccounts').apiVersions[0]).keys[0].value]"
        }
      }

  To deploy the deploy and extract the outputs in the script:

      $storageOutput = az deployment group create --resource-group $resourceGroupName --name $storageAccountName --template-file "$templatesLocation\Storage.json" --parameters storageAccountName=$storageAccountName
      $storageJSON = $storageOutput | ConvertFrom-Json
      $storageAccountAccessKey = $storageJSON.properties.outputs.storageAccountKey.value

  To upload the secret into a keyvault, use:

      az keyvault secret set --vault-name $keyVaultName --name $keyVaultSecretName --value $storageAccountAccessKey 

    
- **Parallel Jobs**: With this method of deployment, we can make use of parallel jobs. For example, to deploy storage, cdn and sql. Storage (30s) is a dependency for CDN (30s), but SQL (120s) can be deployed independently - we could argue that running this in 3 jobs will be fast

    Diagram showing serial deployment in 3 minutes
    
    Diagram showing parallel deployment in 2 minutes
    
- **Dependencies**: watch out for missing DependsOn. Troubleshooting - use a Azure CLI window. 
- **Secrets**: Don't have secrets visible in code. 
