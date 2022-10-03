//-----------------------------------------------------------------------
// <copyright file="ALMAcceleratorSampleCreate.cs" company="Microsoft">
// Copyright (c) 2022 All Rights Reserved
// </copyright>
// <summary>
// Custom API example for ALM Accelerator Solution.
// Creates a record in 'AlmAcceleratorSample' table
// </summary>
//-----------------------------------------------------------------------
namespace Cat.Plugins.CustomAPI
{
    using System;
    using Microsoft.Xrm.Sdk;

    /// <summary>
    /// ALM Accelerator Example API which creates new record
    /// </summary>
    public class ALMAcceleratorSampleCreate : PluginBase
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="ALMAcceleratorSampleCreate" /> class
        /// </summary>
        /// <param name="unsecureConfiguration">Unsecure Configuration</param>
        /// <param name="secureConfiguration">Secure Configuration</param>
        public ALMAcceleratorSampleCreate(string unsecureConfiguration, string secureConfiguration)
            : base(typeof(ALMAcceleratorSampleCreate))
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

            if (context.MessageName.Equals("ALMAcceleratorSampleCreate") && context.Stage.Equals(30))
            {
                try
                {
                    // Read Details and Name from Parameters
                    string strName = (string)context.InputParameters["Name"];
                    string strDetails = (string)context.InputParameters["Details"];

                    if (!string.IsNullOrEmpty(strName) && !string.IsNullOrEmpty(strDetails))
                    {
                        Entity entAlmAcceleratorSample = new Entity("cat_almacceleratorsample");
                        entAlmAcceleratorSample["cat_name"] = strName;
                        entAlmAcceleratorSample["cat_details"] = strDetails;
                        Guid newAlmAcceleratorSampleID = localPluginContext.InitiatingUserService.Create(entAlmAcceleratorSample);

                        // Pass the guid of newly created "ALMAcceleratorSample" record as output parameter
                        context.OutputParameters["AlmAcceleratorSampleID"] = newAlmAcceleratorSampleID;
                    }
                }
                catch (Exception ex)
                {
                    localPluginContext.Trace("ALMAcceleratorSampleCreate: {0}", ex.ToString());
                    throw new InvalidPluginExecutionException("An error occurred in ALMAcceleratorSampleCreate.", ex);
                }
            }
        }
    }
}