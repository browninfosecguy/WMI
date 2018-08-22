<#
To remove the instance use following 
Remove-CimInstance -Query 'select * from __IntervalTimerInstruction where TimerId="MyTimerId"'

Once done to unregister the event run the following Command 
Unregister-Event Kity
#>


New-CimInstance -ClassName __IntervalTimerInstruction -Property @{TimerId="MyTimerId";IntervalBetweenEvents=[uint32]5000}
$test = 'SELECT * FROM __TimerEvent where TimerId="MyTimerId"'
$action = {write-host Cat}
Register-WmiEvent -Query $test -SourceIdentifier "Kity" -Action $action
