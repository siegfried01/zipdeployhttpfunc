/*
   From a (cygwin) bash prompt, use this perl one-liner to extract the powershell script fragments and exeucte them. This example shows how to execute steps 2 (shutdown) and steps 4-13 and skipping steps 7,8,9 because they don't work (yet). Adjust that list of steps according to your needs.

   powershell -executionPolicy unrestricted -Command - <<EOF
   `perl -lne 'sub range {$b=shift; $e=shift; $r=""; for(($b..$e)){ $r=$r."," if $r; $r=$r.$_;} $r } BEGIN {  $_ = shift; s/([0-9]+)-([0-9]+)/range($1,$2)/e; @idx=split ","; $c=0; $x=0; $f=0; $s=[] } $c++ if /^\s*Begin/; if (/^\s*End/) {$c--;$s[$f++]=""}; if ($x+$c>1) { $s->[$f]=$s->[$f].$_."\n"  } $x=$c; END { push(@idx, $#s); unshift @idx,0; for (@idx) { $p=$s->[$_]; chomp $p; print $p } }' "2,4-6,10-13" < "Az CLI commands for deployment using ARM Template.bicep"  `
EOF

   Begin common prolog commands
   $env:subscriptionId=(az account show --query id --output tsv | ForEach-Object { $_ -replace "`r", ""})
   $env:name="UpdateFunctionZipDeploy_$($env:USERNAME)"
   If ($env:USERNAME -eq "shein") { $env:name='UpdateFunctionZipDeploy' } else { $env:name="UpdateFunctionZipDeploy_$($env:USERNAME)" }
   $env:rg="rg_$($env:name)"
   $env:loc=If ($env:AZ_DEFAULT_LOC) { $env:AZ_DEFAULT_LOC} Else {'eastus2'}
   $env:uniquePrefix="$(If ($env:USERNAME -eq "richard") {"zhbov"} ElseIf ($env:USERNAME -eq "paperry") { "clwti" } ElseIf ($env:USERNAME -eq "shein") {"zsevf"} Else { "pjhcs"  } )"
   $env:functionAppName="$($env:uniquePrefix)-func"
   $env:storageAccountName="$($env:uniquePrefix)funcstg"
   $env:stgContainer="mycontainer"
   $StartTime = $(get-date)
   write-output "start build for resource group = $($env:rg) at $StartTime"
   End common prolog commands

   emacs F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   az deployment group create --name $env:name --resource-group $env:rg --mode Incremental --template-file  "deploy-UpdateFunctionZipDeploy.bicep" --parameters "{'uniquePrefix': {'value': '$env:uniquePrefix'}}" "{'packageUri': {'value': '$env:sasUrl'}}" | ForEach-Object { $_ -replace "`r", ""}
   write-output "end deploy $(Get-Date)"
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 2 F10
   Begin commands to shut down this deployment using Azure CLI with PowerShell
   write-output "begin shutdown $env:rg $(Get-Date)"
   az deployment group create --mode complete --template-file ./clear-resources.json --resource-group $env:rg  | ForEach-Object { $_ -replace "`r", ""}
   write-output "showdown is complete $env:rg $(Get-Date)" 
   End commands to shut down this deployment using Azure CLI with PowerShell

   emacs ESC 3 F10
   Begin commands to shut down this deployment using Azure CLI with PowerShell
   write-output "Step 3: begin shutdown delete resource group $($env:rg) $(Get-Date)"
   write-output "az group delete -n $env:rg"
   az group delete -n $env:rg --yes
   write-output "shutdown is complete $env:rg $(Get-Date)"
   End commands to shut down this deployment using Azure CLI with PowerShell

   emacs ESC 4 F10
   Begin commands for one time initializations using Azure CLI with PowerShell
   write-output "One time initializations: Create resource group and service principal for github workflow"
   write-output "az group create -l $env:loc -n $env:rg"
   az group create -l $env:loc -n $env:rg
   write-output "{`n`"`$schema`": `"https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#`",`n `"contentVersion`": `"1.0.0.0`",`n `"resources`": [] `n}" | Out-File -FilePath clear-resources.json
   End commands for one time initializations using Azure CLI with PowerShell
   
   emacs ESC 5 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 5 Publish"
   write-output "dotnet publish '../zipdeployhttpfunc.csproj'  --configuration Release  -f net6.0 --self-contained --output ./publish-functionapp"
   dotnet publish "../zipdeployhttpfunc.csproj"  --configuration Release  -f net6.0 --self-contained --output ./publish-functionapp
   End commands to deploy this file using Azure CLI with PowerShell

   This code will eventually reside in the pipeline yaml
   emacs ESC 6 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 6 zip"
   pushd ./publish-functionapp
   write-output "Compress-Archive -Path .\* -DestinationPath ../publish-functionapp.zip -Force"
   Compress-Archive -Path .\* -DestinationPath ../publish-functionapp.zip -Force
   popd
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 7 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 7 Create Storage Account for Function App"
   write-output "az storage account create --name $env:storageAccountName  --resource-group $env:rg --location $env:loc --sku Standard_LRS --access-tier Cool"
   az storage account create --name $env:storageAccountName  --resource-group $env:rg --location $env:loc --sku Standard_LRS --access-tier Cool
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 8 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 8 Show Connection strings for storage Storage Account for Function App"
   write-output "az storage account show-connection-string --resource-group $env:rg --name $env:storageAccountName --output TSV"
   az storage account show-connection-string --resource-group $env:rg --name $env:storageAccountName --output TSV
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 9 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 9 Create Windows Function App"
   az functionapp create --resource-group $env:rg --consumption-plan-location $env:loc --runtime dotnet-isolated --runtime-version 8 --functions-version 4 --name $env:functionAppName --storage-account $env:storageAccountName
   az functionapp config appsettings list -n $env:functionAppName -g $env:rg
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 10 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 10 configure function app"
   write-output "az functionapp config appsettings set -g $env:rg -n $env:functionAppName --settings 'WEBSITE_USE_PLACEHOLDER_DOTNETISOLATED=1'"
   az functionapp config appsettings set -g $env:rg -n $env:functionAppName --settings WEBSITE_USE_PLACEHOLDER_DOTNETISOLATED=1
   write-output "az functionapp config set -g $env:rg -n $env:functionAppName --net-framework-version 'v8.0'"
   az functionapp config set -g $env:rg -n $env:functionAppName --net-framework-version v8.0
   write-output "az functionapp config set -g $env:rg -n $env:functionAppName --use-32bit-worker-process false"
   az functionapp config set -g $env:rg -n $env:functionAppName --use-32bit-worker-process false
   write-output "az functionapp config appsettings set --name $env:functionAppName --resource-group $env:rg --settings FUNCTIONS_EXTENSION_VERSION=~4"
   az functionapp config appsettings set --name $env:functionAppName --resource-group $env:rg --settings FUNCTIONS_EXTENSION_VERSION=~4
   End commands to deploy this file using Azure CLI with PowerShell


   // https://learn.microsoft.com/en-us/cli/azure/functionapp?view=azure-cli-latest#az-functionapp-deploy
   emacs ESC 11 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 11 deploy compiled #C code deployment to azure resource"
   write-output "az functionapp deployment source config-zip -g $env:rg -n $env:functionAppName --src ./publish-functionapp.zip"
   az functionapp deployment source config-zip -g $env:rg -n $env:functionAppName --src ./publish-functionapp.zip
   End commands to deploy this file using Azure CLI with PowerShell

   see also: https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#azure-service-bus-data-receiver

   emacs ESC 12 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Step 12 create service principal"
   write-output "az ad sp create-for-rbac --name $env:functionAppName --role contributor --scopes '/subscriptions/$($env:subscriptionId)/resourceGroups/$env:rg' --sdk-auth"
   az ad sp create-for-rbac --name $env:functionAppName --role contributor --scopes "/subscriptions/$($env:subscriptionId)/resourceGroups/$env:rg" --sdk-auth  
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 13 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Step 13 create blob storage account to hold zip of compiled C# for functionapp"
   write-output "az storage account create -n '$($env:uniquePrefix)blobstg' -g $env:rg --access-tier cool --sku Standard_LRS"
   az storage account create -n "$($env:uniquePrefix)blobstg" -g $env:rg   --access-tier cool --sku Standard_LRS
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 14 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Step 14 create storage container"
   $env:conn=(az storage account show-connection-string --name "$($env:uniquePrefix)blobstg" --resource-group $env:rg | jq '.connectionString')
   write-output "az storage container create -n $env:stgContainer --account-name '$($env:uniquePrefix)blobstg'"
   az storage container create -n $env:stgContainer --account-name "$($env:uniquePrefix)blobstg"  --connection-string $env:conn
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 15 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Step 15 upload zip to blob"
   $env:conn=(az storage account show-connection-string --name "$($env:uniquePrefix)blobstg" --resource-group $env:rg | jq '.connectionString')
   write-output "conn=$($env:conn)"
   write-output "az storage blob upload -f publish-functionapp.zip --account-name '$($env:uniquePrefix)blobstg'  -c $env:stgContainer -n "package_zip" --overwrite true  --connection-string $env:conn"
   az storage blob upload -f publish-functionapp.zip --account-name "$($env:uniquePrefix)blobstg"  -c $env:stgContainer -n "package_zip" --overwrite true  --connection-string $env:conn
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 16 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Step 16 deploy with az functionapp deploy"
   $env:conn=(az storage account show-connection-string --name "$($env:uniquePrefix)blobstg" --resource-group $env:rg | jq '.connectionString')
   write-output "az storage blob generate-sas --full-uri --permissions r --expiry (get-date).AddMinutes(60).ToString('yyyy-MM-ddTHH:mm:ssZ') --account-name '$($env:uniquePrefix)blobstg' -c $env:stgContainer -n package_zip"
   $env:sasUrl=(az storage blob generate-sas --full-uri --permissions r --expiry (get-date).AddMinutes(60).ToString("yyyy-MM-ddTHH:mm:ssZ") --account-name "$($env:uniquePrefix)blobstg" -c $env:stgContainer -n package_zip  --connection-string $env:conn)
   write-output "sasUrl=$($env:sasUrl)"
   write-output "az functionapp deploy --async false --clean true --name $($env:functionAppName) --resource-group $($env:rg) --restart true --src-url $($env:sasUrl) --type zip"
   az functionapp deploy --async false --clean true --name $env:functionAppName --resource-group $env:rg --restart true --src-url $env:sasUrl --type zip
   End commands to deploy this file using Azure CLI with PowerShell

   start build for resource group = rg_UpdateFunctionZipDeploy_v-richardsi at 07/11/2024 13:22:04
   Step 16 deploy with az functionapp deploy
   az storage blob generate-sas --full-uri --permissions r --expiry (get-date).AddMinutes(60).ToString('yyyy-MM-ddTHH:mm:ssZ') --account-name 'pjhcsblobstg' -c mycontainer -n package_zip
   sasUrl="https://pjhcsblobstg.blob.core.windows.net/mycontainer/package_zip?se=2024-07-11T14%3A22%3A08Z&sp=r&sv=2022-11-02&sr=b&sig=oG9qrzkRLhudLx0oKyDmHRbbDP3nKxejb84TP4sQpns%3D"
   az functionapp deploy --async false --clean true --name pjhcs-func --resource-group rg_UpdateFunctionZipDeploy_v-richardsi --restart true --src-url "https://pjhcsblobstg.blob.core.windows.net/mycontainer/package_zip?se=2024-07-11T14%3A22%3A08Z&sp=r&sv=2022-11-02&sr=b&sig=oG9qrzkRLhudLx0oKyDmHRbbDP3nKxejb84TP4sQpns%3D" --type zip
   WARNING: This command is in preview and under development. Reference and support levels: https://aka.ms/CLI_refstatus
   WARNING: Deployment status is: "InProgress"
   {
     "active": false,
     "author": "N/A",
     "author_email": "N/A",
     "complete": false,
     "deployer": "OneDeploy",
     "end_time": null,
     "id": null,
     "is_readonly": false,
     "is_temp": true,
     "last_success_end_time": null,
     "log_url": null,
     "message": "OneDeploy",
     "progress": "Fetching changes.",
     "provisioningState": "InProgress",
     "received_time": "2024-07-11T20:22:26.0870065Z",
     "site_name": "pjhcs-func",
     "start_time": "2024-07-11T20:22:26.0870065Z",
     "status": 0,
     "status_text": "Receiving changes.",
     "url": null
   }
   resource group = rg_UpdateFunctionZipDeploy_v-richardsi
   Name                            Flavor       ResourceType                                        Region
   ------------------------------  -----------  --------------------------------------------------  --------
   pjhcsfuncstg                    StorageV2    Microsoft.Storage/storageAccounts                   eastus2
   pjhcs-func                      functionapp  Microsoft.Web/sites                                 eastus2
   pjhcs-func                      web          Microsoft.Insights/components                       eastus2
   EastUS2Plan                     functionapp  Microsoft.Web/serverFarms                           eastus2
   aztblogsv12f6djjmnefzwsa        StorageV2    microsoft.storage/storageAccounts                   eastus2
   Failure Anomalies - pjhcs-func               microsoft.alertsmanagement/smartDetectorAlertRules  global
   pjhcsblobstg                    StorageV2    Microsoft.Storage/storageAccounts                   eastus2
   all done 07/11/2024 13:22:30 elapse time = 00:00:25 


   emacs ESC 17 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Step 17 generate blob SAS and deploy"
   $env:conn=(az storage account show-connection-string --name "$($env:uniquePrefix)blobstg" --resource-group $env:rg | jq '.connectionString')
   write-output "az storage blob generate-sas --full-uri --permissions r --expiry (get-date).AddMinutes(60).ToString('yyyy-MM-ddTHH:mm:ssZ') --account-name '$($env:uniquePrefix)blobstg' -c $env:stgContainer -n package_zip"
   $env:sasUrl=(az storage blob generate-sas --full-uri --permissions r --expiry (get-date).AddMinutes(60).ToString("yyyy-MM-ddTHH:mm:ssZ") --account-name "$($env:uniquePrefix)blobstg" -c $env:stgContainer -n package_zip  --connection-string $env:conn)
   write-output "sasUrl=$($env:sasUrl)"
   az deployment group create --name $env:name --resource-group $env:rg --mode Incremental --template-file  "deploy-UpdateFunctionZipDeploy.bicep" --parameters '{\"blobSASUri\": {\"value\": \"$env:sasUrl\"}}' '{\"functionAppName\": {\"value\": \"zipdeployhttpfunc20240529150920\"}}' | ForEach-Object { $_ -replace "`r", ""}
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 18 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Step 18 use REST command to deploy instead of 'az function app"
   $env:conn=(az storage account show-connection-string --name "$($env:uniquePrefix)blobstg" --resource-group $env:rg | jq '.connectionString')
   write-output "az storage blob generate-sas --full-uri --permissions r --expiry (get-date).AddMinutes(60).ToString('yyyy-MM-ddTHH:mm:ssZ') --account-name '$($env:uniquePrefix)blobstg' -c $env:stgContainer -n package_zip"
   $env:sasUrl=(az storage blob generate-sas --full-uri --permissions r --expiry (get-date).AddMinutes(60).ToString("yyyy-MM-ddTHH:mm:ssZ") --account-name "$($env:uniquePrefix)blobstg" -c $env:stgContainer -n package_zip  --connection-string $env:conn)
   write-output "sasUrl=$($env:sasUrl)"
   az rest --method PUT --uri https://management.azure.com/subscriptions/${SUBSCRIPTION}/resourceGroups/${RESOURCE_GROUP}/providers/Microsoft.Web/sites/${WEBAPP}/extensions/onedeploy?api-version=2020-12-01 --body '{ "properties": { "properties": { "packageUri": "'"${APP_URL}"'" }, "type": "zip" } }'
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 18 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Step 18 hard code function and SAS and deploy"
   az deployment group create --name $env:name --resource-group $env:rg --mode Incremental --template-file  "deploy-UpdateFunctionZipDeploy.bicep"  | ForEach-Object { $_ -replace "`r", ""}
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 19 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "delete storage account"
   write-output "az storage account delete -n '$($env:uniquePrefix)blobstg' -g $env:rg --yes"
   az storage account delete -n "$($env:uniquePrefix)blobstg" -g $env:rg --yes
   End commands to deploy this file using Azure CLI with PowerShell

   Begin common epilog commands
   write-output "resource group = $($env:rg)"
   az resource list -g $env:rg --query "[?resourceGroup=='$env:rg'].{ name: name, flavor: kind, resourceType: type, region: location }" --output table  | ForEach-Object { $_ -replace "`r", ""}
   $elapsedTime = $(get-date) - $StartTime
   $totalTime = "{0:HH:mm:ss}" -f ([datetime]$elapsedTime.Ticks)
   write-output "all done $(Get-Date) elapse time = $totalTime "
   End common epilog commands

 */


//    See https://github.com/Azure-Samples/function-app-arm-templates/blob/main/zip-deploy-arm-az-cli/README.md#steps
// see zip-deploy-arm-az-cli/README.md


@description('The name of the Azure Function app.')
param functionAppName string = 'zipdeployhttpfunc20240529150920'

@description('The zip content url.')
param blobSASUri string = 'https://zsevfblobstg.blob.core.windows.net/mycontainer/package_zip?se=2024-05-30T16%3A31%3A51Z&sp=r&sv=2022-11-02&sr=b&sig=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'

output outblobSASUri string = blobSASUri
output outfunctionAppName string = functionAppName

resource functionAppName_ZipDeploy 'Microsoft.Web/sites/extensions@2021-02-01' = {
  name: '${functionAppName}/MSDeploy'
  properties: {
    packageUri: blobSASUri
  }
}
