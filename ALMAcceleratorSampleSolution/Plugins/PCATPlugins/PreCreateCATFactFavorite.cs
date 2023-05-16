using Microsoft.Xrm.Sdk;
using System;

namespace PCATPlugins
{
    /// <summary>
    /// Plugin development guide: https://docs.microsoft.com/powerapps/developer/common-data-service/plug-ins
    /// Best practices and guidance: https://docs.microsoft.com/powerapps/developer/common-data-service/best-practices/business-logic/
    /// </summary>
    public class PreCreateCATFactFavorite : PluginBase
    {
        public PreCreateCATFactFavorite(string unsecureConfiguration, string secureConfiguration)
            : base(typeof(PreCreateCATFactFavorite))
        {
            // TODO: Implement your custom configuration handling
            // https://docs.microsoft.com/powerapps/developer/common-data-service/register-plug-in#set-configuration-data
        }

        // Entry point for custom business logic execution
        protected override void ExecuteDataversePlugin(ILocalPluginContext localPluginContext)
        {
            if (localPluginContext == null)
            {
                throw new ArgumentNullException(nameof(localPluginContext));
            }

            var context = localPluginContext.PluginExecutionContext;

            // Check for the entity on which the plugin would be registered
            if (context.InputParameters.Contains("Target") && context.InputParameters["Target"] is Entity)
            {
                var entCATFactFavorite = (Entity)context.InputParameters["Target"];

                // Check for entCATFactFavorite name on which this plugin would be registered
                if (entCATFactFavorite.LogicalName == "cat_almacceleratorsample")
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
            }
        }
    }
}
