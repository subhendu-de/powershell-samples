<#
	.NOTES
		==============================================================================================
		File:		BlobCountReport.ps1
		Purpose:	Provide the number of blobs inside a container. In several scenarios, the blobs 
                    are stored in virtual folders under the containers. The convention is like 
                    YYYY/MM/DD/HH. This script takes the filter parameter and calculate the number 
                    of blobs.
		==============================================================================================
#>

#region Parameters

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]
    $StorageAccountName,
    [Parameter(Mandatory = $true)]
    [string]
    $StorageAccountKey,    
    [Parameter(Mandatory = $true)]
    [string]
    $ContainerName,
    [Parameter(Mandatory = $false)]
    [string]
    $Filter
)

#endregion 

#Number of blobs to return in a single call
$MaxCount = 1000
#Calculate the sum of the blobs count
$Total = 0
#Hold the token for retrieving the next set of records
$Token = $null
#Hold the data returned from the blob listing operation
$BlobList = [System.Collections.Generic.List[object]]@()
#Hold the data after transform the data
$SummaryList = [System.Collections.Generic.List[object]]@()

#Connecting the storage account
$Context = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey

#Iterate over the blobs in a batch of size 1000
do 
{
    if($Filter -eq $null)
    {
        #Listing teh blobs without filter
        $Blobs = Get-AzStorageBlob -Context $Context -Container $ContainerName -MaxCount $MaxCount -ContinuationToken $Token
    }
    else
    {
        #Listing teh blobs with filter
        $Blobs = Get-AzStorageBlob -Context $Context -Container $ContainerName -MaxCount $MaxCount -ContinuationToken $Token -Blob $Filter
    }
    
    $BlobList.AddRange($Blobs)
    $Total += $Blobs.Count
    $Token = $Blobs[$Blobs.Count - 1].ContinuationToken
} 
while ($Token -ne $null)

foreach ($Blob in $BlobList)
{
    #Retrieve the last index of the /
    $StartIndex = $Blob.Name.LastIndexOf("/") + 1
    #Name of the virtual folder without the filename
    $FolderName = $Blob.Name.Substring(0, $StartIndex - 1)
    #Number of characters in the blob name (filename without virtual directory path)
    #$NumberOfChars = $Blob.Name.Length - $Blob.Name.LastIndexOf("/") - 1
    #Name of the filename
    #$BlobName = $Blob.Name.Substring($StartIndex, $NumberOfChars)
    #Adding folder path to the list
    $SummaryList.Add($FolderName)
}

#Applying a grouping clause to find the count of blobs in a virtual folder path
$SummaryList | Group-Object | Select-Object Name, Count