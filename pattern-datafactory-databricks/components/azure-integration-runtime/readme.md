
## Azure Intgeration runtime

There is a built in Azure Integration runtime created when you create a new Azure Data factory which is called AutoResolveIntegrationruntime. It is created automatically and is used whenever you need to connect to cloud data sources which have a publicly accessible endpoint. The location or region for this Integration runtime is automatically resolved during the pipeline execution depending on several parameters. Normally, the Autoresolve IR should suffice most of your needs but there could be scenarions where you want Azure IR to be hosted in a specific region or you want to configure hardware for Azure IR which will be service Mapping Dataflows. In those scenarios you can create an Azure IR environment with respective parameters.

Please run the **adfazureirdeploy.sh** script to deploy and configure Azure IR within the specified region and the Compute specifications like Core count, Compute\Memory optimized settings etc.

