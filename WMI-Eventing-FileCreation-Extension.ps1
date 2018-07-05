$test = 'SELECT * FROM __InstanceCreationEvent WITHIN 10 WHERE TargetInstance ISA "cim_datafile" AND TargetInstance.extension="txt" '
$action = {Write-host hello}
Register-WmiEvent -Query $test -SourceIdentifier "Im" -Action $action






#Register-WMIEvent -Query "select * from __instancecreationevent within 10 where targetinstance ISA cim_datafile and targetinstance.extension='txt'" -action {write-host "hello"}