### Monitor and Manage


### CI\CD for Pipelines and Templates

Azure Data Factory has native integration with Github and Azure Devops git repos as Source control. You can deploy your pipelines and other ADF artifacts like Linked Servicesm Datasets, Triggers, Templates etc directly to these git repos natively. It enabled multiple users to work on their on feature branch and then push it into a collaboration branch for deployments into other environments.

![image](https://user-images.githubusercontent.com/22504173/89733033-b93fdb80-da20-11ea-8432-733b6cd70ba4.png)
![image](https://user-images.githubusercontent.com/22504173/89733054-dc6a8b00-da20-11ea-9e02-63ef32bbf22a.png)

For Azure Devops, you can select the right Git repo and collaboration branch accordingly


![image](https://user-images.githubusercontent.com/22504173/89733083-0623b200-da21-11ea-98be-01a1fb148a05.png)


For repos which are not Github or Azure Devops, there is an option to export the ARM templates of Data factory and upload them into the corresponding source control platforms
![image](https://user-images.githubusercontent.com/22504173/89733931-e3949780-da26-11ea-9e10-c4cc87afe48b.png)
![image](https://user-images.githubusercontent.com/22504173/89733947-fa3aee80-da26-11ea-9d1d-d6b148acb565.png)
