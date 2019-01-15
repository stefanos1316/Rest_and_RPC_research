using System;
using System.Net.Http;
namespace HttpClientTest
{
	class Program {
		static void Main(string[] args) {
			var client = new HttpClient();
			for (int i = 0; i < 20000; ++i) {
				var response = client.GetAsync("http://195.251.251.27:5001").Result;
				Console.WriteLine(response.StatusCode);
			}
		}
	}
}
