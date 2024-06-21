/*
   From a (cygwin) bash prompt, use this perl one-liner to extract the powershell script fragments and exeucte them. This example shows how to execute steps 2 (shutdown) and steps 4-13 and skipping steps 7,8,9 because they don't work (yet). Adjust that list of steps according to your needs.

   powershell -executionPolicy unrestricted -Command - <<EOF
   `perl -lne 'sub range {$b=shift; $e=shift; $r=""; for(($b..$e)){ $r=$r."," if $r; $r=$r.$_;} $r } BEGIN {  $_ = shift; s/([0-9]+)-([0-9]+)/range($1,$2)/e; @idx=split ","; $c=0; $x=0; $f=0; $s=[] } $c++ if /^\s*Begin/; if (/^\s*End/) {$c--;$s[$f++]=""}; if ($x+$c>1) { $s->[$f]=$s->[$f].$_."\n"  } $x=$c; END { push(@idx, $#s); unshift @idx,0; for (@idx) { $p=$s->[$_]; chomp $p; print $p } }' "2,4-6,10-13" < "deploy-zipdeployDemo.bicep"  `
EOF

   Begin common prolog commands
   $env:subscriptionId=(az account show --query id --output tsv | ForEach-Object { $_ -replace "`r", ""})
   $StartTime = $(get-date)
   $env:name='zipdeployDemo'
   $env:rg="rg_$($env:name)"
   $env:sp="spad_$env:name"
   $env:location=If ($env:AZ_DEFAULT_LOC) { $env:AZ_DEFAULT_LOC} Else {'eastus2'}
   $env:uniquePrefix="$(If ($env:USERNAME -eq "v-richardsi") {"pkjdh"} ElseIf ($env:USERNAME -eq "v-paperry") { "mytrk" } ElseIf ($env:USERNAME -eq "hein") {"wkeof"} Else { "mpkvs" } )"
   $env:deployStorageAccountName="$($env:uniquePrefix)dplystg"
   $env:stgContainer="deployfunc"
   End common prolog commands

   emacs F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   az deployment group create --name $env:name --resource-group $env:rg --mode Incremental --template-file  "deploy-zipdeployDemo.bicep" --parameters "{'uniquePrefix': {'value': '$env:uniquePrefix'}}" "{'location': {'value': '$env:location'}}" | ForEach-Object { $_ -replace "`r", ""}
   write-output "end deploy $(Get-Date)"
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 2 F10
   Begin commands to shut down this deployment using Azure CLI with PowerShell
   write-output "begin shutdown $env:rg $(Get-Date)"
   If (![string]::IsNullOrEmpty($kv)) {
     write-output "keyvault=$kv"
     write-output "az keyvault delete --name '$($env:uniquePrefix)-kv' -g '$env:rg'"
     az keyvault delete --name "$($env:uniquePrefix)-kv" -g "$env:rg"
     write-output "az keyvault purge --name `"$($env:uniquePrefix)-kv`" --location $env:location"
     az keyvault purge --name "$($env:uniquePrefix)-kv" --location $env:location 
   } Else {
     write-output "No key vault to delete & purge"
   }
   az deployment group create --mode complete --template-file ./clear-resources.json --resource-group $env:rg  | ForEach-Object { $_ -replace "`r", ""}
   write-output "showdown is complete $env:rg $(Get-Date)" 
   End commands to shut down this deployment using Azure CLI with PowerShell

   emacs ESC 3 F10
   Begin commands to shut down this deployment using Azure CLI with PowerShell
   write-output "Step 3: begin shutdown delete resource group $env:rg and associated service principal $(Get-Date)"
   write-output "az ad sp list --display-name $env:sp"
   az ad sp list --display-name $env:sp
   write-output "az ad sp list --filter `"displayname eq '$env:sp'`" --output json"
   $env:spId=(az ad sp list --filter "displayname eq '$env:sp'" --query "[].id" --output tsv)
   write-output "az ad sp delete --id $env:spId"
   az ad sp delete --id $env:spId
   write-output "az group delete -n $env:rg"
   az group delete -n $env:rg --yes
   write-output "showdown is complete $env:rg $(Get-Date)"
   End commands to shut down this deployment using Azure CLI with PowerShell

   emacs ESC 4 F10
   Begin commands for one time initializations using Azure CLI with PowerShell
   az group create -l $env:location -n $env:rg
   $env:id=(az group show --name $env:rg --query 'id' --output tsv)
   write-output "id=$env:id"
   az ad sp create-for-rbac --name $env:sp --json-auth --role contributor --scopes $env:id
   write-output "go to github settings->secrets and create a secret called AZURE_CREDENTIALS with the above output"
   write-output "{`n`"`$schema`": `"https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#`",`n `"contentVersion`": `"1.0.0.0`",`n `"resources`": [] `n}" | Out-File -FilePath clear-resources.json
   End commands for one time initializations using Azure CLI with PowerShell

   emacs ESC 5 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Step 5: Upddate the built at timestamp in the source code (ala ChatGPT)"
   # Path to your C# source file
   $filePath = "..\SimpleServiceBusSendReceiveAzureFuncs/SimpleServiceBusSenderReceiver.cs"
   # Read the contents of the file
   $content = Get-Content -Path $filePath -Raw
   # Regular expression to match the version number in the format "Version 000000000"
   $versionRegex = 'Version [0-9]+'
   # Regular expression to match the date-time string
   $regex = 'Built at [A-Za-z]{3} +[A-Za-z]{3} +[0-9]{1,2} +[0-9]{1,2}:+[0-9]{1,2}:+[0-9]{1,2} +[0-9]{4}'
   # Initialize flags to check if replacements were made
   $dateUpdated = $false
   $versionUpdated = $false
   if ($content -match $regex) {
     # Get the current date-time in the same format
     $currentDateTime = Get-Date -Format "ddd MMM dd HH:mm:ss yyyy"
     write-output "Replace the old date-time with the current date-time $currentDateTime"
     $updatedContent = [regex]::Replace($content, $regex, "Built at $currentDateTime")
     $dateUpdated = $true
     Write-Output "Date-time string updated successfully."
   } else {
     write-output "Built At timestamp not found"
   }
   # Check if the version regex finds a match
   if ($content -match $versionRegex) {
       # Extract the current version number
       $currentVersion = [regex]::Match($content, $versionRegex).Value
       # Increment the version number by 1
       $versionNumber = [int]($currentVersion -replace '[^0-9]', '')
       write-output "found version $versionNumber"
       $newVersionNumber = $versionNumber + 1
       write-output "increment version $versionNumber"
       $newVersionString = "Version " + $newVersionNumber.ToString("D5")
       write-output "new version string= $newVersionString"
       # Replace the old version number with the new version number
       $content = $content -replace $versionRegex, $newVersionString
       $versionUpdated = $true
   } else {
       Write-Output "No version number found matching the pattern."
   }
   if ($dateUpdated -or $versionUpdated) {
       Set-Content -Path $filePath -Value $content
       Write-Output "File updated successfully in $filePath."
   } else {
      Write-Output "No updates made to the file."
   }   
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 6 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 6 Publish"
   write-output "dotnet publish '../zipdeployhttpfunc.csproj'  --configuration Release  -f net6.0 --self-contained --output ./publish-functionapp"
   dotnet publish "../zipdeployhttpfunc.csproj"  --configuration Release  -f net6.0 --self-contained --output ./publish-functionapp
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 7 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 7 zip"
   pushd ./publish-functionapp
   write-output "Compress-Archive -Path .\* -DestinationPath ../publish-functionapp.zip -Force"
   Compress-Archive -Path .\* -DestinationPath ../publish-functionapp.zip -Force
   popd
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 8 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Step 8 create storage account $env:deployStorageAccountName"
   write-output "az storage account create -n $env:deployStorageAccountName -g $env:rg --access-tier cool --sku Standard_LRS"
   az storage account create -n $env:deployStorageAccountName -g $env:rg   --access-tier cool --sku Standard_LRS
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 9 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Step 9 create storage container $env:stgContainer in account $env:deployStorageAccountName"
   $env:conn=(az storage account show-connection-string --name $env:deployStorageAccountName --resource-group $env:rg | jq '.connectionString')
   write-output "az storage container create -n $env:stgContainer --account-name $env:deployStorageAccountName"
   az storage container create -n $env:stgContainer --account-name $env:deployStorageAccountName  --connection-string $env:conn
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 10 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Step 10 confirm container has been created"
   $env:conn=(az storage account show-connection-string --name $env:deployStorageAccountName --resource-group $env:rg | jq '.connectionString')
   write-output "az storage container list --account-name $env:deployStorageAccountName  --connection-string $env:conn --output table"
   az storage container list --account-name $env:deployStorageAccountName  --connection-string $env:conn --output table
   write-output "az storage container show --account-name $env:deployStorageAccountName  --connection-string $env:conn -n $env:stgContainer"
   az storage container show --account-name $env:deployStorageAccountName  --connection-string $env:conn -n $env:stgContainer
   write-output "az storage container show-permission --account-name $env:deployStorageAccountName  --connection-string $env:conn -n $env:stgContainer"
   az storage container show-permission --account-name $env:deployStorageAccountName  --connection-string $env:conn -n $env:stgContainer
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 11 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Step 11 upload zip to blob"
   $env:conn=(az storage account show-connection-string --name $env:deployStorageAccountName --resource-group $env:rg | jq '.connectionString')
   write-output "conn=$($env:conn)"
   write-output "az storage blob upload -f publish-functionapp.zip --account-name $env:deployStorageAccountName  -c $env:stgContainer -n "package_zip" --overwrite true  --connection-string $env:conn"
   az storage blob upload -f publish-functionapp.zip --account-name $env:deployStorageAccountName  -c $env:stgContainer -n "package_zip" --overwrite true  --connection-string $env:conn
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 12 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Step 12 update appsettings WEBSITE_RUN_FROM_PACKAGE=1"
   write-output "az functionapp config appsettings set -n $env:functionAppName -g $env:rg --settings 'WEBSITE_RUN_FROM_PACKAGE=1'"
   az functionapp config appsettings set -n $env:functionAppName -g $env:rg --settings "WEBSITE_RUN_FROM_PACKAGE=1"
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 13 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Step 13 generate blob SAS and confirm we can download"
   $env:conn=(az storage account show-connection-string --name $env:deployStorageAccountName --resource-group $env:rg | jq '.connectionString')
   write-output "az storage blob generate-sas --full-uri --permissions acdeimrtwx --expiry (get-date).AddMinutes(60).ToString('yyyy-MM-ddTHH:mm:ssZ') --account-name $env:deployStorageAccountName -c $env:stgContainer -n package_zip --https-only --output tsv"
   $env:sasUrl=(az storage blob generate-sas --full-uri --permissions acdeimrtwx --expiry (get-date).AddMinutes(60).ToString("yyyy-MM-ddTHH:mm:ssZ") --account-name $env:deployStorageAccountName -c $env:stgContainer -n package_zip  --connection-string $env:conn --https-only --output tsv)
   write-output "sasUrl=$($env:sasUrl)"
   $path = "downloaded.zip"
   if (Test-Path -LiteralPath $path) {
       write-output "Deleting $path"
       Remove-Item -LiteralPath $path
   } else {
      write-output "$path doesn't exist: create it"
   }
   write-output "az storage blob download --account-name $env:deployStorageAccountName -n $env:stgContainer -f $path --blob-url `$env:sasUrl"
   az storage blob download --account-name $env:deployStorageAccountName -n $env:stgContainer -f downloaded.zip --blob-url $env:sasUrl
   write-output "Get-ChildItem"
   Get-ChildItem
   End commands to deploy this file using Azure CLI with PowerShell
   
   emacs ESC 14 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Step 14 generate blob SAS and deploy"
   $env:conn=(az storage account show-connection-string --name $env:deployStorageAccountName --resource-group $env:rg | jq '.connectionString')
   write-output "az storage blob generate-sas --full-uri --permissions acdeimrtwx --expiry (get-date).AddMinutes(60).ToString('yyyy-MM-ddTHH:mm:ssZ') --account-name $env:deployStorageAccountName -c $env:stgContainer -n package_zip --https-only --output tsv"
   $env:sasUrl=(az storage blob generate-sas --full-uri --permissions acdeimrtwx --expiry (get-date).AddMinutes(60).ToString("yyyy-MM-ddTHH:mm:ssZ") --account-name $env:deployStorageAccountName -c $env:stgContainer -n package_zip  --connection-string $env:conn --https-only --output tsv)
   write-output "sasUrl=$($env:sasUrl)"
   $env:sasUrl =  $env:sasUrl -replace '&', '%26'
   write-output "escaped sasUrl=$($env:sasUrl)"
   write-output "az deployment group create --name $env:name --resource-group $env:rg --mode Incremental --template-file  'deploy-zipdeployDemo.bicep' --parameters '{'uniquePrefix': {'value': '$env:uniquePrefix'}}' '{'location': {'value': '$env:location'}}' '{'blobSASUri': {'value': '$env:sasUrl'}}'"
   az deployment group create --name $env:name --resource-group $env:rg --mode Incremental --template-file  "deploy-zipdeployDemo.bicep" --parameters "{'uniquePrefix': {'value': '$env:uniquePrefix'}}" "{'location': {'value': '$env:location'}}" "{'blobSASUri': {'value': '$env:sasUrl'}}" | ForEach-Object { $_ -replace "`r", ""}
   End commands to deploy this file using Azure CLI with PowerShell

   Begin common epilog commands
   az resource list -g $env:rg --query "[?resourceGroup=='$env:rg'].{ name: name, flavor: kind, resourceType: type, region: location }" --output table  | ForEach-Object { $_ -replace "`r", ""}
   $elapsedTime = $(get-date) - $StartTime
   $totalTime = "{0:HH:mm:ss}" -f ([datetime]$elapsedTime.Ticks)
   write-output "all done $(Get-Date) elapse time = $totalTime "
   End common epilog commands

 */
