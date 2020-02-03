This script requires administrative rights to do its job correctly as it allows the Squad Server EXE through the firewall.
This script assumes that powershell 1.0 is installed in the following fashion (it usually is installed so it should be fine for most users): %SYSTEMROOT%\System32\WindowsPowerShell\v1.0\powershell.exe
That effectively translates to: C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe

This script does the following things:
Opens ports in the firewall if a user decides to do so
	It can use CUSTOM ports if a user decides they want to use them, do note, however, that it only opens 3 ports, so it doesn't open 27166/7788 by default and those are potential secondary ports.
Creates server files either to the directory the script is run in or to a custom location if a user does so choose
Downloads all files necessary (SteamCMD and Squad Server files via SteamCMD)
Creates an update and start server script for users to launch in order to update the Squad server or start the server on the correct ports.


If a user DOES not go through opening ports via the program it will automatically add the following to the start server bat: query port: 27165, game port: 7787.
These can be changed by opening the bat file in a text editor.
