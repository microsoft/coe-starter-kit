//-----------------------------------------------------------------------
// <copyright file="AlmAcceleratorSampleHelper.cs" company="Microsoft">
// Copyright (c) 2022 All Rights Reserved
// </copyright>
// <summary>
// Helper class for AlmAcceleratorSample functionality
// </summary>
//-----------------------------------------------------------------------

namespace Cat.Plugins.Helper
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using System.Threading.Tasks;

    /// <summary>
    /// Helper class for ALM Accelerator Sample functionality
    /// </summary>
    public class ALMAcceleratorSampleHelper
    {
        /// <summary>
        /// Static method to trim and return the 'Details'
        /// </summary>
        /// <param name="details">ALM Accelerator Sample Details field</param>
        /// <returns>Trimmed Details</returns>
        public static string TrimandExtractDetails(string details)
        {
            string strTrimmedDetails = string.Empty;
            if (!string.IsNullOrEmpty(details))
            {
                strTrimmedDetails = (details.Length > 50) ? details.Substring(0, 49) : details;
            }

            return strTrimmedDetails;
        }
    }
}