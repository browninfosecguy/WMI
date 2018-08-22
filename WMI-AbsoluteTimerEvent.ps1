<#
To remove the instance use following 
Remove-CimInstance -Query 'select * from __IntervalTimerInstruction where TimerId="MyTimerId"'

Once done to unregister the event run the following Command 
Unregister-Event Kity
#>


New-CimInstance -ClassName __AbsoluteTimerInstruction -Property @{TimerId="MyTimerId";EventDateTime=[DateTime]"2018-08-22 17:00"}
$test = 'SELECT * FROM __TimerEvent where TimerId="MyTimerId"'
$action = {write-host Cat}
Register-WmiEvent -Query $test -SourceIdentifier "Kity" -Action $action
