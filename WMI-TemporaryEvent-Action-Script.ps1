$action = {write-host hello}
$WQLQuery = 'SELECT * FROM __InstanceCreationEvent WITHIN 10 
             WHERE TargetInstance ISA "CIM_DirectoryContainsFile"
             AND TargetInstance.GroupComponent = "Win32_Directory.Name=\"c:\\\\test\""'
 
Register-WmiEvent -Query $WQLQuery -SourceIdentifier "WatchFolder2Email" -Action $action 