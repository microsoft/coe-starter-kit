//-----------------------------------------------------------------------
// <copyright file="PreALMAcceleratorSampleCreateEarlyBound.cs" company="Microsoft">
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
    using Cat.Plugins.EarlyBound;
    using Cat.Plugins.Helper;
    using Microsoft.Xrm.Sdk;

    /// <summary>
    /// ALM Accelerator Sample Class triggers on Pre Create 
    /// </summary>
    public class PreALMAcceleratorSampleCreateEarlyBound : PluginBase
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="PreALMAcceleratorSampleCreateEarlyBound" /> class
        /// </summary>
        /// <param name="unsecureConfiguration">Unsecure Configuration</param>
        /// <param name="secureConfiguration">Secure Configuration</param>
        public PreALMAcceleratorSampleCreateEarlyBound(string unsecureConfiguration, string secureConfiguration)
            : base(typeof(PreALMAcceleratorSampleCreateEarlyBound))
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
                cat_AlmAcceleratorSample targetAlmAcceleratorSampleCreate = entity.ToEntity<cat_AlmAcceleratorSample>();

                try
                {
                    string strDetails = string.Empty;

                    // Read first 50 characters of "Details" column
                    if (!string.IsNullOrEmpty(targetAlmAcceleratorSampleCreate.cat_Details))
                    {
                        strDetails = ALMAcceleratorSampleHelper.TrimandExtractDetails(targetAlmAcceleratorSampleCreate.cat_Details);
                    }

                    // Set 'Name' column with first 50 characters of 'Details' column.
                    targetAlmAcceleratorSampleCreate.cat_Name = string.IsNullOrEmpty(strDetails) ? targetAlmAcceleratorSampleCreate.cat_Name : targetAlmAcceleratorSampleCreate.cat_Name + " - " + strDetails;
                }
                catch (FaultException<OrganizationServiceFault> ex)
                {
                    throw new InvalidPluginExecutionException("An error occurred in PreALMAcceleratorSampleCreateEarlyBound.", ex);
                }
                catch (Exception ex)
                {
                    localPluginContext.Trace("PreALMAcceleratorSampleCreateEarlyBound: {0}", ex.ToString());
                    throw;
                }
            }
        }
    }
}