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

$SummaryData = @{}
$MaxCount = 1000
$Total = 0
$Token = $null
[System.Collections.ArrayList]$BlobList = @()

$Context = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey

do 
{
    $Blobs = Get-AzStorageBlob -Context $Context -Container $ContainerName -MaxCount $MaxCount -ContinuationToken $Token
    $BlobList.AddRange($Blobs)
    $Total += $Blobs.Count
    $Token = $Blobs[$Blobs.Count - 1].ContinuationToken    
    Write-Output "Get 1000 recs"
} 
while ($Token -ne $null)

$BlobList
#foreach ($Blob in $Blobs)
#{
#    Write-Host $Blob.Name
#    $StartIndex = $Blob.Name.LastIndexOf("/") + 1
#    $NumberOfChars = $Blob.Name.Length - $Blob.Name.LastIndexOf("/") - 1
#    $FolderName = $Blob.Name.Substring(0, $StartIndex - 1)
#    $BlobName = $Blob.Name.Substring($StartIndex, $NumberOfChars)

#    $SummaryData.Add($FolderName, $BlobName)  
#}

#$SummaryData | Group-Object Name -NoElement | Select-Object Name, Count

#Import-Csv C:\File.csv | Group-Object "location" | %{Set-Variable ($_.Name) ($_.Group | Select-Object -ExpandProperty id)}