@echo off
echo      ____  _____ ___ ____        ___           
echo     ^|  _ \^|  ___^|_ _^|  _ \      / _ \ _ __ ___ 
echo     ^| ^| ^| ^| ^|_   ^| ^|^| ^|_) ^|____^| ^| ^| ^| '__/ __^|
echo     ^| ^|_^| ^|  _^|  ^| ^|^|  _ ^<_____^| ^|_^| ^| ^| ^| (__ 
echo     ^|____/^|_^|   ^|___^|_^| \_\     \___/^|_^|  \___^|
echo                                                 by ANSSI feat Croko-fr
echo.

setlocal enabledelayedexpansion

set ORC_TOOLS_FOLDER=tools
set ORC_OUTPUT_FOLDER=output

:: %ORC_TOOLS_FOLDER%\DFIR-Orc_x64.exe is necessary
:: You have to compile it first https://github.com/DFIR-ORC/dfir-orc
if not exist "%~dp0%ORC_TOOLS_FOLDER%\DFIR-Orc_x64.exe" (
	echo [x] Error : Compiled binary %~dp0%ORC_TOOLS_FOLDER%\DFIR-Orc_x64.exe not found
	echo [x] Build %~dp0%ORC_TOOLS_FOLDER%\DFIR-Orc_x64.exe from https://github.com/DFIR-ORC/dfir-orc
	goto :EOF
)

:: Detecting user input for first arg : %1
if ["%~dp0%1"] neq ["%~dp0"] (

	if not exist "%~dp0%1" (
		echo [x] Error : This configuration folder doesn't exist : %~dp0%1
		goto :EOF
	)
	set ORC_CONFIG_FOLDER=%1

) else (

	for /f %%f in ('dir /b %~dp0 ^| findstr /v "\. output tools" ^| find /v "" /C') do ( set "nb_conf=%%f" )

	if [!nb_conf!] equ [0] (
		echo [x] Error : The configuration folder "config" is missing
		goto :EOF
	)

	if [!nb_conf!] gtr [1] ( 

		echo [+] Found !nb_conf! configurations
		echo.
		
		:: Si plusieurs configurations presentes on propose un choix
		set /a count=0
		for /F %%f in ('dir /b %~dp0 ^| findstr /v "\. output tools"') do (
			set /a count=!count!+1
			set "conf!count!=%%f"
			call echo [ !count! ] ---- %%conf!count!%%
		)
		
		echo.
:choix
		set "choix_conf="
		set /P choix_conf="[?] Please select configuration number : "
		if [!choix_conf!] leq [!nb_conf!] ( 
			if [!choix_conf!] geq [1] (
				call set ORC_CONFIG_FOLDER=%%conf!choix_conf!%%
				goto choixok
			)
		)
		goto choix
		
	) else (
		for /F %%f in ('dir /b %~dp0 ^| findstr /v "\. output tools"') do ( set "ORC_CONFIG_FOLDER=%%f" )
		echo [+] Found only one configuration : !ORC_CONFIG_FOLDER!
	)

)

:choixok

echo [+] Configuration folder defined: %ORC_CONFIG_FOLDER%

:: We set the configuration folder as name for our binary except for default
if "%ORC_CONFIG_FOLDER%" equ "config" (
	set ORC_OUTPUT=DFIR-Orc.exe
) else (
	set ORC_OUTPUT=%ORC_CONFIG_FOLDER%.exe
)

echo [+] Binary name defined: %ORC_OUTPUT%
echo [+] Crafting binary: %ORC_OUTPUT_FOLDER%\%ORC_OUTPUT% with config: %ORC_CONFIG_FOLDER%

:: Launching Embeding command without output
%~dp0%ORC_TOOLS_FOLDER%\DFIR-Orc_x64.exe ToolEmbed /Config="%~dp0%ORC_CONFIG_FOLDER%\DFIR-ORC_embed.xml" >NUL

:: If an error is returned we launch the debug command
if %ERRORLEVEL% neq 0 (
	echo [x] Error : Compilation command returned error %ERRORLEVEL%
	echo [+] Launching debug command
	%~dp0%ORC_TOOLS_FOLDER%\DFIR-Orc_x64.exe ToolEmbed /Config="%~dp0%ORC_CONFIG_FOLDER%\DFIR-ORC_embed.xml" /Error >NUL
) else (
	:: No error was returned, we check for the binary in destination path
	if exist "%~dp0%ORC_OUTPUT_FOLDER%\%ORC_OUTPUT%" (
		echo [+] Binary crafted succesfully: %~dp0%ORC_OUTPUT_FOLDER%\%ORC_OUTPUT%
	) else (
		echo [x] Binary not found: %~dp0%ORC_OUTPUT_FOLDER%\%ORC_OUTPUT%
	)
)

:: Cleaning our vars
set ORC_CONFIG_FOLDER=
set ORC_TOOLS_FOLDER=
set ORC_OUTPUT_FOLDER=
set ORC_OUTPUT=
