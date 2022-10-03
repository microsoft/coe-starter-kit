namespace Cat.Plugins.Test
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using FakeItEasy;
    using Microsoft.VisualStudio.TestTools.UnitTesting;
    using Microsoft.Xrm.Sdk;
    using MockQueryable.FakeItEasy;
    using Cat.Plugins;
    using Microsoft.Xrm.Sdk.PluginTelemetry;

    [TestClass]
    public class TestsForExample : PluginTestBase
    {
        [TestMethod]
        public void TestExecute()
        {
            // Arrange
            var fakeServiceProvider = A.Fake<IServiceProvider>();
            var fakeILogger = A.Fake<ILogger>();

            // Act
            var plugin = new PreALMAcceleratorSampleCreate(string.Empty, string.Empty);
            plugin.Execute(fakeServiceProvider);

            //Assert
            Assert.AreEqual(true, true);
        }
    }
}