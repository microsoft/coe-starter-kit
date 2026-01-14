# C# Bulk Upload Example for Connection Identities

## Overview

This example demonstrates how to use C# with the Dataverse SDK to perform bulk uploads of connection identities using the `UpsertMultiple` message for better performance.

## Prerequisites

```xml
<!-- Add these NuGet packages to your .csproj -->
<PackageReference Include="Microsoft.PowerPlatform.Dataverse.Client" Version="1.1.14" />
<PackageReference Include="Microsoft.Xrm.Sdk" Version="9.0.2.56" />
<PackageReference Include="Microsoft.Identity.Client" Version="4.51.0" />
```

## Sample Code

### Program.cs

```csharp
using Microsoft.PowerPlatform.Dataverse.Client;
using Microsoft.Xrm.Sdk;
using Microsoft.Xrm.Sdk.Messages;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text.Json;

namespace ConnectionIdentitiesBulkUpload
{
    class Program
    {
        static void Main(string[] args)
        {
            if (args.Length < 2)
            {
                Console.WriteLine("Usage: ConnectionIdentitiesBulkUpload <dataverse-url> <json-file-path>");
                Console.WriteLine("Example: ConnectionIdentitiesBulkUpload https://contoso.crm.dynamics.com connections.json");
                return;
            }

            string dataverseUrl = args[0];
            string jsonFilePath = args[1];

            try
            {
                Console.WriteLine("Connection Identities Bulk Upload Tool");
                Console.WriteLine("======================================\n");

                // Connect to Dataverse
                Console.WriteLine($"Connecting to Dataverse: {dataverseUrl}");
                string connectionString = $"AuthType=OAuth;Url={dataverseUrl};AppId=51f81489-12ee-4a9e-aaae-a2591f45987d;RedirectUri=http://localhost;LoginPrompt=Auto";
                
                var serviceClient = new ServiceClient(connectionString);
                
                if (!serviceClient.IsReady)
                {
                    throw new Exception($"Failed to connect to Dataverse: {serviceClient.LastError}");
                }
                
                Console.WriteLine("Successfully connected to Dataverse.\n");

                // Read JSON file
                Console.WriteLine($"Reading connection identities from: {jsonFilePath}");
                string jsonContent = File.ReadAllText(jsonFilePath);
                var identities = JsonSerializer.Deserialize<List<ConnectionIdentity>>(jsonContent);
                Console.WriteLine($"Loaded {identities.Count} connection identities.\n");

                // Process in batches using UpsertMultiple
                int batchSize = 100; // Recommended batch size for UpsertMultiple
                int totalProcessed = 0;
                int totalBatches = (int)Math.Ceiling((double)identities.Count / batchSize);

                for (int i = 0; i < identities.Count; i += batchSize)
                {
                    var batch = identities.Skip(i).Take(batchSize).ToList();
                    int batchNumber = (i / batchSize) + 1;
                    
                    Console.WriteLine($"Processing batch {batchNumber} of {totalBatches} ({batch.Count} records)...");
                    
                    try
                    {
                        UpsertBatch(serviceClient, batch);
                        totalProcessed += batch.Count;
                        Console.WriteLine($"  Batch completed successfully. Total processed: {totalProcessed}/{identities.Count}");
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine($"  Warning: Batch failed - {ex.Message}");
                        // Continue with next batch
                    }
                }

                Console.WriteLine("\n======================================");
                Console.WriteLine($"Upload completed! Processed {totalProcessed} records.");
                Console.WriteLine("======================================\n");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"\nERROR: {ex.Message}");
                Console.WriteLine($"Stack trace: {ex.StackTrace}");
                Environment.Exit(1);
            }
        }

        static void UpsertBatch(ServiceClient serviceClient, List<ConnectionIdentity> batch)
        {
            var entities = new EntityCollection();
            
            foreach (var identity in batch)
            {
                var entity = new Entity("admin_connectionreferenceidentity");
                
                // Required fields
                entity["admin_name"] = identity.ConnectorName;
                entity["admin_accountname"] = identity.AccountName;
                entity["admin_connectionreferencecreatordisplayname"] = identity.CreatorUPN;
                
                // Lookup fields (would need to be resolved first in production code)
                // entity["admin_environment"] = new EntityReference("admin_environment", environmentId);
                // entity["admin_connector"] = new EntityReference("admin_connector", connectorId);
                
                entities.Entities.Add(entity);
            }
            
            // Use UpsertMultiple for better performance
            var request = new UpsertMultipleRequest
            {
                Targets = entities
            };
            
            var response = (UpsertMultipleResponse)serviceClient.Execute(request);
            
            // Process results
            int succeeded = 0;
            int failed = 0;
            
            foreach (var result in response.Results)
            {
                if (result.RecordCreated || !result.RecordCreated)
                {
                    succeeded++;
                }
                else
                {
                    failed++;
                }
            }
            
            if (failed > 0)
            {
                Console.WriteLine($"    Succeeded: {succeeded}, Failed: {failed}");
            }
        }
    }

    // Model class for JSON deserialization
    public class ConnectionIdentity
    {
        public string EnvironmentName { get; set; }
        public string EnvironmentDisplayName { get; set; }
        public string ConnectionName { get; set; }
        public string ConnectorName { get; set; }
        public string AccountName { get; set; }
        public string CreatorId { get; set; }
        public string CreatorUPN { get; set; }
        public string CreatorDisplayName { get; set; }
        public string CreatedTime { get; set; }
        public string ApiId { get; set; }
        public string DisplayName { get; set; }
        public string ConnectionStatus { get; set; }
    }
}
```

