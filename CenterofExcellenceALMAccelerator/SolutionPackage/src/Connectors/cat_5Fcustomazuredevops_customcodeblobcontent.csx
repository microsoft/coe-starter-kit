public class Script : ScriptBase
{
    public override async Task<HttpResponseMessage> ExecuteAsync()
    {
        HttpResponseMessage response = new HttpResponseMessage(HttpStatusCode.OK);
        response.Content = CreateJsonContent("{\"message\": \"Hello World 2\"}");
        return response;
    }
}
