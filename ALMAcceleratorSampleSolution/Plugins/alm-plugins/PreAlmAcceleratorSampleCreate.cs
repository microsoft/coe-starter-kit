//-----------------------------------------------------------------------
// <copyright file="PreAlmAcceleratorSampleCreate.cs" company="Microsoft">
// Copyright (c) 2022 All Rights Reserved
// </copyright>
// <summary>
// Plugin example for ALM Accelerator Solution.
// On pre creation event of 'AlmAcceleratorSample' table
// Read the value from 'Details' column (Limit the length to 50 characters) and set to 'Name' column
// </summary>
//-----------------------------------------------------------------------
namespace Alm.Plugins
{
    using System;
    using System.ServiceModel;
    using Microsoft.Xrm.Sdk;

    /// <summary>
    /// Sync plugin on Pre Create event.
    /// </summary>
    public class PreAlmAcceleratorSampleCreate : PluginBase
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="PreAlmAcceleratorSampleCreate" /> class
        /// </summary>
        /// <param name="unsecureConfiguration">Unsecure Configuration</param>
        /// <param name="secureConfiguration">Secure Configuration</param>
        public PreAlmAcceleratorSampleCreate(string unsecureConfiguration, string secureConfiguration)
            : base(typeof(PreAlmAcceleratorSampleCreate))
        {
            // TODO: Implement your custom configuration handling
        }

        /// <summary>
        /// Default Execute Method
        /// </summary>
        /// <param name="localPluginContext">Local Plugin Context</param>
        protected override void ExecuteCdsPlugin(ILocalPluginContext localPluginContext)
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
                        strDetails = targetAlmAcceleratorSampleCreate["cat_details"].ToString();
                        strDetails = (strDetails.Length > 50) ? strDetails.Substring(0, 49) : strDetails;
                    }

                    // Set 'Name' column with first 50 characters of 'Details' column.
                    targetAlmAcceleratorSampleCreate["cat_name"] = string.IsNullOrEmpty(strDetails) ? targetAlmAcceleratorSampleCreate["cat_name"] : targetAlmAcceleratorSampleCreate["cat_name"] + " - " + strDetails;
                }
                catch (FaultException<OrganizationServiceFault> ex)
                {
                    throw new InvalidPluginExecutionException("An error occurred in PreAlmAcceleratorSampleCreate.", ex);
                }
                catch (Exception ex)
                {
                    localPluginContext.Trace("PreAlmAcceleratorSampleCreate: {0}", ex.ToString());
                    throw;
                }
            }
        }
    }
}