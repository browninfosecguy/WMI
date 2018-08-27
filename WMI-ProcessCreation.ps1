<#
Dont forget to unregister the event
Unregister-Event -SourceIdentifier "Im"
#>
$test = 'SELECT * FROM __InstanceCreationEvent WITHIN 10 WHERE TargetInstance ISA "win32_process" AND TargetInstance.name like "%chrome%" '
$action = {Write-host hello}
Register-WmiEvent -Query $test -SourceIdentifier "Im" -Action $action

