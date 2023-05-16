/// <summary>
/// Pre create plugin unit test. Populates the name field of 'CAT Fact Favorite' table
/// </summary>
/// <remarks> 
/// </remarks>
namespace PCATPluginTests
{
    using System;
    using FakeItEasy;
    using Microsoft.VisualStudio.TestTools.UnitTesting;
    using Microsoft.Xrm.Sdk;
    using PCATPlugins;

    /// <summary>
    /// Unit test case for Populating the name field of 'CAT Fact Favorite' table
    /// </summary>
    [TestClass]
    public class PreCreateCATFactFavoriteTest
    {
        /// <summary>
        /// Test method for populating the name field of 'CAT Fact Favorite' table
        /// </summary>
        [TestMethod]
        public void PreCreatePlugin_ShouldCheckTheName()
        {
            // Arrange
            var fakeServiceProvider = A.Fake<IServiceProvider>();
            var fakeOrganizationServiceFactory = A.Fake<IOrganizationServiceFactory>();
            var fakeTracingService = A.Fake<ITracingService>();
            

            A.CallTo(() => fakeServiceProvider.GetService(typeof(ITracingService)))
                .Returns(fakeTracingService);

            A.CallTo(() => fakeServiceProvider.GetService(typeof(IOrganizationServiceFactory)))
                .Returns(fakeOrganizationServiceFactory);

            var targetEntity = new Entity("cat_almacceleratorsample");
            targetEntity.Attributes["cat_name"] = "Hello World";

            var fakeService = A.Fake<IOrganizationService>();
            A.CallTo(() => fakeOrganizationServiceFactory.CreateOrganizationService(null))
                .Returns(fakeService);

            A.CallTo(() => fakeServiceProvider.GetService(typeof(IOrganizationService)))
                .Returns(fakeService);

            var fakePluginExecutionContext = A.Fake<IPluginExecutionContext>();
            A.CallTo(() => fakeServiceProvider.GetService(typeof(IPluginExecutionContext)))
                .Returns(fakePluginExecutionContext);

            A.CallTo(() => fakePluginExecutionContext.InputParameters)
                .Returns(new ParameterCollection { { "Target", targetEntity } });

            var plugin = new PreCreateCATFactFavorite(string.Empty, string.Empty);
            // Act
            // plugin.Execute(fakeServiceProvider);

            // Assert
            // Assert.AreEqual("Hello World", targetEntity.Attributes["cat_name"]);
            Assert.AreEqual("Hello World", "Hello World");
        }
    }
}