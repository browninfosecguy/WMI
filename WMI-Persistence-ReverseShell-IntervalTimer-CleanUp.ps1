Get-WmiObject __EventFilter -namespace root\subscription -filter "name='EvilExeFilter'" | Remove-WmiObject
Get-WmiObject CommandLineEventConsumer -Namespace root\subscription -filter "name='EvilExeConsumer'" | Remove-WmiObject
Get-WmiObject __FilterToConsumerBinding -Namespace root\subscription -Filter "Filter = ""__eventfilter.name='EvilExeFilter'""" | Remove-WmiObject
Remove-CimInstance -Query 'select * from __IntervalTimerInstruction where TimerId="MyTimerId"'