/// <summary>
/// Pre create plugin. Populates the name field of 'CAT Fact Favorite' table
/// </summary>
/// <remarks> 
/// </remarks>
namespace PCAT.Plugins
{
    using System;
    using System.ServiceModel;
    using System.Xml.Linq;
    using Microsoft.Xrm.Sdk;
    
    /// <summary>
    /// Populates the name field of 'CAT Fact Favorite' table
    /// </summary>
    public class PreCreateCATFactFavorite : IPlugin
    {
        /// <summary>
        /// IPlugin Execute method
        /// </summary>
        /// <param name="serviceProvider">Service Provider</param>
        /// <exception cref="InvalidPluginExecutionException"></exception>
        public void Execute(IServiceProvider serviceProvider)
        {
            // Obtain the tracing service
            ITracingService tracingService =
            (ITracingService)serviceProvider.GetService(typeof(ITracingService));

            // Obtain the execution context from the service provider.  
            IPluginExecutionContext context = (IPluginExecutionContext)
                serviceProvider.GetService(typeof(IPluginExecutionContext));

            // The InputParameters collection contains all the data passed in the message request.  
            if (context.InputParameters.Contains("Target") &&
                context.InputParameters["Target"] is Entity)
            {
                // Obtain the target entity from the input parameters.  
                Entity entCATFactFavorite = (Entity)context.InputParameters["Target"];

                // Obtain the organization service reference which you will need for  
                // web service calls.  
                IOrganizationServiceFactory serviceFactory =
                    (IOrganizationServiceFactory)serviceProvider.GetService(typeof(IOrganizationServiceFactory));
                IOrganizationService service = serviceFactory.CreateOrganizationService(context.UserId);

                try
                {
                    var name = entCATFactFavorite["cat_name"].ToString();
                    // Check if the length is greater than 50
                    if (name.Length > 50)
                    {
                        // Truncate the 'name' field to a maximum length of 50 characters
                        name = name.Substring(0, 50);

                        // Update the 'name' field with the truncated value
                        entCATFactFavorite["cat_name"] = name;
                    }
                }
                catch (FaultException<OrganizationServiceFault> ex)
                {
                    throw new InvalidPluginExecutionException("An error occurred in PreCreateCATFactFavorite.", ex);
                }

                catch (Exception ex)
                {
                    tracingService.Trace("PreCreateCATFactFavorite: {0}", ex.ToString());
                    throw;
                }
            }
        }
    }
}
