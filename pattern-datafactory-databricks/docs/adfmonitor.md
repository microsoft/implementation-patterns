
## Monitor and Manage

### Monitor Visually
Monitor pipeline and activity runs with a simple list view interface. All the runs are displayed in local browser time zone. You can change the time zone and all the date time fields will snap to the selected time zone.

![image](https://user-images.githubusercontent.com/22504173/90347075-fa755400-dffb-11ea-8ca3-05e856eed069.png)

You can monitor pipeline runs, Trigger runs under their respective tabs on the Monitoring page which will provide you with the history of all the executions that happened on this data factory

Pipeline runs:
![image](https://user-images.githubusercontent.com/22504173/90347519-fbf44b80-dffe-11ea-8281-5dc90ee61b02.png)

Activity runs:
![image](https://user-images.githubusercontent.com/22504173/90347549-26de9f80-dfff-11ea-8862-f9d0c7e9d06b.png)

Error Dialogs:

![image](https://user-images.githubusercontent.com/22504173/90347575-61483c80-dfff-11ea-941e-d07d8d0ee890.png)

Integration runtimes can be monitored under the Runtimes and sessions category:
![image](https://user-images.githubusercontent.com/22504173/90347226-e120d780-dffc-11ea-88c2-f23a84a4a205.png)
![image](https://user-images.githubusercontent.com/22504173/90347216-d403e880-dffc-11ea-8290-dfe0ea1d2c79.png)

## Monitor Azure Data Factory with Azure Monitor

Data Factory stores pipeline-run data for only 45 days. Use Azure Monitor if you want to keep that data for a longer time. With Monitor, you can route diagnostic logs for analysis to multiple different targets. •Azure Monitor is not enabled by default for data factory.

Azure Data factory emits Metrics which is part of Azure monitor where you can get a wealth of system health information and other counters which you can monitor

![image](https://user-images.githubusercontent.com/22504173/90347703-f9debc80-dfff-11ea-80da-fd3be267a6c3.png)

You can persist Azure Data factory Metrics and Logs information externally so that you can retain this data beyond the 45 day retention period. This where we need to enable Diagnostics settings on Azure portal for the service and configure the settings accordingly. You can send this data to Azure Log Analytics workspace where you can join and correlate with other service logs or you can retain them on Azure storage for long term retention or send it to Eventhubs for any third party monitoring integration.

![image](https://user-images.githubusercontent.com/22504173/90347813-8a1d0180-e000-11ea-9adb-a01e44ef205c.png)

Once the data reaches Azure Log analytics, you can leverage the rich features of the Kusto query language(KQL) to explore this data. 

You can also leverage the Market place solution to monitor multiple Azure Data factories across your enterprise

![image](https://user-images.githubusercontent.com/22504173/90347954-7d4cdd80-e001-11ea-8590-eca6d806bdfc.png)
![image](https://user-images.githubusercontent.com/22504173/90347945-6c9c6780-e001-11ea-8568-2fab685bb3be.png)
![image](https://user-images.githubusercontent.com/22504173/90347959-88077280-e001-11ea-820a-5f4fd93289f5.png)
![image](https://user-images.githubusercontent.com/22504173/90347966-905fad80-e001-11ea-87f8-ed5e820b4752.png)

For more information: https://docs.microsoft.com/en-us/azure/data-factory/monitor-using-azure-monitor
