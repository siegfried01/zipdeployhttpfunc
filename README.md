# zipdeployhttpfunc
## Background
We want to protect our azure functions using private end points. We 
1. deploy the compiled C# code to our azure function and confirm it works use cURL
2. deploy the azure private end points and confirm they are work.
3. update the C# code from v1 to v2 and recompile and try re-deploy the upated code to the azure function and this does not work because the azure private end points are doing their job
## Introduction
We believe the solution is to use zipdeploy. The purpose of this repository is to
1. demonstrate using ZipDeploy with no private end points
2. demonstrate using ZipDeploy with private end points and a Azure API Management System (APIM)
## Approach
1. Execute the perl program (using cygwin perl) embedded in [deploy-UpdateFunctionZipDeploy.bicep](infrastructure/deploy-UpdateFunctionZipDeploy.bicep) to execute the fragments of powershell script to demonstrate the ZipDeploy feature. Execute one step at a time and observe the results. Start with step 1, skip step 2, execute step 3 only once, and execute all the sequent steps. These fragments of powershell script embeeded in the comments are place holders for bicep code (except for steps 1-3).
2. Fix the errors to make it work. See the comments for the errors I'm getting.
3. Add fragments of powershell script to protect the azure function with private end points.
4. Deploy an (APIM) to store the keys for the azure function and call the azure function using cURL via the APIM. Configure the APIM appropriately with regard to the Azure Private End Points.
5. Demonstrate that we can deploy subsequent versions of [zipdeployhttpfunc.cs](zipdeployhttpfunc.cs). Subsequent versions will have an updated verssion number and time stamp in the response message.
6. Demonstrate this works with cURL.
7. Replace steps 4-25 with bicep code.
## References
* https://learn.microsoft.com/en-us/azure/azure-functions/deployment-zip-push#example-zipdeploy-arm-template
* 