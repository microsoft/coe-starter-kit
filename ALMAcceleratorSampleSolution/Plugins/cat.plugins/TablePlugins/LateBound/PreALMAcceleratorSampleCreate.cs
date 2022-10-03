//-----------------------------------------------------------------------
// <copyright file="PreALMAcceleratorSampleCreate.cs" company="Microsoft">
// Copyright (c) 2022 All Rights Reserved
// </copyright>
// <summary>
// Plugin example for ALM Accelerator Solution.
// On pre creation event of 'AlmAcceleratorSample' table
// Read the value from 'Details' column (Limit the length to 50 characters) and set to 'Name' column
// </summary>
//-----------------------------------------------------------------------
namespace Cat.Plugins
{
    using System;
    using System.ServiceModel;
    using Cat.Plugins.Helper;
    using Microsoft.Xrm.Sdk;

    /// <summary>
    /// Alm Accelerator Sample Class triggers on Pre Create 
    /// </summary>
    public class PreALMAcceleratorSampleCreate : PluginBase
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="PreALMAcceleratorSampleCreate" /> class
        /// </summary>
        /// <param name="unsecureConfiguration">Unsecure Configuration</param>
        /// <param name="secureConfiguration">Secure Configuration</param>
        public PreALMAcceleratorSampleCreate(string unsecureConfiguration, string secureConfiguration)
            : base(typeof(PreALMAcceleratorSampleCreate))
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

            // The InputParameters collection contains all the data passed in the message request.  
            if (context != null && context.InputParameters.Contains("Target") && context.InputParameters["Target"] is Entity entity)
            {
                // Obtain the target entity from the input parameters.  
                Entity targetAlmAcceleratorSampleCreate = entity;

                try
                {
                    string strDetails = string.Empty;

                    // Read first 50 characters of "Details" column
                    if (targetAlmAcceleratorSampleCreate.Contains("cat_details") && targetAlmAcceleratorSampleCreate["cat_details"] != null)
                    {
                        strDetails = ALMAcceleratorSampleHelper.TrimandExtractDetails(targetAlmAcceleratorSampleCreate["cat_details"].ToString());
                    }

                    // Set 'Name' column with first 50 characters of 'Details' column.
                    targetAlmAcceleratorSampleCreate["cat_name"] = string.IsNullOrEmpty(strDetails) ? targetAlmAcceleratorSampleCreate["cat_name"] : targetAlmAcceleratorSampleCreate["cat_name"] + " - " + strDetails;
                }
                catch (FaultException<OrganizationServiceFault> ex)
                {
                    throw new InvalidPluginExecutionException("An error occurred in PreALMAcceleratorSampleCreate.", ex);
                }
                catch (Exception ex)
                {
                    localPluginContext.Trace("PreALMAcceleratorSampleCreate: {0}", ex.ToString());
                    throw;
                }
            }
        }
    }
}