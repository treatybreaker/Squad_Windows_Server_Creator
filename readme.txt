This script requires administrative rights to do its job correctly as it allows the Squad Server EXE through the firewall.
This script assumes that powershell 1.0 is installed in the following fashion (it usually is installed so it should be fine for most users): %SYSTEMROOT%\System32\WindowsPowerShell\v1.0\powershell.exe
That effectively translates to: C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe

This script does the following things:
Allows the Squad Server EXE through the firewall both inbound and outbound.
Creates server files either to the directory the script is run in or to a custom location if a user does so choose
Downloads all files necessary (SteamCMD and Squad Server files via SteamCMD)
Creates an update and start server script for users to launch in order to update the Squad server or start the server on the correct ports.

These can be changed by opening the bat file in a text editor.
