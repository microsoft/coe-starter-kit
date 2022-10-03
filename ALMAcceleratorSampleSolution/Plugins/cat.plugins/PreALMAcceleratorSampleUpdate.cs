//-----------------------------------------------------------------------
// <copyright file="PreALMAcceleratorSampleUpdate.cs" company="Microsoft">
// Copyright (c) 2022 All Rights Reserved
// </copyright>
// <summary>
// Plugin example for ALM Accelerator Solution.
// On pre update event of 'AlmAcceleratorSample' table
// Check whether 'Details' column modified
// Read the value from 'Details' column (Limit the length to 50 characters) and set to 'Name' column
// </summary>
//-----------------------------------------------------------------------
namespace Plugins
{
    using System;
    using System.ServiceModel;
    using Cat.Plugins.Helper;
    using Microsoft.Xrm.Sdk;

    /// <summary>
    /// Alm Accelerator Sample Class triggers on Pre Update 
    /// </summary>
    public class PreALMAcceleratorSampleUpdate : PluginBase
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="PreALMAcceleratorSampleUpdate" /> class
        /// </summary>
        /// <param name="unsecureConfiguration">Unsecure Configuration</param>
        /// <param name="secureConfiguration">Secure Configuration</param>
        public PreALMAcceleratorSampleUpdate(string unsecureConfiguration, string secureConfiguration)
            : base(typeof(PreALMAcceleratorSampleUpdate))
        {
            // TODO: Implement your custom configuration handling
            // https://docs.microsoft.com/powerapps/developer/common-data-service/register-plug-in#set-configuration-data
        }

        /// <summary>
        /// Entry point for custom business logic execution
        /// </summary>
        /// <param name="localPluginContext">Local Plugin Context</param>
        protected override void ExecuteDataversePlugin(ILocalPluginContext localPluginContext)
        {
            if (localPluginContext == null)
            {
                throw new ArgumentNullException(nameof(localPluginContext));
            }

            var context = localPluginContext.PluginExecutionContext;
            Entity preImageAlmAcceleratorSampleCreate = null;
            try
            {
                // The InputParameters collection contains all the data passed in the message request.  
                if (context != null && context.InputParameters.Contains("Target") && context.InputParameters["Target"] is Entity entity)
                {
                    // Obtain the target entity from the input parameters.  
                    Entity targetAlmAcceleratorSampleCreate = entity;

                    // Obtain the preimage entity from the PreEntityImages parameters.  
                    if (context.PreEntityImages.Contains("preImage") && context.PreEntityImages["preImage"] is Entity preImageEntity)
                    {
                        preImageAlmAcceleratorSampleCreate = preImageEntity;
                    }

                    string strName = "Quote";
                    string strDetails = string.Empty;

                    // If 'Details' column modified, read from 'Target'; else read from PreImage
                    if (targetAlmAcceleratorSampleCreate.Contains("cat_details"))
                    {
                        strDetails = targetAlmAcceleratorSampleCreate["cat_details"] != null ? targetAlmAcceleratorSampleCreate["cat_details"].ToString() : string.Empty;
                    }
                    else if (preImageAlmAcceleratorSampleCreate != null && preImageAlmAcceleratorSampleCreate.Contains("cat_details"))
                    {
                        strDetails = preImageAlmAcceleratorSampleCreate["cat_details"] != null ? preImageAlmAcceleratorSampleCreate["cat_details"].ToString() : string.Empty;
                    }

                    strDetails = ALMAcceleratorSampleHelper.TrimandExtractDetails(targetAlmAcceleratorSampleCreate["cat_details"].ToString());


                    // Set 'Name' as { Quote - 'Details' column data }
                    targetAlmAcceleratorSampleCreate["cat_name"] = string.IsNullOrEmpty(strDetails) ? strName : strName + " - " + strDetails;
                }
            }
            catch (FaultException<OrganizationServiceFault> ex)
            {
                throw new InvalidPluginExecutionException("An error occurred in PreALMAcceleratorSampleUpdate.", ex);
            }
            catch (Exception ex)
            {
                localPluginContext.Trace("PreALMAcceleratorSampleUpdate: {0}", ex.ToString());
                throw;
            }
        }
    }
}