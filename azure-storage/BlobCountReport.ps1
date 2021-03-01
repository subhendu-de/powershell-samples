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

$MaxCount = 1000
$Total = 0
$Token = $null
$BlobList = [System.Collections.Generic.List[object]]@()
$SummaryList = [System.Collections.Generic.List[object]]@()

$Context = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey

do 
{
    if($Filter -eq $null)
    {
        $Blobs = Get-AzStorageBlob -Context $Context -Container $ContainerName -MaxCount $MaxCount -ContinuationToken $Token
    }
    else
    {
        $Blobs = Get-AzStorageBlob -Context $Context -Container $ContainerName -MaxCount $MaxCount -ContinuationToken $Token -Blob $Filter
    }
    
    $BlobList.AddRange($Blobs)
    $Total += $Blobs.Count
    $Token = $Blobs[$Blobs.Count - 1].ContinuationToken    
    Write-Output $Total
} 
while ($Token -ne $null)

foreach ($Blob in $BlobList)
{
    $StartIndex = $Blob.Name.LastIndexOf("/") + 1
    $NumberOfChars = $Blob.Name.Length - $Blob.Name.LastIndexOf("/") - 1
    $FolderName = $Blob.Name.Substring(0, $StartIndex - 1)
    $BlobName = $Blob.Name.Substring($StartIndex, $NumberOfChars)
    $SummaryList.Add($FolderName)
}

$SummaryList | Group-Object | Select-Object Name, Count