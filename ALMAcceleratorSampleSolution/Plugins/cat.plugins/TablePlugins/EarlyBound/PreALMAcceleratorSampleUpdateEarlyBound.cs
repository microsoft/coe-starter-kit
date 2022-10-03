//-----------------------------------------------------------------------
// <copyright file="PreALMAcceleratorSampleUpdateEarlyBound.cs" company="Microsoft">
// Copyright (c) 2022 All Rights Reserved
// </copyright>
// <summary>
// Plugin example for ALM Accelerator Solution.
// On pre update event of 'AlmAcceleratorSample' table
// Check whether 'Details' column modified
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
    /// ALM Accelerator Sample Class triggers on Pre Update 
    /// </summary>
    public class PreALMAcceleratorSampleUpdateEarlyBound : PluginBase
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="PreALMAcceleratorSampleUpdateEarlyBound" /> class
        /// </summary>
        /// <param name="unsecureConfiguration">Unsecure Configuration</param>
        /// <param name="secureConfiguration">Secure Configuration</param>
        public PreALMAcceleratorSampleUpdateEarlyBound(string unsecureConfiguration, string secureConfiguration)
            : base(typeof(PreALMAcceleratorSampleUpdateEarlyBound))
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
            cat_AlmAcceleratorSample preImageAlmAcceleratorSampleCreate = null;
            try
            {
                // The InputParameters collection contains all the data passed in the message request.  
                if (context != null && context.InputParameters.Contains("Target") && context.InputParameters["Target"] is Entity entity)
                {
                    // Obtain the target entity from the input parameters.  
                    cat_AlmAcceleratorSample targetAlmAcceleratorSampleCreate = entity.ToEntity<cat_AlmAcceleratorSample>();

                    // Obtain the preimage entity from the PreEntityImages parameters.  
                    if (context.PreEntityImages.Contains("preImage") && context.PreEntityImages["preImage"] is Entity preImageEntity)
                    {
                        preImageAlmAcceleratorSampleCreate = preImageEntity.ToEntity<cat_AlmAcceleratorSample>();
                    }

                    string strName = "Quote";
                    string strDetails = string.Empty;

                    // If 'Details' column modified, read from 'Target'; else read from PreImage
                    if (targetAlmAcceleratorSampleCreate.Contains("cat_details"))
                    {
                        strDetails = !string.IsNullOrEmpty(targetAlmAcceleratorSampleCreate.cat_Details) ? targetAlmAcceleratorSampleCreate.cat_Details : string.Empty;
                    }
                    else if (preImageAlmAcceleratorSampleCreate != null && preImageAlmAcceleratorSampleCreate.Contains("cat_details"))
                    {
                        strDetails = !string.IsNullOrEmpty(preImageAlmAcceleratorSampleCreate.cat_Details) ? preImageAlmAcceleratorSampleCreate.cat_Details : string.Empty;
                    }

                    strDetails = ALMAcceleratorSampleHelper.TrimandExtractDetails(targetAlmAcceleratorSampleCreate.cat_Details);

                    // Set 'Name' as { Quote - 'Details' column data }
                    targetAlmAcceleratorSampleCreate.cat_Name = string.IsNullOrEmpty(strDetails) ? strName : strName + " - " + strDetails;
                }
            }
            catch (FaultException<OrganizationServiceFault> ex)
            {
                throw new InvalidPluginExecutionException("An error occurred in PreALMAcceleratorSampleUpdateEarlyBound.", ex);
            }
            catch (Exception ex)
            {
                localPluginContext.Trace("PreALMAcceleratorSampleUpdateEarlyBound: {0}", ex.ToString());
                throw;
            }
        }
    }
}