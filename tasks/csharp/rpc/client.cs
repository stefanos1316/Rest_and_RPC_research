using System;    
using System.Collections.Generic;    
using System.Linq;    
using System.Text;    
using System.Net.Sockets;    
using System.IO;    
    
namespace Client_test
{
    class Program
    {
        static void Main(string[] args)
        {
            try
            {
                TcpClient Tcpclient = new TcpClient();
                Console.WriteLine("Connecting..");
                Tcpclient.Connect("195.251.251.27", 8000);
                Console.WriteLine("Connected");
                Console.WriteLine("Ente the String you want to send ");
                string str = Console.ReadLine();
                Stream stm = Tcpclient.GetStream();
                ASCIIEncoding ascnd = new ASCIIEncoding();
                byte[] ba = ascnd.GetBytes(str);
                Console.WriteLine("Sending..");
                stm.Write(ba, 0, ba.Length);
                byte[] bb = new byte[100];
                int k = stm.Read(bb, 0, 100);
                for (int i = 0; i < k; i++)
                {
                    Console.Write(Convert.ToChar(bb[i]));
                }

                Tcpclient.Close();
                Console.ReadLine();
            }
            catch (Exception ex)
            {
                Console.WriteLine("Error" + ex.StackTrace);
            }
        }
    }
}
