# Powershell Samples

| File Name | Description |
| ------------- |:-------------  |
| azure-storage/BlobCountReport.ps | This is a script to find the numbers of blobs in a container. The blobs are stored in the in virtual directory ordered by year, month, day and hours. |

##### How to call the scripts

###### BlobCountReport.ps
```ps
.\BlobCountReport.ps1 -StorageAccountName my-storage -StorageAccountKey xxxxxxxxxxx -ContainerName data -Filter 2020/01/12/14*
```