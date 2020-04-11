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


@setlocal EnableDelayedExpansion
:custom_steam_yn
set /P use_custom_steamcmd=Would you like to use a previous installation of SteamCMD instead of installing it again? (Y/N): 
IF !use_custom_steamcmd! == Y set use_custom_steamcmd=T
IF !use_custom_steamcmd! == y set use_custom_steamcmd=T
IF !use_custom_steamcmd! == N set use_custom_steamcmd=F
IF !use_custom_steamcmd! == n set use_custom_steamcmd=F
IF !use_custom_steamcmd! == T (
	echo HERE
	:custom_steam_location
	set /P custom_steamcmd=What is the directory where your SteamCMD.exe is?
	echo !custom_steamcmd!
	IF NOT EXIST !custom_steamcmd!\steamcmd.exe (
		echo steamcmd.exe does not exist in that directory, please try again!
		goto custom_steam_location
	)
) else (
	IF !use_custom_steamcmd! == F  (
		set use_custom_steamcmd=F
		set custom_steamcmd=!cd!\SteamCMD
	) else (
		echo !use_custom_steamcmd! is not valid! Use either Y or N.
		goto custom_steam_yn
	)
)

:custom_install_location_yn
echo Current server installation directory: !cd!
set /P use_custom_install_path=Would you like to use a different installation location for your server? (Y/N): 
IF !use_custom_install_path!==Y set use_custom_install_path=T
IF !use_custom_install_path!==y set use_custom_install_path=T
IF !use_custom_install_path!==N set use_custom_install_path=F
IF !use_custom_install_path!==n set use_custom_install_path=F
IF !use_custom_install_path!==T (
	:custom_install_location
	set /P server_path="Custom installation location: "
	IF NOT EXIST !server_path! (
		echo That install path is not valid, try again!
		goto custom_install_location
	)
	echo !server_path!
) else (
	IF !use_custom_install_path!==F (
		set server_path=!cd!
	)
	IF NOT !use_custom_install_path! == F (
		echo !use_custom_install_path! is not valid! Use either Y or N.
		goto custom_install_location_yn
	)
)
echo Creating Directories at !server_path!

set folder_number=0
:create_server_folder
set folder_name=Server
set folder_location=!server_path!\!folder_name!
echo !folder_location!
IF NOT EXIST !folder_location! (
	md !server_path!\!folder_name!
	echo Created folder: !folder_name! at !server_path!
) else (
	set /A folder_number=!folder_number! + 1
	set folder_new_name=!folder_name!!folder_number!

	set folder_new_location=!server_path!\!folder_new_name!
	IF NOT EXIST !folder_new_location! (
		set folder_name=!folder_new_name!
		md !server_path!\!folder_new_name!
		echo Created folder: !folder_name! at !folder_new_location!
	) else (
		goto create_server_folder
	)
)


echo Finished Making Directories at !server_path!
echo "!custom_steamcmd!\SteamCMD\steamcmd.exe" +login anonymous +force_install_dir "!server_path!\!folder_name!" +app_update 403240 validate > !server_path!\!folder_name!\update_squad_server.bat
echo start SquadGameServer.exe -log -fullcrashdump Port= QueryPort= FIXEDMAXPLAYERS=80 RANDOM=NONE > !server_path!\!folder_name!\start_squad_server.bat

:firewall_rules
set /P create_firewall_rules="Would you like the script to allow the SquadGame.exe through the firewall? (Y/N): "
IF !create_firewall_rules! == Y set create_firewall_rules=T
IF !create_firewall_rules! == y set create_firewall_rules=T
IF !create_firewall_rules! == N set create_firewall_rules=F
IF !create_firewall_rules! == n set create_firewall_rules=F
IF !create_firewall_rules! == T (
	echo Allowing the Squad Server EXE through the firewall
	!SYSTEMROOT!\System32\netsh.exe advfirewall firewall add rule name="Squad Server EXE" dir=in action=allow program="!server_path!\!folder_name!\SquadGameServer.exe"
	!SYSTEMROOT!\System32\netsh.exe advfirewall firewall add rule name="Squad Server EXE" dir=out action=allow program="!server_path!\!folder_name!\SquadGameServer.exe"
	!SYSTEMROOT!\System32\netsh.exe advfirewall firewall add rule name="Squad Server EXE" dir=out action=allow program="!server_path!\!folder_name!\SquadGame\Binaries\Win64\SquadGameServer.exe"
	!SYSTEMROOT!\System32\netsh.exe advfirewall firewall add rule name="Squad Server EXE" dir=in action=allow program="!server_path!\!folder_name!\SquadGame\Binaries\Win64\SquadGameServer.exe"
) else (
	IF NOT !create_firewall_rules! == F goto firewall_rules
)

IF !use_custom_steamcmd! == F (
	echo Downloading SteamCMD.exe
	!SYSTEMROOT!\System32\WindowsPowerShell\v1.0\powershell.exe -command "Start-BitsTransfer -Source "https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip""
	!SYSTEMROOT!\System32\WindowsPowerShell\v1.0\powershell.exe -command "Expand-Archive steamcmd.zip !custom_SteamCMD!
)

(
@echo Make sure to edit your RCON port in Rcon.cfg to your custom port: !rcon_port! if you used a custom port
@echo Check server.cfg to change the name of the server and other configuration options.
@echo Check MOTD.cfg to set server rules etc. on the team selection menu.
@echo Check MapRotation.cfg to set the map rotation, map names can be found at https://squad.gamepedia.com/Server_Configuration#Map_Rotation_in_MapRotation.cfg
@echo Check Admins.cfg to set admins. This config folder requires Steam64 IDs which can be grabbed from: https://steamid.uk/ by pasting in a steamcommunity link.
@echo Check ServerMessages.cfg to set messages to occasionally broadcast to all players with text. This is typically used to broadcast server rules or upcoming events.
@echo Bans.cfg can be used to create bans ^(and typically will have a bajillion automatic TK kicks on licensed servers^). Most servers use battlemetrics: http://battlemetrics.com/ to manage their servers.
@echo Thanks for using the spaghetti script
) > !server_path!\Server\README.txt

echo !server_path!\!folder_name!
echo !custom_steamcmd!\steamcmd.exe
SET STEAMCMD=!custom_steamcmd!\steamcmd.exe
!STEAMCMD! +login anonymous +force_install_dir "!server_path!\!folder_name!" +app_update 403240 validate +quit
echo.
echo.
echo Ensure you open the start_squad_server.bat and set your game port (usually 7787) and your query port (usually 27165) as well as setting your RCON configuration in Rcon.cfg!
echo Important info is included in the readme, highly recommended you read it if you are new to Squad Server hosting.
echo Script is done
PAUSE
