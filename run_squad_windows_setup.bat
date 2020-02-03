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

@echo "%path%\SteamCMD\steamcmd.exe" +login anonymous +force_install_dir "%path%\Server" +app_update 403240 validate > %path%\Server\update_squad_server.bat
@echo "start SquadGameServer.exe -log -fullcrashdump Port=%game_port% QueryPort=%query_port% FIXEDMAXPLAYERS=80 RANDOM=NONE" > %path%\Server\start_squad_server.bat

echo "Allowing the Squad Server EXE through the firewall"
%SYSTEMROOT%\System32\netsh.exe advfirewall firewall add rule name="Squad Server EXE" dir=in action=allow program="%path%\Server\SquadGameServer.exe"
%SYSTEMROOT%\System32\netsh.exe advfirewall firewall add rule name="Squad Server EXE" dir=out action=allow program="%path%\Server\SquadGameServer.exe"

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

echo Downloading SteamCMD.exe
%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\powershell.exe -command "Start-BitsTransfer -Source "https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip""
%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\powershell.exe -command "Expand-Archive steamcmd.zip %path%\SteamCMD"

SET STEAMCMD="%path%\SteamCMD\steamcmd.exe"
%STEAMCMD% +login anonymous +force_install_dir "%path%\Server" +app_update 403240 validate

echo Script is done
PAUSE
