<#

Date: 6 March 2020

Author: @browninfosecguy


Use Following commands to cleanup the Permenant Event subscription

Get-CimInstance -ClassName __EventFilter -namespace root\subscription -filter "name='myFilter'" | Remove-CimInstance
Get-CimInstance -ClassName NTEventLogEventConsumer -Namespace root\subscription -filter "name='myConsumer'" | Remove-CimInstance
Get-CimInstance -ClassName __FilterToConsumerBinding -Namespace root\subscription -Filter "Filter = ""__eventfilter.name='myFilter'""" | Remove-CimInstance

#>

#Requires -RunAsAdministrator

$WQLQuery = 'SELECT * FROM __InstanceModificationEvent WITHIN 10 WHERE TargetInstance ISA "CIM_DataFile" AND TargetInstance.Name = "C:\\Users\\Administrator\\Downloads\\cat.rtf"'

if(!(Get-CimInstance -ClassName __EventFilter -namespace root\subscription -filter "name='myFilter'") -or !(Get-CimInstance -ClassName NTEventLogEventConsumer -Namespace root\subscription -filter "name='myConsumer'") -or !(Get-CimInstance -ClassName __FilterToConsumerBinding -Namespace root\subscription -Filter "Filter = ""__eventfilter.name='myFilter'"""))
{

    Write-Host "Creating WMI Permenant Subscription"

    try {
            $WMIFilterInstance = New-CimInstance -ClassName __EventFilter -Namespace "root\subscription" -Property @{Name="myFilter";
                         EventNameSpace="root\cimv2";
                         QueryLanguage="WQL";
                         Query=$WQLQuery
                    }

        $WMIEventConsumer = New-CimInstance -ClassName NTEventLogEventConsumer -Namespace "root\subscription" -Property  @{Name="myConsumer";
                                EventId = [uint32] 1; EventType = [uint32] 4; #EventType can have following values; Error 1, FailureAudit 16, Information 4, SuccesAudit 8, Warning 2
                                SourceName="PowerShell-Script-Log"; Category= [uint16] 1000 } #Category is never really used but can have any value and basically meant to provide more information about the event


        $WMIWventBinding = New-CimInstance -ClassName __FilterToConsumerBinding -Namespace "root\subscription" -Property @{Filter = [Ref] $WMIFilterInstance;
                            Consumer = [Ref] $WMIEventConsumer
                            }
    }
    catch {

            "Could not create permanent WMI Event subscription"
            Get-CimInstance -ClassName __EventFilter -namespace root\subscription -filter "name='myFilter'" | Remove-CimInstance
            Get-CimInstance -ClassName NTEventLogEventConsumer -Namespace root\subscription -filter "name='myConsumer'" | Remove-CimInstance
            Get-CimInstance -ClassName __FilterToConsumerBinding -Namespace root\subscription -Filter "Filter = ""__eventfilter.name='myFilter'""" | Remove-CimInstance
    }
}
else
{
    Write-Host "WMI Permenant Subscription already exist"
}