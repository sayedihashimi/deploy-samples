using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Configuration;

namespace ContactManager
{
    public class Program
    {
        public static void Main(string[] args)
        {
            BuildWebHost(args).Run();
        }

        public static IWebHost BuildWebHost(string [] args)
        {
            var envName = System.Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT");
            if (string.IsNullOrWhiteSpace(envName))
            {
                envName = "no-envname";
            }

            var config = new ConfigurationBuilder()
                                .SetBasePath(Directory.GetCurrentDirectory())
                                .AddJsonFile("appsettings.json", true)
                                .AddJsonFile($"appsettings.{envName}.json", optional: true)
                                .AddJsonFile("appsettings.secrets.user", optional: true)
                                .AddEnvironmentVariables();

            var builder = WebHost.CreateDefaultBuilder(args)
                            .UseStartup<Startup>()
                            .UseConfiguration(config.Build())
                            .Build();
      

            return builder;
        }


    }
}
