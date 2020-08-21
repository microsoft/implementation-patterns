Common Azure DevOps patterns when consuming ARM templates, following best practices.

## Sample Pipeline to deploy ARM templates

Linux runner (including sample utilizing storage account outputs and uploading the secret to Azure Key Vault):

    name: ServiceBus deployment

    trigger: 
    - master
    
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
           
           $storageOutput = az deployment group create --resource-group $resourceGroupName --name $storageAccountName --template-file "$templatesLocation\Storage.json" --parameters storageAccountName=$storageAccountName
           $storageJSON = $storageOutput | ConvertFrom-Json
           $storageAccountAccessKey = $storageJSON.properties.outputs.storageAccountKey.value

           az keyvault secret set --vault-name $keyVaultName --name $keyVaultSecretName --value $storageAccountAccessKey 

Windows runner:

    name: ServiceBus deployment

    trigger: 
    - master
    
    pool:
      vmImage: 'windows-latest'
    
    steps:
    - checkout: self  
    
    - task: AzureCLI@2
      displayName: Deploy ARM Templates
      inputs:
        azureSubscription: 'Azure implementation patterns connection'
        scriptType: ps
        scriptLocation: inlineScript
        inlineScript: | 
       
           az deployment group create --resource-group network-eastus2-rg --name network-eastus2 --template-file pattern-functions-servicebus/components/base-network/azuredeploy.json --parameters hubVnetPrefix="10.0.0.0/16" firewallSubnetPrefix="10.0.1.0/24" DNSSubnetPrefix="10.0.2.0/24" spokeVnetPrefix="10.1.0.0/16" workloadSubnetPrefix="10.1.2.0/24"
           az deployment group create --resource-group network-centralus-rg --name network-centralus --template-file pattern-functions-servicebus/components/base-network/azuredeploy.json --parameters hubVnetPrefix="10.2.0.0/16" firewallSubnetPrefix="10.2.1.0/24" DNSSubnetPrefix="10.2.2.0/24" spokeVnetPrefix="10.3.0.0/16" workloadSubnetPrefix="10.3.2.0/24"


## Best Practices
- **Outputs**: Use Outputs to extract information from ARM Templates where needed. This can be used to generate access keys, connection strings, and secrets, and save them in a key vault without touching the secrets. For example, to get a Azure Storage access key, add this code to the outputs section of the ARM template:

      "outputs": {
        "storageAccountKey": {
          "type": "string",
          "value": "[listKeys(resourceId('Microsoft.Storage/storageAccounts', parameters('storageAccountName')), providers('Microsoft.Storage', 'storageAccounts').apiVersions[0]).keys[0].value]"
        }
      }

  Then in the PowerShell script, use this to deploy the storage account and extract the outputs:

      $storageOutput = az deployment group create --resource-group $resourceGroupName --name $storageAccountName --template-file "$templatesLocation\Storage.json" --parameters storageAccountName=$storageAccountName
      $storageJSON = $storageOutput | ConvertFrom-Json
      $storageAccountAccessKey = $storageJSON.properties.outputs.storageAccountKey.value

  Now that we have the secret, we can set it in a configuration, or upload it. The sample below uploads the secret into a keyvault:

      az keyvault secret set --vault-name $keyVaultName --name $keyVaultSecretName --value $storageAccountAccessKey 

    
- **Parallel Jobs**: By default, an Azure Pipeline has one job that runs the tasks in serial. If we add multiple jobs, we can parallelize the tasks. For example, to deploy storage, CDN and SQL: Storage (30s) is a dependency for CDN (30s), but SQL (120s) can be deployed independently. - we could argue that running this in 3 jobs will be fast

    When deploying with one job, the tasks require 6 minutes to deploy. Each item must wait for the previous item to deploy.
    ![serial deployment](https://github.com/microsoft/implementation-patterns/blob/main/azure-pipelines/serialJobPipelines.png)
    
    When using multiple parallel jobs, the tasks only require 3-4 minutes. We group items that don't have dependencies, and separate long running tasks into their own job. I have a real world sample 
    ![parallel deployment](https://github.com/microsoft/implementation-patterns/blob/main/azure-pipelines/parallelJobPipelines.png)
    
    We can see see the use of multiple jobs in the sample YAML below, with the usage of "dependsOn", to create job dependencies. We can also use conditions to run particular jobs in certain circumstances. This YAML is deploying storage in one job, and some CDN, Redis, and web app services in a second job, and finally deploying a SQL server in a third job.
    
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

