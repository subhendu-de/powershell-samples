# Description

The script performs the following things

 - Create a repo if it doesn't exist
 - Create a main branch for newly created repo
 - Delete the existing policies, if any
 - Create a new set of policies

### How to run the script

```ps
$PAT = "{PERSONAL ACCESS TOKEN}" | ConvertTo-SecureString -AsPlainText -Force

.\AzDevOpsScript.ps1 `
    -PAT $PAT `
    -Organization "https://dev.azure.com/{organization}" `
    -Project "{project}" `
    -Repo "{repo name}"
```

### How to print the list of repos of a Azure DevOps project

```ps
$env:AZURE_DEVOPS_EXT_PAT = "{PERSONAL ACCESS TOKEN}"
az repos list `
    --org "https://dev.azure.com/{organization}" `
    --project "{project}" `
    --query "[].{name:name}" `
    -o table
```
