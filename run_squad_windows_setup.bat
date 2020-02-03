@echo off

:: BatchGotAdmin
:-------------------------------------
REM  --> Check for permissions
    IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
>nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
) ELSE (
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params= %*
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params:"=""%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
:--------------------------------------  

set /P open_ports="Would you like to open ports needed for your game server via this script? (Y/N): "
IF %open_ports%==Y set open_ports=T
IF %open_ports%==y set open_ports=T
set use_custom_ports=F
IF %open_ports%==T set /P use_custom_ports="Would you like to use custom ports? (Y/N): "
IF %use_custom_ports%==y set use_custom_ports=T
IF %use_custom_ports%==Y set use_custom_ports=T

IF %use_custom_ports%==T (
	set /P rcon_port="What rcon port would you like to use (default is 21114): "
	set /P game_port="What game port would you like to use (default is 7787): "
	set /p query_port="What query port would you like to use (default is 21765): "
)

IF %use_custom_ports%==T (
		echo "Using custom ports, %rcon_port%=RCON, %query_port%=steam query port, %game_port%=Game Port"
		netsh advfirewall firewall add rule name="Squad Game Port" dir=in action=allow protocol=UDP localport=%game_port%
		netsh advfirewall firewall add rule name="Squad Game Port" dir=out action=allow protocol=UDP localport=%game_port%
		netsh advfirewall firewall add rule name="Steam Query Port UDP" dir=in action=allow protocol=UDP localport=%query_port%
		netsh advfirewall firewall add rule name="Steam Query Port TCP" dir=in action=allow protocol=TCP localport=%query_port%
		netsh advfirewall firewall add rule name="Steam Query Port UDP" dir=out action=allow protocol=UDP localport=%query_port%
		netsh advfirewall firewall add rule name="Steam Query Port TCP" dir=out action=allow protocol=TCP localport=%query_port%
		netsh advfirewall firewall add rule name="Squad RCON Port UDP" dir=out action=allow protocol=UDP localport=%rcon_port%
		netsh advfirewall firewall add rule name="Squad RCON Port TCP" dir=out action=allow protocol=TCP localport=%rcon_port%
		netsh advfirewall firewall add rule name="Squad RCON Port UDP" dir=in action=allow protocol=UDP localport=%rcon_port%
		netsh advfirewall firewall add rule name="Squad RCON Port TCP" dir=in action=allow protocol=TCP localport=%rcon_port%
		echo "Finished with firewall!"
)

IF %open_ports%==T (
		set rcon_port=21114
		set game_port=7787
		set query_port=27165
		echo "Using default ports, 21114=RCON, 27165=steam query port, 7787=Game Port"
		netsh advfirewall firewall add rule name="Squad Game Port" dir=in action=allow protocol=UDP localport=%game_port%
		netsh advfirewall firewall add rule name="Squad Game Port" dir=out action=allow protocol=UDP localport=%game_port%
		netsh advfirewall firewall add rule name="Steam Query Port UDP" dir=in action=allow protocol=UDP localport=%query_port%
		netsh advfirewall firewall add rule name="Steam Query Port TCP" dir=in action=allow protocol=TCP localport=%query_port%
		netsh advfirewall firewall add rule name="Steam Query Port UDP" dir=out action=allow protocol=UDP localport=%query_port%
		netsh advfirewall firewall add rule name="Steam Query Port TCP" dir=out action=allow protocol=TCP localport=%query_port%
		netsh advfirewall firewall add rule name="Squad RCON Port UDP" dir=out action=allow protocol=UDP localport=%rcon_port%
		netsh advfirewall firewall add rule name="Squad RCON Port TCP" dir=out action=allow protocol=TCP localport=%rcon_port%
		netsh advfirewall firewall add rule name="Squad RCON Port UDP" dir=in action=allow protocol=UDP localport=%rcon_port%
		netsh advfirewall firewall add rule name="Squad RCON Port TCP" dir=in action=allow protocol=TCP localport=%rcon_port%
)

set query_port=27165
set game_port=7787
set rcon_port=21114

echo "Current installation directory: %cd%"
echo "By default the script uses the location of where it's run to install server files and SteamCMD!"
set /P use_custom_install_path="Would you like to use a different installation location for your files? (Y/N): "
IF %use_custom_install_path%==Y set use_custom_install_path=T
IF %use_custom_install_path%==y set use_custom_install_path=T

IF %use_custom_install_path%==T (
	set /P path="Custom installation location: "
)  else (
	set path=%cd%
)
IF %use_custom_install_path%==T (
	echo "Creating Directories at %path%"
	md %path%\Server %path%\SteamCMD
	echo Finished Making Directories at %path%
) else (
	echo Creating Directories at %path%
	md Server SteamCMD
	echo Done Making Directories at %path%
)

echo Downloading SteamCMD.exe
%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\powershell.exe -command "Start-BitsTransfer -Source "https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip""
%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\powershell.exe -command "Expand-Archive steamcmd.zip %path%\SteamCMD"

@echo "%path%\SteamCMD\steamcmd.exe" +login anonymous +force_install_dir "%path%\Server" +app_update 403240 validate > %path%\Server\update_squad_server.bat
@echo "start SquadGameServer.exe -log -fullcrashdump Port=%game_port% QueryPort=%query_port% FIXEDMAXPLAYERS=80 RANDOM=NONE" > %path%\Server\start_squad_server.bat

(
@echo "Make sure to edit your RCON port in Rcon.cfg to your custom port: %rcon_port% if you used a custom port"
@echo "Check server.cfg to change the name of the server and other configuration options."
@echo "Check MOTD.cfg to set server rules etc. on the team selection menu."
@echo "Check MapRotation.cfg to set the map rotation, map names can be found at https://squad.gamepedia.com/Server_Configuration#Map_Rotation_in_MapRotation.cfg"
@echo "Check Admins.cfg to set admins. This config file requires Steam64 IDs which can be grabbed from: https://steamid.uk/ by pasting in a steamcommunity link."
@echo "Check ServerMessages.cfg to set messages to occasionally broadcast to all players with text. This is typically used to broadcast server rules or upcoming events."
@echo "Bans.cfg can be used to create bans (and typically will have a bajillion automatic TK kicks on licensed servers). It's recommended to only ban from in-game or using battlmetrics: http://battlemetrics.com/"
@echo "Thanks for using the spaghetti script that went through an initial iteration of Python3 for no good reason."
) > %path%\Server\README_IMPORTANT.txt


SET STEAMCMD="%path%\SteamCMD\steamcmd.exe"
%STEAMCMD% +login anonymous +force_install_dir "%path%\Server" +app_update 403240 validate

PAUSE
