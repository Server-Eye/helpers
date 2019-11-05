Das Script ShutdownRestartwithoutSU.ps1 auf dem System ablegen.

In den Verknüpfungen muss der Pfad zum Script angeben werden.

Das Ziel muss angepasst werden.

Der Parameter -File "" muss richtig eingetragen werden.
Shutdown.Ink
C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -noexit -ExecutionPolicy Bypass -File "Hier bitte pfad zum Script" -shutdown

Reboot.Ink:
C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -noexit -ExecutionPolicy Bypass -File "Hier bitte pfad zum Script" -reboot