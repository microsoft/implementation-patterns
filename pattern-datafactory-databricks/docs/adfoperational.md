## CI\CD for Pipelines and Templates

Azure Data Factory has native integration with Github and Azure Devops git repos as Source control. You can deploy your pipelines and other ADF artifacts like Linked Servicesm Datasets, Triggers, Templates etc directly to these git repos natively. It enabled multiple users to work on their on feature branch and then push it into a collaboration branch for deployments into other environments.

![image](https://user-images.githubusercontent.com/22504173/89733033-b93fdb80-da20-11ea-8432-733b6cd70ba4.png)
![image](https://user-images.githubusercontent.com/22504173/89733054-dc6a8b00-da20-11ea-9e02-63ef32bbf22a.png)

For Azure Devops, you can select the right Git repo and collaboration branch accordingly


![image](https://user-images.githubusercontent.com/22504173/89733083-0623b200-da21-11ea-98be-01a1fb148a05.png)


For repos which are not Github or Azure Devops, there is an option to export the ARM templates of Data factory and upload them into the corresponding source control platforms
![image](https://user-images.githubusercontent.com/22504173/89733931-e3949780-da26-11ea-9e10-c4cc87afe48b.png)
![image](https://user-images.githubusercontent.com/22504173/89733947-fa3aee80-da26-11ea-9d1d-d6b148acb565.png)


Incase you want to export the contents of a single pipeline and its corresponding artifacts instead of the entire data factory, then you need to select "Download Support files" option within the pipeline properties.
![image](https://user-images.githubusercontent.com/22504173/89733983-25254280-da27-11ea-9854-8e28f0b09e18.png)

![image](https://user-images.githubusercontent.com/22504173/89734089-e0e67200-da27-11ea-94dc-c131e224c016.png)

## Monitor and Manage

### Monitor Visually
Monitor pipeline and activity runs with a simple list view interface. All the runs are displayed in local browser time zone. You can change the time zone and all the date time fields will snap to the selected time zone.
![image](https://user-images.githubusercontent.com/22504173/90347075-fa755400-dffb-11ea-8ca3-05e856eed069.png)

You can monitor pipeline runs, Trigger runs under their respective tabs on the Monitoring page which will provide you with the history of all the executions that happened on this data factory
![image](https://user-images.githubusercontent.com/22504173/90347183-b3d42980-dffc-11ea-8ea8-f49160cd7520.png)

Integration runtimes can be monitored under the Runtimes and sessions category
![image](https://user-images.githubusercontent.com/22504173/90347226-e120d780-dffc-11ea-88c2-f23a84a4a205.png)
![image](https://user-images.githubusercontent.com/22504173/90347216-d403e880-dffc-11ea-8290-dfe0ea1d2c79.png)

### Monitor Pipeline and Activity runs

### Monitor with Azure Monitor

