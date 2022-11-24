public class Script : ScriptBase
{
    public override async Task<HttpResponseMessage> ExecuteAsync()
    {
        if (this.Context.OperationId == "HasPermissions")
        {
            return await this.HandleTransformOperation().ConfigureAwait(false);
        }
        else
        {
            return await this.Context.SendAsync(this.Context.Request, this.CancellationToken).ConfigureAwait(continueOnCapturedContext: false);
        }
    }

    private async Task<HttpResponseMessage> HandleTransformOperation()
    {
    // Use the context to forward/send an HTTP request
    HttpResponseMessage response = await this.Context.SendAsync(this.Context.Request, this.CancellationToken).ConfigureAwait(continueOnCapturedContext: false);

    // Do the transformation if the response was successful, otherwise return error responses as-is
    if (response.IsSuccessStatusCode)
    {
        var responseString = await response.Content.ReadAsStringAsync().ConfigureAwait(continueOnCapturedContext: false);
        
        // Example case: response string is some JSON object
        var result = responseString;
        
        // Wrap the original JSON object into a new JSON object with just one key ('wrapped')
        var newResult = new JObject
        {
            ["result"] = result,
        };
        
        response.Content = CreateJsonContent(newResult.ToString());
    }

    return response;
}
}
