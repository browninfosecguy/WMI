$test = 'SELECT * FROM __InstanceModificationEvent WITHIN 10 WHERE TargetInstance ISA "cim_datafile" AND TargetInstance.name="C:\\Users\\sunny\\Documents\\sunny\\hook.txt" AND TargetInstance.lastmodified > TargetInstance.creationdate '
$action = {New-EventLog –LogName Application –Source “Hook”;Write-EventLog –LogName Application –Source “Hook” –EntryType Information –EventID 1 –Message “Bait Taken”}
Register-wmiEvent -Query $test -SourceIdentifier "Hook" -Action $action

