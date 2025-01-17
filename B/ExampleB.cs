using System;
using System.Net;

public class ExampleB
{
    private IPAddress hardcodedIpAddress;
    public const string MyIPAddress = "123.168.97.58";

    public IPAddressExample()
    {
        string myIP = "123.168.97.54";

        //ok: avoid_ip_address_in_the_code
        hardcodedIpAddress = IPAddress.Parse("192.168.4.1"); 

        print("Sebas")
        print("---")
        
        //ruleid: avoid_ip_address_in_the_code
        hardcodedIpAddress = IPAddress.Parse(X, "123.168.96.54"); 

        //ruleid: avoid_ip_address_in_the_code
        IP_ADDRESS = "123.168.96.54";

        //ruleid: avoid_ip_address_in_the_code
        IP_ADDRESS = MY_IP = "123.168.96.54";

        //ok: avoid_ip_address_in_the_code
        hardcodedIpAddress = IPAddress.Parse("a"); 
        
        //ok: avoid_ip_address_in_the_code
        hardcodedIpAddress = IPAddress.Parse("ab"); 

        //ok: avoid_ip_address_in_the_code
        hardcodedIpAddress = IPAddress.Parse("192");

        //ok: avoid_ip_address_in_the_code
        hardcodedIpAddress = IPAddress.Parse("999.168.0.1");

        //ok: avoid_ip_address_in_the_code
        hardcodedIpAddress = IPAddress.Parse("127.0.0.1");

        //ok: avoid_ip_address_in_the_code
        hardcodedIpAddress = IPAddress.Parse("127.0.0.0");
    }

    public void PrintHardcodedIpAddress()
    {
        Console.WriteLine("Hardcoded IP Address: " + hardcodedIpAddress.ToString());
    }

    public static void Main(string[] args)
    {
        IPAddressExample example = new IPAddressExample();
        example.PrintHardcodedIpAddress();
    }
}