// https://github.com/Azure/azure-quickstart-templates/blob/master/quickstarts/microsoft.web/function-app-windows-consumption/azuredeploy.json
// zip deploy vs msdeploy https://github.com/projectkudu/kudu/wiki/MSDeploy-VS.-ZipDeploy

@description('The name of the Azure Function app.')
param uniquePrefix string = uniqueString(resourceGroup().id)
param functionAppName string = 'func-${uniquePrefix}'

@description('Storage Account type')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
])
param storageAccountType string = 'Standard_LRS'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('The language worker runtime to load in the function app.')
@allowed([
  'dotnet-isolated'
  'dotnet'
  'node'
  'python'
  'java'
])
param functionWorkerRuntime string = 'node'

@description('The zip content url.')
param blobSASUri string

var hostingPlanName = 'plan-${uniquePrefix}'
var applicationInsightsName = 'appins-${uniquePrefix}'
var storageAccountName = '${uniquePrefix}holdfuncstg'

output outblobSASUri string = blobSASUri
var packageUri = replace(blobSASUri, '%26', '&')
output outputUnescapedBlobSASUri string = packageUri


resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountType
  }
  kind: 'Storage'
}

resource hostingPlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: hostingPlanName
  location: location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
    size: 'Y1'
    family: 'Y'
  }
  properties: {
    computeMode: 'Dynamic'
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: location
  tags: {
    'hidden-link:${resourceId('Microsoft.Web/sites',applicationInsightsName)}': 'Resource'
  }
  properties: {
    Application_Type: 'web'
  }
  kind: 'web'
}

