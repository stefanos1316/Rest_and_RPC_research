using System;
using System.Collections.Generic;
using Microsoft.Extensions.DependencyInjection;
using SimpleRpc.Sample.Shared;
using SimpleRpc.Transports;
using SimpleRpc.Transports.Http.Client;

namespace SimpleRpc.Sample.Client
{
    class Program
    {
        static void Main(string[] args)
        {
            var sc = new ServiceCollection();

            sc.AddSimpleRpcClient("sample", new HttpClientTransportOptions
            {
                Url = "http://195.251.251.20:5001/rpc",
            //    Serializer = "wire"
            });

            sc.AddSimpleRpcProxy<IFooService>("sample");
            // or
            sc.AddSimpleRpcProxy(typeof(IFooService), "sample");

            var pr = sc.BuildServiceProvider();

            var service = pr.GetService<IFooService>();

	    for (int i = 0; i < 20000; ++i) 
            	service.Plus(1, 5);

        }
    }
}
