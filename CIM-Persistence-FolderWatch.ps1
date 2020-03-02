<#

Get-WmiObject __EventFilter -namespace root\subscription -filter "name='myFilter'" | Remove-WmiObject
Get-WmiObject CommandLineEventConsumer -Namespace root\subscription -filter "name='myConsumer'" | Remove-WmiObject
Get-WmiObject __FilterToConsumerBinding -Namespace root\subscription -Filter "Filter = ""__eventfilter.name='myFilter'""" | Remove-WmiObject

#>

$WQLQuery = 'SELECT * FROM __InstanceCreationEvent WITHIN 60 
             WHERE TargetInstance ISA "CIM_DirectoryContainsFile"
             AND TargetInstance.GroupComponent = "Win32_Directory.Name=\"C:\\\\Test\""'

$WMIFilterInstance = New-CimInstance -ClassName __EventFilter -Namespace "root\subscription" -Property @{Name="myFilter";
                 EventNameSpace="root\cimv2";
                 QueryLanguage="WQL";
                 Query=$WQLQuery
                }



$WMIEventConsumer = New-CimInstance -ClassName CommandLineEventConsumer -Namespace "root\subscription" -Property @{Name="myConsumer";
                 CommandLineTemplate = "C:\\Windows\\System32\\notepad.exe"
                }


$WMIWventBinding = New-CimInstance -ClassName __FilterToConsumerBinding -Namespace "root\subscription" -Property @{Filter = [Ref] $WMIFilterInstance;
                    Consumer = [Ref] $WMIEventConsumer
                    }