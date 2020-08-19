## Rehydration\Maintenance of Self hosted Integration Runtime

Often times there are situations where you want to do maintenance or patching on the Windows VM's which run Self hosted Integration runtime. In these situations, you may want to **take your node out of the node pool** for the self hosted integration runtime and then **add the node back** after all the rehydration has been complete or in some scenarios, add a new node altogether.

### **Removing a node from Integration Runtime can be done manually from Azure portal or using Powershell:**

Azure portal:

![image](https://user-images.githubusercontent.com/22504173/90650963-8066ea00-e20a-11ea-82a6-82faee1a183a.png)

Powershell:

```powershell
Remove-AzDataFactoryV2IntegrationRuntimeNode -DataFactoryName 'srgoadfv2devopsint' -IntegrationRuntimeName 'ofhwzklincclu' -NodeName 'Node_3' -ResourceGroupName 'TESTRG'
```

Once the node is removed from the Node pool for Self hosted Integration runtime, you could do all the maintenance activities on the node like Windows updates etc before its added back. In some scenarios, you can decommission this VM and provision another VM which is ready to go.

### **Adding the same node back to the node pool within the self hosted integration runtime**:

You can add the node back to the node pool again by manually registering with UI or by using Powershell

Either way, you need to get the AuthKeys to register the node to the Integration runtime

You can obtain this either from Azure portal or by Powershell

Azure portal:

![image](https://user-images.githubusercontent.com/22504173/90652668-4f87b480-e20c-11ea-8739-daca29509bbd.png)

Powershell:

```powershell
Get-AzDataFactoryV2IntegrationRuntimeKey -ResourceGroupName 'TESTRG' -DataFactoryName 'srgoadfv2devopsint' -Name 'ofhwzklincclu'
```

You get something like this as the output

AuthKey1                         AuthKey2

--------                         --------

IR@89895504-f647-48fd-8dd3-42fa556d67e3******      IR@89895504-f647-48fd-8dd3-42fa556d67e3****

Once you get the AuthKeys, you can either register manually with Integration runtime UI or by using the below Powershell script

Please execute this Powershell script as an Admin by passing the above AuthKey as a parameter

https://github.com/microsoft/implementation-patterns/blob/main/pattern-datafactory-databricks/components/self-hosted-integration-runtime/irInstall.ps1

This will add the node back to the Integration Runtime

#### Adding a new Windows VM as a node back to the node pool within the self hosted integration runtime

In this case, we are provisioning a new VM which will be added to the Self hosted Integration runtime as a node pool. You cannot add more than 4 nodes to a Self hosted Integration runtime.

Please follow the instructions in **Step 2** in the below  article to deploy the VM along with Integration runtime installed and configured. In this scenario, we only provide the **Data factory name** and **Existing Integration runtime** as the input parameters and automation will complete all the necessary steps to add the node back to the pool

https://github.com/microsoft/implementation-patterns/tree/main/pattern-datafactory-databricks/components/self-hosted-integration-runtime
