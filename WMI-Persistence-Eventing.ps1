<#

Get-WmiObject __EventFilter -namespace root\subscription -filter "name='EvilExeFilter'" | Remove-WmiObject
Get-WmiObject CommandLineEventConsumer -Namespace root\subscription -filter "name='EvilExeConsumer'" | Remove-WmiObject
Get-WmiObject __FilterToConsumerBinding -Namespace root\subscription -Filter "Filter = ""__eventfilter.name='EvilExeFilter'""" | Remove-WmiObject

#>

$WQLQuery = 'SELECT * FROM __InstanceCreationEvent WITHIN 60 
             WHERE TargetInstance ISA "CIM_DirectoryContainsFile"
             AND TargetInstance.GroupComponent = "Win32_Directory.Name=\"C:\\\\Test\""'

$WMIEventFilter = New-CIMInstance -Class __EventFilter -NameSpace "root\subscription" -Arguments @{Name="myFilter";
                 EventNameSpace="root\cimv2";
                 QueryLanguage="WQL";
                 Query=$WQLQuery
                }


$WMIEventConsumer = New-CIMInstance -Class CommandLineEventConsumer -Namespace "root\subscription" -Arguments @{Name="myConsumer";
                 ExecutablePath = "C:\\Windows\\System32\\powershell.exe"
                 CommandLineTemplate = "ise"
                }


New-CIMInstance -Class __FilterToConsumerBinding -Namespace "root\subscription" -Arguments @{Filter=$WMIEventFilter;Consumer=$WMIEventConsumer}
