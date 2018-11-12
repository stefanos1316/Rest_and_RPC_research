using System;    
using System.Collections.Generic;    
using System.Linq;    
using System.Text;    
using System.Net.Sockets;    
using System.Net;    
   
namespace server_test    
{    
    class Program    
    {    
        static void Main(string[] args)    
        {    
    
            try    
            {    
                IPAddress ipaddress = IPAddress.Parse("195.251.251.27");    
                TcpListener mylist = new TcpListener(ipaddress, 8000);    
                mylist.Start();    
                Console.WriteLine("Server is Running on Port: 8000");    
                Console.WriteLine("Local endpoint:" + mylist.LocalEndpoint);    
                Console.WriteLine("Waiting for Connections...");    
                int end = 0;
		while (end == 0) {
                Socket s = mylist.AcceptSocket();    
	       	Console.WriteLine("Connection Accepted From:" + s.RemoteEndPoint);    
                byte[] b = new byte[100];    
                int k = s.Receive(b);    
                Console.WriteLine("Recieved..");    
                for (int i = 0; i < k; i++)    
                {    
                    Console.Write(Convert.ToChar(b[i]));    
                }    
                ASCIIEncoding asencd = new ASCIIEncoding();    
                s.Send(asencd.GetBytes("Automatic Message:" + "String Received byte server !"));    
                Console.WriteLine("\nAutomatic Message is Sent");    
		end++;
		s.Close();    
		}
		mylist.Stop();    
                Console.ReadLine();    
            }    
            catch (Exception ex)    
            {    
                Console.WriteLine("Error.." + ex.StackTrace);    
            }    
             
        }    
    }    
}  