resource functionApp 'Microsoft.Web/sites@2022-03-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp'
  properties: {
    serverFarmId: hostingPlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: reference(applicationInsights.id, '2020-02-02').InstrumentationKey
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccount.id,'2021-09-01').keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccount.id,'2021-09-01').keys[0].value}'
        }
        {
          name: 'WEBSITE_USE_PLACEHOLDER_DOTNETISOLATED'
          value: '1'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower(functionAppName)
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: functionWorkerRuntime
        }
        // {
        //   name: 'WEBSITE_NODE_DEFAULT_VERSION'
        //   value: '~14'
        // }
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '1'
        }
      ]
    }
  }
}

//   ERROR: {
//     "status": "Failed",
//     "error": {
//       "code": "DeploymentFailed",
//       "target": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_zipdeployDemo/providers/Microsoft.Resources/deployments/zipdeployDemo",
//       "message": "At least one resource deployment operation failed. Please list deployment operations for details. Please see https://aka.ms/arm-deployment-operations for usage details.",
//       "details": [
//         {
//           "code": "ResourceDeploymentFailure",
//           "target": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_zipdeployDemo/providers/Microsoft.Web/sites/func-mpkvs/extensions/zipdeploy",
//           "message": "The resource write operation failed to complete successfully, because it reached terminal provisioning state 'Failed'."
//         }
//       ]
//     }
//   }
//
// WARNING: C:\Users\shein\source\repos\Siegfried Samples\zipdeployhttpfunc\infrastructure\deploy-zipdeployDemo.bicep(274,5) : Warning BCP037: The property "computeMode" is not allowed on objects of type "AppServicePlanProperties". Permissible properties include "elasticScaleEnabled", "freeOfferExpirationTime", "hostingEnvironmentProfile", "hyperV", "isSpot", "isXenon", "kubeEnvironmentProfile", "maximumElasticWorkerCount", "perSiteScaling", "reserved", "spotExpirationTime", "targetWorkerCount", "targetWorkerSizeId", "workerTierName", "zoneRedundant". If this is an inaccuracy in the documentation, please report it to the Bicep Team. [https://aka.ms/bicep-type-issues]
resource functionAppName_zipdeploy 'Microsoft.Web/sites/extensions@2022-03-01' = {
  parent: functionApp
  name: 'zipdeploy'
  properties: {
    packageUri: packageUri
  }
}
