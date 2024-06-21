using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;

namespace zipdeployhttpfunc;

public class zipdeployhttpfunc
{
    private readonly ILogger<zipdeployhttpfunc> _logger;

    public zipdeployhttpfunc(ILogger<zipdeployhttpfunc> logger)
    {
        _logger = logger;
    }

    [Function("zipdeployhttpfunc")]
    public async Task<IActionResult> RunAsync([HttpTrigger(AuthorizationLevel.Function, "get", "post")] HttpRequest req)
    {
        string name = req.Query["name"];

        string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
        dynamic data = JsonConvert.DeserializeObject(requestBody);
        name = name ?? data?.name;

        string responseMessage = "Built at Mon Jun  3 14:15:45 2024 V0001 "+(string.IsNullOrEmpty(name)
            ? "This HTTP triggered function executed successfully. Pass a name in the query string or in the request body for a personalized response."
            : $"Hello, {name}. This HTTP triggered function executed successfully.")
              + DateTime.Now.ToString("yyyy MMM dd hh:mm:ss.fff ttt (zzz)" + "");

        _logger.LogInformation("C# HTTP trigger function processed a request. {responseMessage}", responseMessage);

        return new OkObjectResult(responseMessage);
    }
}
