
#  How to execute these scripts?

Here are the instructions on how to execute these scripts to deploy Databricks Workspace and other artifacts within Databricks



1. Make sure that you have the VNET and other networking components like NSGs and UDRs configured correctly.

   - Pre  provision VNET  to make sure that you have the public-subnet and private-subnet configured as documented in this link https://github.com/microsoft/implementation-patterns/tree/main/pattern-datafactory-databricks/components/base-network
   - Use **adbnsg.json** and **adbnsg.parameters.json** files to create the NSGs for both the subnets
   - Finally, use the **adbvnetinjection.json** and **adbvnetinjection.parameters.json** to assign the NSGs to the subnets and enable delegation on these subnets to Microsoft.Databricks/Workspaces

2. Create the Databricks workspace using the ARM template **azure-databricks.json** and **azure-databricks.parameters.json**. Make sure to add any Workspace admins to the Owners or Contributors role on the Azure databricks workspace resource. they will be automatically getting Admin privilege when they log onto the databricks workspace.

3. Once the Databricks workspace is provisioned, then all the remaining steps are managed via an REST API. We will be using Powershell to call this REST API to perform some basic operations

   - First thing is it to create a Personal access token within databricks workspace from User settings. It looks something like dapi** etc. This can be created programmatically using the REST API. Removing the token values for brevity and security.

     ```powershell
     $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
     $headers.Add("Authorization", "Bearer  eyJ0eXA***")
     $headers.Add("X-Databricks-Azure-SP-Management-Token", "eyJ0eXAiOiJKV1Q****")
     $headers.Add("X-Databricks-Azure-Workspace-Resource-Id", "/subscriptions/*****/resourceGroups/Network-RG-EastUS2/providers/Microsoft.Databricks/workspaces/dbtest1tmnew")
     
     $response = Invoke-RestMethod 'https://adb-653***.14.azuredatabricks.net/api/2.0/token/create' -Method 'POST' -Headers $headers -Body $body
     $response | ConvertTo-Json
     ```
     

   - Once the Personal access token is created, the remaining steps to manage are pretty straightforward, you need to point to the right API endpoint and provide the necessary header\body as per per the API specifications.

   - Create a Spark cluster using the powershell script **create-workspace-cluster.ps1**

   - Create a notebook using the powershell script **create-notebook.-jobps1**

   - Import a notebook using the powershell script **import-notebook.ps1**

   - Run a Job using the powershell script **runjob-notebook.-jobps1**

   - Here is an exclusive list of all the different REST API's available for Databricks which you can leverage as part of your documentation. https://docs.microsoft.com/en-us/azure/databricks/dev-tools/api/latest/clusters

