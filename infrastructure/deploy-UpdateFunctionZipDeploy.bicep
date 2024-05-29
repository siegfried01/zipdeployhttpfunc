/*
   From a (cygwin) bash prompt, use this perl one-liner to extract the powershell script fragments and exeucte them. This example shows how to execute steps 2 (shutdown) and steps 4-13 and skipping steps 7,8,9 because they don't work (yet). Adjust that list of steps according to your needs.

   powershell -executionPolicy unrestricted -Command - <<EOF
   `perl -lne 'sub range {$b=shift; $e=shift; $r=""; for(($b..$e)){ $r=$r."," if $r; $r=$r.$_;} $r } BEGIN {  $_ = shift; s/([0-9]+)-([0-9]+)/range($1,$2)/e; @idx=split ","; $c=0; $x=0; $f=0; $s=[] } $c++ if /^\s*Begin/; if (/^\s*End/) {$c--;$s[$f++]=""}; if ($x+$c>1) { $s->[$f]=$s->[$f].$_."\n"  } $x=$c; END { push(@idx, $#s); unshift @idx,0; for (@idx) { $p=$s->[$_]; chomp $p; print $p } }' "2,4-6,10-13" < "Az CLI commands for deployment using ARM Template.bicep"  `
EOF

   Begin common prolog commands
   $env:subscriptionId=(az account show --query id --output tsv | ForEach-Object { $_ -replace "`r", ""})
   $env:name="UpdateFunctionZipDeploy_$($env:USERNAME)"
   $env:rg="rg_$($env:name)"
   $env:loc=$env:AZ_DEFAULT_LOC
   $env:uniquePrefix="$(If ($env:USERNAME -eq "v-richardsi") {"zhbov"} ElseIf ($env:USERNAME -eq "v-paperry") { "clwti" } ElseIf ($env:USERNAME -eq "hein") {"pjhcs"} Else { "zsevf" } )"
   End common prolog commands

   emacs F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   az deployment group create --name $env:name --resource-group $env:rg --mode Incremental --template-file  "Az CLI commands for deployment using ARM Template.bicep" --parameters "{'uniquePrefix': {'value': '$env:uniquePrefix'}}" | ForEach-Object { $_ -replace "`r", ""}
   write-output "end deploy $(Get-Date)"
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 2 F10
   Begin commands to shut down this deployment using Azure CLI with PowerShell
   write-output "begin shutdown $env:rg $(Get-Date)"
   az deployment group create --mode complete --template-file ./clear-resources.json --resource-group $env:rg  | ForEach-Object { $_ -replace "`r", ""}
   write-output "showdown is complete $env:rg $(Get-Date)" 
   End commands to shut down this deployment using Azure CLI with PowerShell

   emacs ESC 3 F10
   Begin commands for one time initializations using Azure CLI with PowerShell
   az group create -l $env:loc -n $env:rg
   $env:id=(az group show --name $env:rg --query 'id' --output tsv)
   write-output "id=$env:id"
   $env:sp="spad_$env:name"
   #az ad sp create-for-rbac --name $env:sp --json-auth --role contributor --scopes $env:id
   write-output "go to github settings->secrets and create a secret called AZURE_CREDENTIALS with the above output"
   write-output "{`n`"`$schema`": `"https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#`",`n `"contentVersion`": `"1.0.0.0`",`n `"resources`": [] `n}" | Out-File -FilePath clear-resources.json
   End commands for one time initializations using Azure CLI with PowerShell

   This code will eventually reside in the pipeline yaml
   Tue May 21 10:12 2024: Tried and failed to skip this step with source control in the bicep.
   emacs ESC 4 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 4 Publish"
   write-output "dotnet publish '../zipdeployhttpfunc.csproj'  --configuration Release  -f net6.0 --self-contained --output ./publish-functionapp"
   dotnet publish "../zipdeployhttpfunc.csproj"  --configuration Release  -f net6.0 --self-contained --output ./publish-functionapp
   End commands to deploy this file using Azure CLI with PowerShell

   This code will eventually reside in the pipeline yaml
   emacs ESC 5 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 5 zip"
   pushd ./publish-functionapp
   write-output "Compress-Archive -Path .\* -DestinationPath ../publish-functionapp.zip -Force"
   Compress-Archive -Path .\* -DestinationPath ../publish-functionapp.zip -Force
   popd
   End commands to deploy this file using Azure CLI with PowerShell

   see also: https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#azure-service-bus-data-receiver

   az ad sp create-for-rbac --name 'zhbov-func' --role contributor --scopes '/subscriptions/13c9725f-d20a-4c99-8ef4-d7bb78f98cff/resourceGroups/rg_UpdateFunctionZipDeploy_v-richardsi' --sdk-auth
   WARNING: Option '--sdk-auth' has been deprecated and will be removed in a future release.
   WARNING: Creating 'contributor' role assignment under scope '/subscriptions/13c9725f-d20a-4c99-8ef4-d7bb78f98cff/resourceGroups/rg_UpdateFunctionZipDeploy_v-richardsi'
   WARNING:   Role assignment creation failed.
   
   WARNING:   role assignment response headers: {'Cache-Control': 'no-cache', 'Pragma': 'no-cache', 'Content-Length': '535', 'Content-Type': 'application/json; charset=utf-8', 'Expires': '-1', 'x-ms-failure-cause': 'gateway', 'x-ms-request-id': '86d64c21-92af-4313-b59a-98e9eb21abc1', 'x-ms-correlation-request-id': '86d64c21-92af-4313-b59a-98e9eb21abc1', 'x-ms-routing-request-id': 'WESTUS2:20240529T160018Z:86d64c21-92af-4313-b59a-98e9eb21abc1', 'Strict-Transport-Security': 'max-age=31536000; includeSubDomains', 'X-Content-Type-Options': 'nosniff', 'X-Cache': 'CONFIG_NOCACHE', 'X-MSEdge-Ref': 'Ref A: 3CC732708BEF4904BF4CB969E56120E6 Ref B: CO6AA3150219017 Ref C: 2024-05-29T16:00:18Z', 'Date': 'Wed, 29 May 2024 16:00:17 GMT'}
   
   ERROR: (AuthorizationFailed) The client 'v-richardsi@microsoft.com' with object id '59a5c091-d444-4ef3-912c-4761185c3cf2' does not have authorization to perform action 'Microsoft.Authorization/roleAssignments/write' over scope '/subscriptions/13c9725f-d20a-4c99-8ef4-d7bb78f98cff/resourceGroups/rg_UpdateFunctionZipDeploy_v-richardsi/providers/Microsoft.Authorization/roleAssignments/c38c7a11-3b25-4fbb-b26e-6ab686050b49' or the scope is invalid. If access was recently granted, please refresh your credentials.
   Code: AuthorizationFailed
   Message: The client 'v-richardsi@microsoft.com' with object id '59a5c091-d444-4ef3-912c-4761185c3cf2' does not have authorization to perform action 'Microsoft.Authorization/roleAssignments/write' over scope '/subscriptions/13c9725f-d20a-4c99-8ef4-d7bb78f98cff/resourceGroups/rg_UpdateFunctionZipDeploy_v-richardsi/providers/Microsoft.Authorization/roleAssignments/c38c7a11-3b25-4fbb-b26e-6ab686050b49' or the scope is invalid. If access was recently granted, please refresh your credentials.


   emacs ESC 6 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Step 6 create service principal"
   write-output "az ad sp create-for-rbac --name '$($env:uniquePrefix)-func' --role contributor --scopes '/subscriptions/$($env:subscriptionId)/resourceGroups/$env:rg' --sdk-auth"
   az ad sp create-for-rbac --name zipdeployhttpfunc20240529083641 --role contributor --scopes "/subscriptions/$($env:subscriptionId)/resourceGroups/$env:rg" --sdk-auth  
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 7 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Step 7 create storage account"
   write-output "az storage account create -n '$($env:uniquePrefix)stgacc' -g $env:rg"
   az storage account create -n "$($env:uniquePrefix)stgacc" -g $env:rg  
   End commands to deploy this file using Azure CLI with PowerShell

   Begin common epilog commands
   az resource list -g $env:rg --query "[?resourceGroup=='$env:rg'].{ name: name, flavor: kind, resourceType: type, region: location }" --output table  | ForEach-Object { $_ -replace "`r", ""}
   write-output "all done $(Get-Date)"
   End common epilog commands

 */


//    See https://github.com/Azure-Samples/function-app-arm-templates/blob/main/zip-deploy-arm-az-cli/README.md#steps
// see zip-deploy-arm-az-cli/README.md


param uniquePrefix string = uniqueString(resourceGroup().id)

@description('The name of the Azure Function app.')
param functionAppName string = '${uniquePrefix}-func'

@description('The location into which the resources should be deployed.')
param location string = resourceGroup().location

@description('The zip content url.')
param packageUri string

resource functionAppName_ZipDeploy 'Microsoft.Web/sites/extensions@2021-02-01' = {
  name: '${functionAppName}/ZipDeploy'
  properties: {
    packageUri: packageUri
  }
}
