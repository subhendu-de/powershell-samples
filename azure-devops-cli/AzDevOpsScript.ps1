[CmdletBinding()]
PARAM
(
    #the script input variables

    [Parameter(Mandatory = $true)]
    [SecureString] $PAT,

    [Parameter(Mandatory = $true)]
    [String] $Organization,
    
    [Parameter(Mandatory = $true)]
    [String] $Project,

    [Parameter(Mandatory = $true)]
    [String] $RepoName
)

#region - Global Script Variables

$branchName = "main"
$ReadmeContent = "# Introduction `
TODO: Give a short introduction of your project. Let this section explain the objectives or the motivation behind this project. `
`
# Getting Started`
TODO: Guide users through getting your code up and running on their own system. In this section you can talk about:`
1.	Installation process`
2.	Software dependencies`
3.	Latest releases`
4.	API references`
`
# Build and Test`
TODO: Describe and show how to build your code and run the tests. `
`
# Contribute`
TODO: Explain how other users and developers can contribute to make your code better. `
`
If you want to learn more about creating good readme files then refer the following [guidelines](https://docs.microsoft.com/en-us/azure/devops/repos/git/create-a-readme?view=azure-devops). You can also seek inspiration from the below readme files:`
- [ASP.NET Core](https://github.com/aspnet/Home)`
- [Visual Studio Code](https://github.com/Microsoft/vscode)`
- [Chakra Core](https://github.com/Microsoft/ChakraCore)"`

#endregion

#region - Script Functions
<#
 =========================================================================================================	 
Script Functions
Get-RepoList			- Gets the repo list	
Get-Repo				- Gets a repo details
New-Repo                - Create a new repo
Initialize-Repo         - Initialize the repo
Set-BranchPolicy        - Sets the branch policy
 =========================================================================================================
#>

function Get-RepoList
{
    $env:AZURE_DEVOPS_EXT_PAT = $PAT

    Write-Host "Calling Function to get the list of Repos"
    $RepoList = az repos list --org $Organization --project $Project | ConvertFrom-Json
    $RepoList | ForEach-Object {
        if($_.name -eq $RepoName)
        {
            return $true
        } 
    }
}

function Get-Repo
{
    Write-Host 'Calling Function to get the Repo' $RepoName 'details'
    return az repos show --repository $RepoName --project $Project --org $Organization | ConvertFrom-Json
}

function New-Repo
{
    Write-Host 'Calling Function to create the Repo' $RepoName
    $NewRepo = az repos create --name $RepoName --project $Project --organization $Organization | ConvertFrom-Json
    return $NewRepo
}

function Initialize-Repo
{
    param (
        [string]$RemoteUrl,
        [string]$RepoName
    )
    Write-Host 'Calling Function to initialize the Repo' $RepoName
    Write-Host "Repo $($RepoName) URL - $($remoteUrl)"
    git clone $remoteUrl
    Push-Location $RepoName
    Write-Output $ReadmeContent >> README.md
    git add README.md
    git commit -m "initialize git repository"
    git push
    Pop-Location
    Remove-Item -LiteralPath $RepoName -Force -Recurse
}

function Set-BranchPolicy
{
    Param
    (
        [string]$repoId, 
        [string]$branchName
    )

    Write-Host "Deleting branch policies on $($branchName)"
    
    $PolicyList = az repos policy list --branch $branchName --project $Project --organization $Organization --repository-id $repoId | ConvertFrom-Json
    $PolicyList | ForEach-Object {
        az repos policy delete --id $_.id --project $Project --org $Organization --yes
    }

    Write-Host "Creating branch policies on $($branchName)"

    Write-Host 'Policy: Require a minimum number of reviewers'
    az repos policy approver-count create --blocking true --allow-downvotes false --branch $branchName --creator-vote-counts false --enabled true --minimum-approver-count 2 --repository-id $repoId --reset-on-source-push false  --project $Project --organization $Organization | ConvertFrom-Json    
    
    Write-Host 'Policy: Checked for linked work items'    
    az repos policy work-item-linking create --blocking true --branch $branchName --enabled true --repository-id $repoId --project $Project --organization $Organization | ConvertFrom-Json  
    
    Write-Host 'Policy: Checked for merge strategy'    
    az repos policy merge-strategy create --blocking true --branch $branchName --enabled true --repository-id $repoId --use-squash-merge true --project $Project --organization $Organization | ConvertFrom-Json        

    Write-Host 'Policy: Checked for comment resolution'
    az repos policy comment-required create --blocking true --branch $branchName --enabled true --repository-id $repoId --project $Project --organization $Organization | ConvertFrom-Json
}

try
{
    Write-Host "Script Started."

    $RepoDetails = $null

    if(Get-RepoList)
    {
        Write-Host 'Repo' $RepoName 'exists!'
        $RepoDetails = Get-Repo
    }
    else
    {
        $RepoDetails = New-Repo
        Initialize-Repo $RepoDetails.remoteUrl $RepoName  
    }

    Set-BranchPolicy -repoId $RepoDetails.id -branchName $branchName

    Write-Host "Script Finished."
}
catch [system.exception]
{
	Write-Host "Script Error: $($_.Exception.Message) "
    Write-Host "Error Details are: "
    Write-Host $Error[0].ToString()
	Stop-Transcript
	Exit $ERRORLEVEL
}