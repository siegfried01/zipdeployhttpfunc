/*
   From a (cygwin) bash prompt, use this perl one-liner to extract the powershell script fragments and exeucte them. This example shows how to execute steps 2 (shutdown) and steps 4-13 and skipping steps 7,8,9 because they don't work (yet). Adjust that list of steps according to your needs.

  See https://learn.microsoft.com/en-us/answers/questions/1689513/msdeploy-causes-error-failed-to-download-package-s
    Also: https://github.com/Azure-Samples/function-app-arm-templates/blob/main/zip-deploy-arm-az-cli/README.md#steps (this does not work)
    Also: https://azure.github.io/AppService/2021/03/01/deploying-to-network-secured-sites-2.html (try this for web app)
    Also: https://learn.microsoft.com/en-us/cli/azure/functionapp?view=azure-cli-latest#az-functionapp-deploy (try this for function app)


   powershell -executionPolicy unrestricted -Command - <<EOF
   `perl -lne 'sub range {$b=shift; $e=shift; $r=""; for(($b..$e)){ $r=$r."," if $r; $r=$r.$_;} $r } BEGIN {  $_ = shift; s/([0-9]+)-([0-9]+)/range($1,$2)/e; @idx=split ","; $c=0; $x=0; $f=0; $s=[] } $c++ if /^\s*Begin/; if (/^\s*End/) {$c--;$s[$f++]=""}; if ($x+$c>1) { $s->[$f]=$s->[$f].$_."\n"  } $x=$c; END { push(@idx, $#s); unshift @idx,0; for (@idx) { $p=$s->[$_]; chomp $p; print $p } }' "2,4-6,10-13" < "Az CLI commands for deployment using ARM Template.bicep"  `
EOF

   Begin common prolog commands
   $env:subscriptionId=(az account show --query id --output tsv | ForEach-Object { $_ -replace "`r", ""})
   If ($env:USERNAME -eq "shein") { $env:name="UpdateFunctionZipDeploy" } Else { $env:name="UpdateFunctionZipDeploy_$($env:USERNAME)" }
   $env:rg="rg_$($env:name)"
   $env:loc=$env:AZ_DEFAULT_LOC
   $env:uniquePrefix="$(If ($env:USERNAME -eq "richard") {"zhbov"} ElseIf ($env:USERNAME -eq "paperry") { "clwti" } ElseIf ($env:USERNAME -eq "shein") {"zsevf"} Else { "pjhcs"  } )"
   $env:functionAppName="$($env:uniquePrefix)-func"
   $env:functionName="zipdeployhttpfunc"
   $env:sp=$env:functionAppName
   $env:storageAccountName="$($env:uniquePrefix)funcstg"
   $env:blobstg="$($env:uniquePrefix)blobstg"
   $env:stgContainer="mycontainer"
   $env:package_zip="package.zip"
   End common prolog commands

   emacs F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "start with step 3."
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 2 F10
   Begin commands to shut down this deployment using Azure CLI with PowerShell
   write-output "begin shutdown $env:rg $(Get-Date)"
   az deployment group create --mode complete --template-file ./clear-resources.json --resource-group $env:rg  | ForEach-Object { $_ -replace "`r", ""}
   write-output "showdown is complete $env:rg $(Get-Date)" 
   End commands to shut down this deployment using Azure CLI with PowerShell

   emacs ESC 3 F10
   Begin commands for one time initializations using Azure CLI with PowerShell
   write-output "az group create -l $env:loc -n $env:rg"
   az group create -l $env:loc -n $env:rg
   $env:id=(az group show --name $env:rg --query 'id' --output tsv)
   write-output "id=$env:id"
   $env:sp="spad_$env:name"
   #az ad sp create-for-rbac --name $env:sp --json-auth --role contributor --scopes $env:id
   write-output "go to github settings->secrets and create a secret called AZURE_CREDENTIALS with the above output"
   write-output "{`n`"`$schema`": `"https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#`",`n `"contentVersion`": `"1.0.0.0`",`n `"resources`": [] `n}" | Out-File -FilePath clear-resources.json
   End commands for one time initializations using Azure CLI with PowerShell

   emacs ESC 4 F10
   Begin commands to shut down this deployment using Azure CLI with PowerShell
   write-output "step 4 delete resource group"
   write-output "az ad sp list --display-name $env:sp"
   az ad sp list --display-name $env:sp
   write-output "az ad sp list --filter `"displayname eq '$env:sp'`" --output json"
   $env:spId=(az ad sp list --filter "displayname eq '$env:sp'" --query "[].id" --output tsv)
   write-output "az ad sp delete --id $env:spId"
   az ad sp delete --id $env:spId
   write-output "az group delete -n $env:rg --yes"
   az group delete  -n $env:rg --yes
   End commands to shut down this deployment using Azure CLI with PowerShell

   emacs ESC 5 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 5 Publish"
   write-output "dotnet publish '../zipdeployhttpfunc.csproj'  --configuration Release  -f net6.0 --self-contained --output ./publish-functionapp"
   dotnet publish "../zipdeployhttpfunc.csproj"  --configuration Release  -f net6.0 --self-contained --output ./publish-functionapp
   End commands to deploy this file using Azure CLI with PowerShell

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
   write-output "az functionapp create --resource-group $env:rg --consumption-plan-location $env:loc --runtime dotnet-isolated --runtime-version 6 --functions-version 4 --name $env:functionAppName --storage-account $env:storageAccountName"
   az functionapp create --resource-group $env:rg --consumption-plan-location $env:loc --runtime dotnet-isolated --runtime-version 6 --functions-version 4 --name $env:functionAppName --storage-account $env:storageAccountName
   az functionapp config appsettings list -n $env:functionAppName -g $env:rg
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 10 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 10 configure function app"
   write-output "az functionapp config appsettings set -g $env:rg -n $env:functionAppName --settings 'WEBSITE_USE_PLACEHOLDER_DOTNETISOLATED=1'"
   az functionapp config appsettings set -g $env:rg -n $env:functionAppName --settings "WEBSITE_USE_PLACEHOLDER_DOTNETISOLATED=1"
   write-output "az functionapp config set -g $env:rg -n $env:functionAppName --net-framework-version 'v8.0'"
   az functionapp config set -g $env:rg -n $env:functionAppName --net-framework-version v8.0
   write-output "az functionapp config set -g $env:rg -n $env:functionAppName --use-32bit-worker-process false"
   az functionapp config set -g $env:rg -n $env:functionAppName --use-32bit-worker-process false
   write-output "az functionapp config appsettings set --name $env:functionAppName --resource-group $env:rg --settings FUNCTIONS_EXTENSION_VERSION=~4"
   az functionapp config appsettings set --name $env:functionAppName --resource-group $env:rg --settings "FUNCTIONS_EXTENSION_VERSION=~4"
   write-output "az functionapp cors add --name $env:functionAppName --resource-group $env:rg --allowed-origins https://portal.azure.com https://ms-portal.azure.com https://172.56.107.204"
   az functionapp cors add --name $env:functionAppName --resource-group $env:rg --allowed-origins https://portal.azure.com https://ms-portal.azure.com https://172.56.107.204
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 11 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 11 deploy compiled #C code deployment to azure resource (skip this and do with with the zip deploy instead)"
   write-output "az functionapp deployment source config-zip -g $env:rg -n $env:functionAppName --src ./publish-functionapp.zip"
   az functionapp deployment source config-zip -g $env:rg -n $env:functionAppName --src ./publish-functionapp.zip
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 12 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 12 Invoke the function app"
   write-output  "az functionapp keys list -g $env:rg -n $env:functionAppName"
   $FunctionKey=(az functionapp keys list -g $env:rg -n $env:functionAppName --query "functionKeys.default" --output tsv)
   write-output "key = $FunctionKey"
   write-output "`$FunctionApp = Get-AzWebApp -ResourceGroupName $env:rg -Name $env:functionAppName"
   $FunctionApp = Get-AzWebApp -ResourceGroupName $env:rg -Name $env:functionAppName
   # Extract the default hostname (URL)
   Write-output "`$FunctionAppUrl = `$FunctionApp.DefaultHostName"
   $FunctionAppUrl = $FunctionApp.DefaultHostName
   write-output "`$FunctionAppUrl=$FunctionAppUrl"
   write-output "`$RestUrl = `"https://$FunctionAppUrl/api/$($env:functionAppName)?code=$FunctionKey`""
   $RestUrl = "https://$FunctionAppUrl/api/$($env:functionName)?code=$FunctionKey&name=sieg"
   write-output "Invoke-RestMethod -Uri `"$RestUrl`" -Method GET"
   Invoke-RestMethod -Uri "$RestUrl" -Method GET
   End commands to deploy this file using Azure CLI with PowerShell

   see also: https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#azure-service-bus-data-receiver

   emacs ESC 13 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Step 13: Upddate the built at timestamp in the source code (ala ChatGPT)"
   # Path to your C# source file
   $filePath = "..\zipdeployhttpfunc.cs"
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

   emacs ESC 14 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Step 14 create service principal"
   write-output "az ad sp create-for-rbac --name $env:functionAppName --role contributor --scopes '/subscriptions/$($env:subscriptionId)/resourceGroups/$env:rg' --sdk-auth"
   az ad sp create-for-rbac --name $env:functionAppName --role contributor --scopes "/subscriptions/$($env:subscriptionId)/resourceGroups/$env:rg" --sdk-auth  
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 15 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Step 15 create storage account from which to upload the zipped and compiled C# function code"
   write-output "az storage account create -n $($blobstg) -g $env:rg --access-tier cool --sku Standard_LRS"
   az storage account create -n $env:blobstg -g $env:rg   --access-tier cool --sku Standard_LRS
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 16 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Step 16 create storage container"
   $env:conn=(az storage account show-connection-string --name $env:blobstg --resource-group $env:rg | jq '.connectionString')
   write-output "az storage container create -n $env:stgContainer --account-name $($blobstg)"
   az storage container create -n $env:stgContainer --account-name $env:blobstg  --connection-string $env:conn
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 17 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Step 17 upload zip to blob"
   $env:conn=(az storage account show-connection-string --name $env:blobstg --resource-group $env:rg | jq '.connectionString')
   write-output "conn=$($env:conn)"
   write-output "az storage blob upload -f publish-functionapp.zip --account-name $($blobstg)  -c $env:stgContainer -n $($env:package_zip) --overwrite true  --connection-string $env:conn"
   az storage blob upload -f publish-functionapp.zip --account-name $env:blobstg  -c $env:stgContainer -n $env:package_zip --overwrite true  --connection-string $env:conn
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 18 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 18 configure function app WEBSITE_RUN_FROM_PACKAGE=1 after uploading initial deployment"
   write-output "az functionapp config appsettings set -g $env:rg -n $env:functionAppName --settings WEBSITE_RUN_FROM_PACKAGE=1"
   az functionapp config appsettings set -g $env:rg -n $env:functionAppName --settings "WEBSITE_RUN_FROM_PACKAGE=1"
   write-output "az functionapp config appsettings list -n $env:functionAppName -g $env:rg"
   az functionapp config appsettings list -n $env:functionAppName -g $env:rg
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 19 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Step 19 generate blob SAS and deploy"
   $env:conn=(az storage account show-connection-string --name $env:blobstg --resource-group $env:rg | jq '.connectionString')
   write-output "az storage blob generate-sas --full-uri --permissions acdeimrtwx --expiry (get-date).AddMinutes(60).ToString('yyyy-MM-ddTHH:mm:ssZ') --account-name $($blobstg) -c $env:stgContainer -n $($env:package_zip) --https-only --output tsv"
   $env:sasUrl=(az storage blob generate-sas --full-uri --permissions acdeimrtwx --expiry (get-date).AddMinutes(60).ToString("yyyy-MM-ddTHH:mm:ssZ") --account-name $env:blobstg -c $env:stgContainer -n $env:package_zip  --connection-string $env:conn --https-only --output tsv)
   write-output "sasUrl=$($env:sasUrl)"
   $env:sasUrl =  $env:sasUrl -replace '&', '%26'
   write-output "escaped sasUrl=$($env:sasUrl)"
   az deployment group create --name $env:name --resource-group $env:rg --mode Incremental --template-file  "deploy-UpdateFunctionZipDeploy.bicep" --parameters "{'packageUri': {'value': '$env:sasUrl'}}" "{'functionAppName': {'value': '$env:functionAppName'}}" | ForEach-Object { $_ -replace "`r", ""}
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 20 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Step 20 deploy using parameters file deploy-UpdateFunctionZipDeploy.parameters.json"
   az deployment group create --name $env:name --resource-group $env:rg --mode Incremental --template-file  "deploy-UpdateFunctionZipDeploy.bicep" --parameters "@deploy-UpdateFunctionZipDeploy.parameters.json" | ForEach-Object { $_ -replace "`r", ""}
   End commands to deploy this file using Azure CLI with PowerShell


   ERROR: {
     "status": "Failed",
     "error": {
       "code": "DeploymentFailed",
       "target": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_UpdateFunctionZipDeploy_shein/providers/Microsoft.Resources/deployments/UpdateFunctionZipDeploy_shein",
       "message": "At least one resource deployment operation failed. Please list deployment operations for details. Please see https://aka.ms/arm-deployment-operations for usage details.",
       "details": [
         {
           "code": "ResourceDeploymentFailure",
           "target": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_UpdateFunctionZipDeploy_shein/providers/Microsoft.Web/sites/zipdeployhttpfunc20240529150920/extensions/ZipDeploy",
           "message": "The resource write operation failed to complete successfully, because it reached terminal provisioning state 'Failed'."
         }
       ]
     }
   }


   emacs ESC 21 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Step 21 confirm containers."
   $env:conn=(az storage account show-connection-string --name $env:blobstg --resource-group $env:rg | jq '.connectionString')
   write-output "az storage container list  --account-name $($blobstg)"
   az storage container list --account-name $($blobstg)  --connection-string $env:conn
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 22 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Step 22 manual deploy, this prompts for a passwoprd and does not work."
   write-output "curl -X POST -u sheintze https://zipdeployhttpfunc20240529150920.scm.azurewebsites.net/api/zipdeploy -T publish-functionapp.zip"
   curl -X POST -u sheintze https://zipdeployhttpfunc20240529150920.scm.azurewebsites.net/api/zipdeploy -T publish-functionapp.zip
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 23 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Step 23 manual deploy"
   $publishUrl = "https://zipdeployhttpfunc20240529150920.scm.azurewebsites.net/msdeploy.axd?site=<yourappname>"
   $zipPath = "publish-functionapp.zip"
   $deployUser = "sheintze@hotmail.com"
   $deployPassword = "\"
   "C:\Program Files (x86)\IIS\Microsoft Web Deploy V3\msdeploy.exe" -verb:sync -source:package="$zipPath" -dest:auto,computerName="$publishUrl",userName="$deployUser",password="$deployPassword",authtype="Basic"
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 24 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "curl -X GET 'https://zipdeployhttpfunc20240529150920.azurewebsites.net/api/zipdeployhttpfunc?code=n4uvzuVpQ5iOuEMSSROOSKMD-oW7wBPKfYoEMdA9TQh5AzFuvby8Bg%3D%3D&name=siegfried'"
   curl -X GET "https://zipdeployhttpfunc20240529150920.azurewebsites.net/api/zipdeployhttpfunc?code=n4uvzuVpQ5iOuEMSSROOSKMD-oW7wBPKfYoEMdA9TQh5AzFuvby8Bg%3D%3D&name=siegfried"
   write-output "Built at Fri May 31 05:52:32 2024 Hello, siegfried. This HTTP triggered function executed successfully.2024 Jun 03 12:45:03.216 AM (+00:00)Name   "
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 25 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Step 25 delete storage account"
   write-output "az storage account delete -n $($blobstg) -g $env:rg --yes"
   az storage account delete -n $env:blobstg -g $env:rg --yes
   End commands to deploy this file using Azure CLI with PowerShell

   Begin common epilog commands
   write-output "resource group $($env:rg)"
   az resource list -g $env:rg --query "[?resourceGroup=='$env:rg'].{ name: name, flavor: kind, resourceType: type, region: location }" --output table  | ForEach-Object { $_ -replace "`r", ""}
   write-output "all done $(Get-Date)"
   End common epilog commands

 */


//    See https://github.com/Azure-Samples/function-app-arm-templates/blob/main/zip-deploy-arm-az-cli/README.md#steps
// see zip-deploy-arm-az-cli/README.md


@description('The name of the Azure Function app.')
param functionAppName string 

@description('The zip content url.')
param packageUri string 

output outpackageUri string = packageUri
output outfunctionAppName string = functionAppName

// https://github.com/projectkudu/kudu/wiki/MSDeploy-VS.-ZipDeploy#zipdeploy MSDeploy does not work with WEBSITE_RUN_FROM_PACKAGE=1.
resource functionAppName_ZipDeploy 'Microsoft.Web/sites/extensions@2021-02-01' = {
  name: '${functionAppName}/ZipDeploy'
  properties: {
    packageUri: packageUri
  }
}
