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
   $env:uniquePrefix="$(If ($env:USERNAME -eq "richard") {"zhbov"} ElseIf ($env:USERNAME -eq "paperry") { "clwti" } ElseIf ($env:USERNAME -eq "shein") {"zsevf"} Else { "pjhcs"  } )"
   $env:functionAppName="$($env:uniquePrefix)-func"
   $env:functionAppName="zipdeployhttpfunc20240529150920"
   $env:stgContainer="mycontainer"
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
   Begin commands for one time initializations using Azure CLI with PowerShell
   az group create -l $env:loc -n $env:rg
   $env:id=(az group show --name $env:rg --query 'id' --output tsv)
   write-output "id=$env:id"
   $env:sp="spad_$env:name"
   #az ad sp create-for-rbac --name $env:sp --json-auth --role contributor --scopes $env:id
   write-output "go to github settings->secrets and create a secret called AZURE_CREDENTIALS with the above output"
   write-output "{`n`"`$schema`": `"https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#`",`n `"contentVersion`": `"1.0.0.0`",`n `"resources`": [] `n}" | Out-File -FilePath clear-resources.json
   End commands for one time initializations using Azure CLI with PowerShell

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

   emacs ESC 6 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 6 configure function app"
   write-output "az functionapp config appsettings set -g $env:rg -n $env:functionAppName --settings 'WEBSITE_USE_PLACEHOLDER_DOTNETISOLATED=1'"
   az functionapp config appsettings set -g $env:rg -n $env:functionAppName --settings WEBSITE_USE_PLACEHOLDER_DOTNETISOLATED=1
   write-output "az functionapp config set -g $env:rg -n $env:functionAppName --net-framework-version 'v8.0'"
   az functionapp config set -g $env:rg -n $env:functionAppName --net-framework-version v8.0
   write-output "az functionapp config set -g $env:rg -n $env:functionAppName --use-32bit-worker-process false"
   az functionapp config set -g $env:rg -n $env:functionAppName --use-32bit-worker-process false
   write-output "az functionapp config appsettings set --name $env:functionAppName --resource-group $env:rg --settings FUNCTIONS_EXTENSION_VERSION=~4"
   az functionapp config appsettings set --name $env:functionAppName --resource-group $env:rg --settings FUNCTIONS_EXTENSION_VERSION=~4
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 7 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 7 deploy compiled #C code deployment to azure resource"
   write-output "az functionapp deployment source config-zip -g $env:rg -n $env:functionAppName --src ./publish-functionapp.zip"
   az functionapp deployment source config-zip -g $env:rg -n $env:functionAppName --src ./publish-functionapp.zip
   End commands to deploy this file using Azure CLI with PowerShell

   see also: https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#azure-service-bus-data-receiver

   emacs ESC 8 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Step 8 create service principal"
   write-output "az ad sp create-for-rbac --name $env:functionAppName --role contributor --scopes '/subscriptions/$($env:subscriptionId)/resourceGroups/$env:rg' --sdk-auth"
   az ad sp create-for-rbac --name $env:functionAppName --role contributor --scopes "/subscriptions/$($env:subscriptionId)/resourceGroups/$env:rg" --sdk-auth  
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 9 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Step 9 create storage account"
   write-output "az storage account create -n '$($env:uniquePrefix)stgacc' -g $env:rg --access-tier cool --sku Standard_LRS"
   az storage account create -n "$($env:uniquePrefix)stgacc" -g $env:rg   --access-tier cool --sku Standard_LRS
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 10 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Step 10 create storage container"
   $env:conn=(az storage account show-connection-string --name "$($env:uniquePrefix)stgacc" --resource-group $env:rg | jq '.connectionString')
   write-output "az storage container create -n $env:stgContainer --account-name '$($env:uniquePrefix)stgacc'"
   az storage container create -n $env:stgContainer --account-name "$($env:uniquePrefix)stgacc"  --connection-string $env:conn
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 11 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Step 11 upload zip to blob"
   $env:conn=(az storage account show-connection-string --name "$($env:uniquePrefix)stgacc" --resource-group $env:rg | jq '.connectionString')
   write-output "conn=$($env:conn)"
   write-output "az storage blob upload -f publish-functionapp.zip --account-name '$($env:uniquePrefix)stgacc'  -c $env:stgContainer -n "package_zip" --overwrite true  --connection-string $env:conn"
   az storage blob upload -f publish-functionapp.zip --account-name "$($env:uniquePrefix)stgacc"  -c $env:stgContainer -n "package_zip" --overwrite true  --connection-string $env:conn
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 12 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Step 12 generate blob SAS and deploy"
   $env:conn=(az storage account show-connection-string --name "$($env:uniquePrefix)stgacc" --resource-group $env:rg | jq '.connectionString')
   write-output "az storage blob generate-sas --full-uri --permissions r --expiry (get-date).AddMinutes(60).ToString('yyyy-MM-ddTHH:mm:ssZ') --account-name '$($env:uniquePrefix)stgacc' -c $env:stgContainer -n package_zip"
   $env:sasUrl=(az storage blob generate-sas --full-uri --permissions r --expiry (get-date).AddMinutes(60).ToString("yyyy-MM-ddTHH:mm:ssZ") --account-name "$($env:uniquePrefix)stgacc" -c $env:stgContainer -n package_zip  --connection-string $env:conn)
   write-output "sasUrl=$($env:sasUrl)"
   az deployment group create --name $env:name --resource-group $env:rg --mode Incremental --template-file  "deploy-UpdateFunctionZipDeploy.bicep" --parameters '{\"blobSASUri\": {\"value\": \"$env:sasUrl\"}}' '{\"functionAppName\": {\"value\": \"zipdeployhttpfunc20240529150920\"}}' | ForEach-Object { $_ -replace "`r", ""}
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 13 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Step 13 hard code function and SAS and deploy"
   az deployment group create --name $env:name --resource-group $env:rg --mode Incremental --template-file  "deploy-UpdateFunctionZipDeploy.bicep"  | ForEach-Object { $_ -replace "`r", ""}
   End commands to deploy this file using Azure CLI with PowerShell

   Step 13 hard code function and SAS and deploy
   WARNING: C:\Users\shein\source\repos\Siegfried Samples\zipdeployhttpfunc\infrastructure\deploy-UpdateFunctionZipDeploy.bicep(307,53) : Warning no-hardcoded-env-urls: Environment URLs should not be hardcoded. Use the environment() function to ensure compatibility across clouds. Found this disallowed host: "core.windows.net" [https://aka.ms/bicep/linter/no-hardcoded-env-urls]
   
   ERROR: {
     "status": "Failed",
     "error": {
       "code": "DeploymentFailed",
       "target": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_UpdateFunctionZipDeploy_shein/providers/Microsoft.Resources/deployments/UpdateFunctionZipDeploy_shein",
       "message": "At least one resource deployment operation failed. Please list deployment operations for details. Please see https://aka.ms/arm-deployment-operations for usage details.",
       "details": [
         {
           "code": "ResourceDeploymentFailure",
           "target": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_UpdateFunctionZipDeploy_shein/providers/Microsoft.Web/sites/zipdeployhttpfunc20240529150920/extensions/MSDeploy",
           "message": "The resource write operation failed to complete successfully, because it reached terminal provisioning state 'failed'.",
           "details": [
             {
               "code": "Failed",
               "message": "Failed to download package.
                          ARM-MSDeploy Deploy Failed: 'System.AggregateException: One or more errors occurred. ---&amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;gt; System.Net.WebException: The remote server returned an error: (403) Forbidden.
                             at System.Net.HttpWebRequest.EndGetResponse(IAsyncResult asyncResult)
                             at System.Net.WebClient.GetWebResponse(WebRequest request, IAsyncResult result)
                             at System.Net.WebClient.DownloadBitsResponseCallback(IAsyncResult result)
                             --- End of inner exception stack trace ---
                             at System.Threading.Tasks.Task.ThrowIfExceptional(Boolean includeTaskCanceledExceptions)
                             at System.Threading.Tasks.Task.Wait(Int32 millisecondsTimeout, CancellationToken cancellationToken)
                             at System.Threading.Tasks.Task.Wait(TimeSpan timeout)
                             at Microsoft.Web.Deployment.WebApi.AppGalleryPackage.&amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;lt;Download&amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;gt;d__17.MoveNext() in C:\__w\1\s\src\hosting\wdeploy\Microsoft.Web.Deployment.WebApi\AppGalleryPackage.cs:line 196
                          --- End of stack trace from previous location where exception was thrown ---
                             at System.Runtime.ExceptionServices.ExceptionDispatchInfo.Throw()
                             at System.Runtime.CompilerServices.TaskAwaiter.HandleNonSuccessAndDebuggerNotification(Task task)
                             at Microsoft.Web.Deployment.WebApi.AppGalleryPackage.&amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;lt;Download&amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;gt;d__15.MoveNext() in C:\__w\1\s\src\hosting\wdeploy\Microsoft.Web.Deployment.WebApi\AppGalleryPackage.cs:line 93
                          --- End of stack trace from previous location where exception was thrown ---
                             at System.Runtime.ExceptionServices.ExceptionDispatchInfo.Throw()
                             at System.Runtime.CompilerServices.TaskAwaiter.HandleNonSuccessAndDebuggerNotification(Task task)
                             at Microsoft.Web.Deployment.WebApi.DeploymentController.&amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;lt;DownloadPackageAndSettings&amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;gt;d__27.MoveNext() in C:\__w\1\s\src\hosting\wdeploy\Microsoft.Web.Deployment.WebApi\Controllers\DeploymentController.cs:line 623
                          --- End of stack trace from previous location where exception was thrown ---
                             at System.Runtime.ExceptionServices.ExceptionDispatchInfo.Throw()
                             at System.Runtime.CompilerServices.TaskAwaiter.HandleNonSuccessAndDebuggerNotification(Task task)
                             at Microsoft.Web.Deployment.WebApi.DeploymentController.&amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;lt;DownloadAndDeployPackage&amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;gt;d__25.MoveNext() in C:\__w\1\s\src\hosting\wdeploy\Microsoft.Web.Deployment.WebApi\Controllers\DeploymentController.cs:line 491
                          ---&amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;gt; (Inner Exception #0) System.Net.WebException: The remote server returned an error: (403) Forbidden.
                             at System.Net.HttpWebRequest.EndGetResponse(IAsyncResult asyncResult)
                             at System.Net.WebClient.GetWebResponse(WebRequest request, IAsyncResult result)
                             at System.Net.WebClient.DownloadBitsResponseCallback(IAsyncResult result)&amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;lt;---
                          '
                          Failed to download package.
                          ARM-MSDeploy Deploy Failed: 'System.AggregateException: One or more errors occurred. ---&amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;gt; System.Net.WebException: The remote server returned an error: (403) Forbidden.
                             at System.Net.HttpWebRequest.EndGetResponse(IAsyncResult asyncResult)
                             at System.Net.WebClient.GetWebResponse(WebRequest request, IAsyncResult result)
                             at System.Net.WebClient.DownloadBitsResponseCallback(IAsyncResult result)
                             --- End of inner exception stack trace ---
                             at System.Threading.Tasks.Task.ThrowIfExceptional(Boolean includeTaskCanceledExceptions)
                             at System.Threading.Tasks.Task.Wait(Int32 millisecondsTimeout, CancellationToken cancellationToken)
                             at System.Threading.Tasks.Task.Wait(TimeSpan timeout)
                             at Microsoft.Web.Deployment.WebApi.AppGalleryPackage.&amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;lt;Download&amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;gt;d__17.MoveNext() in C:\__w\1\s\src\hosting\wdeploy\Microsoft.Web.Deployment.WebApi\AppGalleryPackage.cs:line 196
                          --- End of stack trace from previous location where exception was thrown ---
                             at System.Runtime.ExceptionServices.ExceptionDispatchInfo.Throw()
                             at System.Runtime.CompilerServices.TaskAwaiter.HandleNonSuccessAndDebuggerNotification(Task task)
                             at Microsoft.Web.Deployment.WebApi.AppGalleryPackage.&amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;lt;Download&amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;gt;d__15.MoveNext() in C:\__w\1\s\src\hosting\wdeploy\Microsoft.Web.Deployment.WebApi\AppGalleryPackage.cs:line 93
                          --- End of stack trace from previous location where exception was thrown ---
                             at System.Runtime.ExceptionServices.ExceptionDispatchInfo.Throw()
                             at System.Runtime.CompilerServices.TaskAwaiter.HandleNonSuccessAndDebuggerNotification(Task task)
                             at Microsoft.Web.Deployment.WebApi.DeploymentController.&amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;lt;DownloadPackageAndSettings&amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;gt;d__27.MoveNext() in C:\__w\1\s\src\hosting\wdeploy\Microsoft.Web.Deployment.WebApi\Controllers\DeploymentController.cs:line 623
                          --- End of stack trace from previous location where exception was thrown ---
                             at System.Runtime.ExceptionServices.ExceptionDispatchInfo.Throw()
                             at System.Runtime.CompilerServices.TaskAwaiter.HandleNonSuccessAndDebuggerNotification(Task task)
                             at Microsoft.Web.Deployment.WebApi.DeploymentController.&amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;lt;DownloadAndDeployPackage&amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;gt;d__25.MoveNext() in C:\__w\1\s\src\hosting\wdeploy\Microsoft.Web.Deployment.WebApi\Controllers\DeploymentController.cs:line 491
                          ---&amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;gt; (Inner Exception #0) System.Net.WebException: The remote server returned an error: (403) Forbidden.
                             at System.Net.HttpWebRequest.EndGetResponse(IAsyncResult asyncResult)
                             at System.Net.WebClient.GetWebResponse(WebRequest request, IAsyncResult result)
                             at System.Net.WebClient.DownloadBitsResponseCallback(IAsyncResult result)&amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;lt;---
                          '
                          ARM-MSDeploy Deploy Failed: 'System.UriFormatException: Invalid URI: The URI scheme is not valid.
                             at System.Uri.CreateThis(String uri, Boolean dontEscape, UriKind uriKind)
                             at Microsoft.Web.Deployment.WebApi.DeploymentController.&amp;amp;amp;amp;amp;amp;amp;amp;amp;lt;DownloadPackageAndSettings&amp;amp;amp;amp;amp;amp;amp;amp;amp;gt;d__27.MoveNext() in C:\__w\1\s\src\hosting\wdeploy\Microsoft.Web.Deployment.WebApi\Controllers\DeploymentController.cs:line 618
                          --- End of stack trace from previous location where exception was thrown ---
                             at System.Runtime.ExceptionServices.ExceptionDispatchInfo.Throw()
                             at System.Runtime.CompilerServices.TaskAwaiter.HandleNonSuccessAndDebuggerNotification(Task task)
                             at Microsoft.Web.Deployment.WebApi.DeploymentController.&amp;amp;amp;amp;amp;amp;amp;amp;amp;lt;DownloadAndDeployPackage&amp;amp;amp;amp;amp;amp;amp;amp;amp;gt;d__25.MoveNext() in C:\__w\1\s\src\hosting\wdeploy\Microsoft.Web.Deployment.WebApi\Controllers\DeploymentController.cs:line 491'
                          ARM-MSDeploy Deploy Failed: 'System.UriFormatException: Invalid URI: The URI scheme is not valid.
                             at System.Uri.CreateThis(String uri, Boolean dontEscape, UriKind uriKind)
                             at Microsoft.Web.Deployment.WebApi.DeploymentController.&amp;amp;amp;amp;amp;amp;amp;amp;lt;DownloadPackageAndSettings&amp;amp;amp;amp;amp;amp;amp;amp;gt;d__27.MoveNext() in C:\__w\1\s\src\hosting\wdeploy\Microsoft.Web.Deployment.WebApi\Controllers\DeploymentController.cs:line 618
                          --- End of stack trace from previous location where exception was thrown ---
                             at System.Runtime.ExceptionServices.ExceptionDispatchInfo.Throw()
                             at System.Runtime.CompilerServices.TaskAwaiter.HandleNonSuccessAndDebuggerNotification(Task task)
                             at Microsoft.Web.Deployment.WebApi.DeploymentController.&amp;amp;amp;amp;amp;amp;amp;amp;lt;DownloadAndDeployPackage&amp;amp;amp;amp;amp;amp;amp;amp;gt;d__25.MoveNext() in C:\__w\1\s\src\hosting\wdeploy\Microsoft.Web.Deployment.WebApi\Controllers\DeploymentController.cs:line 491'
                          ARM-MSDeploy Deploy Failed: 'System.UriFormatException: Invalid URI: The URI scheme is not valid.
                             at System.Uri.CreateThis(String uri, Boolean dontEscape, UriKind uriKind)
                             at Microsoft.Web.Deployment.WebApi.DeploymentController.&amp;amp;amp;amp;amp;amp;amp;lt;DownloadPackageAndSettings&amp;amp;amp;amp;amp;amp;amp;gt;d__27.MoveNext() in C:\__w\1\s\src\hosting\wdeploy\Microsoft.Web.Deployment.WebApi\Controllers\DeploymentController.cs:line 618
                          --- End of stack trace from previous location where exception was thrown ---
                             at System.Runtime.ExceptionServices.ExceptionDispatchInfo.Throw()
                             at System.Runtime.CompilerServices.TaskAwaiter.HandleNonSuccessAndDebuggerNotification(Task task)
                             at Microsoft.Web.Deployment.WebApi.DeploymentController.&amp;amp;amp;amp;amp;amp;amp;lt;DownloadAndDeployPackage&amp;amp;amp;amp;amp;amp;amp;gt;d__25.MoveNext() in C:\__w\1\s\src\hosting\wdeploy\Microsoft.Web.Deployment.WebApi\Controllers\DeploymentController.cs:line 491'
                          ARM-MSDeploy Deploy Failed: 'System.UriFormatException: Invalid URI: The URI scheme is not valid.
                             at System.Uri.CreateThis(String uri, Boolean dontEscape, UriKind uriKind)
                             at Microsoft.Web.Deployment.WebApi.DeploymentController.&amp;amp;amp;amp;amp;amp;lt;DownloadPackageAndSettings&amp;amp;amp;amp;amp;amp;gt;d__27.MoveNext() in C:\__w\1\s\src\hosting\wdeploy\Microsoft.Web.Deployment.WebApi\Controllers\DeploymentController.cs:line 618
                          --- End of stack trace from previous location where exception was thrown ---
                             at System.Runtime.ExceptionServices.ExceptionDispatchInfo.Throw()
                             at System.Runtime.CompilerServices.TaskAwaiter.HandleNonSuccessAndDebuggerNotification(Task task)
                             at Microsoft.Web.Deployment.WebApi.DeploymentController.&amp;amp;amp;amp;amp;amp;lt;DownloadAndDeployPackage&amp;amp;amp;amp;amp;amp;gt;d__25.MoveNext() in C:\__w\1\s\src\hosting\wdeploy\Microsoft.Web.Deployment.WebApi\Controllers\DeploymentController.cs:line 491'
                          ARM-MSDeploy Deploy Failed: 'System.UriFormatException: Invalid URI: The URI scheme is not valid.
                             at System.Uri.CreateThis(String uri, Boolean dontEscape, UriKind uriKind)
                             at Microsoft.Web.Deployment.WebApi.DeploymentController.&amp;amp;amp;amp;amp;lt;DownloadPackageAndSettings&amp;amp;amp;amp;amp;gt;d__27.MoveNext() in C:\__w\1\s\src\hosting\wdeploy\Microsoft.Web.Deployment.WebApi\Controllers\DeploymentController.cs:line 618
                          --- End of stack trace from previous location where exception was thrown ---
                             at System.Runtime.ExceptionServices.ExceptionDispatchInfo.Throw()
                             at System.Runtime.CompilerServices.TaskAwaiter.HandleNonSuccessAndDebuggerNotification(Task task)
                             at Microsoft.Web.Deployment.WebApi.DeploymentController.&amp;amp;amp;amp;amp;lt;DownloadAndDeployPackage&amp;amp;amp;amp;amp;gt;d__25.MoveNext() in C:\__w\1\s\src\hosting\wdeploy\Microsoft.Web.Deployment.WebApi\Controllers\DeploymentController.cs:line 491'
                          ARM-MSDeploy Deploy Failed: 'System.UriFormatException: Invalid URI: The URI scheme is not valid.
                             at System.Uri.CreateThis(String uri, Boolean dontEscape, UriKind uriKind)
                             at Microsoft.Web.Deployment.WebApi.DeploymentController.&amp;amp;amp;amp;lt;DownloadPackageAndSettings&amp;amp;amp;amp;gt;d__27.MoveNext() in C:\__w\1\s\src\hosting\wdeploy\Microsoft.Web.Deployment.WebApi\Controllers\DeploymentController.cs:line 618
                          --- End of stack trace from previous location where exception was thrown ---
                             at System.Runtime.ExceptionServices.ExceptionDispatchInfo.Throw()
                             at System.Runtime.CompilerServices.TaskAwaiter.HandleNonSuccessAndDebuggerNotification(Task task)
                             at Microsoft.Web.Deployment.WebApi.DeploymentController.&amp;amp;amp;amp;lt;DownloadAndDeployPackage&amp;amp;amp;amp;gt;d__25.MoveNext() in C:\__w\1\s\src\hosting\wdeploy\Microsoft.Web.Deployment.WebApi\Controllers\DeploymentController.cs:line 491'
                          ARM-MSDeploy Deploy Failed: 'System.UriFormatException: Invalid URI: The URI scheme is not valid.
                             at System.Uri.CreateThis(String uri, Boolean dontEscape, UriKind uriKind)
                             at Microsoft.Web.Deployment.WebApi.DeploymentController.&amp;amp;amp;lt;DownloadPackageAndSettings&amp;amp;amp;gt;d__27.MoveNext() in C:\__w\1\s\src\hosting\wdeploy\Microsoft.Web.Deployment.WebApi\Controllers\DeploymentController.cs:line 618
                          --- End of stack trace from previous location where exception was thrown ---
                             at System.Runtime.ExceptionServices.ExceptionDispatchInfo.Throw()
                             at System.Runtime.CompilerServices.TaskAwaiter.HandleNonSuccessAndDebuggerNotification(Task task)
                             at Microsoft.Web.Deployment.WebApi.DeploymentController.&amp;amp;amp;lt;DownloadAndDeployPackage&amp;amp;amp;gt;d__25.MoveNext() in C:\__w\1\s\src\hosting\wdeploy\Microsoft.Web.Deployment.WebApi\Controllers\DeploymentController.cs:line 491'
                          Failed to download package.
                          ARM-MSDeploy Deploy Failed: 'System.AggregateException: One or more errors occurred. ---&amp;amp;gt; System.Net.WebException: The remote server returned an error: (403) Forbidden.
                             at System.Net.HttpWebRequest.EndGetResponse(IAsyncResult asyncResult)
                             at System.Net.WebClient.GetWebResponse(WebRequest request, IAsyncResult result)
                             at System.Net.WebClient.DownloadBitsResponseCallback(IAsyncResult result)
                             --- End of inner exception stack trace ---
                             at System.Threading.Tasks.Task.ThrowIfExceptional(Boolean includeTaskCanceledExceptions)
                             at System.Threading.Tasks.Task.Wait(Int32 millisecondsTimeout, CancellationToken cancellationToken)
                             at System.Threading.Tasks.Task.Wait(TimeSpan timeout)
                             at Microsoft.Web.Deployment.WebApi.AppGalleryPackage.&amp;amp;lt;Download&amp;amp;gt;d__17.MoveNext() in C:\__w\1\s\src\hosting\wdeploy\Microsoft.Web.Deployment.WebApi\AppGalleryPackage.cs:line 196
                          --- End of stack trace from previous location where exception was thrown ---
                             at System.Runtime.ExceptionServices.ExceptionDispatchInfo.Throw()
                             at System.Runtime.CompilerServices.TaskAwaiter.HandleNonSuccessAndDebuggerNotification(Task task)
                             at Microsoft.Web.Deployment.WebApi.AppGalleryPackage.&amp;amp;lt;Download&amp;amp;gt;d__15.MoveNext() in C:\__w\1\s\src\hosting\wdeploy\Microsoft.Web.Deployment.WebApi\AppGalleryPackage.cs:line 93
                          --- End of stack trace from previous location where exception was thrown ---
                             at System.Runtime.ExceptionServices.ExceptionDispatchInfo.Throw()
                             at System.Runtime.CompilerServices.TaskAwaiter.HandleNonSuccessAndDebuggerNotification(Task task)
                             at Microsoft.Web.Deployment.WebApi.DeploymentController.&amp;amp;lt;DownloadPackageAndSettings&amp;amp;gt;d__27.MoveNext() in C:\__w\1\s\src\hosting\wdeploy\Microsoft.Web.Deployment.WebApi\Controllers\DeploymentController.cs:line 623
                          --- End of stack trace from previous location where exception was thrown ---
                             at System.Runtime.ExceptionServices.ExceptionDispatchInfo.Throw()
                             at System.Runtime.CompilerServices.TaskAwaiter.HandleNonSuccessAndDebuggerNotification(Task task)
                             at Microsoft.Web.Deployment.WebApi.DeploymentController.&amp;amp;lt;DownloadAndDeployPackage&amp;amp;gt;d__25.MoveNext() in C:\__w\1\s\src\hosting\wdeploy\Microsoft.Web.Deployment.WebApi\Controllers\DeploymentController.cs:line 491
                          ---&amp;amp;gt; (Inner Exception #0) System.Net.WebException: The remote server returned an error: (403) Forbidden.
                             at System.Net.HttpWebRequest.EndGetResponse(IAsyncResult asyncResult)
                             at System.Net.WebClient.GetWebResponse(WebRequest request, IAsyncResult result)
                             at System.Net.WebClient.DownloadBitsResponseCallback(IAsyncResult result)&amp;amp;lt;---
                          '
                          ARM-MSDeploy Deploy Failed: 'System.UriFormatException: Invalid URI: The URI scheme is not valid.
                             at System.Uri.CreateThis(String uri, Boolean dontEscape, UriKind uriKind)
                             at Microsoft.Web.Deployment.WebApi.DeploymentController.&amp;lt;DownloadPackageAndSettings&amp;gt;d__27.MoveNext() in C:\__w\1\s\src\hosting\wdeploy\Microsoft.Web.Deployment.WebApi\Controllers\DeploymentController.cs:line 618
                          --- End of stack trace from previous location where exception was thrown ---
                             at System.Runtime.ExceptionServices.ExceptionDispatchInfo.Throw()
                             at System.Runtime.CompilerServices.TaskAwaiter.HandleNonSuccessAndDebuggerNotification(Task task)
                             at Microsoft.Web.Deployment.WebApi.DeploymentController.&amp;lt;DownloadAndDeployPackage&amp;gt;d__25.MoveNext() in C:\__w\1\s\src\hosting\wdeploy\Microsoft.Web.Deployment.WebApi\Controllers\DeploymentController.cs:line 491'
                          Failed to download package.
                          ARM-MSDeploy Deploy Failed: 'System.AggregateException: One or more errors occurred. ---> System.Net.WebException: The remote server returned an error: (403) Forbidden.
                             at System.Net.HttpWebRequest.EndGetResponse(IAsyncResult asyncResult)
                             at System.Net.WebClient.GetWebResponse(WebRequest request, IAsyncResult result)
                             at System.Net.WebClient.DownloadBitsResponseCallback(IAsyncResult result)
                             --- End of inner exception stack trace ---
                             at System.Threading.Tasks.Task.ThrowIfExceptional(Boolean includeTaskCanceledExceptions)
                             at System.Threading.Tasks.Task.Wait(Int32 millisecondsTimeout, CancellationToken cancellationToken)
                             at System.Threading.Tasks.Task.Wait(TimeSpan timeout)
                             at Microsoft.Web.Deployment.WebApi.AppGalleryPackage.<Download>d__17.MoveNext() in C:\__w\1\s\src\hosting\wdeploy\Microsoft.Web.Deployment.WebApi\AppGalleryPackage.cs:line 196
                          --- End of stack trace from previous location where exception was thrown ---
                             at System.Runtime.ExceptionServices.ExceptionDispatchInfo.Throw()
                             at System.Runtime.CompilerServices.TaskAwaiter.HandleNonSuccessAndDebuggerNotification(Task task)
                             at Microsoft.Web.Deployment.WebApi.AppGalleryPackage.<Download>d__15.MoveNext() in C:\__w\1\s\src\hosting\wdeploy\Microsoft.Web.Deployment.WebApi\AppGalleryPackage.cs:line 93
                          --- End of stack trace from previous location where exception was thrown ---
                             at System.Runtime.ExceptionServices.ExceptionDispatchInfo.Throw()
                             at System.Runtime.CompilerServices.TaskAwaiter.HandleNonSuccessAndDebuggerNotification(Task task)
                             at Microsoft.Web.Deployment.WebApi.DeploymentController.<DownloadPackageAndSettings>d__27.MoveNext() in C:\__w\1\s\src\hosting\wdeploy\Microsoft.Web.Deployment.WebApi\Controllers\DeploymentController.cs:line 623
                          --- End of stack trace from previous location where exception was thrown ---
                             at System.Runtime.ExceptionServices.ExceptionDispatchInfo.Throw()
                             at System.Runtime.CompilerServices.TaskAwaiter.HandleNonSuccessAndDebuggerNotification(Task task)
                             at Microsoft.Web.Deployment.WebApi.DeploymentController.<DownloadAndDeployPackage>d__25.MoveNext() in C:\__w\1\s\src\hosting\wdeploy\Microsoft.Web.Deployment.WebApi\Controllers\DeploymentController.cs:line 491
                          ---> (Inner Exception #0) System.Net.WebException: The remote server returned an error: (403) Forbidden.
                             at System.Net.HttpWebRequest.EndGetResponse(IAsyncResult asyncResult)
                             at System.Net.WebClient.GetWebResponse(WebRequest request, IAsyncResult result)
                             at System.Net.WebClient.DownloadBitsResponseCallback(IAsyncResult result)<---
                          '"
             }
           ]
         }
       ]
     }
   }

   emacs ESC 14 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "delete storage account"
   write-output "az storage account delete -n '$($env:uniquePrefix)stgacc' -g $env:rg --yes"
   az storage account delete -n "$($env:uniquePrefix)stgacc" -g $env:rg --yes
   End commands to deploy this file using Azure CLI with PowerShell

   Begin common epilog commands
   az resource list -g $env:rg --query "[?resourceGroup=='$env:rg'].{ name: name, flavor: kind, resourceType: type, region: location }" --output table  | ForEach-Object { $_ -replace "`r", ""}
   write-output "all done $(Get-Date)"
   End common epilog commands

 */


//    See https://github.com/Azure-Samples/function-app-arm-templates/blob/main/zip-deploy-arm-az-cli/README.md#steps
// see zip-deploy-arm-az-cli/README.md


@description('The name of the Azure Function app.')
param functionAppName string = 'zipdeployhttpfunc20240529150920'

@description('The zip content url.')
param blobSASUri string = 'https://zsevfstgacc.blob.core.windows.net/mycontainer/package_zip?se=2024-05-30T16%3A31%3A51Z&sp=r&sv=2022-11-02&sr=b&sig=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'

output outblobSASUri string = blobSASUri
output outfunctionAppName string = functionAppName

resource functionAppName_ZipDeploy 'Microsoft.Web/sites/extensions@2021-02-01' = {
  name: '${functionAppName}/MSDeploy'
  properties: {
    packageUri: blobSASUri
  }
}
