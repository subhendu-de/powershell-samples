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
    $ContainerName
)

$Context = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey

$Blobs = Get-AzStorageBlob -Container $ContainerName -Context $Context
$SummaryData = New-Object System.Collections.Generic.List[System.Object]

foreach ($Blob in $Blobs)
{
    $StartIndex = $Blob.Name.LastIndexOf("/") + 1
    $NumberOfChars = $Blob.Name.Length - $Blob.Name.LastIndexOf("/") - 1
    $FolderName = $Blob.Name.Substring(0, $StartIndex - 1)
    $BlobName = $Blob.Name.Substring($StartIndex, $NumberOfChars)
    #Write-Output $FolderName $BlobName

    $SummaryData.Add($FolderName)  
}

$SummaryData | Group-Object -NoElement | Select-Object Name, Count  | Sort-Object Count -Descending