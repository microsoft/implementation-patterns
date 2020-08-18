Common Azure DevOps patterns when consuming ARM templates, following best practices.

We will be using service principals created in Azure DevOps and scoped to specific resource groups in Azure
- Azure implementation patterns connection

Azure DevOps project: https://dev.azure.com/implementation-patterns/implementation-patterns

We currently have just 2 builds:

[![Build Status](https://dev.azure.com/implementation-patterns/implementation-patterns/_apis/build/status/microsoft.implementation-patterns?branchName=main)](https://dev.azure.com/implementation-patterns/implementation-patterns/_build/latest?definitionId=2&branchName=main)

[![Build Status](https://dev.azure.com/implementation-patterns/implementation-patterns/_apis/build/status/Servicebus%20deployment?branchName=main)](https://dev.azure.com/implementation-patterns/implementation-patterns/_build/latest?definitionId=3&branchName=main)

## Sample Pipeline

          more details incoming/ TBD
          name: ServiceBus deployment

    trigger: none
    
    pool:
      vmImage: 'ubuntu-latest'
    
    steps:
    - checkout: self  
    
    - task: AzureCLI@2
      displayName: Deploy ARM Templates
      inputs:
        azureSubscription: 'Azure implementation patterns connection'
        scriptType: pscore
        scriptLocation: inlineScript
        inlineScript: | 
       
           az deployment group create --resource-group network-eastus2-rg --name network-eastus2 --template-file pattern-functions-servicebus/components/base-network/azuredeploy.json --parameters hubVnetPrefix="10.0.0.0/16" firewallSubnetPrefix="10.0.1.0/24" DNSSubnetPrefix="10.0.2.0/24" spokeVnetPrefix="10.1.0.0/16" workloadSubnetPrefix="10.1.2.0/24"
           az deployment group create --resource-group network-centralus-rg --name network-centralus --template-file pattern-functions-servicebus/components/base-network/azuredeploy.json --parameters hubVnetPrefix="10.2.0.0/16" firewallSubnetPrefix="10.2.1.0/24" DNSSubnetPrefix="10.2.2.0/24" spokeVnetPrefix="10.3.0.0/16" workloadSubnetPrefix="10.3.2.0/24"


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

    Diagram showing serial deployment in 6 minutes. Each item must wait for the previous item to deploy.
    ![serial deployment](https://github.com/microsoft/implementation-patterns/blob/main/azure-pipelines/serialJobPipelines.png)
    
    Diagram showing parallel deployment in 3-4 minutes. We group items that don't have dependencies, and separate long running tasks into their own job.
    ![parallel deployment](https://github.com/microsoft/implementation-patterns/blob/main/azure-pipelines/parallelJobPipelines.png)
    
    We can see see the use of multiple jobs in the sample YAML below, with the usage of "dependsOn", to create job dependencies. We can also use conditions to run particular jobs in certain circumstances
    
        jobs:


          - job: DeployStorage
            displayName: 'Deploy Key Vault and Azure Storage'
            pool:
              vmImage: windows-latest
            steps:
            - task: DownloadBuildArtifacts@0
              displayName: 'Download the build artifacts'
              inputs:
                buildType: 'current'
                downloadType: 'single'
                artifactName: 'drop'
                downloadPath: '$(build.artifactstagingdirectory)'
            - task: AzureCLI@2
              displayName: 'Deploy ARM templates'
              inputs:
                azureSubscription: 'Service connection to Azure Portal'
                scriptType: ps
                scriptLocation: inlineScript
                inlineScript: |             
                $keyVaultName = "$appPrefix-$environment-$locationShort-vault"
                $storageAccountName = "$appPrefix$environment$($locationShort)storage"
                $templatesLocation = "$(build.artifactstagingdirectory)\drop\ARMTemplates"
               
                #Create resource group
                az group create --name $resourceGroupName --location $location 
                
                #Key vault
                az deployment group create --resource-group $resourceGroupName --name $keyVaultName --template-file "$templatesLocation\AzureKeyVault.json" --parameters keyVaultName=$keyVaultName
                
                #Storage
                $storageOutput = az deployment group create --resource-group $resourceGroupName --name $storageAccountName --template-file "$templatesLocation\AzureStorage.json" --parameters storageAccountName=$storageAccountName
 

          - job: DeployServices
            displayName: 'Deploy CDN, Redis, App insights, and Web apps'
            pool:
              vmImage: windows-latest
            dependsOn: DeployStorage
            steps:
            - task: DownloadBuildArtifacts@0
              displayName: 'Download the build artifacts'
              inputs:
                buildType: 'current'
                downloadType: 'single'
                artifactName: 'drop'
                downloadPath: '$(build.artifactstagingdirectory)'
            - task: AzureCLI@2
              displayName: 'Deploy ARM templates'
              inputs:
                azureSubscription: 'Service connection to Azure Portal'
                scriptType: ps
                scriptLocation: inlineScript
                inlineScript: |             
                #Deploy abc/def/ghi/klm


          - job: DeploySQL
            displayName: 'Deploy Azure SQL'
            pool:
              vmImage: windows-latest
            dependsOn: DeployStorage
            steps:
            - task: DownloadBuildArtifacts@0
              displayName: 'Download the build artifacts'
              inputs:
                buildType: 'current'
                downloadType: 'single'
                artifactName: 'drop'
                downloadPath: '$(build.artifactstagingdirectory)'
            - task: AzureCLI@2
              displayName: 'Deploy ARM templates'
              inputs:
                azureSubscription: 'Service connection to Azure Portal'
                scriptType: ps
                scriptLocation: inlineScript
                inlineScript: |             
                #Deploy abc/def/ghi/klm
    
- **Dependencies**: watch out for missing DependsOn. Troubleshooting - use a Azure CLI window. 

          more details incoming/ TBD
- **Secrets**: Don't have secrets visible in code. 

          more details incoming/ TBD
