//-----------------------------------------------------------------------
// <copyright file="PreAlmAcceleratorSampleUpdate.cs" company="Microsoft">
// Copyright (c) 2022 All Rights Reserved
// </copyright>
// <summary>
// Plugin example for ALM Accelerator Solution.
// On pre update event of 'AlmAcceleratorSample' table
// Check whether 'Details' column modified
// Read the value from 'Details' column (Limit the length to 50 characters) and set to 'Name' column
// </summary>
//-----------------------------------------------------------------------
namespace Alm.Plugins
{
    using System;
    using System.ServiceModel;
    using Microsoft.Xrm.Sdk;

    /// <summary>
    /// Sync plugin on Pre update event.
    /// </summary>
    public class PreAlmAcceleratorSampleUpdate : PluginBase
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="PreAlmAcceleratorSampleUpdate" /> class
        /// </summary>
        /// <param name="unsecureConfiguration">Unsecure Configuration</param>
        /// <param name="secureConfiguration">Secure Configuration</param>
        public PreAlmAcceleratorSampleUpdate(string unsecureConfiguration, string secureConfiguration)
            : base(typeof(PreAlmAcceleratorSampleUpdate))
        {
            // TODO: Implement your custom configuration handling
        }

        /// <summary>
        /// Default Execute Method
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

                    // Read first 50 characters of "Details" column
                    if (!string.IsNullOrEmpty(strDetails))
                    {
                        strDetails = (strDetails.Length > 50) ? strDetails.Substring(0, 49) : strDetails;
                    }

                    var strName = "Quote";

                    // Set 'Name' as { Quote - 'Details' column data }
                    targetAlmAcceleratorSampleCreate["cat_name"] = string.IsNullOrEmpty(strDetails) ? strName : strName + " - " + strDetails;
                }
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