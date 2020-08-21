
## CI\CD for Pipelines and Templates

Azure Data Factory has native integration with Github and Azure Devops git repos as Source control. You can deploy your pipelines and other ADF artifacts like Linked Servicesm Datasets, Triggers, Templates etc directly to these git repos natively. It enabled multiple users to work on their on feature branch and then push it into a collaboration branch for deployments into other environments. 

![image](https://user-images.githubusercontent.com/22504173/89733033-b93fdb80-da20-11ea-8432-733b6cd70ba4.png)
![image](https://user-images.githubusercontent.com/22504173/89733054-dc6a8b00-da20-11ea-9e02-63ef32bbf22a.png)

In case you want to deploy an Azure Data Factory with CI\CD integration as part of the deployment. Please follow the instructions here https://github.com/microsoft/implementation-patterns/tree/main/pattern-datafactory-databricks/components/data-factory

For Azure Devops, you can select the right Git repo and collaboration branch accordingly


![image](https://user-images.githubusercontent.com/22504173/89733083-0623b200-da21-11ea-98be-01a1fb148a05.png)


For repos which are not Github or Azure Devops, there is an option to export the ARM templates of Data factory and upload them into the corresponding source control platforms
![image](https://user-images.githubusercontent.com/22504173/89733931-e3949780-da26-11ea-9e10-c4cc87afe48b.png)
![image](https://user-images.githubusercontent.com/22504173/89733947-fa3aee80-da26-11ea-9d1d-d6b148acb565.png)


Incase you want to export the contents of a single pipeline and its corresponding artifacts instead of the entire data factory, then you need to select "Download Support files" option within the pipeline properties.
![image](https://user-images.githubusercontent.com/22504173/89733983-25254280-da27-11ea-9854-8e28f0b09e18.png)

![image](https://user-images.githubusercontent.com/22504173/89734089-e0e67200-da27-11ea-94dc-c131e224c016.png)

