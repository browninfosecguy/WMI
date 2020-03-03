<#

Date: 2 March 2020

Author: @browninfosecguy


Use Following commands to cleanup the Permenant Event subscription

Get-WmiObject __EventFilter -namespace root\subscription -filter "name='myFilter'" | Remove-WmiObject
Get-WmiObject NTEventLogEventConsumer -Namespace root\subscription -filter "name='FolderWriteLogging'" | Remove-WmiObject
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

$WMIEventConsumer = New-CimInstance -ClassName NTEventLogEventConsumer -Namespace "root\subscription" -Property  @{Name="FolderWriteLogging";
                        EventId = [uint32] 1; EventType = [uint32] 4; #EventType can have following values; Error 1, FailureAudit 16, Information 4, SuccesAudit 8, Warning 2
                        SourceName="PowerShell-Script-Log"; Category= [uint16] 1000 } #Category is never really used but can have any value and basically meant to provide more information about the event


$WMIWventBinding = New-CimInstance -ClassName __FilterToConsumerBinding -Namespace "root\subscription" -Property @{Filter = [Ref] $WMIFilterInstance;
                    Consumer = [Ref] $WMIEventConsumer
                    }