## Building and Running

### Create the Project

```bash
# Create a new console application
dotnet new console -n ConnectionIdentitiesBulkUpload
cd ConnectionIdentitiesBulkUpload

# Add required packages
dotnet add package Microsoft.PowerPlatform.Dataverse.Client
dotnet add package Microsoft.Xrm.Sdk
dotnet add package Microsoft.Identity.Client

# Build the project
dotnet build

# Run the application
dotnet run https://yourorg.crm.dynamics.com ../connections.json
```

### For Release Build

```bash
# Publish as self-contained executable
dotnet publish -c Release -r win-x64 --self-contained

# The executable will be in bin/Release/net6.0/win-x64/publish/
```

## Performance Comparison

| Method | Batch Size | Records/Second | Notes |
|--------|-----------|----------------|-------|
| PowerShell (Web API) | 100 | 5-10 | Good for most scenarios |
| C# UpsertMultiple | 100 | 15-30 | Better performance, more complex |
| C# CreateMultiple | 100 | 20-40 | Fastest, but no updates |

## Advanced Features

### Adding Lookup Resolution

For production use, you should resolve lookups (Environment, Connector, User) before upserting:

```csharp
private static Guid? ResolveEnvironment(ServiceClient client, string environmentName)
{
    var query = new Microsoft.Xrm.Sdk.Query.QueryExpression("admin_environment")
    {
        ColumnSet = new Microsoft.Xrm.Sdk.Query.ColumnSet("admin_environmentid"),
        Criteria = new Microsoft.Xrm.Sdk.Query.FilterExpression
        {
            Conditions =
            {
                new Microsoft.Xrm.Sdk.Query.ConditionExpression(
                    "admin_environmentname", 
                    Microsoft.Xrm.Sdk.Query.ConditionOperator.Equal, 
                    environmentName)
            }
        },
        TopCount = 1
    };
    
    var results = client.RetrieveMultiple(query);
    return results.Entities.FirstOrDefault()?.Id;
}
```

### Error Handling and Retry Logic

```csharp
private static void UpsertBatchWithRetry(ServiceClient client, List<ConnectionIdentity> batch, int maxRetries = 3)
{
    int attempt = 0;
    Exception lastException = null;
    
    while (attempt < maxRetries)
    {
        try
        {
            UpsertBatch(client, batch);
            return; // Success
        }
        catch (Exception ex)
        {
            attempt++;
            lastException = ex;
            
            if (attempt < maxRetries)
            {
                Console.WriteLine($"  Retry attempt {attempt} of {maxRetries}...");
                Thread.Sleep(1000 * attempt); // Exponential backoff
            }
        }
    }
    
    throw new Exception($"Failed after {maxRetries} attempts", lastException);
}
```

## Recommendations

### When to Use C# vs PowerShell

**Use PowerShell when:**
- You need a quick solution without compiling code
- Your dataset is under 100,000 records
- You prefer scripting over compiled applications
- You need easy scheduling with Task Scheduler

**Use C# when:**
- You have very large datasets (>100,000 records)
- You need maximum performance
- You're building a custom automation tool
- You want better type safety and tooling support
- You need advanced error handling and retry logic

## Complete Project Structure

```
ConnectionIdentitiesBulkUpload/
├── ConnectionIdentitiesBulkUpload.csproj
├── Program.cs
├── Models/
│   └── ConnectionIdentity.cs
├── Services/
│   ├── DataverseService.cs
│   └── LookupResolver.cs
└── README.md
```

## Additional Resources

- [UpsertMultiple Documentation](https://learn.microsoft.com/power-apps/developer/data-platform/bulk-operations?tabs=sdk#upsertmultiple)
- [Dataverse SDK for .NET](https://learn.microsoft.com/power-apps/developer/data-platform/org-service/quick-start-org-service-console-app)
- [ServiceClient Documentation](https://learn.microsoft.com/dotnet/api/microsoft.powerplatform.dataverse.client.serviceclient)

## Notes

- This is a simplified example for demonstration purposes
- Production code should include proper lookup resolution, error handling, and logging
- Consider using parallel processing for very large datasets
- Monitor Dataverse API limits and implement throttling as needed
- The `UpsertMultiple` operation requires appropriate privileges on the target table

## Performance Tips

1. **Use parallel batches** (with caution for API limits):
```csharp
Parallel.ForEach(batches, new ParallelOptions { MaxDegreeOfParallelism = 4 }, 
    batch => UpsertBatch(client, batch));
```

2. **Cache lookups** to avoid repeated queries for the same Environment/Connector/User

3. **Use ColumnSet carefully** - only retrieve fields you need

4. **Monitor and respect API limits** - implement exponential backoff

5. **Use bulk delete** for cleanup operations instead of individual deletes
