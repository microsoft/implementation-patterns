Here are the detailed steps to automate installation of Self hosted Integration Runtime on Azure VM's

1. **Create Self hosted Integration runtime configuration within Azure data factory**: Please run the **adfshirdeploy.sh** script to configure Self hosted Integration runtime configuration within the specified Azure Data Factory. It deploys the *adf-template.json* and the corresponding parameter file *adf-template.parameters.json*. Please provide the existing Azure Data factory name as one of the input parameters. If you havent created data factory yet, please go to the folder [data-factory](https://github.com/microsoft/implementation-patterns/tree/main/pattern-datafactory-databricks/components/data-factory) where you can find the templates to create a brand new datafactory with or without CI\CD integration.


2. **Create a Windows VM which will act as the Self hosted Integration runtime node:** Please run the **windowsvmdeploy.sh** to deploy the Self hosted integration runtime VM within the specified Virtual network\subnet. As part of this deployment, it will deploy the ARM template *vm-windows.json*  , we will also install and configure the Integration runtime software as part of the custom script extension. Please note that you need to provide the **datafactory name** and **self hosted integration runtime name** obtained in the above step as input parameters within the *vm-windows.parameters.json* file.
  This script will be able to accomplish the following tasks	

- It will be able to configure up to 4 VMs as part of the Self hosted integration runtime. You can pass the number of instances as a parameter to this ARM template
- It will configure all the nodes as part of different Availability zones within the region. This will ensure High availability and resiliency of Self hosted Integration runtime within the region.
- Configure Self hosted integration runtime software, Register this node with the Self hosted Integration runtime configured within Azure Data Factory. 

3. **Configure Self hosted integration runtime on an existing Windows VM:** Please note that in this case, the VM is already provisioned and you just need to run the powershell script **irCustomscript.ps1** script to configure Self hosted integration runtime programatically. It takes care of downloading the software, configuring with the provided AuthKey etc
