@ECHO off

set ORC_CONFIG_FOLDER=.\config
set ORC_TOOLS_FOLDER=.\tools
set ORC_OUTPUT_FOLDER=.\output

if not "%1"=="" (
	echo Configuration folder defined: %1
	set ORC_CONFIG_FOLDER=%1
)

if not defined ORC_OUTPUT goto DEFINE_ORC_OUTPUT
if "%ORC_OUTPUT%" == "" goto DEFINE_ORC_OUTPUT

goto CONFIGURE_ORC


:DEFINE_ORC_OUTPUT

set ORC_OUTPUT=DFIR-Orc.exe

goto CONFIGURE_ORC


:CONFIGURE_ORC

echo Configuring Orc (%ORC_OUTPUT_FOLDER%\%ORC_OUTPUT%) with config: %ORC_CONFIG_FOLDER%

%ORC_TOOLS_FOLDER%\DFIR-Orc_x64.exe ToolEmbed /Config=%ORC_CONFIG_FOLDER%\DFIR-ORC_embed.xml

set ORC_CONFIG_FOLDER=
set ORC_TOOLS_FOLDER=
set ORC_OUTPUT_FOLDER=
set ORC_OUTPUT=
