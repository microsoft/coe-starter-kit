using Microsoft.Xrm.Sdk;
using System;
using System.ServiceModel;

namespace $safeprojectname$
{
    /* 
     * Plugin development guide: https://docs.microsoft.com/powerapps/developer/common-data-service/plug-ins
     * Best practices and guidance: https://docs.microsoft.com/powerapps/developer/common-data-service/best-practices/business-logic/
     */
    public abstract class PluginBase : IPlugin
    {
        protected string PluginClassName { get; }

        internal PluginBase(Type pluginClassName)
        {
            PluginClassName = pluginClassName.ToString();
        }

        public void Execute(IServiceProvider serviceProvider)
        {
            if (serviceProvider == null)
            {
                throw new InvalidPluginExecutionException("serviceProvider");
            }

            var localPluginContext = new LocalPluginContext(serviceProvider);

            localPluginContext.Trace($"Entered {PluginClassName}.Execute() " +
                $"Correlation Id: {localPluginContext.PluginExecutionContext.CorrelationId}, " +
                $"Initiating User: {localPluginContext.PluginExecutionContext.InitiatingUserId}");

            try
            {
                ExecuteCdsPlugin(localPluginContext);

                // Now exit - if the derived plugin has incorrectly registered overlapping event registrations, guard against multiple executions.
                return;
            }
            catch (FaultException<OrganizationServiceFault> orgServiceFault)
            {
                localPluginContext.Trace($"Exception: {orgServiceFault.ToString()}");

                throw new InvalidPluginExecutionException($"OrganizationServiceFault: {orgServiceFault.Message}", orgServiceFault);
            }
            finally
            {
                localPluginContext.Trace($"Exiting {PluginClassName}.Execute()");
            }
        }

        protected virtual void ExecuteCdsPlugin(ILocalPluginContext localPluginContext)
        {
            // Do nothing. 
        }
    }

     /*
     * This interface provides an abstraction on top of IServiceProvider for commonly used PowerApps CDS Plugin development constructs
     */
    public interface ILocalPluginContext
    {
        // The PowerApps CDS organization service for current user account
        IOrganizationService CurrentUserService { get; }

        // The PowerApps CDS organization service for system user account
        IOrganizationService SystemUserService { get; }

        // IPluginExecutionContext contains information that describes the run-time environment in which the plugin executes, information related to the execution pipeline, and entity business information
        IPluginExecutionContext PluginExecutionContext { get; }

        // Synchronous registered plugins can post the execution context to the Microsoft Azure Service Bus.
        // It is through this notification service that synchronous plug-ins can send brokered messages to the Microsoft Azure Service Bus
        IServiceEndpointNotificationService NotificationService { get; }

        // Provides logging run time trace information for plug-ins. 
        ITracingService TracingService { get; }

        // Writes a trace message to the CDS trace log
        void Trace(string message);
    }

    public class LocalPluginContext : ILocalPluginContext
    {
        public IOrganizationService CurrentUserService { get; }

        public IOrganizationService SystemUserService { get; }

        public IPluginExecutionContext PluginExecutionContext { get; }

        public IServiceEndpointNotificationService NotificationService { get; }

        public ITracingService TracingService { get; }

        public LocalPluginContext(IServiceProvider serviceProvider)
        {
            if (serviceProvider == null)
            {
                throw new InvalidPluginExecutionException("serviceProvider");
            }

            PluginExecutionContext = (IPluginExecutionContext)serviceProvider.GetService(typeof(IPluginExecutionContext));

            TracingService = new LocalTracingService(serviceProvider);

            NotificationService = (IServiceEndpointNotificationService)serviceProvider.GetService(typeof(IServiceEndpointNotificationService));

            IOrganizationServiceFactory factory = (IOrganizationServiceFactory)serviceProvider.GetService(typeof(IOrganizationServiceFactory));

            CurrentUserService = factory.CreateOrganizationService(PluginExecutionContext.UserId);

            SystemUserService = factory.CreateOrganizationService(null);
        }

        public void Trace(string message)
        {
            if (string.IsNullOrWhiteSpace(message) || TracingService == null)
            {
                return;
            }

            TracingService.Trace(message);
        }
    }

    /*
     * Specialized ITracingService implementation that prefixes all traced messages with a time delta for Plugin performance diagnostics
     */
    public class LocalTracingService : ITracingService
    {
        private readonly ITracingService _tracingService;

        private DateTime _previousTraceTime;

        public LocalTracingService(IServiceProvider serviceProvider)
        {
            DateTime utcNow = DateTime.UtcNow;

            var context = (IExecutionContext)serviceProvider.GetService(typeof(IExecutionContext));

            DateTime initialTimestamp = context.OperationCreatedOn;

            if (initialTimestamp > utcNow)
            {
                initialTimestamp = utcNow;
            }

            _tracingService = (ITracingService)serviceProvider.GetService(typeof(ITracingService));

            _previousTraceTime = initialTimestamp;
        }

        public void Trace(string message, params object[] args)
        {
            var utcNow = DateTime.UtcNow;

            // The duration since the last trace.
            var deltaMilliseconds = utcNow.Subtract(_previousTraceTime).TotalMilliseconds;

            _tracingService.Trace($"[+{deltaMilliseconds:N0}ms)] - {message}");

            _previousTraceTime = utcNow;
        }
    }
}